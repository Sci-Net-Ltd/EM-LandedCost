pageextension 66001 "Item Charges-LC" extends "Item Charges"
{
    Caption = 'Item Charges';


    layout
    {

        addafter("Freight/Insurance")
        {
            field("Landed Cost Calc. Type"; rec."Landed Cost Calc. Type")
            {
                ApplicationArea = all;
            }
            field("Matrix Line Type"; rec."Matrix Line Type")
            {
                ApplicationArea = all;
            }
            field("Post Accrual Diff. Account"; rec."Post Accrual Diff. Account")
            {
                ApplicationArea = all;
            }
            field("Accrued Landed Cost (LCY)"; rec."Accrued Landed Cost (LCY)")
            {
                ApplicationArea = all;
            }
            field("Actual Landed Cost (LCY)"; rec."Actual Landed Cost (LCY)")
            {
                ApplicationArea = all;
            }
            field("Remaining Accr. LCost (LCY)"; rec."Remaining Accr. LCost (LCY)")
            {
                ApplicationArea = all;
            }
            field("G/L Act. Landed Cost (LCY)"; rec."G/L Act. Landed Cost (LCY)")
            {
                ApplicationArea = all;
            }
        }
    }
    actions
    {
        addafter(Dimensions)
        {
            action("Setup Landed Cost Matrix")
            {
                ApplicationArea = all;
                trigger OnAction()
                begin

                end;
            }
        }
    }
}
