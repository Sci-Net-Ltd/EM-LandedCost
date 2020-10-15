table 66001 "Landed Cost Lines"
{
    DrillDownPageID = 66000;
    LookupPageID = 66000;

    fields
    {
        field(1; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = IF ("Matrix Line Type" = CONST(Purchase)) "Purchase Header"."No." WHERE("Document Type" = FIELD("Document Type"))
            ELSE
            IF ("Matrix Line Type" = CONST(Sale)) "Sales Header"."No." WHERE("Document Type" = FIELD("Document Type"));
        }
        field(3; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            TableRelation = IF ("Matrix Line Type" = CONST(Purchase)) "Purchase Line"."Line No." WHERE("Document Type" = FIELD("Document Type"),
                                                                                                      "Document No." = FIELD("Document No."))
            ELSE
            IF ("Matrix Line Type" = CONST(Sale)) "Sales Line"."Line No." WHERE("Document Type" = FIELD("Document Type"),
                                                                                                                                                                              "Document No." = FIELD("Document No."));
        }
        field(4; "Matrix Line No."; integer)
        {

        }
        field(10; "Item Charge No."; Code[20])
        {
            Caption = 'Item Charge No.';
            NotBlank = true;
            TableRelation = "Item Charge";

            trigger OnValidate()
            begin
                if ItemCharge.Get("Item Charge No.") then
                    Validate("Gen. Prod. Posting Group", ItemCharge."Gen. Prod. Posting Group");
            end;
        }
        field(11; "Gen. Prod. Posting Group"; Code[10])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";

            trigger OnValidate()
            begin
            end;
        }
        field(15; "Landed Cost Calc. Type"; Option)
        {
            OptionMembers = " ",Freight,Duty,Insurance,Commission,Packaging,Custom1,Custom2,Custom3,Custom4,Custom5,Custom6,Custom7,Custom8,Custom9;
        }
        field(19; "Matrix Line Type"; option)
        {
            OptionMembers = Purchase,Sale," ";
            InitValue = 3;
        }
        field(20; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(25; "Variant Code"; Code[10])
        {
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(30; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(35; "Value Type"; Option)
        {
            OptionMembers = Percentage,Amount;
        }
        field(36; Value; Decimal)
        {
        }
        field(40; "Unit Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost';
        }
        field(50; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';

            trigger OnValidate()
            begin
            end;
        }
        field(60; "Currency Code"; Code[10])
        {
        }
        field(61; "Currency Factor"; Decimal)
        {
        }
        field(70; "Unit Cost (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost (LCY)';
        }
        field(80; "Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount (LCY)';

            trigger OnValidate()
            begin
            end;
        }
        field(200; "Cost Matrix No. Applied"; Integer)
        {
            Editable = false;
            TableRelation = "Landed Cost Matrix"."Entry No.";
        }
    }

    keys
    {
        key(Key1; "Document Type", "Document No.", "Document Line No.", "Item Charge No.")
        {
            Clustered = true;
            SumIndexFields = "Amount (LCY)", Amount;
        }
        key(Key2; "Document Type", "Document No.", "Matrix Line No.", "Item Charge No.")
        {
            SumIndexFields = "Amount (LCY)", Amount;
        }
    }

    fieldgroups
    {
    }

    var
        PurchLine: Record "Purchase Line";
        Currency: Record Currency;
        ItemCharge: Record "Item Charge";
}

