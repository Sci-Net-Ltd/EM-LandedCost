page 66002 "Landed Cost Matrix"
{

    ApplicationArea = All;
    Caption = 'Landed Cost Matrix';
    PageType = List;
    SourceTable = "Landed Cost Matrix";
    UsageCategory = Lists;
    PopulateAllFields = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Landed Cost Calc. Type"; Rec."Landed Cost Calc. Type")
                {
                    ApplicationArea = All;
                }
                field("Transport Method"; Rec."Transport Method")
                {
                    ApplicationArea = All;
                }
                field("Destination Location"; Rec."Destination Location")
                {
                    ApplicationArea = All;
                }
                field("Source Country"; Rec."Source Country")
                {
                    ApplicationArea = All;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Tariff/Commodity Code"; Rec."Tariff/Commodity Code")
                {
                    ApplicationArea = All;
                }
                field("Value Type"; Rec."Value Type")
                {
                    ApplicationArea = All;
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                }
                field(Boxed; Rec.Boxed)
                {
                    ApplicationArea = All;
                }
                field("Matrix Line Type"; Rec."Matrix Line Type")
                {
                    ApplicationArea = All;
                }
                field("Brand Code"; Rec."Brand Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
