pageextension 60007 ExtPostedPurchInv extends "Posted Purchase Invoices"
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