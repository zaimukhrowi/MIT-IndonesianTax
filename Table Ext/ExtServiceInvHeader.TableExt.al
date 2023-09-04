tableextension 60023 ExtServiceInvHeader extends "Service Invoice Header"
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
    }

}