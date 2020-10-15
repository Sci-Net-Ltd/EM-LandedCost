tableextension 66006 "Purch. Inv. Line-LC" extends "Purch. Inv. Line"
{
    fields
    {
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
    }
}
