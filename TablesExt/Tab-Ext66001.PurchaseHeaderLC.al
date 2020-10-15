tableextension 66001 "Purchase Header-LC" extends "Purchase Header"
{
    fields
    {
        field(66000; "Accrued Landed Cost (LCY)"; Decimal)
        {
            Caption = 'Accrued Landed Cost (LCY)';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = Sum("Value Entry"."Cost Amount (Actual)" WHERE("Order No." = FIELD("No."), "Entry Type" = FILTER("Direct Cost"), "Landed Cost Entry Type" = FILTER(Accrual), "Posting Date" = FIELD("Date Filter")));
        }
        field(66001; "Actual Landed Cost (LCY)"; Decimal)
        {
            Caption = 'Actual Landed Cost (LCY)';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = Sum("Value Entry"."Cost Amount (Actual)" WHERE("Order No." = FIELD("No."), "Landed Cost Entry Type" = FILTER(Actual), "Posting Date" = FIELD("Date Filter")));
        }
        field(66002; "Remaining Accr. LCost (LCY)"; Decimal)
        {
            Caption = 'Remaining Accr. LCost (LCY)';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = Sum("Value Entry"."Cost Amount (Actual)" WHERE("Order No." = FIELD("No."), "Entry Type" = FILTER("Direct Cost"), "Landed Cost Entry Type" = FILTER(Accrual | Reversal), "Posting Date" = FIELD("Date Filter")));
        }
        field(66003; "Order Landed Cost (LCY)"; Decimal)
        {
            Caption = 'Order Landed Cost (LCY)';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = Sum("Purchase Line"."Landed Cost (LCY)" WHERE("Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.")));
        }
    }
}
