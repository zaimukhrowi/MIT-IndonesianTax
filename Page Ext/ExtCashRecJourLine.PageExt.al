pageextension 60025 ExtCashRecJourLine extends "Cash Receipt Journal"
{
    layout
    {
        modify("Amount")
        {
            trigger OnAfterValidate()
            begin
                SetWHTAmount(Rec);
                CurrPage.Update();
            end;
        }
        addafter("Credit Amount")
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
                    Vendor: Record Vendor;
                begin
                    if Rec."Account Type" = Rec."Account Type"::Vendor then
                        if Vendor.Get(Rec."Account No.") then
                            if Vendor.ISNPWP then begin
                                if Kre_MasterPPh.Get(rec.WHTProductPostingGroup) then begin
                                    Rec.WHTPercentage := Kre_MasterPPh.Percentage;
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

                    if Rec."Account Type" = Rec."Account Type"::Customer then
                        if Customer.Get(Rec."Account No.") then
                            if Customer.ISNPWP then begin
                                if Kre_MasterPPh.Get(rec.WHTProductPostingGroup) then begin
                                    Rec.WHTPercentage := Kre_MasterPPh."Percentage";
                                    SetWHTAmountCustomer(Rec);
                                end;
                            end else begin
                                if Kre_MasterPPh.Get(Rec.WHTProductPostingGroup) then begin
                                    Rec.WHTPercentage := Kre_MasterPPh."Percentage Up";
                                    CurrPage.Update();
                                    SetWHTAmountCustomer(Rec);
                                end;
                            end;
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

            field("WHT Source Type"; Rec."WHT Source Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the WHT Source Type field.';
                Caption = 'WHT Source Type';
            }
            field("WHT Source No."; Rec."WHT Source No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the WHT Source No. field.';
                Caption = 'WHT Source No.';
            }
            field("WHT Source Document No."; Rec."WHT Source Document No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the WHT Source Document No. field.';
                Caption = 'WHT Source Document No.';
            }

        }
    }
    actions
    {
        addlast(processing)
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
                begin
                    PPhCode.UpdateGenJourLineAmount(Rec."Document No.");
                    CurrPage.Update();
                end;
            }
            action("Retrieve WHT")
            {
                ToolTip = 'Retrieve WHT';
                Caption = 'Retrieve WHT';
                ApplicationArea = All;
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Category6;
                trigger OnAction()
                var
                    PPhCode: Codeunit PPhCode;
                begin
                    PPhCode.UpdateGenJourLineAmountRetrieve(Rec."Document No.", Rec."Journal Template Name", Rec."Journal Batch Name", Rec."Source Code", Rec."Applies-to Doc. No.");
                    CurrPage.Update();
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        GLSetup.Get();
        TaxSetup.FindFirst();
    end;

    local procedure SetWHTAmount(var GJL: Record "Gen. Journal Line")
    begin
        if Rec.WHTProductPostingGroup <> '' then begin
            if GLSetup."LCY Code" = TaxSetup."Export to Currency" then
                GJL.WHTAmount := (GJL.WHTPercentage / 100) * System.Abs(GJL."Amount")
            else begin
                // Additional Currency
                if GJL."Currency Code" = TaxSetup."Export to Currency" then begin
                    GJL.WHTAmount := (GJL.WHTPercentage / 100) * System.Abs(GJL."Amount (LCY)");
                    GJL."WHTAmount Additional Currency" := ((GJL.WHTPercentage / 100) * System.Abs(GJL."Amount")) * GJL."Currency Factor";
                end else begin
                    GJL.WHTAmount := (GJL.WHTPercentage / 100) * System.Abs(GJL."Amount");
                    GJL."WHTAmount Additional Currency" := ((GJL.WHTPercentage / 100) * System.Abs(GJL."Amount (LCY)")) * Exchange.GetExchangeRate(TaxSetup."Export to Currency", GJL."Currency Code", GJL."Posting Date");
                end;
            end;
            GJL.Modify();
        end;
    end;

    local procedure SetWHTAmountCustomer(var GJL: Record "Gen. Journal Line")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        if Rec.WHTProductPostingGroup <> '' then
            if Rec."Applies-to Doc. No." = '' then
                SetWHTAmount(Rec)
            else begin
                SalesInvoiceLine.SetRange("Document No.", Rec."Applies-to Doc. No.");
                SalesInvoiceLine.SetRange("WHT Applicable", true);
                if not SalesInvoiceLine.IsEmpty then begin
                    SalesInvoiceLine.CalcSums("VAT Base Amount");
                    GJL.WHTAmount := (Rec.WHTPercentage / 100) * SalesInvoiceLine."VAT Base Amount";
                    GJL.Modify(true);
                end else
                    SetWHTAmount(Rec);
            end;
    end;

    var
        TaxSetup: Record Kre_TaxSetup;
        GLSetup: Record "General Ledger Setup";
        Exchange: Codeunit ExchangeRateIDR;
}