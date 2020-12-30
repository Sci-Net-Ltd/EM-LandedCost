table 66002 "Landed Cost Matrix"
{
    DrillDownPageID = 66002;
    LookupPageID = 66002;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Editable = false;
        }
        field(10; "Landed Cost Calc. Type"; Option)
        {
            OptionMembers = " ",Freight,Duty,Insurance,Commission,Packaging,Custom1,Custom2,Custom3,Custom4,Custom5,Custom6,Custom7,Custom8,Custom9;
        }
        field(19; "Matrix Line Type"; Option)
        {
            InitValue = 3;
            OptionCaption = 'Purchase,Sale, ';
            OptionMembers = Purchase,Sale," ";
        }
        field(20; "Transport Method"; Code[20])
        {
            TableRelation = "Transport Method";
        }
        field(25; "Source Country"; Code[20])
        {
            TableRelation = "Country/Region";
        }
        field(30; "Destination Location"; Code[20])
        {
            TableRelation = Location;
        }
        field(40; "Vendor No."; Code[20])
        {
            TableRelation = Vendor;
        }
        field(41; "Customer No."; Code[20])
        {
            TableRelation = Customer;
        }
        field(42; "Brand Code"; Code[20])
        {
            TableRelation = "Brand";
        }
        field(45; "Item No."; Code[20])
        {
            TableRelation = Item;
        }
        field(50; "Tariff/Commodity Code"; Code[20])
        {
            TableRelation = "Tariff Number"."No.";
        }
        field(70; "Item Category Code"; Code[20])
        {
            TableRelation = "Item Category".Code;
        }
        field(90; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(100; Boxed; Boolean)
        {
        }
        field(200; "Value Type"; Option)
        {
            OptionMembers = Percentage,Amount,"Fixed Amount";
            OptionCaption = 'Percentage,Amount,Fixed Amount';
        }
        field(210; Value; Decimal)
        {
            DecimalPlaces = 0 : 5;
            trigger OnValidate()
            begin
                if Value <> 0 then
                    CheckFields();
            end;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Landed Cost Calc. Type", "Vendor No.", "Source Country", "Destination Location", "Transport Method", "Tariff/Commodity Code", "Item No.")
        {
        }
    }

    fieldgroups
    {
    }

    local procedure CheckFields()
    begin
        if ("Transport Method" = '') and
           ("Destination Location" = '') and
           ("Source Country" = '') and
           ("Vendor No." = '') and
           ("Customer No." = '') and
           ("Item Category Code" = '') and
           ("Global Dimension 2 Code" = '') and
           ("Item No." = '') and
           ("Tariff/Commodity Code" = '') and
           (Value <> 0) then
            error('Please provide at least a %1 %2 %3 %4 %5 %6 %7 %8 %9', Rec.FieldCaption("Transport Method"),
                  Rec.FieldCaption("Destination Location"),
                  Rec.FieldCaption("Source Country"),
                  Rec.FieldCaption("Vendor No."),
                  Rec.FieldCaption("Customer No."),
                  Rec.FieldCaption("Item Category Code"),
                  Rec.FieldCaption("Global Dimension 2 Code"),
                  Rec.FieldCaption("Item No."),
                  Rec.FieldCaption("Tariff/Commodity Code"));
    end;
}

