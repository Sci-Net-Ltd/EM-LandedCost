tableextension 66002 "Purchase Line-LC" extends "Purchase Line"
{
    fields
    {
        field(66000; "Unit Cost Excl. LC"; Decimal)
        {
            Caption = 'Unit Cost Excl. LC';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(66001; "Unit Cost Excl. LC (LCY)"; Decimal)
        {
            Caption = 'Unit Cost Excl. LC (LCY)';
            DataClassification = CustomerContent;
            editable = false;
        }
        field(66002; "Previous Unit Cost"; Decimal)
        {
            Caption = 'Previous Unit Cost';
            DataClassification = CustomerContent;

        }
        field(66003; "Previous Unit Cost (LCY)"; Decimal)
        {
            Caption = 'Previous Unit Cost (LCY)';
            DataClassification = CustomerContent;
        }
        field(66004; "Previous Line Value (LCY)"; Decimal)
        {
            Caption = 'Previous Line Value (LCY)';
            DataClassification = CustomerContent;
        }
        field(66005; "Line Difference (LCY)"; Decimal)
        {
            Caption = 'Line Difference (LCY)';
            DataClassification = CustomerContent;
        }
        field(66006; "Last Price Update"; Date)
        {
            Caption = 'Last Price Update';
            DataClassification = CustomerContent;
        }
        field(66007; "Outstanding Amt. LC (LCY)"; Decimal)
        {
            Caption = 'Outstanding Amt. LC (LCY)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(66008; "Landed Cost (LCY)"; Decimal)
        {
            Caption = 'Landed Cost (LCY)';
            DataClassification = CustomerContent;
            editable = false;
        }
        field(66009; "Line Amount Excl. VAT (LCY)"; Decimal)
        {
            Caption = 'Line Amount Excl. VAT (LCY)';
            DataClassification = CustomerContent;
            editable = false;
        }
        field(66010; "Line Amount Excl. VAT LC (LCY)"; Decimal)
        {
            Caption = 'Line Amount Excl. VAT LC (LCY)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(66011; "Post Landed Cost Accrual"; Boolean)
        {
            Caption = 'Post Landed Cost Accrual';
            DataClassification = CustomerContent;
        }
        field(66012; "Post Landed Cost Reversal"; Boolean)
        {
            Caption = 'Post Landed Cost Reversal';
            DataClassification = CustomerContent;
        }
        field(66013; "Det. Landed Cost (LCY)"; Decimal)
        {
            Caption = 'Det. Landed Cost (LCY)';
            FieldClass = FlowField;
            CalcFormula = Sum("Landed Cost Lines"."Amount (LCY)" WHERE("Document Type" = FIELD("Document Type"), "Document No." = FIELD("Document No."), "Document Line No." = FIELD("Line No.")));
            Editable = false;
        }
        field(66014; "Zero Landed Cost"; Boolean)
        {
            Caption = 'Zero Landed Cost';
            DataClassification = CustomerContent;
        }
        field(66015; "G/L Posting Only"; Boolean)
        {
            Caption = 'G/L Posting Only';
            DataClassification = CustomerContent;
        }
    }
}
