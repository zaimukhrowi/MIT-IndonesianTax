query 60007 "Kre Tax Journal per Customer"
{
    QueryType = Normal;

    elements
    {
        dataitem(KRE_TAXJOUR; KRE_TAXJOUR)
        {
            column(ACCOUNTID; ACCOUNTID)
            {

            }
            column(DPPAMOUNT; DPPAMOUNT)
            {
                Method = Sum;
            }
        }
    }

    var
        myInt: Integer;

    trigger OnBeforeOpen()
    begin

    end;
}