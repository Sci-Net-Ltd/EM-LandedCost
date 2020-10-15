tableextension 66003 "Gen. Journal Line-LC" extends "Gen. Journal Line"
{
    fields
    {
        field(66000; "Item Charge No."; Code[20])
        {
            Caption = 'Item Charge No.';
            DataClassification = CustomerContent;
            TableRelation = "Item Charge";
        }
        field(66001; "Container No."; Code[20])
        {
            Caption = 'Container No.';
            DataClassification = CustomerContent;
        }
    }
}
