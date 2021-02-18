codeunit 66000 "Landed Cost Mgt."
{
    SingleInstance = false;
    Permissions = TableData "Purch. Rcpt. Header" = rimd,
                  TableData "Purch. Rcpt. Line" = rimd,
                  TableData "Purch. Inv. Header" = rimd,
                  TableData "Purch. Inv. Line" = rimd,
                  TableData "Purch. Cr. Memo Hdr." = rimd,
                  TableData "Purch. Cr. Memo Line" = rimd;

    trigger OnRun()
    begin
    end;

    var
        PurchaseHdr: Record "Purchase Header";
        SalesHdr: Record "Sales Header";
        RechargeGenJnlLineNo: Integer;
        TempRechargeGnlJnl: Record "Gen. Journal Line" temporary;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        QX001: Label 'No Sales Recharge entries exist for this Shipment No. %1 to be reversed.';
        GlobalItemJnlLine: Record "Item Journal Line" temporary;
        QX002: Label 'Please assign %1 to the Item Charge before attempting to set up the landed cost matrix.';
        TempPurchLine: Record "Purchase Line" temporary;
        SingleInstanceVar: Codeunit "Single Instance Variables";
        SystemSetup: Record "System Setup";
        QX003: Label 'Please confirm all associated landed cost accruals posted by this Receipt require a reversal?';

    procedure CalcLCelements(var PurchLine: Record "Purchase Line"): Boolean
    var
        LandedCostLines: Record "Landed Cost Lines";
        ItemCharge: Record "Item Charge";
        Item: Record Item;
        LandedCostMatrix: Record "Landed Cost Matrix";
        LandedCostAdded: Boolean;
    begin
        if (PurchLine.Type <> PurchLine.Type::Item) or (PurchLine."Zero Landed Cost") then
            exit;

        if not (PurchLine."Document Type" in [PurchLine."Document Type"::Order, PurchLine."Document Type"::"Return Order"]) then
            exit;

        LandedCostAdded := false;
        GetPurchHeader(PurchLine);
        DeleteLandedCostLines(PurchLine);

        ItemCharge.Reset;
        ItemCharge.SetCurrentKey("Matrix Line Type", "Landed Cost Calc. Type", "No.");
        ItemCharge.SetFilter("Landed Cost Calc. Type", '<>%1', ItemCharge."Landed Cost Calc. Type"::" ");
        ItemCharge.SetRange("Matrix Line Type", ItemCharge."Matrix Line Type"::Purchase);
        if not ItemCharge.FindSet(false, false) then
            exit;
        with ItemCharge do begin
            repeat
                if FindCostMatrix(LandedCostMatrix, PurchLine, ItemCharge) then begin
                    UpdateLandedCostLine(LandedCostMatrix, PurchLine, ItemCharge);
                    LandedCostAdded := true;
                end;
            until Next = 0;
        end;
        exit(LandedCostAdded);
    end;

    local procedure FindCostMatrix(var MatchedCostMatrix: Record "Landed Cost Matrix"; pPurchLine: Record "Purchase Line"; pItemCharge: Record "Item Charge"): Boolean
    var
        CheckLandedCostMatrix: Record "Landed Cost Matrix";
        ItemRec: Record Item;
    begin
        MatchedCostMatrix.Reset;
        MatchedCostMatrix.SetRange("Landed Cost Calc. Type", pItemCharge."Landed Cost Calc. Type");
        MatchedCostMatrix.SetRange("Matrix Line Type", pItemCharge."Matrix Line Type");
        if not MatchedCostMatrix.FindSet(false, false) then
            exit(false);

        CheckLandedCostMatrix.Reset;
        CheckLandedCostMatrix.SetRange("Landed Cost Calc. Type", pItemCharge."Landed Cost Calc. Type");
        CheckLandedCostMatrix.SetRange("Matrix Line Type", pItemCharge."Matrix Line Type");

        ItemRec.Get(pPurchLine."No.");
        if ItemRec.Type <> ItemRec.Type::Inventory then
            exit(false);

        if ItemRec."Tariff No." <> '' then begin
            CheckLandedCostMatrix.SetRange("Tariff/Commodity Code", ItemRec."Tariff No.");
            if CheckLandedCostMatrix.IsEmpty then
                MatchedCostMatrix.SetFilter("Tariff/Commodity Code", '%1', '')
            else
                MatchedCostMatrix.SetRange("Tariff/Commodity Code", ItemRec."Tariff No.");
        end else
            MatchedCostMatrix.SetFilter("Tariff/Commodity Code", '%1', '');
        CheckLandedCostMatrix.SetRange("Tariff/Commodity Code");

        if ItemRec."Item Category Code" <> '' then begin
            CheckLandedCostMatrix.SetRange("Item Category Code", ItemRec."Item Category Code");
            if CheckLandedCostMatrix.IsEmpty then
                MatchedCostMatrix.SetFilter("Item Category Code", '%1', '')
            else
                MatchedCostMatrix.SetRange("Item Category Code", ItemRec."Item Category Code");
        end else
            MatchedCostMatrix.SetFilter("Item Category Code", '%1', '');
        CheckLandedCostMatrix.SetRange("Item Category Code");

        CheckLandedCostMatrix.SetRange("Item No.", pPurchLine."No.");
        if CheckLandedCostMatrix.IsEmpty then
            MatchedCostMatrix.SetFilter("Item No.", '%1', '')
        else
            MatchedCostMatrix.SetRange("Item No.", pPurchLine."No.");
        if MatchedCostMatrix.IsEmpty then
            MatchedCostMatrix.SetFilter("Item No.", '%1', '');
        CheckLandedCostMatrix.SetRange("Item No.");

        CheckLandedCostMatrix.SetRange("Vendor No.", pPurchLine."Buy-from Vendor No.");
        if CheckLandedCostMatrix.IsEmpty then
            MatchedCostMatrix.SetFilter("Vendor No.", '%1', '')
        else
            MatchedCostMatrix.SetRange("Vendor No.", pPurchLine."Buy-from Vendor No.");
        if MatchedCostMatrix.IsEmpty then
            MatchedCostMatrix.SetFilter("Vendor No.", '%1', '');
        CheckLandedCostMatrix.SetRange("Vendor No.");

        CheckLandedCostMatrix.SetRange("Source Country", PurchaseHdr."Buy-from Country/Region Code");
        if CheckLandedCostMatrix.IsEmpty then
            MatchedCostMatrix.SetFilter("Source Country", '%1', '')
        else
            MatchedCostMatrix.SetRange("Source Country", PurchaseHdr."Buy-from Country/Region Code");
        if MatchedCostMatrix.IsEmpty then
            MatchedCostMatrix.SetFilter("Source Country", '%1', '');
        CheckLandedCostMatrix.SetRange("Source Country");

        CheckLandedCostMatrix.SetRange("Destination Location", pPurchLine."Location Code");
        if CheckLandedCostMatrix.IsEmpty then
            MatchedCostMatrix.SetFilter("Destination Location", '%1', '')
        else
            MatchedCostMatrix.SetRange("Destination Location", pPurchLine."Location Code");
        if MatchedCostMatrix.IsEmpty then
            MatchedCostMatrix.SetFilter("Destination Location", '%1', '');
        CheckLandedCostMatrix.SetRange("Destination Location");

        CheckLandedCostMatrix.SetRange("Transport Method", pPurchLine."Transport Method");
        if CheckLandedCostMatrix.IsEmpty then
            MatchedCostMatrix.SetFilter("Transport Method", '%1', '')
        else
            MatchedCostMatrix.SetRange("Transport Method", pPurchLine."Transport Method");
        if MatchedCostMatrix.IsEmpty then
            MatchedCostMatrix.SetFilter("Transport Method", '%1', '');
        CheckLandedCostMatrix.SetRange("Transport Method");

        CheckLandedCostMatrix.SetRange("Global Dimension 2 Code", pPurchLine."Shortcut Dimension 2 Code");
        if CheckLandedCostMatrix.IsEmpty then
            MatchedCostMatrix.SetFilter("Global Dimension 2 Code", '%1', '')
        else
            MatchedCostMatrix.SetRange("Global Dimension 2 Code", pPurchLine."Shortcut Dimension 2 Code");
        if MatchedCostMatrix.IsEmpty then
            MatchedCostMatrix.SetFilter("Global Dimension 2 Code", '%1', '');
        CheckLandedCostMatrix.SetRange("Global Dimension 2 Code");

        If MatchedCostMatrix.Findlast() then
            Exit(true)
        else
            Exit(false);
    end;

    local procedure UpdateLandedCostLine(CostMatrix: Record "Landed Cost Matrix"; pPurchLine: Record "Purchase Line"; pItemCharge: Record "Item Charge")
    var
        UpdLandedCostLine: Record "Landed Cost Lines";
        FreightCostLine: Record "Landed Cost Lines";
        AdjPurchLineAmountLCY: Decimal;
    begin
        AdjPurchLineAmountLCY := 0;

        if (CostMatrix."Landed Cost Calc. Type" = CostMatrix."Landed Cost Calc. Type"::Duty) and
              (CostMatrix."Value Type" = CostMatrix."Value Type"::Percentage) then begin

            //Find Freight Costs already calculated & add to line amount to make duty value calc more accurate
            FreightCostLine.Reset;
            FreightCostLine.SetRange("Document Type", pPurchLine."Document Type");
            FreightCostLine.SetRange("Document No.", pPurchLine."Document No.");
            FreightCostLine.SetRange("Document Line No.", pPurchLine."Line No.");
            FreightCostLine.SetRange("Landed Cost Calc. Type", FreightCostLine."Landed Cost Calc. Type"::Freight);
            if FreightCostLine.FindSet(False, False) then
                repeat
                    AdjPurchLineAmountLCY := AdjPurchLineAmountLCY + FreightCostLine."Amount (LCY)";
                until FreightCostLine.Next = 0;
        end;

        UpdLandedCostLine.Init;
        UpdLandedCostLine.Validate("Document Type", pPurchLine."Document Type");
        UpdLandedCostLine.Validate("Document No.", pPurchLine."Document No.");
        UpdLandedCostLine."Document Line No." := pPurchLine."Line No.";
        UpdLandedCostLine."Matrix Line No." := pPurchLine."Matrix Line No.";
        UpdLandedCostLine."Cost Matrix No. Applied" := CostMatrix."Entry No.";
        UpdLandedCostLine.Validate("Item Charge No.", pItemCharge."No.");
        UpdLandedCostLine.Validate("Landed Cost Calc. Type", pItemCharge."Landed Cost Calc. Type");
        UpdLandedCostLine."Matrix Line Type" := pItemCharge."Matrix Line Type";
        UpdLandedCostLine.Validate("Item No.", pPurchLine."No.");
        UpdLandedCostLine.Validate("Variant Code", pPurchLine."Variant Code");
        UpdLandedCostLine.Description := pItemCharge.Description;
        UpdLandedCostLine.Validate("Value Type", CostMatrix."Value Type");
        if pPurchLine."Currency Code" = CostMatrix."Currency Code" then
            UpdLandedCostLine.Validate(Value, CostMatrix.Value)
        else
            UpdLandedCostLine.Validate(Value, ConvertCurrency(pPurchLine."Currency Code", CostMatrix.Value, PurchaseHdr."Currency Factor", PurchaseHdr."Document Date"));
        UpdLandedCostLine.Validate("Currency Code", pPurchLine."Currency Code");
        UpdLandedCostLine.Validate("Currency Factor", PurchaseHdr."Currency Factor");
        if UpdLandedCostLine."Currency Code" = '' then
            UpdLandedCostLine.Validate("Currency Factor", 1);
        if CostMatrix."Value Type" = CostMatrix."Value Type"::Amount then begin
            //Amount per qty on line
            UpdLandedCostLine."Unit Cost (LCY)" := CostMatrix.Value;
            UpdLandedCostLine."Amount (LCY)" := Round(pPurchLine.Quantity * CostMatrix.Value);
            UpdLandedCostLine."Unit Cost" := ConvertCurrency(UpdLandedCostLine."Currency Code", UpdLandedCostLine."Unit Cost (LCY)", UpdLandedCostLine."Currency Factor", PurchaseHdr."Document Date");
        end;
        if CostMatrix."Value Type" = CostMatrix."Value Type"::Percentage then begin
            //% Value of line
            if pPurchLine.Quantity <> 0 then begin
                UpdLandedCostLine."Amount (LCY)" := ((pPurchLine.Amount / UpdLandedCostLine."Currency Factor") + AdjPurchLineAmountLCY) * (CostMatrix.Value / 100);
                UpdLandedCostLine.Validate("Amount (LCY)", Round(UpdLandedCostLine."Amount (LCY)"));
                UpdLandedCostLine.Validate("Unit Cost (LCY)", UpdLandedCostLine."Amount (LCY)" / pPurchLine.Quantity);
            end else begin
                UpdLandedCostLine.Validate("Amount (LCY)", 0);
                UpdLandedCostLine.Validate("Unit Cost (LCY)", 0);
            end;
        end;
        //Alexnir.SN
        if CostMatrix."Value Type" = CostMatrix."Value Type"::"Fixed Amount" then begin
            if pPurchLine.Quantity <> 0 then begin
                UpdLandedCostLine."Unit Cost (LCY)" := CostMatrix.Value;
                UpdLandedCostLine."Amount (LCY)" := Round(CostMatrix.Value / pPurchLine.Quantity);
                UpdLandedCostLine."Unit Cost" := ConvertCurrency(UpdLandedCostLine."Currency Code", UpdLandedCostLine."Unit Cost (LCY)", UpdLandedCostLine."Currency Factor", PurchaseHdr."Document Date");
            end else begin
                UpdLandedCostLine.Validate("Amount (LCY)", 0);
                UpdLandedCostLine.Validate("Unit Cost (LCY)", 0);
            end;
        end;
        //Alexnir.EN
        UpdLandedCostLine.Insert(true);

    end;

    local procedure UpdateLCFields(var PurchLine: Record "Purchase Line"; XrecPurchLine: Record "Purchase Line")
    var
        GLSetup: Record "General Ledger Setup";
        PurchHeader: Record "Purchase Header";
        CurrExchRate: Record "Currency Exchange Rate";
        Currency2: Record Currency;
    begin
        with PurchLine do begin
            if CalcLCelements(PurchLine) then
                PurchLine."Post Landed Cost Accrual" := true
            else
                PurchLine."Post Landed Cost Accrual" := false;

            PurchHeader.Get("Document Type", "Document No.");
            Currency2.InitRoundingPrecision;
            if "VAT Calculation Type" = "VAT Calculation Type"::"Full VAT" then
                "Unit Cost Excl. LC" := 0
            else
                if PurchHeader."Prices Including VAT" then
                    "Unit Cost Excl. LC" :=
                      ("Direct Unit Cost" / (1 + "VAT %" / 100)) - "VAT Difference"
                else
                    "Unit Cost Excl. LC" := "Direct Unit Cost";

            if PurchHeader."Currency Code" <> '' then begin
                PurchHeader.TestField("Currency Factor");
                "Unit Cost Excl. LC (LCY)" :=
                  CurrExchRate.ExchangeAmtFCYToLCY(
                    GetDate, "Currency Code",
                    "Unit Cost Excl. LC", PurchHeader."Currency Factor");
            end else
                "Unit Cost Excl. LC (LCY)" := "Unit Cost Excl. LC";

            "Unit Cost Excl. LC (LCY)" := Round("Unit Cost Excl. LC (LCY)", GLSetup."Unit-Amount Rounding Precision");

            if PurchHeader."Currency Code" <> '' then
                "Line Amount Excl. VAT (LCY)" :=
                  Round(
                    CurrExchRate.ExchangeAmtFCYToLCY(
                      GetDate, "Currency Code",
                      "Line Amount", PurchHeader."Currency Factor"),
                    Currency2."Amount Rounding Precision")
            else
                "Line Amount Excl. VAT (LCY)" :=
                  Round("Line Amount", Currency2."Amount Rounding Precision");

            CalcFields("Det. Landed Cost (LCY)");
            //bug fix. During the deletion of a line
            //std system empties the Quantity field prior to the code below and that causes an division by zero error
            //if ("Outstanding Quantity" <> 0) and (Quantity <> 0) then
            if ("Outstanding Quantity" <> 0) then
                "Landed Cost (LCY)" := Round(("Outstanding Quantity" / Quantity) * "Det. Landed Cost (LCY)", Currency2."Amount Rounding Precision")
            else
                "Landed Cost (LCY)" := 0;
            "Outstanding Amt. LC (LCY)" := "Outstanding Amt. Ex. VAT (LCY)" + "Landed Cost (LCY)";

            "Line Amount Excl. VAT LC (LCY)" := "Line Amount Excl. VAT (LCY)" + "Landed Cost (LCY)";

            if (XrecPurchLine."Outstanding Amt. Ex. VAT (LCY)" = 0) and ("Outstanding Amt. Ex. VAT (LCY)" <> 0) then begin
                "Previous Line Value (LCY)" := "Outstanding Amt. Ex. VAT (LCY)";
                "Previous Unit Cost" := "Direct Unit Cost";
                "Previous Unit Cost (LCY)" := "Unit Cost Excl. LC (LCY)";
            end else
                if (XrecPurchLine."Outstanding Amt. Ex. VAT (LCY)" <> "Outstanding Amt. Ex. VAT (LCY)") then begin
                    "Previous Line Value (LCY)" := XrecPurchLine."Outstanding Amt. Ex. VAT (LCY)";
                    "Previous Unit Cost" := XrecPurchLine."Direct Unit Cost";
                    "Previous Unit Cost (LCY)" := XrecPurchLine."Unit Cost Excl. LC (LCY)";
                    "Last Price Update" := Today;
                end;
            "Line Difference (LCY)" := "Outstanding Amt. Ex. VAT (LCY)" - "Previous Line Value (LCY)";
            "Line Amount Excl. VAT LC (LCY)" := "Line Amount Excl. VAT (LCY)" + "Landed Cost (LCY)";
        end;
    end;

    local procedure GetPurchHeader(LocPurchLine: Record "Purchase Line")
    begin
        if (PurchaseHdr."Document Type" <> LocPurchLine."Document Type") and (PurchaseHdr."No." <> LocPurchLine."Document No.") then
            PurchaseHdr.Get(LocPurchLine."Document Type", LocPurchLine."Document No.");
    end;


    procedure DeleteLandedCostLines(pPurchLine: Record "Purchase Line")
    var
        CostLinestoDelete: Record "Landed Cost Lines";
    begin
        CostLinestoDelete.Reset; //was CostLinestoDelete.Init //Alexnir.R 30/12/2020
        CostLinestoDelete.SetRange("Document Type", pPurchLine."Document Type");
        CostLinestoDelete.SetRange("Document No.", pPurchLine."Document No.");
        CostLinestoDelete.SetRange("Document Line No.", pPurchLine."Line No.");
        CostLinestoDelete.SetRange("Matrix Line Type", CostLinestoDelete."Matrix Line Type"::Purchase);
        if CostLinestoDelete.FindSet(true, true) then
            CostLinestoDelete.DeleteAll;
    end;


    procedure CalcRechargeElements(var SalesLine: Record "Sales Line")
    var
        LandedCostLines: Record "Landed Cost Lines";
        ItemCharge: Record "Item Charge";
        Item: Record Item;
        LandedCostMatrix: Record "Landed Cost Matrix";
    begin
        //Doc LC1.0 MF 04.03.18 - Introduce new sales type landed cost recharge mechanism

        if (SalesLine.Type <> SalesLine.Type::Item) or (SalesLine."Zero Landed Cost") then
            exit;

        if not (SalesLine."Document Type" in [SalesLine."Document Type"::Order, SalesLine."Document Type"::"Return Order"]) then
            exit;

        GetSalesHeader(SalesLine);
        DeleteRechargeCostLines(SalesLine);

        ItemCharge.Reset;
        ItemCharge.SetFilter("Landed Cost Calc. Type", '<>%1', ItemCharge."Landed Cost Calc. Type"::" ");
        ItemCharge.SetRange("Matrix Line Type", ItemCharge."Matrix Line Type"::Purchase);

        if not ItemCharge.FindSet then
            exit;
        with ItemCharge do begin
            repeat
                if FindRechargeMatrix(LandedCostMatrix, SalesLine, ItemCharge) then begin
                    UpdateRechargeCostLine(LandedCostMatrix, SalesLine, ItemCharge);
                end;
            until Next = 0;
        end;
    end;

    local procedure FindRechargeMatrix(var MatchedCostMatrix: Record "Landed Cost Matrix"; pSalesLine: Record "Sales Line"; pItemCharge: Record "Item Charge"): Boolean
    var
        CheckLandedCostMatrix: Record "Landed Cost Matrix";
        ItemRec: Record Item;
    begin
        //Doc LC1.0 MF 04.03.18 - Introduce new sales type landed cost recharge mechanism       
        MatchedCostMatrix.Reset;
        MatchedCostMatrix.SetRange("Landed Cost Calc. Type", pItemCharge."Landed Cost Calc. Type");
        MatchedCostMatrix.SetRange("Matrix Line Type", pItemCharge."Matrix Line Type");

        CheckLandedCostMatrix.Reset;
        CheckLandedCostMatrix.SetRange("Landed Cost Calc. Type", pItemCharge."Landed Cost Calc. Type");
        CheckLandedCostMatrix.SetRange("Matrix Line Type", pItemCharge."Matrix Line Type");

        ItemRec.Get(pSalesLine."No.");

        if MatchedCostMatrix.FindSet(false, false) then begin

            if ItemRec."Tariff No." <> '' then begin
                CheckLandedCostMatrix.SetRange("Tariff/Commodity Code", ItemRec."Tariff No.");
                if CheckLandedCostMatrix.IsEmpty then
                    MatchedCostMatrix.SetFilter("Tariff/Commodity Code", '%1', '')
                else
                    MatchedCostMatrix.SetRange("Tariff/Commodity Code", ItemRec."Tariff No.");
            end else
                MatchedCostMatrix.SetFilter("Tariff/Commodity Code", '%1', '');
            CheckLandedCostMatrix.SetRange("Tariff/Commodity Code");

            if ItemRec."Item Category Code" <> '' then begin
                CheckLandedCostMatrix.SetRange("Item Category Code", ItemRec."Item Category Code");
                if CheckLandedCostMatrix.IsEmpty then
                    MatchedCostMatrix.SetFilter("Item Category Code", '%1', '')
                else
                    MatchedCostMatrix.SetRange("Item Category Code", ItemRec."Item Category Code");
            end else
                MatchedCostMatrix.SetFilter("Item Category Code", '%1', '');
            CheckLandedCostMatrix.SetRange("Item Category Code");

            CheckLandedCostMatrix.SetRange("Item No.", pSalesLine."No.");
            if CheckLandedCostMatrix.IsEmpty then
                MatchedCostMatrix.SetFilter("Item No.", '%1', '')
            else
                MatchedCostMatrix.SetRange("Item No.", pSalesLine."No.");
            if MatchedCostMatrix.IsEmpty then
                MatchedCostMatrix.SetFilter("Item No.", '%1', '');
            CheckLandedCostMatrix.SetRange("Item No.");

            CheckLandedCostMatrix.SetRange("Customer No.", pSalesLine."Sell-to Customer No.");
            if CheckLandedCostMatrix.IsEmpty then
                MatchedCostMatrix.SetFilter("Customer No.", '%1', '')
            else
                MatchedCostMatrix.SetRange("Customer No.", pSalesLine."Sell-to Customer No.");
            if MatchedCostMatrix.IsEmpty then
                MatchedCostMatrix.SetFilter("Customer No.", '%1', '');
            CheckLandedCostMatrix.SetRange("Customer No.");

            CheckLandedCostMatrix.SetRange("Source Country", SalesHdr."Ship-to County");
            if CheckLandedCostMatrix.IsEmpty then
                MatchedCostMatrix.SetFilter("Source Country", '%1', '')
            else
                MatchedCostMatrix.SetRange("Source Country", SalesHdr."Ship-to County");
            if MatchedCostMatrix.IsEmpty then
                MatchedCostMatrix.SetFilter("Source Country", '%1', '');
            CheckLandedCostMatrix.SetRange("Source Country");

            CheckLandedCostMatrix.SetRange("Destination Location", pSalesLine."Location Code");
            if CheckLandedCostMatrix.IsEmpty then
                MatchedCostMatrix.SetFilter("Destination Location", '%1', '')
            else
                MatchedCostMatrix.SetRange("Destination Location", pSalesLine."Location Code");
            if MatchedCostMatrix.IsEmpty then
                MatchedCostMatrix.SetFilter("Destination Location", '%1', '');
            CheckLandedCostMatrix.SetRange("Destination Location");

            CheckLandedCostMatrix.SetRange("Transport Method", pSalesLine."Transport Method");
            if CheckLandedCostMatrix.IsEmpty then
                MatchedCostMatrix.SetFilter("Transport Method", '%1', '')
            else
                MatchedCostMatrix.SetRange("Transport Method", pSalesLine."Transport Method");
            if MatchedCostMatrix.IsEmpty then
                MatchedCostMatrix.SetFilter("Transport Method", '%1', '');
            CheckLandedCostMatrix.SetRange("Transport Method");

            CheckLandedCostMatrix.SetRange("Global Dimension 2 Code", pSalesLine."Shortcut Dimension 2 Code");
            if CheckLandedCostMatrix.IsEmpty then
                MatchedCostMatrix.SetFilter("Global Dimension 2 Code", '%1', '')
            else
                MatchedCostMatrix.SetRange("Global Dimension 2 Code", pSalesLine."Shortcut Dimension 2 Code");
            if MatchedCostMatrix.IsEmpty then
                MatchedCostMatrix.SetFilter("Global Dimension 2 Code", '%1', '');
            CheckLandedCostMatrix.SetRange("Global Dimension 2 Code");

            if MatchedCostMatrix.FindLast then
                exit(true)
            else
                exit(false);
        end else
            exit(false);
    end;

    local procedure UpdateRechargeCostLine(CostMatrix: Record "Landed Cost Matrix"; pSalesLine: Record "Sales Line"; pItemCharge: Record "Item Charge")
    var
        UpdLandedCostLine: Record "Landed Cost Lines";
    begin
        UpdLandedCostLine.Init;
        UpdLandedCostLine.Validate("Document Type", pSalesLine."Document Type");
        UpdLandedCostLine.Validate("Document No.", pSalesLine."Document No.");
        UpdLandedCostLine."Document Line No." := pSalesLine."Line No.";
        UpdLandedCostLine.Validate("Item Charge No.", pItemCharge."No.");
        UpdLandedCostLine.Validate("Landed Cost Calc. Type", pItemCharge."Landed Cost Calc. Type");
        UpdLandedCostLine."Matrix Line Type" := pItemCharge."Matrix Line Type";
        UpdLandedCostLine.Validate("Item No.", pSalesLine."No.");
        UpdLandedCostLine.Validate("Variant Code", pSalesLine."Variant Code");
        UpdLandedCostLine.Description := pItemCharge.Description;
        UpdLandedCostLine.Validate("Value Type", CostMatrix."Value Type");
        if pSalesLine."Currency Code" = CostMatrix."Currency Code" then
            UpdLandedCostLine.Validate(Value, CostMatrix.Value)
        else
            UpdLandedCostLine.Validate(Value, ConvertCurrency(pSalesLine."Currency Code", CostMatrix.Value, SalesHdr."Currency Factor", SalesHdr."Document Date"));
        UpdLandedCostLine.Validate("Currency Code", pSalesLine."Currency Code");
        UpdLandedCostLine.Validate("Currency Factor", SalesHdr."Currency Factor");
        if UpdLandedCostLine."Currency Code" = '' then
            UpdLandedCostLine.Validate("Currency Factor", 1);
        if CostMatrix."Value Type" = CostMatrix."Value Type"::Amount then begin
            //Amount per qty on line
            UpdLandedCostLine."Unit Cost (LCY)" := CostMatrix.Value;
            UpdLandedCostLine."Amount (LCY)" := Round(pSalesLine.Quantity * CostMatrix.Value);
            UpdLandedCostLine."Unit Cost" := ConvertCurrency(UpdLandedCostLine."Currency Code", UpdLandedCostLine."Unit Cost (LCY)", UpdLandedCostLine."Currency Factor", SalesHdr."Document Date");
        end;
        if CostMatrix."Value Type" = CostMatrix."Value Type"::Percentage then begin
            //% Value of line
            UpdLandedCostLine."Amount (LCY)" := (pSalesLine.Amount * (CostMatrix.Value / 100)) / UpdLandedCostLine."Currency Factor";
            UpdLandedCostLine.Validate("Amount (LCY)", Round(UpdLandedCostLine."Amount (LCY)"));
            UpdLandedCostLine.Validate("Unit Cost (LCY)", UpdLandedCostLine."Amount (LCY)" / pSalesLine.Quantity);
        end;
        //Alexnir.SN
        if CostMatrix."Value Type" = CostMatrix."Value Type"::"Fixed Amount" then begin
            if pSalesLine.Quantity <> 0 then begin
                UpdLandedCostLine."Amount (LCY)" := (pSalesLine.Amount / UpdLandedCostLine."Currency Factor") + CostMatrix.Value;
                UpdLandedCostLine.Validate("Amount (LCY)", Round(UpdLandedCostLine."Amount (LCY)"));
                UpdLandedCostLine.Validate("Unit Cost (LCY)", UpdLandedCostLine."Amount (LCY)" / pSalesLine.Quantity);
                UpdLandedCostLine."Unit Cost" := ConvertCurrency(UpdLandedCostLine."Currency Code", UpdLandedCostLine."Unit Cost (LCY)", UpdLandedCostLine."Currency Factor", SalesHdr."Document Date");
            end else begin
                UpdLandedCostLine.Validate("Amount (LCY)", 0);
                UpdLandedCostLine.Validate("Unit Cost (LCY)", 0);
            end;
        end;
        //Alexnir.EN        
        UpdLandedCostLine.Insert;
    end;

    local procedure GetSalesHeader(LocSalesLine: Record "Sales Line")
    begin
        if (SalesHdr."Document Type" <> LocSalesLine."Document Type") and (SalesHdr."No." <> LocSalesLine."Document No.") then
            SalesHdr.Get(LocSalesLine."Document Type", LocSalesLine."Document No.");
    end;


    procedure DeleteRechargeCostLines(pSalesLine: Record "Sales Line")
    var
        CostLinestoDelete: Record "Landed Cost Lines";
    begin
        CostLinestoDelete.Init;
        CostLinestoDelete.SetRange("Document Type", pSalesLine."Document Type");
        CostLinestoDelete.SetRange("Document No.", pSalesLine."Document No.");
        CostLinestoDelete.SetRange("Document Line No.", pSalesLine."Line No.");
        CostLinestoDelete.SetRange("Matrix Line Type", CostLinestoDelete."Matrix Line Type"::Sale);
        if CostLinestoDelete.FindSet then
            CostLinestoDelete.DeleteAll;
    end;


    procedure ReverseAccrualReceipt(ReceiptNo: Code[20])
    var
        ValueEntry: Record "Value Entry";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        AccrualRemaining: Decimal;
    begin
        //Doc LC1.0 MF 01.06.18 - Added new function to reverse all accruals remaining for a receipt

        AccrualRemaining := 0;
        ValueEntry.Reset;
        ValueEntry.SetCurrentKey("Document No.");
        ValueEntry.SetRange("Document No.", ReceiptNo);
        ValueEntry.SetFilter("Landed Cost Entry Type", '%1', ValueEntry."Landed Cost Entry Type"::Accrual);
        if ValueEntry.FindSet then begin
            repeat
                AccrualRemaining := CalcAccRemaining(ValueEntry);
                if AccrualRemaining > 0 then
                    PostAccrualReversal(ValueEntry, AccrualRemaining);
            until ValueEntry.Next = 0;

        end;
    end;


    procedure ReverseAccrualContainer(ContainerNo: Code[20]; ItemCharge: Code[20])
    var
        ValueEntry: Record "Value Entry";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        AccrualRemaining: Decimal;
    begin
        AccrualRemaining := 0;
        ValueEntry.Reset;
        ValueEntry.SetCurrentKey("Container No.", "Item Charge No.", "Entry Type", "Landed Cost Entry", "Landed Cost Entry Type", "Posting Date");
        ValueEntry.SetRange("Container No.", ContainerNo);
        ValueEntry.SetFilter("Landed Cost Entry Type", '%1', ValueEntry."Landed Cost Entry Type"::Accrual);
        ValueEntry.SetRange("Item Charge No.", ItemCharge);
        if ValueEntry.FindSet then begin
            repeat
                AccrualRemaining := CalcAccRemaining(ValueEntry);
                if AccrualRemaining > 0 then
                    PostAccrualReversal(ValueEntry, AccrualRemaining);
            until ValueEntry.Next = 0;

        end;
    end;

    local procedure ReverseAccrualItemChargeAssignments(): Boolean
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
        ItemJnlLine: Record "Item Journal Line";
        AccrualValueEntry: Record "Value Entry";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        AccrualAmounttoReverse: Decimal;
        LocTempItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)" temporary;
    begin
        LocTempItemChargeAssgntPurch.Reset;
        SingleInstanceVar.LoadItemChargAssgntPurch(LocTempItemChargeAssgntPurch);
        LocTempItemChargeAssgntPurch.SetFilter("Qty. to Assign", '<>0');

        if LocTempItemChargeAssgntPurch.Find('-') then
            repeat
                if PurchRcptLine.Get(
                     LocTempItemChargeAssgntPurch."Applies-to Doc. No.", LocTempItemChargeAssgntPurch."Applies-to Doc. Line No.")
                then begin
                    AccrualValueEntry.Reset;
                    AccrualValueEntry.SetCurrentKey("Item Ledger Entry No.", "Entry Type");
                    AccrualValueEntry.SetRange("Item Ledger Entry No.", PurchRcptLine."Item Rcpt. Entry No.");
                    AccrualValueEntry.SetRange("Landed Cost Entry Type", AccrualValueEntry."Landed Cost Entry Type"::Accrual);
                    AccrualValueEntry.SetRange("Item Charge No.", LocTempItemChargeAssgntPurch."Item Charge No.");
                    if AccrualValueEntry.FindSet then
                        repeat
                            AccrualAmounttoReverse := CalcAccRemaining(AccrualValueEntry);
                            if AccrualAmounttoReverse <> 0 then begin
                                BuildAccrualReversal(AccrualValueEntry, AccrualAmounttoReverse, ItemJnlLine);
                            end;
                        until AccrualValueEntry.Next = 0;
                end;

            until LocTempItemChargeAssgntPurch.Next = 0;
    end;


    procedure CalcAccRemaining(AccValueEntry: Record "Value Entry"): Decimal
    var
        RevValueEntry: Record "Value Entry";
    begin
        RevValueEntry.Reset;
        RevValueEntry.SetCurrentKey("Container No.", "Item Charge No.", "Entry Type", "Landed Cost Entry", "Landed Cost Entry Type", "Posting Date");
        RevValueEntry.SetRange("Item Ledger Entry No.", AccValueEntry."Item Ledger Entry No.");
        RevValueEntry.SetFilter("Landed Cost Entry Type", '%1|%2', RevValueEntry."Landed Cost Entry Type"::Accrual, RevValueEntry."Landed Cost Entry Type"::Reversal);
        RevValueEntry.SetRange("Item Charge No.", AccValueEntry."Item Charge No.");
        if RevValueEntry.FindSet then begin
            RevValueEntry.CalcSums("Cost Amount (Actual)");
            exit(RevValueEntry."Cost Amount (Actual)");
        end else
            exit(0);
    end;


    procedure PostAccrualReversal(AccrualValueEntry: Record "Value Entry"; ReversalValue: Decimal)
    var
        ItemJnlLine: Record "Item Journal Line";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        ItemJnlLine.Init;
        CopyValueEntrytoItemJnlLine(ItemJnlLine, AccrualValueEntry);

        ItemJnlLine."Posting Date" := Today;
        ItemJnlLine."Invoiced Quantity" := AccrualValueEntry."Valued Quantity";
        ItemJnlLine."Invoiced Qty. (Base)" := AccrualValueEntry."Valued Quantity";
        ItemJnlLine."Unit Cost" := Round(ReversalValue / AccrualValueEntry."Valued Quantity");
        ItemJnlLine.Amount := -ReversalValue;
        ItemJnlLine."Landed Cost Entry Type" := ItemJnlLine."Landed Cost Entry Type"::Reversal;
        Clear(ItemJnlPostLine);
        ItemJnlPostLine.Run(ItemJnlLine);
    end;


    procedure SetLandedCostAdjJnlLine(var ItemJnlLine2: Record "Item Journal Line"; ILENo: Integer)
    var
        LocItemLedgEntry: Record "Item Ledger Entry";
        ItemCharge: Record "Item Charge";
        SalesShipmentHeader: Record "Sales Shipment Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        Item: Record Item;
    begin
        //Doc LC1.0 MF 01.06.18 - New function to post manual recharge
        if ItemJnlLine2."Charge Amount" = 0 then
            Error('Please enter a Charge Amount before setting the target Item Ledger Entry No.');
        LocItemLedgEntry.Get(ILENo);
        ItemCharge.Get(ItemJnlLine2."Item Charge No.");
        ItemJnlLine2."Entry Type" := ItemJnlLine2."Entry Type"::Purchase;
        ItemJnlLine2."Document Type" := ItemJnlLine2."Document Type"::"Purchase Receipt";
        if LocItemLedgEntry."Document Type" = LocItemLedgEntry."Document Type"::"Sales Return Receipt" then begin
            ItemJnlLine2."Document Type" := ItemJnlLine2."Document Type"::"Purchase Credit Memo";
        end;
        ItemJnlLine2."Document No." := LocItemLedgEntry."Document No.";
        ItemJnlLine2."Document Line No." := LocItemLedgEntry."Document Line No.";
        ItemJnlLine2."Item No." := LocItemLedgEntry."Item No.";
        ItemJnlLine2."Variant Code" := LocItemLedgEntry."Variant Code";
        ItemJnlLine2."Location Code" := LocItemLedgEntry."Location Code";
        ItemJnlLine2."Unit of Measure Code" := '';
        ItemJnlLine2."Qty. per Unit of Measure" := 1;
        ItemJnlLine2."Applies-to Entry" := ILENo;
        ItemJnlLine2."Item Shpt. Entry No." := ILENo;
        ItemJnlLine2."Overhead Rate" := 0;
        ItemJnlLine2."Shortcut Dimension 1 Code" := LocItemLedgEntry."Global Dimension 1 Code";
        ItemJnlLine2."Shortcut Dimension 2 Code" := LocItemLedgEntry."Global Dimension 2 Code";
        ItemJnlLine2."Dimension Set ID" := LocItemLedgEntry."Dimension Set ID";
        ItemJnlLine2.Validate("Item Charge No.");
        ItemJnlLine2."Landed Cost Entry" := true;
        ItemJnlLine2."Landed Cost Entry Type" := ItemJnlLine2."Landed Cost Entry Type"::Recharge;
        ItemJnlLine2."Unit Cost" := ItemJnlLine2."Charge Amount";
        ItemJnlLine2.Amount := ItemJnlLine2."Charge Amount";
        ItemJnlLine2."Unit Amount" := 0;
        Item.Get(LocItemLedgEntry."Item No.");
        if LocItemLedgEntry."Document Type" = LocItemLedgEntry."Document Type"::"Sales Shipment" then begin
            SalesShipmentHeader.Get(LocItemLedgEntry."Document No.");
            ItemJnlLine2."Gen. Bus. Posting Group" := SalesShipmentHeader."Gen. Bus. Posting Group";
            ItemJnlLine2."Source Code" := 'SALES';
            ItemJnlLine2."Salespers./Purch. Code" := SalesShipmentHeader."Salesperson Code";
        end;

        if LocItemLedgEntry."Document Type" = LocItemLedgEntry."Document Type"::"Sales Return Receipt" then begin
            ReturnReceiptHeader.Get(LocItemLedgEntry."Document No.");
            ItemJnlLine2."Gen. Bus. Posting Group" := ReturnReceiptHeader."Gen. Bus. Posting Group";
            ItemJnlLine2."Source Code" := 'SALES';
            ItemJnlLine2."Salespers./Purch. Code" := ReturnReceiptHeader."Salesperson Code";
        end;

        if LocItemLedgEntry."Document Type" = LocItemLedgEntry."Document Type"::"Purchase Receipt" then begin
            PurchRcptHeader.Get(LocItemLedgEntry."Document No.");
            ItemJnlLine2."Gen. Bus. Posting Group" := PurchRcptHeader."Gen. Bus. Posting Group";
            ItemJnlLine2."Source Code" := 'PURCHASE';
        end;

        ItemJnlLine2."Source No." := LocItemLedgEntry."Source No.";
        ItemJnlLine2."Source Type" := LocItemLedgEntry."Source Type";
        ItemJnlLine2."Value Entry Type" := ItemJnlLine2."Value Entry Type"::"Direct Cost";
        ItemJnlLine2."Gen. Prod. Posting Group" := ItemCharge."Gen. Prod. Posting Group";
        ItemJnlLine2."External Document No." := LocItemLedgEntry."External Document No.";
        ItemJnlLine2."Value Entry Type" := ItemJnlLine2."Value Entry Type"::"Direct Cost";
        ItemJnlLine2."Container No." := LocItemLedgEntry."Container No.";
        ItemJnlLine2."Country/Region Code" := LocItemLedgEntry."Country/Region Code";
        ItemJnlLine2."Item Category Code" := Item."Item Category Code";
        //ItemJnlLine2."Product Group Code" := Item."Product Group Code";
        ItemJnlLine2."Invoiced Quantity" := LocItemLedgEntry.Quantity;
        ItemJnlLine2."Invoiced Qty. (Base)" := LocItemLedgEntry.Quantity;
        ItemJnlLine2.Quantity := LocItemLedgEntry.Quantity;
    end;


    procedure BuildAccrualReversal(AccrualValueEntry: Record "Value Entry"; ReversalValue: Decimal; var ItemJnlLine: Record "Item Journal Line")
    var
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin

        ItemJnlLine.Init;
        CopyValueEntrytoItemJnlLine(ItemJnlLine, AccrualValueEntry);

        ItemJnlLine."Posting Date" := Today;
        ItemJnlLine."Invoiced Quantity" := AccrualValueEntry."Valued Quantity";
        ItemJnlLine."Invoiced Qty. (Base)" := AccrualValueEntry."Valued Quantity";
        ItemJnlLine."Unit Cost" := Round(ReversalValue / AccrualValueEntry."Valued Quantity");
        ItemJnlLine.Amount := -ReversalValue;
        ItemJnlLine."Landed Cost Entry Type" := ItemJnlLine."Landed Cost Entry Type"::Reversal;
        Clear(ItemJnlPostLine);
        ItemJnlPostLine.Run(ItemJnlLine);
    end;


    procedure ShipmentReverseRecharge(SalesShipmentHeader: Record "Sales Shipment Header")
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        ValueEntry: Record "Value Entry";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        AccrualRemaining: Decimal;
        AccrualPosted: Boolean;
    begin
        AccrualRemaining := 0;
        AccrualPosted := false;
        SalesShipmentLine.SetRange("Document No.", SalesShipmentHeader."No.");
        if SalesShipmentLine.FindSet then begin
            repeat
                ValueEntry.Reset;
                ValueEntry.SetRange("Document No.", SalesShipmentLine."Document No.");
                ValueEntry.SetFilter("Landed Cost Entry Type", '%1', ValueEntry."Landed Cost Entry Type"::Recharge);
                if ValueEntry.FindSet then begin
                    repeat
                        AccrualRemaining := CalcRechargeRemaining(ValueEntry);
                        if AccrualRemaining <> 0 then begin
                            PostRechargeReversal(ValueEntry, AccrualRemaining);
                            AccrualPosted := true;
                        end;
                    until ValueEntry.Next = 0;
                end;
            until SalesShipmentLine.Next = 0;
            if AccrualPosted then
                PostRechargeGenJnl
            else
                Error(QX001, SalesShipmentHeader."No.");
        end;
    end;


    procedure CalcRechargeRemaining(AccValueEntry: Record "Value Entry"): Decimal
    var
        RevValueEntry: Record "Value Entry";
    begin
        RevValueEntry.Reset;
        RevValueEntry.SetCurrentKey("Container No.", "Item Charge No.", "Entry Type", "Landed Cost Entry", "Landed Cost Entry Type", "Posting Date");
        RevValueEntry.SetRange("Item Ledger Entry No.", AccValueEntry."Item Ledger Entry No.");
        RevValueEntry.SetFilter("Landed Cost Entry Type", '%1|%2', RevValueEntry."Landed Cost Entry Type"::Recharge, RevValueEntry."Landed Cost Entry Type"::Reversal);
        RevValueEntry.SetRange("Item Charge No.", AccValueEntry."Item Charge No.");
        if RevValueEntry.FindSet then begin
            RevValueEntry.CalcSums("Cost Amount (Non-Invtbl.)");
            exit(RevValueEntry."Cost Amount (Non-Invtbl.)");
        end else
            exit(0);
    end;


    procedure PostRechargeReversal(AccrualValueEntry: Record "Value Entry"; ReversalValue: Decimal)
    var
        ItemJnlLine: Record "Item Journal Line";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin

        ItemJnlLine.Init;
        ItemJnlLine."Item No." := AccrualValueEntry."Item No.";
        ItemJnlLine."Variant Code" := AccrualValueEntry."Variant Code";
        ItemJnlLine."Posting Date" := Today;
        ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::Purchase;
        ItemJnlLine."Document No." := AccrualValueEntry."Document No.";
        ItemJnlLine."Location Code" := AccrualValueEntry."Location Code";
        ItemJnlLine.Quantity := 0;
        ItemJnlLine."Invoiced Quantity" := AccrualValueEntry."Valued Quantity";
        ItemJnlLine."Invoiced Qty. (Base)" := AccrualValueEntry."Valued Quantity";
        ItemJnlLine."Item Shpt. Entry No." := AccrualValueEntry."Item Ledger Entry No.";
        ItemJnlLine."Applies-to Entry" := AccrualValueEntry."Item Ledger Entry No.";
        ItemJnlLine."Unit Cost" := Round(ReversalValue / AccrualValueEntry."Valued Quantity");
        ItemJnlLine."Unit Amount" := 0;
        ItemJnlLine.Amount := -ReversalValue;
        ItemJnlLine."Gen. Bus. Posting Group" := AccrualValueEntry."Gen. Bus. Posting Group";
        ItemJnlLine."Gen. Prod. Posting Group" := AccrualValueEntry."Gen. Prod. Posting Group";
        ItemJnlLine."External Document No." := AccrualValueEntry."External Document No.";
        ItemJnlLine."Order No." := AccrualValueEntry."Order No.";
        ItemJnlLine."Document Type" := ItemJnlLine."Document Type"::"Purchase Invoice";
        ItemJnlLine."Dimension Set ID" := AccrualValueEntry."Dimension Set ID";
        ItemJnlLine."Qty. per Unit of Measure" := 1;
        ItemJnlLine."Value Entry Type" := ItemJnlLine."Value Entry Type"::"Direct Cost";
        ItemJnlLine."Item Charge No." := AccrualValueEntry."Item Charge No.";
        ItemJnlLine."Landed Cost Entry" := true;
        ItemJnlLine."Landed Cost Entry Type" := ItemJnlLine."Landed Cost Entry Type"::Reversal;
        ItemJnlLine."Source Posting Group" := AccrualValueEntry."Source Posting Group";
        ItemJnlLine."Source Code" := AccrualValueEntry."Source Code";
        ItemJnlLine."Source No." := AccrualValueEntry."Source No.";
        ItemJnlLine."Source Type" := AccrualValueEntry."Source Type";
        ItemJnlLine."Container No." := AccrualValueEntry."Container No.";
        ItemJnlLine.Description := AccrualValueEntry.Description;
        InsertRechargeGenJnlLine(ItemJnlLine);
        Clear(ItemJnlPostLine);

        ItemJnlPostLine.Run(ItemJnlLine);
    end;

    local procedure InsertRechargeGenJnlLine(pItemJnlLine: Record "Item Journal Line")
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        //Doc LC1.0 MF 06.03.18 - New function InsertRechargeGenJnlLine to create Sales Recharge Gen journal lines
        if pItemJnlLine.Amount <> 0 then begin
            RechargeGenJnlLineNo := RechargeGenJnlLineNo + 1;
            GeneralPostingSetup.Get(pItemJnlLine."Gen. Bus. Posting Group", pItemJnlLine."Gen. Prod. Posting Group");
            GeneralPostingSetup.TestField("COGS Account");
            GeneralPostingSetup.TestField("Purch. Account");
            TempRechargeGnlJnl.Init;
            TempRechargeGnlJnl."Line No." := RechargeGenJnlLineNo;
            TempRechargeGnlJnl.Validate("Posting Date", pItemJnlLine."Posting Date");
            TempRechargeGnlJnl."Document Date" := pItemJnlLine."Document Date";
            TempRechargeGnlJnl."Document Type" := TempRechargeGnlJnl."Document Type"::" ";
            TempRechargeGnlJnl."Document No." := pItemJnlLine."Document No.";
            TempRechargeGnlJnl.Validate("Account Type", TempRechargeGnlJnl."Account Type"::"G/L Account");
            TempRechargeGnlJnl.Validate("Account No.", GeneralPostingSetup."COGS Account");
            TempRechargeGnlJnl.Validate("Bal. Account Type", TempRechargeGnlJnl."Bal. Account Type"::"G/L Account");
            TempRechargeGnlJnl.Validate("Bal. Account No.", GeneralPostingSetup."Purch. Account");
            TempRechargeGnlJnl.Description := pItemJnlLine.Description;
            TempRechargeGnlJnl."Gen. Posting Type" := TempRechargeGnlJnl."Gen. Posting Type"::" ";
            TempRechargeGnlJnl.Validate("VAT Bus. Posting Group", '');
            TempRechargeGnlJnl.Validate("VAT Prod. Posting Group", '');
            TempRechargeGnlJnl.Validate("Gen. Bus. Posting Group", '');
            TempRechargeGnlJnl.Validate("Gen. Prod. Posting Group", '');
            TempRechargeGnlJnl.Validate("Bal. VAT Bus. Posting Group", '');
            TempRechargeGnlJnl.Validate("Bal. VAT Prod. Posting Group", '');
            TempRechargeGnlJnl.Validate("Bal. Gen. Bus. Posting Group", '');
            TempRechargeGnlJnl.Validate("Bal. Gen. Prod. Posting Group", '');

            TempRechargeGnlJnl."Shortcut Dimension 1 Code" := pItemJnlLine."Shortcut Dimension 1 Code";
            TempRechargeGnlJnl."Shortcut Dimension 2 Code" := pItemJnlLine."Shortcut Dimension 2 Code";
            TempRechargeGnlJnl."Item Charge No." := pItemJnlLine."Item Charge No.";
            TempRechargeGnlJnl."Dimension Set ID" := pItemJnlLine."Dimension Set ID";
            TempRechargeGnlJnl.Validate(Amount, -pItemJnlLine.Amount);
            TempRechargeGnlJnl."System-Created Entry" := true;
            TempRechargeGnlJnl.Insert;
        end;
    end;


    procedure InsertRechargeCorrGenJnlLine(pItemJnlLine: Record "Item Journal Line")
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        //Doc LC1.0 MF 04.06.18 - New function InsertRechargeCorrGenJnlLine to create Sales correction Recharge Gen journal lines
        if pItemJnlLine.Amount <> 0 then begin
            RechargeGenJnlLineNo := RechargeGenJnlLineNo + 1;
            GeneralPostingSetup.Get(pItemJnlLine."Gen. Bus. Posting Group", pItemJnlLine."Gen. Prod. Posting Group");
            GeneralPostingSetup.TestField("COGS Account");
            GeneralPostingSetup.TestField("Purch. Account");
            TempRechargeGnlJnl.Init;
            TempRechargeGnlJnl."Line No." := RechargeGenJnlLineNo;
            TempRechargeGnlJnl.Validate("Posting Date", pItemJnlLine."Posting Date");
            TempRechargeGnlJnl."Document Date" := pItemJnlLine."Document Date";
            TempRechargeGnlJnl."Document Type" := TempRechargeGnlJnl."Document Type"::" ";
            TempRechargeGnlJnl."Document No." := pItemJnlLine."Document No.";
            TempRechargeGnlJnl.Validate("Account Type", TempRechargeGnlJnl."Account Type"::"G/L Account");
            TempRechargeGnlJnl.Validate("Account No.", GeneralPostingSetup."COGS Account");
            TempRechargeGnlJnl.Validate("Bal. Account Type", TempRechargeGnlJnl."Bal. Account Type"::"G/L Account");
            TempRechargeGnlJnl.Validate("Bal. Account No.", GeneralPostingSetup."Purch. Account");
            TempRechargeGnlJnl.Description := pItemJnlLine.Description;
            TempRechargeGnlJnl."Gen. Posting Type" := TempRechargeGnlJnl."Gen. Posting Type"::" ";
            TempRechargeGnlJnl.Validate("VAT Bus. Posting Group", '');
            TempRechargeGnlJnl.Validate("VAT Prod. Posting Group", '');
            TempRechargeGnlJnl.Validate("Gen. Bus. Posting Group", '');
            TempRechargeGnlJnl.Validate("Gen. Prod. Posting Group", '');
            TempRechargeGnlJnl."Bal. Gen. Posting Type" := TempRechargeGnlJnl."Bal. Gen. Posting Type"::" ";
            TempRechargeGnlJnl.Validate("Bal. VAT Bus. Posting Group", '');
            TempRechargeGnlJnl.Validate("Bal. VAT Prod. Posting Group", '');
            TempRechargeGnlJnl.Validate("Bal. Gen. Bus. Posting Group", '');
            TempRechargeGnlJnl.Validate("Bal. Gen. Prod. Posting Group", '');

            TempRechargeGnlJnl."Shortcut Dimension 1 Code" := pItemJnlLine."Shortcut Dimension 1 Code";
            TempRechargeGnlJnl."Shortcut Dimension 2 Code" := pItemJnlLine."Shortcut Dimension 2 Code";
            TempRechargeGnlJnl."Item Charge No." := pItemJnlLine."Item Charge No.";
            TempRechargeGnlJnl."Dimension Set ID" := pItemJnlLine."Dimension Set ID";
            TempRechargeGnlJnl.Validate(Amount, -pItemJnlLine.Amount);
            TempRechargeGnlJnl."System-Created Entry" := false;
            TempRechargeGnlJnl.Insert;
        end;
        PostRechargeGenJnl;
        TempRechargeGnlJnl.DeleteAll;
    end;

    local procedure PostRechargeGenJnl()
    begin
        //Doc LC1.0 MF 06.03.18 - New function PostRechargeGenJnl

        TempRechargeGnlJnl.Reset;
        TempRechargeGnlJnl.SetFilter(Amount, '<>%1', 0);
        if TempRechargeGnlJnl.Find('-') then
            repeat
                if TempRechargeGnlJnl.Amount <> 0 then
                    GenJnlPostLine.RunWithCheck(TempRechargeGnlJnl);
            until TempRechargeGnlJnl.Next = 0;
    end;

    local procedure CopyValueEntrytoItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; AccrualValueEntry: Record "Value Entry")
    begin
        //Copy all repeated fields required for Item Journal line being created from Value Entry record

        ItemJnlLine."Item No." := AccrualValueEntry."Item No.";
        ItemJnlLine."Variant Code" := AccrualValueEntry."Variant Code";
        ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::Purchase;
        ItemJnlLine."Document No." := AccrualValueEntry."Document No.";
        ItemJnlLine."Location Code" := AccrualValueEntry."Location Code";
        ItemJnlLine.Quantity := 0;
        ItemJnlLine."Invoiced Quantity" := AccrualValueEntry."Valued Quantity";
        ItemJnlLine."Invoiced Qty. (Base)" := AccrualValueEntry."Valued Quantity";
        ItemJnlLine."Item Shpt. Entry No." := AccrualValueEntry."Item Ledger Entry No.";
        ItemJnlLine."Applies-to Entry" := AccrualValueEntry."Item Ledger Entry No.";
        ItemJnlLine."Unit Amount" := 0;
        ItemJnlLine."Gen. Bus. Posting Group" := AccrualValueEntry."Gen. Bus. Posting Group";
        ItemJnlLine."Gen. Prod. Posting Group" := AccrualValueEntry."Gen. Prod. Posting Group";
        ItemJnlLine."External Document No." := AccrualValueEntry."External Document No.";
        ItemJnlLine."Order No." := AccrualValueEntry."Order No.";
        ItemJnlLine."Document Type" := AccrualValueEntry."Document Type"::"Purchase Invoice";
        ItemJnlLine."Dimension Set ID" := AccrualValueEntry."Dimension Set ID";
        ItemJnlLine."Qty. per Unit of Measure" := 1;
        ItemJnlLine."Value Entry Type" := ItemJnlLine."Value Entry Type"::"Direct Cost";
        ItemJnlLine."Item Charge No." := AccrualValueEntry."Item Charge No.";
        ItemJnlLine."Landed Cost Entry" := true;
        ItemJnlLine."Container No." := AccrualValueEntry."Container No.";
        ItemJnlLine.Description := AccrualValueEntry.Description;

        ItemJnlLine."Source Type" := AccrualValueEntry."Source Type"::Vendor;
        ItemJnlLine."Source No." := AccrualValueEntry."Source No.";
        ItemJnlLine."Inventory Posting Group" := AccrualValueEntry."Inventory Posting Group";
        ItemJnlLine."Source Posting Group" := AccrualValueEntry."Source Posting Group";
        ItemJnlLine."Overhead Rate" := 0;
        ItemJnlLine."Shortcut Dimension 1 Code" := AccrualValueEntry."Global Dimension 1 Code";
        ItemJnlLine."Shortcut Dimension 2 Code" := AccrualValueEntry."Global Dimension 2 Code";
    end;

    local procedure ShowContainerLandedCostReviewList(var Container: Record Container)
    var
        ItemCharge: Record "Item Charge";
        ContainerItemCharge: Record "Container Item Charge";
        ContainerLandedCostReview: Page "Container Item Charges";
    begin
        Clear(ContainerLandedCostReview);
        ItemCharge.reset;
        ItemCharge.SetRange("Matrix Line Type", ItemCharge."Matrix Line Type"::" ");
        ItemCharge.SetFilter("Landed Cost Calc. Type", '>%1', 0);
        if ItemCharge.FindSet then
            repeat
                if not ContainerItemCharge.Get(Container."No.", ItemCharge."No.") then begin
                    ContainerItemCharge.Init;
                    ContainerItemCharge."Container No." := Container."No.";
                    ContainerItemCharge."No." := ItemCharge."No.";
                    ContainerItemCharge.Insert;
                end;
            until ItemCharge.Next = 0;
        Commit;

        ContainerItemCharge.SetFilter("Container No.", Container."No.");
        ContainerLandedCostReview.SETTABLEVIEW(ContainerItemCharge);
        ContainerLandedCostReview.RUN;
    end;


    procedure ContainerReviewFldVisibility(var ShowActualiseFields: Boolean; var ShowNonActualiseFields: Boolean)
    begin
        //Show & Hide relevant Landed cost review fields based upon whether Landed costs will be actualised use item charge assignments or simple G/L actual posting
        GetSystemSetup;
        if SystemSetup."Actualise Landed Cost" then begin
            ShowActualiseFields := true;
            ShowNonActualiseFields := false;
        end else begin
            ShowActualiseFields := false;
            ShowNonActualiseFields := true;
        end;
    end;


    procedure ContainerReviewCalcFields(var Container: Record Container): Decimal
    begin
        with Container do begin
            GetSystemSetup;
            if SystemSetup."Actualise Landed Cost" then begin
                CALCFIELDS("Accrued Landed Cost (LCY)", "Actual Landed Cost (LCY)");
                exit("Accrued Landed Cost (LCY)" - "Actual Landed Cost (LCY)");
            end else begin
                CALCFIELDS("Accrued Landed Cost (LCY)", "G/L Act. Landed Cost (LCY)");
                exit("Accrued Landed Cost (LCY)" - "G/L Act. Landed Cost (LCY)");
            end;
        end;
    end;


    procedure ItemChargeReviewCalcFields(var ItemCharge: Record "Item Charge"): Decimal
    begin
        with ItemCharge do begin
            GetSystemSetup;
            if SystemSetup."Actualise Landed Cost" then begin
                CalcFields("Accrued Landed Cost (LCY)", "Actual Landed Cost (LCY)");
                exit("Accrued Landed Cost (LCY)" - "Actual Landed Cost (LCY)");
            end else begin
                CalcFields("Accrued Landed Cost (LCY)", "G/L Act. Landed Cost (LCY)");
                exit("Accrued Landed Cost (LCY)" - "G/L Act. Landed Cost (LCY)");
            end;
        end;
    end;


    procedure ContainerItemChargeReviewCalcFields(var ContainerItemCharge: Record "Container Item Charge"): Decimal
    begin
        with ContainerItemCharge do begin
            GetSystemSetup;
            if SystemSetup."Actualise Landed Cost" then begin
                CalcFields("Accrued Landed Cost (LCY)", "Actual Landed Cost (LCY)");
                exit("Accrued Landed Cost (LCY)" - "Actual Landed Cost (LCY)");
            end else begin
                CalcFields("Accrued Landed Cost (LCY)", "G/L Act. Landed Cost (LCY)");
                exit("Accrued Landed Cost (LCY)" - "G/L Act. Landed Cost (LCY)");
            end;
        end;
    end;

    local procedure GetSystemSetup()
    var
        SystemSetupLoaded: Boolean;
    begin
        if not SystemSetupLoaded then begin
            SystemSetup.Get;
            SystemSetupLoaded := true;
        end;
    end;

    procedure ConvertCurrency(p_CurrentCurrencyCode: code[20]; p_UnitCostLCY: decimal; p_CurrencyFactor: decimal; p_DocumentDate: date): decimal
    var
        Currency: record Currency;
        CurrExchRate: record "Currency Exchange Rate";
        UnitCostToExit: decimal;
    begin
        UnitCostToExit := 0;
        IF p_CurrentCurrencyCode <> '' then begin
            Currency.get(p_CurrentCurrencyCode);
            Currency.TESTFIELD("Unit-Amount Rounding Precision");
            UnitCostToExit := ROUND(CurrExchRate.ExchangeAmtLCYToFCY(p_DocumentDate, Currency.Code, p_UnitCostLCY, p_CurrencyFactor), Currency."Unit-Amount Rounding Precision");
        end else
            UnitCostToExit := p_UnitCostLCY;
        exit(UnitCostToExit);
    end;

    local procedure "##QXSubscriberFuncs"()
    begin
        //Doc EX1.0 MF 09.10.18 - Added subscriber functions for conversion to extensions
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnDeletePurchaseLine(var Rec: Record "Purchase Line"; RunTrigger: Boolean)
    begin
        //Doc EX1.0 MF 09.10.18 - Added subscriber functions for conversion to extensions
        DeleteLandedCostLines(Rec);
    end;

    [EventSubscriber(ObjectType::Table, database::"Purchase Line", 'OnAfterValidateEvent', 'Outstanding Amount', false, false)]
    local procedure OnAfterValidateOutstandingAmount(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        Currency2: Record Currency;
    begin
        //Doc EX1.0 MF 09.10.18 - Added subscriber functions for conversion to extensions
        UpdateLCFields(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterValidateEvent', 'Indirect Cost %', false, false)]
    local procedure OnAfterValidateIndirectCostPct(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        //Doc EX1.0 MF 09.10.18 - Added subscriber functions for conversion to extensions
        Rec.Validate("Outstanding Amount"); //Doc LC1.0 MF 13.09.17 - Ensure LC LCY fields are updated
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnAfterModifyPurchLine(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; RunTrigger: Boolean)
    var
        Currency2: Record Currency;
        LocItemCharge: Record "Item Charge";
    begin
        //Doc EX1.0 MF 09.10.18 - Added subscriber functions for conversion to extensions
        UpdateLCFields(Rec, xRec);

        //Check if Actual Item Charge Landed cost line & flag line to be reversed later by batch routine
        Rec."Post Landed Cost Reversal" := false;
        if Rec.Type = Rec.Type::"Charge (Item)" then begin
            LocItemCharge.Get(Rec."No.");
            if LocItemCharge."Matrix Line Type" = LocItemCharge."Matrix Line Type"::" " then
                Rec."Post Landed Cost Reversal" := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchLine', '', false, false)]
    local procedure OnAfterPostPurchLineReverseLCAccrual(PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; CommitIsSupressed: Boolean)
    begin

    end;

    [EventSubscriber(ObjectType::Page, 54, 'OnAfterActionEvent', 'LandedCostBreakdown', false, false)]
    local procedure OnPurchaseOrderSubFormShowLcLines(var Rec: Record "Purchase Line")
    var
        LandedCostLinesPage: Page "Landed Cost Lines";
        LandedCostLines: Record "Landed Cost Lines";
    begin

        Clear(LandedCostLinesPage);
        LandedCostLines.reset;
        LandedCostLines.SetRange("Document Type", Rec."Document Type");
        LandedCostLines.SetRange("Document No.", Rec."Document No.");
        LandedCostLines.SetRange("Document Line No.", Rec."Line No.");
        if LandedCostLines.FindSet then begin
            LandedCostLinesPage.SETTABLEVIEW(LandedCostLines);
            LandedCostLinesPage.RUN;
        end;
    end;

    [EventSubscriber(ObjectType::Page, page::"Container Card", 'OnAfterActionEvent', 'Review Landed Costs', false, false)]
    local procedure OnContainerCardReviewLC(var Rec: Record Container)
    begin
        ShowContainerLandedCostReviewList(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Finance Review Container List", 'OnAfterActionEvent', 'Review Landed Costs', false, false)]
    local procedure OnFinanceContainerReviewLC(var Rec: Record Container)
    begin
        ShowContainerLandedCostReviewList(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Container List", 'OnAfterActionEvent', 'Review Landed Costs', false, false)]
    local procedure OnContainerListReviewLC(var Rec: Record Container)
    begin
        ShowContainerLandedCostReviewList(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item Charges", 'OnAfterActionEvent', 'Setup Landed Cost Matrix', false, false)]
    local procedure OnItemChargeListPageSetupLCMatrix(var Rec: Record "Item Charge")
    var
        LandedCostMatrixPage: Page "Landed Cost Matrix";
        LandedCostMatrix: Record "Landed Cost Matrix";
    begin
        if Rec."Landed Cost Calc. Type" = Rec."Landed Cost Calc. Type"::" " then
            Error(QX002, Rec.FieldCaption("Landed Cost Calc. Type"));
        //Alexnir.SN
        if Rec."Matrix Line Type" = Rec."Matrix Line Type"::" " then
            Error(QX002, Rec.FieldCaption("Matrix Line Type"));
        //Alexnir.EN
        Clear(LandedCostMatrix);
        LandedCostMatrix.SetRange("Landed Cost Calc. Type", Rec."Landed Cost Calc. Type");
        LandedCostMatrix.SetRange("Matrix Line Type", Rec."Matrix Line Type");
        LandedCostMatrixPage.SETTABLEVIEW(LandedCostMatrix);
        LandedCostMatrixPage.RUN;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Posted Purchase Receipt", 'OnAfterActionEvent', 'Reverse Landed Cost Accruals', false, false)]
    local procedure OnPagePostedPurchRcptReverseLCAccruals(var Rec: Record "Purch. Rcpt. Header")
    begin
        if not Confirm(QX003) then
            exit;
        ReverseAccrualReceipt(Rec."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, 5805, 'OnBeforeInsertItemChargeAssgntWithAssignValues', '', false, false)]
    local procedure OnBeforeInsertItemChargeAssgnt(var ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)")
    var
        ItemCharge: Record "Item Charge";
    begin
        //Doc LC1.0 MF 15.09.17 Set Landed Cost Calc. Type value for item charge record selected
        if ItemCharge.Get(ItemChargeAssgntPurch."Item Charge No.") then
            ItemChargeAssgntPurch.Validate("Landed Cost Calc. Type", ItemCharge."Landed Cost Calc. Type")
        else
            ItemChargeAssgntPurch.Validate("Landed Cost Calc. Type", ItemCharge."Landed Cost Calc. Type"::" ");
        if ItemCharge."Landed Cost Calc. Type" <> ItemCharge."Landed Cost Calc. Type"::" " then
            ItemChargeAssgntPurch."Landed Cost" := true
        else
            ItemChargeAssgntPurch."Landed Cost" := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnAfterPostPurchaseDoc', '', false, false)]

    procedure OnAfterPostPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20]; CommitIsSupressed: Boolean)
    var
        GLSetup: Record "General Ledger Setup";
        ItemJnlLine2: Record "Item Journal Line";
        pLandedCostLine: Record "Landed Cost Lines";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchaseLine: Record "Purchase Line";
        ItemCharge: Record "Item Charge";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        exit;  //why is this exiting //alexnir ----------------------SOS---------------------------

        PurchRcptLine.Reset;
        PurchRcptLine.SetRange("Document No.", PurchRcpHdrNo);
        PurchRcptLine.SetRange(Type, PurchRcptLine.Type::Item);
        PurchRcptLine.SetFilter(Quantity, '<>0');
        if PurchRcptLine.FindSet then
            repeat
                pLandedCostLine.Reset;
                pLandedCostLine.SetRange("Document Type", pLandedCostLine."Document Type"::Order);
                pLandedCostLine.SetRange("Document No.", PurchaseHeader."No.");
                pLandedCostLine.SetRange("Document Line No.", PurchRcptLine."Line No.");
                if pLandedCostLine.FindSet(False, False) then
                    repeat
                        ItemJnlLine2.Init;
                        ItemJnlLine2."Item No." := PurchRcptLine."No.";
                        ItemJnlLine2."Variant Code" := PurchRcptLine."Variant Code";
                        ItemJnlLine2."Posting Date" := PurchRcptLine."Posting Date";
                        ItemJnlLine2."Entry Type" := ItemJnlLine2."Entry Type"::Purchase;
                        ItemJnlLine2."Document No." := PurchRcptLine."Document No.";
                        ItemJnlLine2."Document Line No." := PurchRcptLine."Line No.";
                        ItemJnlLine2."Order No." := PurchaseHeader."No.";
                        ItemJnlLine2."Source Type" := ItemJnlLine2."Source Type"::Vendor;
                        ItemJnlLine2."Source No." := PurchaseHeader."Buy-from Vendor No.";
                        ItemJnlLine2."Location Code" := PurchRcptLine."Location Code";
                        ItemJnlLine2."External Document No." := PurchaseHeader."Vendor Order No.";
                        ItemJnlLine2."Gen. Bus. Posting Group" := PurchaseHeader."Gen. Bus. Posting Group";
                        ItemJnlLine2."Inventory Posting Group" := PurchRcptLine."Posting Group";
                        ItemJnlLine2."Source Posting Group" := PurchaseHeader."Vendor Posting Group";
                        ItemJnlLine2.Quantity := PurchRcptLine.Quantity;
                        ItemJnlLine2."Quantity (Base)" := PurchRcptLine."Quantity (Base)";
                        ItemJnlLine2."Document Type" := ItemJnlLine2."Document Type"::"Purchase Invoice";
                        ItemJnlLine2."Item Charge No." := pLandedCostLine."Item Charge No.";
                        ItemJnlLine2."Container No." := PurchRcptLine."Container No.";
                        ItemJnlLine2.Description := pLandedCostLine.Description;
                        ItemJnlLine2."Unit of Measure Code" := '';
                        ItemJnlLine2."Qty. per Unit of Measure" := 1;
                        ItemJnlLine2."Invoiced Quantity" := ItemJnlLine2.Quantity;
                        ItemJnlLine2."Invoiced Qty. (Base)" := ItemJnlLine2."Quantity (Base)";
                        ItemJnlLine2.Quantity := 0;
                        ItemJnlLine2."Quantity (Base)" := 0;
                        ItemJnlLine2.Amount := pLandedCostLine."Unit Cost (LCY)" * ItemJnlLine2."Invoiced Qty. (Base)";
                        if pLandedCostLine."Document Type" in [pLandedCostLine."Document Type"::"Return Order", pLandedCostLine."Document Type"::"Credit Memo"] then
                            ItemJnlLine2.Amount := -ItemJnlLine2.Amount;

                        ItemJnlLine2.Amount := Round(ItemJnlLine2.Amount);
                        ItemJnlLine2."Unit Cost" := Round(pLandedCostLine."Unit Cost (LCY)", GLSetup."Unit-Amount Rounding Precision");
                        ItemJnlLine2."Applies-to Entry" := PurchRcptLine."Item Rcpt. Entry No.";
                        ItemJnlLine2."Item Shpt. Entry No." := PurchRcptLine."Item Rcpt. Entry No.";
                        ItemJnlLine2."Overhead Rate" := 0;
                        ItemJnlLine2."Shortcut Dimension 1 Code" := PurchRcptLine."Shortcut Dimension 1 Code";
                        ItemJnlLine2."Shortcut Dimension 2 Code" := PurchRcptLine."Shortcut Dimension 2 Code";
                        ItemJnlLine2."Dimension Set ID" := PurchRcptLine."Dimension Set ID";
                        ItemJnlLine2."Gen. Prod. Posting Group" := pLandedCostLine."Gen. Prod. Posting Group";
                        ItemJnlLine2."Landed Cost Entry" := true;
                        ItemJnlLine2."Landed Cost Entry Type" := ItemJnlLine2."Landed Cost Entry Type"::Accrual;
                        ItemJnlLine2."Country/Region Code" := PurchaseHeader."Buy-from Country/Region Code";
                        ItemJnlLine2."Transaction Type" := PurchRcptLine."Transaction Type";
                        ItemJnlLine2."Transport Method" := PurchRcptLine."Transport Method";
                        ItemJnlLine2."Transaction Specification" := PurchRcptLine."Transaction Specification";
                        ItemJnlLine2."Entry/Exit Point" := PurchRcptLine."Entry Point";
                        ItemJnlLine2.Area := PurchRcptLine.Area;
                        ItemJnlLine2."Item Category Code" := PurchRcptLine."Item Category Code";
                        Clear(ItemJnlPostLine);
                        ItemJnlPostLine.RunWithCheck(ItemJnlLine2);
                        PurchRcptLine."Post Landed Cost Accrual" := false;
                        PurchRcptLine.Modify;
                    until pLandedCostLine.Next = 0;
            until PurchRcptLine.Next = 0;

        //Check for Accrual Reversal & Item Charge assignments, post accrual reversals as necessary
        if not (PurchaseHeader.Invoice) or (PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Invoice) then
            exit;

        ReverseAccrualItemChargeAssignments;
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Purch.-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', false, false)]

    procedure OnAfterFinalizePostingOnBeforeCommit(var PurchHeader: Record "Purchase Header"; var PurchRcptHeader: Record "Purch. Rcpt. Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var ReturnShptHeader: Record "Return Shipment Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PreviewMode: Boolean; CommitIsSupressed: Boolean)
    var
        GLSetup: Record "General Ledger Setup";
        ItemJnlLine2: Record "Item Journal Line";
        pLandedCostLine: Record "Landed Cost Lines";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchaseLine: Record "Purchase Line";
        ItemCharge: Record "Item Charge";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        PurchRcptLine.Reset;
        PurchRcptLine.SetRange("Document No.", PurchRcptHeader."No.");
        PurchRcptLine.SetRange(Type, PurchRcptLine.Type::Item);
        PurchRcptLine.SetFilter(Quantity, '<>0');
        if PurchRcptLine.FindSet then
            repeat
                pLandedCostLine.Reset;
                pLandedCostLine.SetRange("Document Type", pLandedCostLine."Document Type"::Order);
                pLandedCostLine.SetRange("Document No.", PurchHeader."No.");
                pLandedCostLine.SetRange("Document Line No.", PurchRcptLine."Line No.");
                if pLandedCostLine.FindSet(False, False) then
                    repeat
                        ItemJnlLine2.Init;
                        ItemJnlLine2."Item No." := PurchRcptLine."No.";
                        ItemJnlLine2."Variant Code" := PurchRcptLine."Variant Code";
                        ItemJnlLine2."Posting Date" := PurchRcptLine."Posting Date";
                        ItemJnlLine2."Entry Type" := ItemJnlLine2."Entry Type"::Purchase;
                        ItemJnlLine2."Document No." := PurchRcptLine."Document No.";
                        ItemJnlLine2."Document Line No." := PurchRcptLine."Line No.";
                        ItemJnlLine2."Order No." := PurchHeader."No.";
                        ItemJnlLine2."Source Type" := ItemJnlLine2."Source Type"::Vendor;
                        ItemJnlLine2."Source No." := PurchHeader."Buy-from Vendor No.";
                        ItemJnlLine2."Location Code" := PurchRcptLine."Location Code";
                        ItemJnlLine2."External Document No." := PurchHeader."Vendor Order No.";
                        ItemJnlLine2."Gen. Bus. Posting Group" := PurchHeader."Gen. Bus. Posting Group";
                        ItemJnlLine2."Inventory Posting Group" := PurchRcptLine."Posting Group";
                        ItemJnlLine2."Source Posting Group" := PurchHeader."Vendor Posting Group";
                        ItemJnlLine2.Quantity := PurchRcptLine.Quantity;
                        ItemJnlLine2."Quantity (Base)" := PurchRcptLine."Quantity (Base)";
                        ItemJnlLine2."Document Type" := ItemJnlLine2."Document Type"::"Purchase Invoice";
                        ItemJnlLine2."Item Charge No." := pLandedCostLine."Item Charge No.";
                        ItemJnlLine2."Container No." := PurchRcptLine."Container No.";
                        ItemJnlLine2.Description := pLandedCostLine.Description;
                        ItemJnlLine2."Unit of Measure Code" := '';
                        ItemJnlLine2."Qty. per Unit of Measure" := 1;
                        ItemJnlLine2."Invoiced Quantity" := ItemJnlLine2.Quantity;
                        ItemJnlLine2."Invoiced Qty. (Base)" := ItemJnlLine2."Quantity (Base)";
                        ItemJnlLine2.Quantity := 0;
                        ItemJnlLine2."Quantity (Base)" := 0;
                        ItemJnlLine2.Amount := pLandedCostLine."Unit Cost (LCY)" * ItemJnlLine2."Invoiced Qty. (Base)";
                        if pLandedCostLine."Document Type" in [pLandedCostLine."Document Type"::"Return Order", pLandedCostLine."Document Type"::"Credit Memo"] then
                            ItemJnlLine2.Amount := -ItemJnlLine2.Amount;

                        ItemJnlLine2.Amount := Round(ItemJnlLine2.Amount);
                        ItemJnlLine2."Unit Cost" := Round(pLandedCostLine."Unit Cost (LCY)", GLSetup."Unit-Amount Rounding Precision");
                        ItemJnlLine2."Applies-to Entry" := PurchRcptLine."Item Rcpt. Entry No.";
                        ItemJnlLine2."Item Shpt. Entry No." := PurchRcptLine."Item Rcpt. Entry No.";
                        ItemJnlLine2."Overhead Rate" := 0;
                        ItemJnlLine2."Shortcut Dimension 1 Code" := PurchRcptLine."Shortcut Dimension 1 Code";
                        ItemJnlLine2."Shortcut Dimension 2 Code" := PurchRcptLine."Shortcut Dimension 2 Code";
                        ItemJnlLine2."Dimension Set ID" := PurchRcptLine."Dimension Set ID";
                        ItemJnlLine2."Gen. Prod. Posting Group" := pLandedCostLine."Gen. Prod. Posting Group";
                        ItemJnlLine2."Landed Cost Entry" := true;
                        ItemJnlLine2."Landed Cost Entry Type" := ItemJnlLine2."Landed Cost Entry Type"::Accrual;
                        ItemJnlLine2."Country/Region Code" := PurchHeader."Buy-from Country/Region Code";
                        ItemJnlLine2."Transaction Type" := PurchRcptLine."Transaction Type";
                        ItemJnlLine2."Transport Method" := PurchRcptLine."Transport Method";
                        ItemJnlLine2."Transaction Specification" := PurchRcptLine."Transaction Specification";
                        ItemJnlLine2."Entry/Exit Point" := PurchRcptLine."Entry Point";
                        ItemJnlLine2.Area := PurchRcptLine.Area;
                        ItemJnlLine2."Item Category Code" := PurchRcptLine."Item Category Code";
                        Clear(ItemJnlPostLine);
                        ItemJnlPostLine.RunWithCheck(ItemJnlLine2);
                        PurchRcptLine."Post Landed Cost Accrual" := false;
                        PurchRcptLine.Modify;
                    until pLandedCostLine.Next = 0;
            until PurchRcptLine.Next = 0;

        //Check for Accrual Reversal & Item Charge assignments, post accrual reversals as necessary
        if not (PurchHeader.Invoice) or (PurchHeader."Document Type" <> PurchHeader."Document Type"::Invoice) then
            exit;

        ReverseAccrualItemChargeAssignments;
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Item Jnl.-Post Line", 'OnBeforeInsertValueEntry', '', false, false)]
    local procedure OnBeforeValueEntryInsert(var ValueEntry: Record "Value Entry"; ItemJournalLine: Record "Item Journal Line")
    begin
        ValueEntry."Container No." := ItemJournalLine."Container No.";
        ValueEntry."Landed Cost Entry" := ItemJournalLine."Landed Cost Entry";
        ValueEntry."Landed Cost Entry Type" := ItemJournalLine."Landed Cost Entry Type";
        if ItemJournalLine."Order No." <> '' then
            ValueEntry."Order No." := ItemJournalLine."Order No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostItemJnlLineJobConsumption', '', false, false)]

    procedure OnBeforePostItemJnlLineJobConsumption(var ItemJournalLine: Record "Item Journal Line"; PurchaseLine: Record "Purchase Line"; PurchInvHeader: Record "Purch. Inv. Header"; PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; QtyToBeInvoiced: Decimal; QtyToBeInvoicedBase: Decimal; SourceCode: Code[10])
    var
        GLSetup: Record "General Ledger Setup";
        ItemJnlLine2: Record "Item Journal Line";
        pLandedCostLine: Record "Landed Cost Lines";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        ItemCharge: Record "Item Charge";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        //Not Required - keep code in case need to re-visit performing accruals online. This code currently gives a G/L Register error.
        exit; //alexnir -review

        pLandedCostLine.Reset;
        pLandedCostLine.SetRange("Document Type", pLandedCostLine."Document Type"::Order);
        pLandedCostLine.SetRange("Document No.", PurchaseLine."Document No.");
        pLandedCostLine.SetRange("Document Line No.", PurchaseLine."Line No.");
        if pLandedCostLine.FindSet(false, false) then
            repeat
                ItemJnlLine2.Init;
                ItemJnlLine2."Item No." := PurchaseLine."No.";
                ItemJnlLine2."Variant Code" := PurchaseLine."Variant Code";
                ItemJnlLine2."Posting Date" := ItemJournalLine."Posting Date";
                ItemJnlLine2."Entry Type" := ItemJnlLine2."Entry Type"::Purchase;
                ItemJnlLine2."Document No." := PurchaseLine."Document No.";
                ItemJnlLine2."Document Line No." := PurchaseLine."Line No.";
                ItemJnlLine2."Order No." := PurchaseLine."Document No.";
                ItemJnlLine2."Source Type" := ItemJnlLine2."Source Type"::Vendor;
                ItemJnlLine2."Source No." := PurchaseLine."Buy-from Vendor No.";
                ItemJnlLine2."Location Code" := PurchaseLine."Location Code";
                ItemJnlLine2."External Document No." := PurchInvHeader."Vendor Order No.";
                ItemJnlLine2."Inventory Posting Group" := PurchaseLine."Posting Group";
                ItemJnlLine2."Source Posting Group" := PurchInvHeader."Vendor Posting Group";
                ItemJnlLine2.Quantity := PurchaseLine.Quantity;
                ItemJnlLine2."Quantity (Base)" := PurchaseLine."Quantity (Base)";
                ItemJnlLine2."Document Type" := ItemJnlLine2."Document Type"::"Purchase Invoice";
                ItemJnlLine2."Item Charge No." := pLandedCostLine."Item Charge No.";
                ItemJnlLine2."Container No." := PurchaseLine."Container No.";
                ItemJnlLine2.Description := pLandedCostLine.Description;
                ItemJnlLine2."Unit of Measure Code" := '';
                ItemJnlLine2."Qty. per Unit of Measure" := 1;
                ItemJnlLine2."Invoiced Quantity" := ItemJnlLine2.Quantity;
                ItemJnlLine2."Invoiced Qty. (Base)" := ItemJnlLine2."Quantity (Base)";
                ItemJnlLine2.Quantity := 0;
                ItemJnlLine2."Quantity (Base)" := 0;
                ItemJnlLine2.Amount := pLandedCostLine."Unit Cost (LCY)" * ItemJnlLine2."Invoiced Qty. (Base)";
                if pLandedCostLine."Document Type" in [pLandedCostLine."Document Type"::"Return Order", pLandedCostLine."Document Type"::"Credit Memo"] then
                    ItemJnlLine2.Amount := -ItemJnlLine2.Amount;

                ItemJnlLine2.Amount := Round(ItemJnlLine2.Amount);
                ItemJnlLine2."Unit Cost" := Round(pLandedCostLine."Unit Cost (LCY)", GLSetup."Unit-Amount Rounding Precision");
                ItemJnlLine2."Applies-to Entry" := ItemJournalLine."Item Shpt. Entry No.";
                ItemJnlLine2."Item Shpt. Entry No." := ItemJournalLine."Item Shpt. Entry No.";
                ItemJnlLine2."Overhead Rate" := 0;
                ItemJnlLine2."Shortcut Dimension 1 Code" := PurchaseLine."Shortcut Dimension 1 Code";
                ItemJnlLine2."Shortcut Dimension 2 Code" := PurchaseLine."Shortcut Dimension 2 Code";
                ItemJnlLine2."Dimension Set ID" := PurchaseLine."Dimension Set ID";
                ItemJnlLine2."Gen. Prod. Posting Group" := pLandedCostLine."Gen. Prod. Posting Group";
                ItemJnlLine2."Landed Cost Entry" := true;
                ItemJnlLine2."Landed Cost Entry Type" := ItemJnlLine2."Landed Cost Entry Type"::Accrual;
                ItemJnlLine2."Country/Region Code" := PurchInvHeader."Buy-from Country/Region Code";
                ItemJnlLine2."Transaction Type" := PurchaseLine."Transaction Type";
                ItemJnlLine2."Transport Method" := PurchaseLine."Transport Method";
                ItemJnlLine2."Transaction Specification" := PurchaseLine."Transaction Specification";
                ItemJnlLine2."Entry/Exit Point" := PurchaseLine."Entry Point";
                ItemJnlLine2.Area := PurchaseLine.Area;
                ItemJnlLine2."Item Category Code" := PurchaseLine."Item Category Code";
                Clear(ItemJnlPostLine);
                ItemJnlPostLine.RunWithCheck(ItemJnlLine2);
                Clear(ItemJnlPostLine);

            until pLandedCostLine.Next = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnBeforeItemJnlPostLine', '', false, false)]
    local procedure OnBeforeItemJnlPostLineContainer(var ItemJournalLine: Record "Item Journal Line"; PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header"; CommitIsSupressed: Boolean)
    var
        LocPurchRcptLine: Record "Purch. Rcpt. Line";
    begin
        if (PurchaseHeader.Invoice) and (PurchaseLine.Type = PurchaseLine.Type::"Charge (Item)") and (PurchaseLine."Post Landed Cost Reversal") then begin
            ItemJournalLine."Landed Cost Entry Type" := ItemJournalLine."Landed Cost Entry Type"::Actual;
            if ItemJournalLine."Item Shpt. Entry No." <> 0 then begin
                LocPurchRcptLine.SetCurrentKey("Item Rcpt. Entry No.");
                LocPurchRcptLine.SetRange("Item Rcpt. Entry No.", ItemJournalLine."Item Shpt. Entry No.");
                if LocPurchRcptLine.FindFirst then begin
                    ItemJournalLine."Container No." := LocPurchRcptLine."Container No.";
                    ItemJournalLine."Order No." := LocPurchRcptLine."Order No.";
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterValidateEvent', 'Zero Landed Cost', false, false)]
    local procedure SalesLineZeroLandedCostOnValidate(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        with Rec do begin
            if "Zero Landed Cost" then
                DeleteRechargeCostLines(Rec);

            Validate("Outstanding Amount");
        end;
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterValidateEvent', 'Zero Landed Cost', false, false)]
    local procedure PurchLineZeroLandedCostOnValidate(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        with Rec do begin
            if "Zero Landed Cost" then
                DeleteLandedCostLines(Rec);

            Validate("Outstanding Amount");

        end;
    end;

    [EventSubscriber(ObjectType::Table, 83, 'OnAfterValidateEvent', 'Target Item Ledger Entry', false, false)]
    local procedure ItemJnlLineTargetItemLedgerEntryOnValidate(var Rec: Record "Item Journal Line"; var xRec: Record "Item Journal Line"; CurrFieldNo: Integer)
    begin
        with Rec do begin
            SetLandedCostAdjJnlLine(Rec, "Target Item Ledger Entry");
            "LC Correction" := true;
        end;
    end;











    /*
    non extension diffs --ALEXNIR-REVIEW


        [EventSubscriber(ObjectType::Codeunit, 90, 'OnBeforeItemJnlPostLine', '', false, false)]
        local procedure OnBeforeItemJnlPostLine(var ItemJournalLine: Record "Item Journal Line"; PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header"; CommitIsSupressed: Boolean; var IsHandled: Boolean; WhseReceiptHeader: Record "Warehouse Receipt Header"; WhseShipmentHeader: Record "Warehouse Shipment Header")
        begin
            Clear(ItemJnlLineG);
            ItemJnlLineG := ItemJournalLine;
        end;


        [EventSubscriber(ObjectType::Codeunit, 90, 'OnAfterPostItemJnlLine', '', false, false)]
        local procedure OnAfterPostItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; var PurchaseLine: Record "Purchase Line"; var PurchaseHeader: Record "Purchase Header"; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line")
        begin
            //Doc LC1.0 MF 12.09.17 - Call new function PostItemJnlLineLCAccruals
            IF (PurchaseLine.Type = PurchaseLine.Type::Item) AND (ItemJournalLine.quantity <> 0) THEN
                PostItemJnlLineLCAccruals(PurchaseLine, ItemJnlLineG, ItemJournalLine."Item Shpt. Entry No.");
        end;

        local procedure PostItemJnlLineLCAccruals(PurchLine: record "Purchase Line"; var OriginalItemJnlLine: record "Item Journal Line"; ItemShptEntryNo: integer)
        var
            LandedCostLines: record "Landed Cost Lines";
        begin
            IF PurchLine.Type <> PurchLine.Type::Item THEN
                EXIT;

            LandedCostLines.RESET;
            LandedCostLines.SETRANGE("Document Type", PurchLine."Document Type");
            LandedCostLines.SETRANGE("Document No.", PurchLine."Document No.");
            LandedCostLines.SETRANGE("Document Line No.", PurchLine."Line No.");
            LandedCostLines.SETRANGE("Matrix Line Type", LandedCostLines."Matrix Line Type"::Purchase);
            IF LandedCostLines.ISEMPTY THEN
                EXIT;

            IF LandedCostLines.FINDSET THEN
                REPEAT
                    PostLCAccrualPerOrder(PurchLine, OriginalItemJnlLine, LandedCostLines, ItemShptEntryNo)
                UNTIL LandedCostLines.NEXT = 0;
        end;

        local procedure PostLCAccrualPerOrder(PurchLine: record "Purchase Line"; ItemJnlLine2: record "Item Journal Line"; pLandedCostLine: record "Landed Cost Lines"; ItemShptEntryNo: integer)
        var
            ItemJnlPostLine: codeunit "Item Jnl.-Post Line";
            GLSetup: record "General Ledger Setup";
        begin
            //Doc LC1.0 MF 12.09.17 Added new function PostLCAccrualPerOrder
            WITH pLandedCostLine DO BEGIN
                GLSetup.get();
                ItemJnlLine2."Item Charge No." := "Item Charge No.";
                ItemJnlLine2.Description := Description;
                ItemJnlLine2."Document Line No." := PurchLine."Line No.";
                ItemJnlLine2."Unit of Measure Code" := '';
                ItemJnlLine2."Qty. per Unit of Measure" := 1;
                IF ItemJnlLine2."Invoiced Quantity" = 0 THEN BEGIN
                    ItemJnlLine2."Invoiced Quantity" := ItemJnlLine2.Quantity;
                    ItemJnlLine2."Invoiced Qty. (Base)" := ItemJnlLine2."Quantity (Base)";
                END;
                ItemJnlLine2.Quantity := 0;

                ItemJnlLine2.Amount := "Unit Cost (LCY)" * ItemJnlLine2."Invoiced Qty. (Base)";
                IF "Document Type" IN ["Document Type"::"Return Order", "Document Type"::"Credit Memo"] THEN
                    ItemJnlLine2.Amount := -ItemJnlLine2.Amount;

                ItemJnlLine2.Amount := ROUND(ItemJnlLine2.Amount);
                ItemJnlLine2."Unit Cost" := ROUND(pLandedCostLine."Unit Cost (LCY)", GLSetup."Unit-Amount Rounding Precision");
                ItemJnlLine2."Applies-to Entry" := ItemShptEntryNo;
                ItemJnlLine2."Item Shpt. Entry No." := ItemShptEntryNo;
                ItemJnlLine2."Overhead Rate" := 0;
                ItemJnlLine2."Shortcut Dimension 1 Code" := PurchLine."Shortcut Dimension 1 Code";
                ItemJnlLine2."Shortcut Dimension 2 Code" := PurchLine."Shortcut Dimension 2 Code";
                ItemJnlLine2."Dimension Set ID" := PurchLine."Dimension Set ID";
                ItemJnlLine2."Gen. Prod. Posting Group" := "Gen. Prod. Posting Group";
                ItemJnlLine2."Landed Cost Entry" := TRUE;
                ItemJnlLine2."Landed Cost Entry Type" := ItemJnlLine2."Landed Cost Entry Type"::Accrual;
            END;
            ItemJnlPostLine.RunWithCheck(ItemJnlLine2);
        end;


        [EventSubscriber(ObjectType::Codeunit, 90, 'OnPostItemChargePerOrderOnAfterCopyToItemJnlLine', '', false, false)]
        local procedure OnPostItemChargePerOrderOnAfterCopyToItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; var PurchaseLine: Record "Purchase Line"; GeneralLedgerSetup: Record "General Ledger Setup"; QtyToInvoice: Decimal; var TempItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)" temporary)
        begin
            //Doc LC1.0 MF 15.09.17 - Update Landed cost related flags on item jnl line if charge assignment relates to a landed cost charge item
            ItemJournalLine."Landed Cost Entry" := TempItemChargeAssignmentPurch."Landed Cost";
            IF ItemJournalLine."Landed Cost Entry" THEN
                ItemJournalLine."Landed Cost Entry Type" := ItemJournalLine."Landed Cost Entry Type"::Actual;
            //Doc LC1.0 MF 15.09.17 +
        end;


        [EventSubscriber(ObjectType::Codeunit, 90, 'OnPostItemChargeOnBeforePostItemJnlLine', '', false, false)]
        local procedure OnPostItemChargeOnBeforePostItemJnlLine(var PurchaseLineToPost: Record "Purchase Line"; var PurchaseLine: Record "Purchase Line"; QtyToAssign: Decimal; var TempItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)" temporary)
        begin
            //Doc LC1.0 MF 15.09.17 Update LC fields if relevant on Actuals posting of LC type item charge assignment
            PurchaseLineToPost."Container No." := TempItemChargeAssgntPurch."Container No.";
        end;


        [EventSubscriber(ObjectType::Codeunit, 90, 'OnPostItemChargeLineOnBeforePostItemCharge', '', false, false)]
        local procedure OnPostItemChargeLineOnBeforePostItemCharge(var TempItemChargeAssgntPurch: record "Item Charge Assignment (Purch)" temporary; PurchHeader: Record "Purchase Header"; PurchLine: Record "Purchase Line")
        begin
            if TempItemChargeAssgntPurch."Applies-to Doc. Type" <> TempItemChargeAssgntPurch."Applies-to Doc. Type"::Receipt then
                exit;


        end;


        var
            ItemJnlLineG: record "Item Journal Line";


    */
}

