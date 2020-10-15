tableextension 66009 "Item Charge Assign. (Purch)-LC" extends "Item Charge Assignment (Purch)"
{
    fields
    {
        field(66000; "Landed Cost Calc. Type"; Option)
        {
            Caption = 'Landed Cost Calc. Type';
            DataClassification = CustomerContent;
            OptionMembers = " ",Freight,Duty,Insurance,Commission,Packaging,Custom1,Custom2,Custom3;
        }
        field(66001; "Landed Cost"; Boolean)
        {
            Caption = 'Landed Cost';
            DataClassification = CustomerContent;
        }
        field(66002; "Container No."; Code[20])
        {
            Caption = 'Container No.';
            DataClassification = CustomerContent;
            TableRelation = Container;
        }
    }
}
