page 60007 TaxSycnh
{
    actions
    {
        area(Processing)
        {
            action(Synchronize)
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = Refresh;
                AccessByPermission = tabledata "VAT Entry" = rm;
                RunObject = report "Tax Synchronize Runner";
                trigger OnAction()
                begin
                    CurrPage.Close();
                end;

            }
            action(Update)
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = UpdateDescription;
                Caption = 'Update flag';
                Visible = false;
                trigger OnAction()
                var
                    PajakCode: Codeunit PajakCode;
                begin
                    IF CONFIRM('Are you sure to Update ?', TRUE) then begin
                        PajakCode.UpdateFlaqExist();
                        Message('Update Success')
                    end
                    ELSE
                        Error('Update Cancel');

                    CurrPage.Close();
                end;
            }
            action(Fixing)
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = UpdateDescription;
                Caption = 'Fixing Tax Line';
                Visible = false;
                trigger OnAction()
                var
                    PajakCode: Codeunit PajakCode;
                begin
                    IF CONFIRM('Are you sure to Fixing ?', TRUE) then begin
                        PajakCode.TaxSynchFixingLine();
                        Message('Fixing Success')
                    end
                    ELSE
                        Error('Fixing Cancel');

                    CurrPage.Close();
                end;
            }
        }
    }
}