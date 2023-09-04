query 60002 KreCashReceiptLineWHT
{
    QueryType = Normal;
    Caption = 'Cash Receipt Line WHT';

    elements
    {
        dataitem(Gen__Journal_Line; "Gen. Journal Line")
        {
            // DataItemTableFilter = "Journal Template Name" = filter('CASHRCPT'), "Source Code" = filter('CASHRECJNL'), "Journal Batch Name" = filter('GENERAL');
            filter(Document_No_; "Document No.")
            { }
            filter(IsWHTCalc; IsWHTCalc)
            { }
            column(Dimension_Set_ID; "Dimension Set ID")
            { }
            column(Document_Type; "Document Type")
            { }
            column(Account_No_; "Account No.")
            { }
            column(Account_Type; "Account Type")
            { }
            column(WHTProductPostingGroup; WHTProductPostingGroup)
            { }
            column(WHTPercentage; WHTPercentage)
            { }
            // column(Unit_Of_Measure_Code; "Job Unit Of Measure Code")
            // { }
            column(Source_Code; "Source Code")
            { }
            column(Journal_Template_Name; "Journal Template Name")
            { }
            column(Journal_Batch_Name; "Journal Batch Name")
            { }
            column(Posting_Date; "Posting Date")
            { }
            // column(Description; Description)
            // { }
            column(Currency_Code; "Currency Code")
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
                DataItemLink = PPhCode = Gen__Journal_Line.WHTProductPostingGroup;
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