tableextension 66005 "Purch. Rcpt. Line-LC" extends "Purch. Rcpt. Line"
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
//