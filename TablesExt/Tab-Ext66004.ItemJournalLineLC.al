tableextension 66004 "Item Journal Line-LC" extends "Item Journal Line"
{
    fields
    {
        field(66000; "Landed Cost Entry"; Boolean)
        {
            Caption = 'Landed Cost Entry';
            DataClassification = CustomerContent;
        }
        field(66001; "Landed Cost Entry Type"; Option)
        {
            Caption = 'Landed Cost Entry Type';
            DataClassification = CustomerContent;
            OptionMembers = " ",Accrual,Reversal,Actual,Recharge;
        }
        field(66002; "Target Item Ledger Entry"; Integer)
        {
            Caption = 'Target Item Ledger Entry';
            DataClassification = CustomerContent;
            TableRelation = "Item Ledger Entry"."Entry No." WHERE("Document Type" = FILTER("Sales Shipment" | "Purchase Receipt" | "Sales Credit Memo" | "Sales Return Receipt" | "Purchase Return Shipment"));
        }
        field(66003; "Charge Amount"; Decimal)
        {
            Caption = 'Charge Amount';
            DataClassification = CustomerContent;
        }
        field(66004; "LC Correction"; Boolean)
        {
            Caption = 'LC Correction';
            DataClassification = CustomerContent;
        }
    }
}
