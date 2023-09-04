pageextension 60035 ExtPostedSalesCrMemoCard extends "Posted Sales Credit Memo"
{
    layout
    {
        addafter(Corrective)
        {
            field(RETURN_TAX_NUMBER; Rec.RETURN_TAX_NUMBER)
            {
                ApplicationArea = All;
                Caption = 'Retur Tax Number';
            }
            field(RETURN_DOC_NUMBER; Rec.RETURN_DOC_NUMBER)
            {
                ApplicationArea = All;
                Caption = 'Return Document No';
            }
            field(RETURN_DATE; Rec.RETURN_DATE)
            {
                ApplicationArea = All;
                Caption = 'Retur Date';
            }
        }
    }
    actions
    {
        addlast(Cancel)
        {
            action("Posting PPN")
            {
                ToolTip = 'Posting VAT';
                Caption = 'Posting VAT';
                ApplicationArea = All;
                Image = Post;
                Promoted = true;
                PromotedCategory = Category5;
                trigger OnAction()
                var
                    PpnCode: Codeunit PajakCode;
                    Exch: Decimal;
                begin
                    if TaxSetup."Export to Currency" = '' then
                        Error('Please fill export currency in tax setup');

                    if GLSetup."LCY Code" = TaxSetup."Export to Currency" then begin
                        PpnCode.InsertTaxExcemptionVATfromPostedCrMm(Rec);
                        Message('Posting Success')
                    end else begin
                        if Rec."Currency Code" = '' then
                            Exch := Exchange.GetExchangeRate(TaxSetup."Export to Currency", GLSetup."LCY Code", Rec."Posting Date")
                        else
                            Exch := Exchange.GetExchangeRate(TaxSetup."Export to Currency", Rec."Currency Code", Rec."Posting Date");
                        PpnCode.InsertTaxExcemptionVATfromPostedCrMmForeignCurrency(Rec, Exch);
                        Message('Posting Success');
                    end;
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        TaxSetup.FindFirst();
        GLSetup.Get();
    end;

    var
        TaxSetup: Record Kre_TaxSetup;
        GLSetup: Record "General Ledger Setup";
        Exchange: Codeunit ExchangeRateIDR;
}