pageextension 66000 "Purchase Order Subform-LC" extends "Purchase Order Subform"
{
    actions
    {
        addafter("Co&mments")
        {

            action(LandedCostBreakdown)
            {
                ApplicationArea = all;
                caption = 'Landed Cost Breakdown';
                trigger OnAction()
                begin

                end;
            }
        }
    }
}
