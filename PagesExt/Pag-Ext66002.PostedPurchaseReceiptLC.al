pageextension 66002 "Posted Purchase Receipt-LC" extends "Posted Purchase Receipt"
{
    actions
    {
        addafter("Co&mments")
        {
            action("Reverse Landed Cost Accruals")
            {
                trigger OnAction()
                begin

                end;
            }
        }
    }
}
