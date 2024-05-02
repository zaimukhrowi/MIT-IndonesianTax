pageextension 60019 ExtSalesOrderLine extends "Sales Order Subform"
{
    layout
    {
        modify("Unit Price")
        {
            trigger OnAfterValidate()
            begin
                SetWHTAmount(Rec);
                CurrPage.Update();
            end;
        }
        modify(Quantity)
        {
            trigger OnAfterValidate()
            begin
                SetWHTAmount(Rec);
                CurrPage.Update();
            end;
        }
        addafter("Shipment Date")
        {
            field(WHTProductPostingGroup; Rec.WHTProductPostingGroup)
            {
                ApplicationArea = All;
                Caption = 'WHT Product Posting Group';
                ToolTip = 'WHT Product Posting Group';
                trigger OnValidate()
                var
                    Kre_MasterPPh: Record Kre_MasterPPh;
                    Customer: Record Customer;
                begin
                    if Customer.Get(rec."Sell-to Customer No.") then
                        if Customer.ISNPWP then begin
                            if Kre_MasterPPh.Get(Rec.WHTProductPostingGroup) then begin
                                Rec.WHTPercentage := Kre_MasterPPh."Percentage";
                                CurrPage.Update();
                                SetWHTAmount(Rec);
                            end;
                        end else begin
                            if Kre_MasterPPh.Get(Rec.WHTProductPostingGroup) then begin
                                Rec.WHTPercentage := Kre_MasterPPh."Percentage Up";
                                CurrPage.Update();
                                SetWHTAmount(Rec);
                            end;
                        end;
                    CalculateTotals();
                end;
            }
            field(WHTPercentage; Rec.WHTPercentage)
            {
                Caption = 'WHT Percentage (%)';
                ToolTip = 'WHT Percentage (%)';
                ApplicationArea = All;
                //Editable = false;
                trigger OnValidate()
                begin
                    SetWHTAmount(Rec);
                    CurrPage.Update();
                end;
            }
            field(WHTAmount; Rec.WHTAmount)
            {
                Caption = 'WHT Amount';
                ToolTip = 'WHT Amount';
                ApplicationArea = All;
                //Editable = false;
            }
            field("WHTAmount Additional Currency"; Rec."WHTAmount Additional Currency")
            {
                Caption = 'WHT Amount Additional Currency';
                ToolTip = 'WHT Amount Additional Currency';
                ApplicationArea = All;
            }
            field("Is TaxExemption"; Rec."Is TaxExemption")
            {
                Caption = 'Is Tax Exemption VAT';
                ToolTip = 'Is Tax Exemption VAT';
                ApplicationArea = All;
                trigger OnValidate()
                begin
                    if Rec."Is TaxExemption" then
                        IsEditable := true
                    else begin
                        IsEditable := false;
                        Rec."Tax Exemption Percentage" := 0;
                        Rec."Tax Exemption Amount" := 0;
                    end;
                    CurrPage.Update();
                end;
            }
            field("Tax Exemption Percentage"; Rec."Tax Exemption Percentage")
            {
                Caption = 'Tax Exemption VAT (%)';
                ToolTip = 'Tax Exemption VAT (%)';
                ApplicationArea = All;
                Editable = IsEditable;

                trigger OnValidate()
                begin
                    if Rec."Tax Exemption Percentage" > 0 then
                        Rec."Tax Exemption Amount" := (Rec."Tax Exemption Percentage") / 100 * Rec.Amount;
                    CurrPage.Update();
                end;
            }
            field("Tax Exemption Amount"; Rec."Tax Exemption Amount")
            {
                Caption = 'Tax Exemption VAT Amount ';
                ToolTip = 'Tax Exemption VAT Amount';
                ApplicationArea = All;
                Editable = false;
            }
        }
    }
    local procedure SetWHTAmount(var SL: Record "Sales Line")
    begin
        TaxSetup.FindFirst();
        if TaxSetup."Export to Currency" = '' then
            Error('Please fill export currency in tax setup');

        SH.Get(SL."Document Type", SL."Document No.");
        if Rec.WHTProductPostingGroup <> '' then begin
            if GLSetup."LCY Code" = TaxSetup."Export to Currency" then begin
                SL.WHTAmount := (SL.WHTPercentage / 100) * SL."Line Amount";
                SL."WHTAmount Additional Currency" := ((SL.WHTPercentage / 100) * SL."Line Amount");
            end else begin
                // Additional Currency
                SL.WHTAmount := (SL.WHTPercentage / 100) * SL."Unit Price" * Rec.Quantity;
                if SH."Currency Code" = TaxSetup."Export to Currency" then begin
                    SL."WHTAmount Additional Currency" := ((SL.WHTPercentage / 100) * SL."Line Amount");
                    CurFac := SH."Currency Factor";
                end else begin
                    if SH."Currency Code" = '' then begin
                        CurFac := Exchange.GetExchangeRate(TaxSetup."Export to Currency", GLSetup."LCY Code", SH."Posting Date");
                        SL."WHTAmount Additional Currency" := ((SL.WHTPercentage / 100) * SL."Line Amount") / Exchange.GetExchangeRate(TaxSetup."Export to Currency", GLSetup."LCY Code", SH."Posting Date");
                    end else begin
                        CurFac := Exchange.GetExchangeRate(TaxSetup."Export to Currency", SL."Currency Code", SH."Posting Date");
                        SL."WHTAmount Additional Currency" := ((SL.WHTPercentage / 100) * SL."Line Amount") / Exchange.GetExchangeRate(TaxSetup."Export to Currency", SL."Currency Code", SH."Posting Date");
                    end;

                end;
            end;
            SL.Modify();
        end;
    end;

    trigger OnOpenPage()
    begin
        TaxSetup.FindFirst();
        GLSetup.Get();
    end;

    var
        TaxSetup: Record Kre_TaxSetup;
        GLSetup: Record "General Ledger Setup";
        IsEditable: Boolean;
        SH: Record "Sales Header";
        Exchange: Codeunit ExchangeRateIDR;
        CurFac: Decimal;
}