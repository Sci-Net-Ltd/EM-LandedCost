tableextension 66007 "Item Charge-LC" extends "Item Charge"
{
    fields
    {
        field(66000; "Landed Cost Calc. Type"; Option)
        {
            Caption = 'Landed Cost Calc. Type';
            DataClassification = CustomerContent;
            OptionMembers = " ",Freight,Duty,Insurance,Commission,Packaging,Custom1,Custom2,Custom3,Custom4,Custom5,Custom6,Custom7,Custom8,Custom9;
        }
        field(66001; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(66002; "Container No. Filter"; Code[20])
        {
            Caption = 'Container No. Filter';
            FieldClass = FlowFilter;
            TableRelation = Container."No.";
        }
        field(66003; "Matrix Line Type"; Option)
        {
            Caption = 'Matrix Line Type';
            DataClassification = CustomerContent;
            OptionMembers = Purchase,Sale," ";
        }
        field(66004; "Post Accrual Diff. Account"; Code[20])
        {
            Caption = 'Post Accrual Diff. Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(66005; "Accrued Landed Cost (LCY)"; Decimal)
        {
            Caption = 'Accrued Landed Cost (LCY)';
            FieldClass = FlowField;
            CalcFormula = Sum("Value Entry"."Cost Amount (Actual)" WHERE("Container No." = FIELD("Container No. Filter"), "Item Charge No." = FIELD("No."), "Landed Cost Entry Type" = FILTER(Accrual), "Posting Date" = FIELD("Date Filter")));
            editable = false;
        }
        field(66006; "Actual Landed Cost (LCY)"; Decimal)
        {
            Caption = 'Actual Landed Cost (LCY)';
            FieldClass = FlowField;
            CalcFormula = Sum("Value Entry"."Cost Amount (Actual)" WHERE("Container No." = FIELD("Container No. Filter"), "Item Charge No." = FIELD("No."), "Landed Cost Entry Type" = FILTER(Actual), "Posting Date" = FIELD("Date Filter")));
            editable = false;

        }
        field(66007; "Remaining Accr. LCost (LCY)"; Decimal)
        {
            Caption = 'Remaining Accr. LCost (LCY)';
            FieldClass = FlowField;
            CalcFormula = Sum("Value Entry"."Cost Amount (Actual)" WHERE("Container No." = FIELD("Container No. Filter"), "Item Charge No." = FIELD("No."), "Landed Cost Entry Type" = FILTER(Accrual | Reversal), "Posting Date" = FIELD("Date Filter")));
            editable = false;
        }
        field(66008; "G/L Posting Only"; Boolean)
        {
            Caption = 'G/L Posting Only';
            DataClassification = CustomerContent;
        }
        field(66009; "Actual LC Last Posted Date"; Date)
        {
            Caption = 'Actual LC Last Posted Date';
            FieldClass = FlowField;
            CalcFormula = Max("Purch. Inv. Line"."Posting Date" WHERE(Type = FILTER('Charge (Item)'), "No." = FIELD("No."), "Container No." = FIELD("Container No. Filter")));
            editable = false;
        }
        field(66010; "G/L Act. Landed Cost (LCY)"; Decimal)
        {
            Caption = 'G/L Act. Landed Cost (LCY)';
            FieldClass = FlowField;
            CalcFormula = Sum("G/L Entry".Amount WHERE("Container No." = FIELD("Container No. Filter"), "Item Charge No." = FIELD("No."), "Posting Date" = FIELD("Date Filter")));
        }
    }
}
