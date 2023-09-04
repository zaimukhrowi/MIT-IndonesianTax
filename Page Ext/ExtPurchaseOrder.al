pageextension 60002 ExtPurchaseOrder extends "Purchase Order"
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

        // modify("Buy-from Vendor No.")
        // {
        //     trigger OnAfterValidate()
        //     var
        //         Vendor: Record Vendor;
        //     begin
        //         if Vendor.Get(Rec."Buy-from Vendor No.") then
        //             if Vendor.ISPPH = true then begin
        //                 PPhCode.UpdateWHTPostingGroupPO(Rec."No.", Vendor.WHTProductPostingGroup);
        //                 POSubForm.Update()
        //             end
        //             else begin
        //                 PPhCode.UpdateWHTPostingGroupPONull(Rec."No.");
        //                 POSubForm.Update()
        //             end;
        //     end;
        // }
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
                    POSubForm: Page "Purchase Order Subform";
                    GrossUpExist: Boolean;
                begin
                    GrossUpExist := PPhCode.CheckGrossUpExistInLine(Rec."No.");
                    if GrossUpExist then
                        PPhCode.UpdatePurchaseLineAmountGrossUp(Rec."No.")
                    else
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

}