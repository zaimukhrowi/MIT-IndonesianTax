pageextension 60012 ExtPostedSalesCrMemo extends "Posted Sales Credit Memos"
{
    layout
    {
        addafter(Corrective)
        {
            field(RETURN_TAX_NUMBER; Rec.RETURN_TAX_NUMBER)
            {
                ApplicationArea = All;
                Caption = 'Return Tax Number';
            }
            field(RETURN_DOC_NUMBER; Rec.RETURN_DOC_NUMBER)
            {
                ApplicationArea = All;
                Caption = 'Return Doc Number';
            }
            field(RETURN_DATE; Rec.RETURN_DATE)
            {
                ApplicationArea = All;
                Caption = 'Return Date';
            }

        }
    }
}