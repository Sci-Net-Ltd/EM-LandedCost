page 66005 "Container Item Charges"
{

    ApplicationArea = All;
    Caption = 'Container Item Charges';
    PageType = List;
    SourceTable = "Container Item Charge";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Container No."; Rec."Container No.")
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Post Accrual Diff. Account"; Rec."Post Accrual Diff. Account")
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
                field("Remaining Accr. LCost (LCY)"; Rec."Remaining Accr. LCost (LCY)")
                {
                    ApplicationArea = All;
                }
                field("G/L Act. Landed Cost (LCY)"; Rec."G/L Act. Landed Cost (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Actual LC Last Posted Date"; Rec."Actual LC Last Posted Date")
                {
                    ApplicationArea = All;
                }
                field("Clear Accrual Differences"; Rec."Clear Accrual Differences")
                {
                    ApplicationArea = All;
                }
                field("Date Accrual Cleared"; Rec."Date Accrual Cleared")
                {
                    ApplicationArea = All;
                }
                field("Accrual Cleared By"; Rec."Accrual Cleared By")
                {
                    ApplicationArea = All;
                }
                field("G/L Posting Only"; Rec."G/L Posting Only")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        LandedCostMgt.ContainerReviewFldVisibility(ShowActualiseFields, ShowNonActualiseFields);
    end;

    trigger OnAfterGetRecord()
    begin
        LCAccrualDiff := LandedCostMgt.ContainerItemChargeReviewCalcFields(Rec);
    end;


    var
        LCAccrualDiff: Decimal;
        SystemSetup: Record "System Setup";
        LandedCostMgt: Codeunit "Landed Cost Mgt.";
        ShowActualiseFields: Boolean;
        ShowNonActualiseFields: Boolean;
}
