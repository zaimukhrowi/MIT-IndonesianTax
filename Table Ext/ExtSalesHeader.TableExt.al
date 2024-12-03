tableextension 60007 ExtSalesHeader extends "Sales Header"
{
    fields
    {
        field(60000; TAXNUMBER; Code[19])
        {
            Caption = 'Tax Number';
        }
        field(60001; TAXDATE; Date)
        {
            Caption = 'Tax Date';
        }
        field(60002; RETURN_TAX_NUMBER; Code[19])
        {
            Caption = 'Return Tax Number';
        }
        field(60003; RETURN_DOC_NUMBER; Text[50])
        {
            Caption = 'Return Doc Number';
        }
        field(60004; RETURN_DATE; Date)
        {
            Caption = 'Return Date';
        }

        field(60005; "Subtotal Excl. WHT"; Decimal)
        {
            Caption = 'Subtotal Excl. WHT';
            AutoFormatType = 1;
            CalcFormula = sum("Sales Line"."Line Amount" where("Document Type" = field("Document Type"),
                                                                "Document No." = field("No."),
                                                                IsWHTCalc = const(false)));
            FieldClass = FlowField;
            Editable = false;
        }
        field(60006; "WHT Amount"; Decimal)
        {
            Caption = 'WHT Amount';
            AutoFormatType = 1;
            CalcFormula = sum("Sales Line"."Line Amount" where("Document Type" = field("Document Type"),
                                                                "Document No." = field("No."),
                                                                IsWHTCalc = const(true)));
            FieldClass = FlowField;
            Editable = false;
        }
    }

}