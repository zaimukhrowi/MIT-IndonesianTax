pageextension 60009 ExtSalesOrder extends "Sales Order"
{
    layout
    {
        addafter(Status)
        {
            field("Subtotal Excl. WHT"; Rec."Subtotal Excl. WHT")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Subtotal Excl. WHT" field.';
            }
            field("WHT Amount"; WHTAmount)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the WHT Amount field.';
                Editable = false;

                trigger OnDrillDown()
                var
                    SalesLine: Record "Sales Line";
                begin
                    SalesLine.SetRange("Document Type", Rec."Document Type");
                    SalesLine.SetRange("Document No.", Rec."No.");
                    SalesLine.SetRange(IsWHTCalc, true);
                    if not SalesLine.IsEmpty then
                        Page.Run(Page::"Sales Lines", SalesLine);
                end;
            }
            field(TAXNUMBER; Rec.TAXNUMBER)
            {
                ApplicationArea = All;
                Caption = 'Tax Number';
                ToolTip = 'Tax Number';
            }
            field(TAXDATE; Rec.TAXDATE)
            {
                ApplicationArea = All;
                Caption = 'Tax Date';
                ToolTip = 'Tax Date';
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
                PromotedCategory = Category6;
                trigger OnAction()
                var
                    PPhCode: Codeunit PPhCode;
                    SOSubForm: Page "Sales Order Subform";
                begin
                    PPhCode.UpdateSalesLineAmount(Rec."No.");
                    SOSubForm.Update();
                    SOSubForm.CalculateTotals();
                end;
            }
            action("Posting PPN")
            {
                ToolTip = 'Posting VAT';
                Caption = 'Posting VAT';
                ApplicationArea = All;
                Image = Post;
                Promoted = true;
                PromotedCategory = Category6;
                trigger OnAction()
                var
                    PpnCode: Codeunit PajakCode;
                    Exch: Decimal;
                begin
                    TaxSetup.FindFirst();
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


    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("WHT Amount");
        WHTAmount := Abs(Rec."WHT Amount");
    end;

    var
        WHTAmount: Decimal;
        TaxSetup: Record Kre_TaxSetup;
        GLSetup: Record "General Ledger Setup";
        Exchange: Codeunit ExchangeRateIDR;

}