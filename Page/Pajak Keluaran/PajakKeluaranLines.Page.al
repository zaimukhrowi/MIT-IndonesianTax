page 60009 PajakKeluaranLines
{
    PageType = ListPart;
    SourceTable = KRE_TAXJOURLINES;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    Caption = 'Pajak Keluaran Lines';

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(INVOICELINENO; Rec.INVOICELINENO)
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field(INVOICENO; Rec.INVOICENO)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(TYPE; Rec.TYPE)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(ITEMID; Rec.ITEMID)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(DESCRIPTION; Rec.DESCRIPTION)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(VAT_Bus_Posting_Group; Rec.VAT_Bus_Posting_Group)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(VAT_Prod_Posting_Group; Rec.VAT_Prod_Posting_Group)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(VAT_Identifier; Rec.VAT_Identifier)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(PRICE; Rec.PRICE)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(QTY; Rec.QTY)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(TOTAL_AMOUNT; Rec.TOTAL_AMOUNT)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(DISCOUNT_AMOUNT; Rec.DISCOUNT_AMOUNT)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(DPP_AMOUNT; Rec.DPP_AMOUNT)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(VAT_AMOUNT; Rec.VAT_AMOUNT)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

}