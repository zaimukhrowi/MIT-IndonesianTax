pageextension 60010 ExtSalesInvoice extends "Sales Invoice"
{
    layout
    {
        addafter(Status)
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
        modify("Document Date")
        {
            trigger OnAfterValidate()
            BEGIN
                Rec.Validate(TAXDATE, Rec."Document Date");
                CurrPage.Update();
            END;
        }
    }
    actions
    {
        addlast("P&osting")
        {
            action("WHT Calculation")
            {
                ToolTip = 'WHT Calculation';
                Caption = 'WHT Calculation';
                ApplicationArea = All;
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Category5;
                trigger OnAction()
                var
                    PPhCode: Codeunit PPhCode;
                    SISubForm: Page "Sales Invoice Subform";
                begin
                    PPhCode.UpdateSalesLineAmount(Rec."No.");
                    SISubForm.Update();
                    SISubForm.CalculateTotals();
                end;
            }
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
                        PpnCode.InsertTaxExcemptionVAT(Rec);
                        Message('Posting Success')
                    end else begin
                        if Rec."Currency Code" = '' then
                            Exch := Exchange.GetExchangeRate(TaxSetup."Export to Currency", GLSetup."LCY Code", Rec."Posting Date")
                        else
                            Exch := Exchange.GetExchangeRate(TaxSetup."Export to Currency", Rec."Currency Code", Rec."Posting Date");
                        PpnCode.InsertTaxExcemptionVATForeignCurrency(Rec, Exch);
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