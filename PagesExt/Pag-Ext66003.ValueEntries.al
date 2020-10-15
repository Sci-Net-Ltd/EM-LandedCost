pageextension 66003 ValueEntries extends "Value Entries"
{
    layout
    {
        addafter("Document No.")
        {
            field("Landed Cost Entry"; rec."Landed Cost Entry")
            {
                ApplicationArea = all;
                Editable = false;
            }
            field("Landed Cost Entry Type"; rec."Landed Cost Entry Type")
            {
                ApplicationArea = all;
                Editable = false;
            }
        }
    }
}
