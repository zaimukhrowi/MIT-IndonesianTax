query 60000 KreSalesLineWHT
{
    QueryType = Normal;
    Caption = 'Sales Line WHT';

    elements
    {
        dataitem(Sales_Line; "Sales Line")
        {
            filter(Document_No_; "Document No.")
            { }
            filter(IsWHTCalc; IsWHTCalc)
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
            column(Bill_to_Customer_No_; "Bill-to Customer No.")
            { }
            column(Sell_to_Customer_No_; "Sell-to Customer No.")
            { }
            column(Shipment_Date; "Shipment Date")
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
            column(Sum_Line_Amount; WHTAmount)
            {
                Method = Sum;
            }
            column(Sum_Line_Amount_Additional_Currency; "WHTAmount Additional Currency")
            {
                Method = Sum;
            }
            dataitem(Kre_MasterPPh; Kre_MasterPPh)
            {
                DataItemLink = PPhCode = Sales_Line.WHTProductPostingGroup;
                SqlJoinType = InnerJoin;
                column(Sales_WHT_Account; "Sales WHT Account")
                { }
                dataitem(G_L_Account; "G/L Account")
                {
                    DataItemLink = "No." = Kre_MasterPPh."Sales WHT Account";
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