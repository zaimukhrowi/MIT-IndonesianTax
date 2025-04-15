query 60006 KreVATEntryForeignCurrency
{
    QueryType = Normal;
    Caption = 'VAT Entry';
    Permissions = TableData "VAT Entry" = RM;
    // TopNumberOfRows = 10;

    elements
    {
        dataitem(VAT_Entry; "VAT Entry")
        {
            DataItemTableFilter = Is_Synch = filter(false), "Type" = filter('<> 0 '), Amount = filter('<> 0 '), "VAT Prod. Posting Group" = filter(<> '');//, "Bill-to/Pay-to No." = filter('<> ''');
            filter(Posting_Date; "Posting Date") { }
            column("Type"; Type)
            { }
            column(Document_No_; "Document No.")
            { }
            column(Document_Date; "Document Date")
            { }
            column(External_Document_No_; "External Document No.")
            { }
            column(VAT_Bus__Posting_Group; "VAT Bus. Posting Group")
            { }
            column(VAT_Calculation_Type; "VAT Calculation Type")
            { }
            column(VAT_Prod__Posting_Group; "VAT Prod. Posting Group")
            { }
            column(Document_Type; "Document Type")
            { }
            column(Bill_to_Pay_to_No_; "Bill-to/Pay-to No.")
            { }
            column(Base; "Additional-Currency Base")
            { }
            column(Amount; "Additional-Currency Amount")
            { }
            column(BaseIDR; Base)
            { }
            column(AmountIDR; Amount)
            { }
            column(Is_Synch; Is_Synch)
            { }

        }
    }
}