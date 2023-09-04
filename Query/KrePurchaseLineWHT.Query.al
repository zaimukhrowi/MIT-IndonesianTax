query 60001 KrePurchaseLineWHT
{
    QueryType = Normal;
    Caption = 'Purchase Line WHT';

    elements
    {
        dataitem(Purchase_Line; "Purchase Line")
        {
            filter(Document_No_; "Document No.")
            { }
            filter(IsWHTCalc; IsWHTCalc)
            { }
            filter(IsGrossUp; "Gross Up")
            { }
            column(Dimension_Set_ID; "Dimension Set ID")
            { }
            column(Document_Type; "Document Type")
            { }
            column(No_; "No.")
            { }
            column(Type; Type)
            { }
            column(WHTProductPostingGroup; WHTProductPostingGroup)
            { }
            column(WHTPercentage; WHTPercentage)
            { }
            column(Unit_of_Measure_Code; "Unit of Measure Code")
            { }
            column(Currency_Code; "Currency Code")
            { }
            column(Buy_from_Vendor_No_; "Buy-from Vendor No.")
            { }
            column(Pay_to_Vendor_No_; "Pay-to Vendor No.")
            { }
            column(Planned_Receipt_Date; "Planned Receipt Date")
            { }
            column(Gen__Bus__Posting_Group; "Gen. Bus. Posting Group")
            { }
            column(Gen__Prod__Posting_Group; "Gen. Prod. Posting Group")
            { }
            column(VAT_Bus__Posting_Group; "VAT Bus. Posting Group")
            { }
            column(VAT_Prod__Posting_Group; "VAT Prod. Posting Group")
            { }
            // column(Description; Description)
            // { }
            column(Sum_Line_Amount; "WHTAmount")
            {
                Method = Sum;
            }
            column(Sum_Line_Amount_Additional_Currency; "WHTAmount Additional Currency")
            {
                Method = Sum;
            }
            column(Sum_Amount; Amount)
            {
                Method = Sum;
            }
            dataitem(Kre_MasterPPh; Kre_MasterPPh)
            {
                DataItemLink = PPhCode = Purchase_Line.WHTProductPostingGroup;
                SqlJoinType = InnerJoin;
                column(Purchase_WHT_Account; "Purchase WHT Account")
                { }
                dataitem(G_L_Account; "G/L Account")
                {
                    DataItemLink = "No." = Kre_MasterPPh."Purchase WHT Account";
                    SqlJoinType = LeftOuterJoin;
                    column(G_L_Account_Name; Name)
                    { }
                }
            }

        }
    }
    trigger OnBeforeOpen()
    begin
        currQuery.SetFilter(WHTProductPostingGroup, '<> %1', '');
    end;
}