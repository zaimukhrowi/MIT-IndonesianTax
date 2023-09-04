page 60002 RegisterTaxNumberList
{
    PageType = List;
    SourceTable = Kre_RegTaxNumber;
    CardPageId = "RegisterTaxNumberCard";
    ApplicationArea = All;
    DeleteAllowed = false;
    UsageCategory = Lists;
    Caption = 'Register Tax Number List';

    layout
    {
        area(Content)
        {
            repeater(RegTaxNumber)
            {
                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("From Date"; Rec.FROMDATE)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("To Date"; Rec.TODATE)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Prefiks Number"; Rec.TAX_PREFIKS)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("From Range Number"; Rec.TAX_NO_FROM)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("To Range Number"; Rec.TAX_NO_TO)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Status; Rec.STATUS)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    // actions
    // {
    //     area(Processing)
    //     {
    //         action("Generate")
    //         {
    //             Promoted = true;
    //             PromotedCategory = Process;
    //             ApplicationArea = All;
    //             trigger OnAction()
    //             var
    //                 RegTaxNumberCode: Codeunit RegTaxNumberCode;
    //             begin
    //                 if (Rec.ID < 1) then begin
    //                     Message('No Row Data');
    //                 end
    //                 else begin
    //                     if (Rec.STATUS = 'Ready To Use') then begin
    //                         RegTaxNumberCode.GenerateRegistertax(Rec.ID);
    //                         Message('Success Generate');
    //                     end
    //                     else begin
    //                         Message('Already Generated or Has been Cancel');
    //                     end;
    //                 end;
    //             end;
    //         }
    //         action("Cancel")
    //         {
    //             Promoted = true;
    //             PromotedCategory = Process;
    //             ApplicationArea = All;
    //             trigger OnAction()
    //             var
    //                 RegTaxNumberCode: Codeunit RegTaxNumberCode;
    //             begin
    //                 if (Rec.ID < 1) then begin
    //                     Message('No Row Data');
    //                 end
    //                 else begin
    //                     if (Rec.STATUS = 'Cancel') then begin
    //                         Message('Already Canceled');
    //                     end
    //                     else begin
    //                         RegTaxNumberCode.UpdateStatusToCancel(Rec.ID);
    //                         Message('Success Cancel');

    //                     end;
    //                 end;
    //             end;
    //         }

    //     }
    // }
}