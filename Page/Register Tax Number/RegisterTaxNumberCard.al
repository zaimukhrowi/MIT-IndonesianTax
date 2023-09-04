page 60000 RegisterTaxNumberCard
{
    PageType = Card;
    SourceTable = Kre_RegTaxNumber;
    Caption = 'Register Tax Number Card';
    DeleteAllowed = false;
    UsageCategory = Tasks;
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("From Date"; Rec.FROMDATE)
                {
                    ApplicationArea = All;
                }
                field("To Date"; Rec.TODATE)
                {
                    ApplicationArea = All;
                }
                field("Prefiks Number"; Rec.TAX_PREFIKS)
                {
                    ApplicationArea = All;
                }
                field("From Range Number"; Rec.TAX_NO_FROM)
                {
                    ApplicationArea = All;
                    Editable = txt_min;
                }
                field("To Range Number"; Rec.TAX_NO_TO)
                {
                    ApplicationArea = All;
                    Editable = txt_max;
                }
            }

            part(RegisterTaxNumber; "Register Tax Number Lines")
            {
                SubPageLink = Kre_RegTaxNumberID = field(ID);
                UpdatePropagation = SubPart;
                Visible = true;
                ApplicationArea = All;

            }
        }

    }

    actions
    {
        area(Processing)
        {
            action("Generate")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Visible = btn_generate;
                Image = Description;
                trigger OnAction()
                var
                    RegTaxNumberCode: Codeunit RegTaxNumberCode;
                begin
                    if (Rec.ID < 1) then
                        Message('No Row Data')

                    else
                        if (Rec.STATUS = 'Ready To Use') then begin
                            RegTaxNumberCode.GenerateRegistertax(Rec.ID);
                            Message('Success Generate');
                        end
                        else
                            Message('Already Generated or has been Cancel');


                end;
            }
            action("Set Ready to Used")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = UpdateDescription;
                trigger OnAction()
                begin
                    if (Rec.ID < 1) then
                        Message('No Row Data')

                    else
                        if (Rec.STATUS = 'Generate') then begin
                            Rec.STATUS := 'Ready To Use';
                            Rec.Modify();
                            Message('Success');
                        end

                end;
            }
            action("Cancel")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Visible = btn_cancel;
                trigger OnAction()
                var
                    RegTaxNumberCode: Codeunit RegTaxNumberCode;
                begin
                    if (Rec.ID < 1) then
                        Message('No Row Data')

                    else
                        if (Rec.STATUS = 'Cancel') then
                            Message('Already Canceled')

                        else begin
                            RegTaxNumberCode.UpdateStatusToCancel(Rec.ID);
                            Message('Success Cancel');

                        end;

                end;
            }

        }
    }

    trigger OnInit()
    begin
        txt_min := true;
        txt_max := true;
    end;

    trigger OnAfterGetRecord()
    begin
        case Rec.STATUS of
            'Ready To Use':
                begin
                    btn_generate := true;
                    btn_cancel := false;
                    txt_min := true;
                    txt_max := true;
                end;
            'Generate':
                begin
                    btn_generate := false;
                    btn_cancel := true;
                    txt_min := false;
                    txt_max := false;
                end;
            'Cancel':
                begin
                    btn_generate := false;
                    btn_cancel := false;
                    txt_min := false;
                    txt_max := false;
                end;
        end;
    end;

    var
        btn_generate: boolean;
        txt_min: Boolean;
        txt_max: boolean;
        btn_cancel: Boolean;

}