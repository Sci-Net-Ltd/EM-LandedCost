page 66003 "System Setup List"
{

    ApplicationArea = All;
    Caption = 'System Setup List';
    PageType = List;
    SourceTable = "System Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Primary Key"; Rec."Primary Key")
                {
                    ApplicationArea = All;
                }
                field("Actualise Landed Cost"; Rec."Actualise Landed Cost")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
