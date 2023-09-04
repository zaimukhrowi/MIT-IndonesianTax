page 60001 "Register Tax Number Lines"
{
    PageType = ListPart;
    SourceTable = Kre_RegTaxNumberDetail;
    Caption = 'Register Tax Number Lines';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(RegTaxNumLines)
            {
                field("TAX NUMBER"; Rec.TAXNUMBER)
                {
                    ApplicationArea = All;
                }
                field(Reference; Rec.Reference)
                {
                    ApplicationArea = All;
                }
                field(STATUS; Rec.STATUS)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Cancel")
            {
                //Promoted = true;
                //PromotedCategory = Process;
                ApplicationArea = All;
                trigger OnAction()
                var
                    RegTaxNumberDetail: Record Kre_RegTaxNumberDetail;
                    RegTaxNumberCode: Codeunit RegTaxNumberCode;
                begin
                    // if (Rec.STATUS = 'USED') then begin
                    CurrPage.SetSelectionFilter(RegTaxNumberDetail);
                    RegTaxNumberCode.UpdateTaxNumberLineToCancel(RegTaxNumberDetail);
                    Message('Success to cancel');
                    // end
                    // else begin
                    //     Message('Its Free');
                    // end;
                end;
            }

            action("Set Used")
            {
                // Promoted = true;
                // PromotedCategory = Process;
                ApplicationArea = All;
                trigger OnAction()
                var
                    RegTaxNumberDetail: Record Kre_RegTaxNumberDetail;
                    RegTaxNumberCode: Codeunit RegTaxNumberCode;
                begin
                    CurrPage.SetSelectionFilter(RegTaxNumberDetail);
                    RegTaxNumberCode.UpdateTaxNumberLineToUsed(RegTaxNumberDetail);
                    Message('Success to Used');
                end;
            }
            action("Set Free")
            {
                // Promoted = true;
                // PromotedCategory = Process;
                ApplicationArea = All;
                trigger OnAction()
                var
                    RegTaxNumberDetail: Record Kre_RegTaxNumberDetail;
                    RegTaxNumberCode: Codeunit RegTaxNumberCode;
                begin
                    // if (Rec.STATUS = 'USED') then begin
                    CurrPage.SetSelectionFilter(RegTaxNumberDetail);
                    RegTaxNumberCode.UpdateTaxNumberLineToFree(RegTaxNumberDetail);
                    Message('Success set to free');
                    // end
                    // else begin
                    //     Message('Its Free');
                    // end;
                end;
            }

        }
    }
}