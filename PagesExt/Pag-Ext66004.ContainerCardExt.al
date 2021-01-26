pageextension 66004 ContainerCardExt extends "Container Card"
{
    actions
    {
        addafter("View Stock Intransit Entries")
        {
            action("Container Item Charges")
            {
                Image = CreateFinanceChargememo;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = all;
                trigger OnAction()
                var
                    ContItemChargeRec: record "Container Item Charge";
                    ContItemChargePag: page "Container Item Charges";
                begin
                    ContItemChargeRec.Reset();
                    ContItemChargeRec.setrange("Container No.", Rec."No.");
                    if ContItemChargeRec.FindSet(false, false) then begin
                        Clear(ContItemChargePag);
                        ContItemChargePag.SetTableView(ContItemChargeRec);
                        ContItemChargePag.RunModal();
                    end;
                end;
            }
        }
    }
}
