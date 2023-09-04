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
                trigger OnAction()
                var
                    PajakCode: Codeunit PajakCode;
                    PPhCode: Codeunit PPhCode;
                    TaxSetup: Record Kre_TaxSetup;
                begin
                    TaxSetup.FindFirst();
                    IF CONFIRM('Are you sure to synchronize ?', TRUE) then begin
                        if TaxSetup."Currency Used" = TaxSetup."Currency Used"::"Currency Amount" then begin
                            PajakCode.TaxSynch();
                            PPhCode.PPhSynch();
                            PPhCode.PPhSynch2Row();

                        end else begin
                            PajakCode.TaxSynchForeignCurrency();
                            PPhCode.PPhSynchForeignCurrency();
                            PPhCode.PPhSynch2RowForeignCurrency();
                        end;

                        Message('Synchronize Success')
                    end
                    ELSE
                        Error('Synchronize Cancel');

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