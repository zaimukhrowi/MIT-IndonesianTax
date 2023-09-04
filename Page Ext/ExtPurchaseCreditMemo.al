pageextension 60004 ExtPurchaseCreditMemo extends "Purchase Credit Memo"
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
                PromotedCategory = Category8;
                trigger OnAction()
                var
                    PPhCode: Codeunit PPhCode;
                    PCrSubForm: Page "Purch. Cr. Memo Subform";
                begin
                    PPhCode.UpdatePurchaseLineAmount(Rec."No.");
                    PCrSubForm.Update();
                    PCrSubForm.CalculateTotals();
                end;
            }
            action("Posting WHT")
            {
                ToolTip = 'Posting WHT';
                Caption = 'Posting WHT';
                ApplicationArea = All;
                Image = Post;
                Promoted = true;
                PromotedCategory = Category8;
                trigger OnAction()
                var
                    PPhCode: Codeunit PPhCode;
                begin
                    PPhCode.InsertTaxExcemptionWHT(Rec);
                    Message('Posting Success')
                end;
            }
        }
    }
}