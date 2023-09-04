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
        // field(60005; "Tax Exemption Amount"; Decimal)
        // {
        //     AutoFormatExpression = "Currency Code";
        //     AutoFormatType = 1;
        //     CalcFormula = Sum("Sales Line"."Tax Exemption Amount" WHERE("Document Type" = FIELD("Document Type"),
        //                                                  "Document No." = FIELD("No."),
        //                                                  "Is TaxExemption" = const(true)));
        //     Caption = 'Tax Exemption Amount';
        //     Editable = false;
        //     FieldClass = FlowField;
        // }
        // field(60006; "Exemption Amount"; Decimal)
        // {
        //     AutoFormatExpression = "Currency Code";
        //     AutoFormatType = 1;
        //     CalcFormula = Sum("Sales Line".Amount WHERE("Document Type" = FIELD("Document Type"),
        //                                                  "Document No." = FIELD("No."),
        //                                                  "Is TaxExemption" = const(true)));
        //     Caption = 'Amount';
        //     Editable = false;
        //     FieldClass = FlowField;
        // }
    }

}