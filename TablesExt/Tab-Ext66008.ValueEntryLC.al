tableextension 66008 "Value Entry-LC" extends "Value Entry"
{
    fields
    {
        field(66000; "Landed Cost Entry"; Boolean)
        {
            Caption = 'Landed Cost Entry';
            DataClassification = CustomerContent;
        }
        /*
        field(66001; "Landed Cost Entry Type"; Option)
        {
            Caption = 'Landed Cost Entry Type';
            DataClassification = CustomerContent;
            OptionMembers = " ",Accrual,Reversal,Actual,Recharge;
        }
        */
        field(66002; "Landed Cost Doc. Type"; Option)
        {
            Caption = 'Landed Cost Doc. Type';
            DataClassification = CustomerContent;
            OptionMembers = Quote,Order,Invoice,"Credit Memo","Blanket Order","Return Order";
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
        }
        field(66003; "Landed Cost Doc. No."; Code[20])
        {
            Caption = 'Landed Cost Doc. No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Landed Cost Doc. Type" = CONST(Order)) "Purchase Header"."No." WHERE("Document Type" = FIELD("Landed Cost Doc. Type"), "No." = FIELD("Landed Cost Doc. No.")) ELSE
            IF ("Landed Cost Doc. Type" = CONST("Return Order")) "Purchase Header"."No." WHERE("Document Type" = FIELD("Landed Cost Doc. Type"), "No." = FIELD("Landed Cost Doc. No.")) ELSE
            IF ("Landed Cost Doc. Type" = CONST(Invoice)) "Purch. Inv. Header"."No." WHERE("No." = FIELD("Landed Cost Doc. No.")) ELSE
            IF ("Landed Cost Doc. Type" = CONST("Credit Memo")) "Purch. Cr. Memo Hdr."."No." WHERE("No." = FIELD("Landed Cost Doc. No."));
            ValidateTableRelation = false;
        }
    }
}
