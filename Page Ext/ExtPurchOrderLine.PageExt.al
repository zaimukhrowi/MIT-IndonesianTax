pageextension 60022 ExtPurchOrderLine extends "Purchase Order Subform"
{
    layout
    {
        modify("Direct Unit Cost")
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
        addafter("Expected Receipt Date")
        {
            field(WHTProductPostingGroup; Rec.WHTProductPostingGroup)
            {
                ApplicationArea = All;
                Caption = 'WHT Product Posting Group';
                ToolTip = 'WHT Product Posting Group';
                trigger OnValidate()
                var
                    Kre_MasterPPh: Record Kre_MasterPPh;
                    Vendor: Record Vendor;
                begin
                    if Vendor.Get(rec."Buy-from Vendor No.") then
                        if Vendor.ISNPWP then begin
                            if Kre_MasterPPh.Get(Rec.WHTProductPostingGroup) then begin
                                Rec.WHTPercentage := Kre_MasterPPh.Percentage;
                                CurrPage.Update();
                                SetWHTAmount(Rec);
                            end;
                        end else begin
                            if Kre_MasterPPh.Get(Rec.WHTProductPostingGroup) then begin
                                Rec.WHTPercentage := Kre_MasterPPh."Percentage Up";
                                CurrPage.Update();
                                SetWHTAmount(Rec);
                                //Rec."Gross Up" := true;
                            end;
                        end;
                    CalculateTotals();
                end;
            }
            field("Gross Up"; Rec."Gross Up")
            {
                Caption = 'Gross Up';
                ToolTip = 'Gross Up';
                ApplicationArea = All;
                // trigger OnValidate()
                // var
                //     Kre_MasterPPh: Record Kre_MasterPPh;
                // begin
                //     if rec."Gross Up" = false then begin
                //         if Kre_MasterPPh.Get(Rec.WHTProductPostingGroup) then begin
                //             Rec.WHTPercentage := Kre_MasterPPh.Percentage;
                //             Rec.WHTAmount := (Rec.WHTPercentage / 100) * Rec."Line Amount";
                //         end;
                //     end else begin
                //         if Kre_MasterPPh.Get(Rec.WHTProductPostingGroup) then begin
                //             Rec.WHTPercentage := Kre_MasterPPh."Percentage Up";
                //             Rec.WHTAmount := (Rec.WHTPercentage / 100) * Rec."Line Amount";
                //         end;
                //     end;
                //     CurrPage.Update();
                //     CalculateTotals();
                // end;
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
                Caption = 'Is Tax Exemption WHT';
                ToolTip = 'Is Tax Exemption WHT';
                ApplicationArea = All;
            }
        }
    }
    local procedure SetWHTAmount(var SL: Record "Purchase Line")
    begin
        if TaxSetup."Export to Currency" = '' then
            Error('Please fill export currency in tax setup');

        SH.Get(SL."Document Type", SL."Document No.");
        if Rec.WHTProductPostingGroup <> '' then begin
            if GLSetup."LCY Code" = TaxSetup."Export to Currency" then begin
                SL.WHTAmount := (SL.WHTPercentage / 100) * SL."Line Amount";
                SL."WHTAmount Additional Currency" := ((SL.WHTPercentage / 100) * SL."Line Amount");
            end else begin
                // Additional Currency
                SL.WHTAmount := (SL.WHTPercentage / 100) * SL."Unit Cost" * Rec.Quantity;
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
        SH: Record "Purchase Header";
        Exchange: Codeunit ExchangeRateIDR;
        CurFac: Decimal;
}