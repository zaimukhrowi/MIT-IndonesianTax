report 60000 "Tax Synchronize Runner"
{
    ApplicationArea = All;
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    Caption = 'Tax Synchronize';
    AllowScheduling = false;

    requestpage
    {
        Caption = 'Filter';
        layout
        {
            area(Content)
            {
                group(Filter)
                {
                    Caption = 'Filter';
                    field("Start Date"; StartDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Start Date';
                        ToolTip = 'Specifies the value of the Start Date field.';

                        trigger OnValidate()
                        begin
                            if (EndDate <> 0D) and (StartDate > EndDate) then
                                Error('Start Date must be earlier than end date');

                            if StartDate > Today then
                                Error('Start Date must be earlier or equal to today');
                        end;
                    }
                    field("End Date"; EndDate)
                    {
                        ApplicationArea = All;
                        Caption = 'End Date';
                        ToolTip = 'Specifies the value of the End Date field.';

                        trigger OnValidate()
                        begin
                            if (EndDate <> 0D) and (StartDate > EndDate) then
                                Error('Start Date must be earlier than end date');
                        end;
                    }
                }
            }
        }
    }

    var
        StartDate: Date;
        EndDate: Date;


    trigger OnPostReport()
    var
        PajakCode: Codeunit PajakCode;
        PPhCode: Codeunit PPhCode;
        TaxSetup: Record Kre_TaxSetup;
    begin
        TaxSetup.FindFirst();
        IF CONFIRM('Are you sure to synchronize ?', TRUE) then begin
            if TaxSetup."Currency Used" = TaxSetup."Currency Used"::"Currency Amount" then begin
                PajakCode.TaxSynch(StartDate, EndDate);
                PPhCode.PPhSynch(StartDate, EndDate);
                PPhCode.PPhSynch2Row(StartDate, EndDate);

            end else begin
                PajakCode.TaxSynchForeignCurrency(StartDate, EndDate);
                PPhCode.PPhSynchForeignCurrency(StartDate, EndDate);
                PPhCode.PPhSynch2RowForeignCurrency(StartDate, EndDate);
            end;

            Message('Synchronize Success')
        end
        ELSE
            Error('Synchronize Cancel');
    end;

}