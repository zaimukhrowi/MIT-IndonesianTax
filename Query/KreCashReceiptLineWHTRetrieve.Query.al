query 60004 KreCashReceiptLineWHTRetrieve
{
    QueryType = Normal;
    Caption = 'Cash Receipt Line WHT Retrieve';

    elements
    {
        dataitem(Sales_Invoice_Line; "Sales Invoice Line")
        {
            filter(Document_No_; "Document No.")
            { }
            column(Dimension_Set_ID; "Dimension Set ID")
            { }
            column(WHTProductPostingGroup; WHTProductPostingGroup)
            { }
            column(WHTPercentage; WHTPercentage)
            { }
            column(Posting_Date; "Posting Date")
            { }
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
                DataItemLink = PPhCode = Sales_Invoice_Line.WHTProductPostingGroup;
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