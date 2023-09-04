pageextension 60013 ExtPostedSalesInv extends "Posted Sales Invoices"
{
    layout
    {
        addafter(Corrective)
        {
            field(TAXNUMBER; Rec.TAXNUMBER)
            {
                ApplicationArea = All;
                Caption = 'Tax Number';
            }
            field(TAXDATE; Rec.TAXDATE)
            {
                ApplicationArea = All;
                Caption = 'Tax Date';
            }
        }

    }
}