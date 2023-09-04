tableextension 60010 ExtServiceCreditMemo extends "Service Cr.Memo Header"
{
    fields
    {
        field(60000; RETURN_TAX_NUMBER; Code[19])
        {
            Caption = 'Return Tax Number';
        }
        field(60001; RETURN_DOC_NUMBER; Text[50])
        {
            Caption = 'Return Doc Number';
        }
        field(60002; RETURN_DATE; Date)
        {
            Caption = 'Return Date';
        }
    }
}