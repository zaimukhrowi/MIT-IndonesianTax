pageextension 60011 ExtSalesCreditMemo extends "Sales Credit Memo"
{
    layout
    {
        addafter(Status)
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
                    SCrSubForm: Page "Sales Cr. Memo Subform";
                begin
                    PPhCode.UpdateSalesLineAmount(Rec."No.");
                    SCrSubForm.Update();
                    SCrSubForm.CalculateTotals();
                end;
            }
            action("Posting VAT")
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
                begin
                    PpnCode.InsertTaxExcemptionVAT(Rec);
                    Message('Posting Success');
                end;
            }
        }
    }
}