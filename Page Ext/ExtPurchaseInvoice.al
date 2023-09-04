pageextension 60003 ExtPurchaseInvoice extends "Purchase Invoice"
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
                PromotedCategory = Category6;
                trigger OnAction()
                var
                    PPhCode: Codeunit PPhCode;
                    PISubForm: Page "Purch. Invoice Subform";
                    GrossUpExist: Boolean;
                begin
                    GrossUpExist := PPhCode.CheckGrossUpExistInLine(Rec."No.");
                    if GrossUpExist then
                        PPhCode.UpdatePurchaseLineAmountGrossUp(Rec."No.")
                    else
                        PPhCode.UpdatePurchaseLineAmount(Rec."No.");
                    PISubForm.Update();
                    PISubForm.CalculateTotals();
                end;
            }
            action("Posting WHT")
            {
                ToolTip = 'Posting WHT';
                Caption = 'Posting WHT';
                ApplicationArea = All;
                Image = Post;
                Promoted = true;
                PromotedCategory = Category6;
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