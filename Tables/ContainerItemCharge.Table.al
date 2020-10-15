table 66000 "Container Item Charge"
{

    fields
    {
        field(1; "Container No."; Code[20])
        {
            Editable = false;
        }
        field(2; "No."; Code[20])
        {
            Editable = false;
            TableRelation = "Item Charge";
        }
        field(66000; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
        }
        field(66001; "Post Accrual Diff. Account"; Code[20])
        {
            CalcFormula = Lookup("Item Charge"."Post Accrual Diff. Account" WHERE("No." = FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
            TableRelation = "G/L Account";
        }
        field(66002; "Accrued Landed Cost (LCY)"; Decimal)
        {
            CalcFormula = Sum("Value Entry"."Cost Amount (Actual)" WHERE("Container No." = FIELD("Container No."),
                                                                          "Item Charge No." = FIELD("No."),
                                                                          "Landed Cost Entry Type" = FILTER(Accrual),
                                                                          "Posting Date" = FIELD("Date Filter")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(66003; "Actual Landed Cost (LCY)"; Decimal)
        {
            CalcFormula = Sum("Value Entry"."Cost Amount (Actual)" WHERE("Container No." = FIELD("Container No."),
                                                                          "Item Charge No." = FIELD("No."),
                                                                          "Landed Cost Entry Type" = FILTER(Actual),
                                                                          "Posting Date" = FIELD("Date Filter")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(66004; "Remaining Accr. LCost (LCY)"; Decimal)
        {
            CalcFormula = Sum("Value Entry"."Cost Amount (Actual)" WHERE("Container No." = FIELD("Container No."),
                                                                          "Item Charge No." = FIELD("No."),
                                                                          "Landed Cost Entry Type" = FILTER(Accrual | Reversal),
                                                                          "Posting Date" = FIELD("Date Filter")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(66005; "G/L Posting Only"; Boolean)
        {
            Editable = false;
        }
        field(66006; "Actual LC Last Posted Date"; Date)
        {
            CalcFormula = Max("Purch. Inv. Line"."Posting Date" WHERE(Type = FILTER("Charge (Item)"),
                                                                       "No." = FIELD("No."),
                                                                       "Container No." = FIELD("Container No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(66007; "G/L Act. Landed Cost (LCY)"; Decimal)
        {
            CalcFormula = Sum("G/L Entry".Amount WHERE("Container No." = FIELD("Container No."), "Item Charge No." = FIELD("No."), "Posting Date" = FIELD("Date Filter")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(66008; "Clear Accrual Differences"; Boolean)
        {
            trigger OnValidate()
            begin
                if "Clear Accrual Differences" then begin
                    "Date Accrual Cleared" := WorkDate;
                    "Accrual Cleared By" := UserId;
                end else begin
                    "Date Accrual Cleared" := 0D;
                    "Accrual Cleared By" := '';
                end;
            end;
        }
        field(66009; "Date Accrual Cleared"; Date)
        {
            Editable = false;
        }
        field(66010; "Accrual Cleared By"; Text[50])
        {
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Container No.", "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

