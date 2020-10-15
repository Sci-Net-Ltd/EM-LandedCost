tableextension 66000 "Sales Line-LC" extends "Sales Line"
{
    fields
    {
        field(66000; "Zero Landed Cost"; Boolean)
        {
            Caption = 'Zero Landed Cost';
            DataClassification = CustomerContent;
        }
        field(66001; "G/L Posting Only"; Boolean)
        {
            Caption = 'G/L Posting Only';
            DataClassification = CustomerContent;
        }
    }
}
