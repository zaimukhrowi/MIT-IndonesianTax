codeunit 60005 ExchangeRateIDR
{
    trigger OnRun()
    begin

    end;

    procedure GetExchangeRate(CurrCode: Code[10]; ExCurrCode: Code[10]; Tanggal: Date): Decimal
    var
        Exch: Record "Currency Exchange Rate";
        ExchRabu: Record "Currency Exchange Rate";
        NewDate: Date;
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        if ExCurrCode = '' then
            ExCurrCode := GLSetup."LCY Code";
        if (CurrCode = 'IDR') and (ExCurrCode = 'IDR') then
            exit(1)
        else begin
            Exch.SetRange("Currency Code", CurrCode);
            Exch.SetRange("Relational Currency Code", ExCurrCode);
            Exch.SetFilter("Starting Date", '<= %1', Tanggal);
            if Exch.FindFirst() then begin
                if DATE2DWY(Exch."Starting Date", 1) = 3 then
                    exit(Exch."Relational Exch. Rate Amount")
                else begin
                    NewDate := CalcDate('-7D', Exch."Starting Date");
                    ExchRabu.SetRange("Currency Code", CurrCode);
                    ExchRabu.SetRange("Relational Currency Code", ExCurrCode);
                    ExchRabu.SetRange("Starting Date", NewDate, Exch."Starting Date");
                    if ExchRabu.FindSet() then
                        if DATE2DWY(ExchRabu."Starting Date", 1) = 3 then begin
                            repeat
                                exit(ExchRabu."Relational Exch. Rate Amount");
                            until ExchRabu.Next() = 0;
                        end;
                end;
            end else
                Error('Please insert exchange rate Currency %1 with Relational Currency Code %2 from starting date %3', CurrCode, ExCurrCode, Tanggal);
        end;
    end;

    procedure GetExchangeRateRelational(CurrCode: Code[10]; ExCurrCode: Code[10]; Tanggal: Date): Decimal
    var
        Exch: Record "Currency Exchange Rate";
        ExchRabu: Record "Currency Exchange Rate";
        NewDate: Date;
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        if ExCurrCode = '' then
            ExCurrCode := GLSetup."LCY Code";
        if (CurrCode = 'IDR') and (ExCurrCode = 'IDR') then
            exit(1)
        else begin
            Exch.SetRange("Currency Code", CurrCode);
            Exch.SetRange("Relational Currency Code", ExCurrCode);
            Exch.SetFilter("Starting Date", '<= %1', Tanggal);
            if Exch.FindFirst() then begin
                if DATE2DWY(Exch."Starting Date", 1) = 3 then
                    exit(Exch."Relational Exch. Rate Amount")
                else begin
                    NewDate := CalcDate('-7D', Exch."Starting Date");
                    ExchRabu.SetRange("Currency Code", CurrCode);
                    ExchRabu.SetRange("Relational Currency Code", ExCurrCode);
                    ExchRabu.SetRange("Starting Date", NewDate, Exch."Starting Date");
                    if ExchRabu.FindSet() then
                        if DATE2DWY(ExchRabu."Starting Date", 1) = 3 then begin
                            repeat
                                exit(ExchRabu."Relational Exch. Rate Amount");
                            until ExchRabu.Next() = 0;
                        end;
                end;
            end else
                Error('Please insert exchange rate Currency %1 with Relational Currency Code %2 from starting date %3', CurrCode, ExCurrCode, Tanggal);
        end;
    end;

}