page 66004 "Finance Review Container List"
{

    ApplicationArea = All;
    Caption = 'Finance Review Container List';
    PageType = List;
    SourceTable = Container;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("External Container Ref."; Rec."External Container Ref.")
                {
                    ApplicationArea = All;
                }
                field("Shipping Status"; Rec."Shipping Status")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Container Type"; Rec."Container Type")
                {
                    ApplicationArea = All;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Freight Forwarder"; Rec."Freight Forwarder")
                {
                    ApplicationArea = All;
                }
                field("Vessel Name"; Rec."Vessel Name")
                {
                    ApplicationArea = All;
                }
                field("Exit Port"; Rec."Exit Port")
                {
                    ApplicationArea = All;
                }
                field("Destination Port"; Rec."Destination Port")
                {
                    ApplicationArea = All;
                }
                field("ETD Date"; Rec."ETD Date")
                {
                    ApplicationArea = All;
                }
                field("ETA Date"; Rec."ETA Date")
                {
                    ApplicationArea = All;
                }
                field("Delivery Date"; Rec."Delivery Date")
                {
                    ApplicationArea = All;
                }
                field("Delivery Time"; Rec."Delivery Time")
                {
                    ApplicationArea = All;
                }
                field("Total Qty in Container"; Rec."Total Qty in Container")
                {
                    ApplicationArea = All;
                }
                field("Actual Receipted Qty."; Rec."Actual Receipted Qty.")
                {
                    ApplicationArea = All;
                }
                field("Accrued Landed Cost (LCY)"; Rec."Accrued Landed Cost (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Actual Landed Cost (LCY)"; Rec."Actual Landed Cost (LCY)")
                {
                    ApplicationArea = All;
                }
                field("G/L Act. Landed Cost (LCY)"; Rec."G/L Act. Landed Cost (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Remaining Accr. LCost (LCY)"; Rec."Remaining Accr. LCost (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Actual LC Last Posted Date"; Rec."Actual LC Last Posted Date")
                {
                    ApplicationArea = All;
                }
                field("Post Accrual Differences"; Rec."Post Accrual Differences")
                {
                    ApplicationArea = All;
                }
                field("Stock Intransit Amount"; Rec."Stock Intransit Amount")
                {
                    ApplicationArea = All;
                }
                field("Stock Intransit Amount (LCY)"; Rec."Stock Intransit Amount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Stock Intransit Qty."; Rec."Stock Intransit Qty.")
                {
                    ApplicationArea = All;
                }
                field("Total Weight in Container"; Rec."Total Weight in Container")
                {
                    ApplicationArea = All;
                }
                field("Total Cubage in Container"; Rec."Total Cubage in Container")
                {
                    ApplicationArea = All;
                }
                field("Total Value in Container"; Rec."Total Value in Container")
                {
                    ApplicationArea = All;
                }
                field("Total Value In Currency"; Rec."Total Value In Currency")
                {
                    ApplicationArea = All;
                }
                field("Total No. Of Cartons"; Rec."Total No. Of Cartons")
                {
                    ApplicationArea = All;
                }
                field("No. Of Cartons (Advised)"; Rec."No. Of Cartons (Advised)")
                {
                    ApplicationArea = All;
                }
                field("Transport Method"; Rec."Transport Method")
                {
                    ApplicationArea = All;
                }
                field("Transport Reason Code"; Rec."Transport Reason Code")
                {
                    ApplicationArea = All;
                }
                field("In Cashflow"; Rec."In Cashflow")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Review Landed Costs")
            {
                trigger OnAction()
                begin

                end;
            }
        }
    }
}
