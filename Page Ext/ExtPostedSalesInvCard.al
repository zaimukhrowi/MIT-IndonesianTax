pageextension 60031 ExtPostedSalesInvCard extends "Posted Sales Invoice"
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
    actions
    {
        addlast(Correct)
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
                        PpnCode.InsertTaxExcemptionVATfromPostedSI(Rec);
                        Message('Posting Success');
                    end else begin
                        if Rec."Currency Code" = '' then
                            Exch := Exchange.GetExchangeRate(TaxSetup."Export to Currency", GLSetup."LCY Code", Rec."Posting Date")
                        else
                            Exch := Exchange.GetExchangeRate(TaxSetup."Export to Currency", Rec."Currency Code", Rec."Posting Date");
                        PpnCode.InsertTaxExcemptionVATfromPostedSIForeignCurrency(Rec, Exch);
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