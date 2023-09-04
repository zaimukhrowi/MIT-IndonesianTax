tableextension 60006 ExtSalesCrMemoHeader extends "Sales Cr.Memo Header"
{
    fields
    {
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
    }

}