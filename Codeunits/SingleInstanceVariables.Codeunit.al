codeunit 66001 "Single Instance Variables"
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        TempItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)" temporary;
        TempPurchRcptLine: Record "Purch. Rcpt. Line" temporary;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure OnBeforePurchPostDoc(var Sender: Codeunit "Purch.-Post"; var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; CommitIsSupressed: Boolean)
    begin
        //Clear all Global variables at start of posting a purchase document
        TempItemChargeAssgntPurch.DeleteAll;
        TempPurchRcptLine.DeleteAll;
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnAfterPostPurchLine', '', false, false)]
    local procedure OnAfterPostPurchLine(PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; CommitIsSupressed: Boolean)
    var
        ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
    begin
        //Store Item Charge assignments for use in reversal call
        ItemChargeAssgntPurch.Reset;
        ItemChargeAssgntPurch.SetRange("Document Type", PurchaseLine."Document Type");
        ItemChargeAssgntPurch.SetRange("Document No.", PurchaseLine."Document No.");
        ItemChargeAssgntPurch.SetRange("Document Line No.", PurchaseLine."Line No.");
        ItemChargeAssgntPurch.SetFilter("Qty. to Assign", '<>0');
        if ItemChargeAssgntPurch.FindSet then
            repeat
                TempItemChargeAssgntPurch := ItemChargeAssgntPurch;
                TempItemChargeAssgntPurch.Insert;
            until ItemChargeAssgntPurch.Next = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnAfterPurchRcptLineInsert', '', false, false)]
    local procedure OnAfterPurchRcptLineInsert(PurchaseLine: Record "Purchase Line"; PurchRcptLine: Record "Purch. Rcpt. Line"; ItemLedgShptEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSupressed: Boolean)
    begin
        TempPurchRcptLine := PurchRcptLine;
        TempPurchRcptLine.Insert;
    end;

    procedure LoadItemChargAssgntPurch(var pItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)" temporary)
    begin
        Clear(pItemChargeAssignmentPurch);
        if TempItemChargeAssgntPurch.FindSet then
            repeat
                pItemChargeAssignmentPurch := TempItemChargeAssgntPurch;
                pItemChargeAssignmentPurch.Insert;
            until TempItemChargeAssgntPurch.Next = 0;
    end;

    procedure LoadPurchRcptLine(var pPurchRcptLine: Record "Purch. Rcpt. Line" temporary)
    begin
        pPurchRcptLine := TempPurchRcptLine;
    end;
}

