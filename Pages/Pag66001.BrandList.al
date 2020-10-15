page 66001 "Brand List"
{

    ApplicationArea = All;
    Caption = 'Brand List';
    PageType = List;
    SourceTable = "Brand";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Brand Code"; Rec."Brand Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
