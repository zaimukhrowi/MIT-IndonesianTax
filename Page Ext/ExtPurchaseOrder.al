pageextension 60002 ExtPurchaseOrder extends "Purchase Order"
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
                    PurchaseLine: Record "Purchase Line";
                begin
                    PurchaseLine.SetRange("Document Type", Rec."Document Type");
                    PurchaseLine.SetRange("Document No.", Rec."No.");
                    PurchaseLine.SetRange(IsWHTCalc, true);
                    if not PurchaseLine.IsEmpty then
                        Page.Run(Page::"Purchase Lines", PurchaseLine);
                end;
            }
            field(TAXNUMBER; Rec.TAXNUMBER)
            {
                ApplicationArea = All;
                Caption = 'Tax Number';
                ToolTip = 'Specifies the value of the Tax Number field.';
            }
            field(TAXDATE; Rec.TAXDATE)
            {
                ApplicationArea = All;
                Caption = 'Tax Date';
                ToolTip = 'Specifies the value of the Tax Date field.';
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
                    Kre_TaxSetup: Record Kre_TaxSetup;
                    PPhCode: Codeunit PPhCode;
                    POSubForm: Page "Purchase Order Subform";
                    GrossUpExist: Boolean;
                begin
                    Kre_TaxSetup.FindFirst();
                    GrossUpExist := PPhCode.CheckGrossUpExistInLine(Rec."No.");
                    if GrossUpExist then begin
                        if not Kre_TaxSetup."Calculate WHT per Line" then
                            Error('Gross Up calculation only can be done when "Calculate WHT per Line" is enabled in Tax Setup');
                        PPhCode.UpdatePurchaseLineAmountGrossUp(Rec."No.")
                    end else
                        PPhCode.UpdatePurchaseLineAmount(Rec."No.");

                    POSubForm.Update();
                    POSubForm.CalculateTotals();
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

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("WHT Amount");
        WHTAmount := Abs(Rec."WHT Amount");
    end;

    var
        WHTAmount: Decimal;

}