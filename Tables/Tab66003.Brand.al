table 66003 "Brand"
{
    Caption = 'Brand';
    DataClassification = ToBeClassified;
    DrillDownPageID = 66001;
    LookupPageID = 66001;
    fields
    {
        field(1; "Brand Code"; Code[20])
        {
            Caption = 'Brand Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Brand Code")
        {
            Clustered = true;
        }
    }

}
