codeunit 60000 RegTaxNumberCode
{
    procedure GenerateRegistertax(ID: Integer)
    var
        Kre_RegTaxNumberDetail: Record Kre_RegTaxNumberDetail;
        Kre_RegTaxNumber: Record Kre_RegTaxNumber;
        len: Integer;
        Tax_num: Text[16];
        i: Text[8];
        j: Integer;
        NoFrom: Integer;
        NoTo: Integer;
        Prefix: Text[16];
    // CheckTax: Boolean;
    begin

        Kre_RegTaxNumber.Get(ID);
        NoFrom := Kre_RegTaxNumber.TAX_NO_FROM;
        NoTo := Kre_RegTaxNumber.TAX_NO_TO;
        Prefix := Kre_RegTaxNumber.TAX_PREFIKS;
        len := 8;

        Kre_RegTaxNumberDetail.LockTable();
        while NoFrom <= NoTo do begin
            j := len - StrLen(Format(NoFrom));
            if (j = 0) then
                i := Format(NoFrom)

            else
                i := CreateTaxPrefix(j, '0') + Format(NoFrom);

            Tax_num := Prefix + i;

            if (TaxNumberExists(Tax_num) = false) then
                InsertTaxNumberDetails(ID, Tax_num);

            NoFrom := NoFrom + 1;
        end;
        Commit();

        UpdateStatusToGenerate(ID);
    end;

    local procedure TaxNumberExists(paramTax: Code[19]): Boolean
    var
        Kre_RegTaxNumberDetail: Record Kre_RegTaxNumberDetail;
    begin
        Kre_RegTaxNumberDetail.SetCurrentKey(TAXNUMBER);
        Kre_RegTaxNumberDetail.SetRange(TAXNUMBER, paramTax);
        Kre_RegTaxNumberDetail.SetFilter(STATUS, '=%1', 'Used');
        exit(Kre_RegTaxNumberDetail.FindFirst())
    end;

    local procedure InsertTaxNumberDetails(RegTaxNumberID: Integer; TAXNUMBER: Code[19])
    var
        Kre_RegTaxNumberDetail: Record Kre_RegTaxNumberDetail;
    begin
        Kre_RegTaxNumberDetail.Init();
        Kre_RegTaxNumberDetail.Kre_RegTaxNumberID := RegTaxNumberID;
        Kre_RegTaxNumberDetail.TAXNUMBER := TAXNUMBER;
        Kre_RegTaxNumberDetail.STATUS := 'Free';
        Kre_RegTaxNumberDetail.Insert();
    end;

    local procedure CreateTaxPrefix(len: Integer; str: Text[8]): Text[8]
    var
        a: Integer;
        b: Text[8];
    begin
        b := '0';
        a := 2;
        while a <= len do begin
            str := str + b;
            a := a + 1;
        end;

        exit(str);
    end;

    local procedure UpdateStatusToGenerate(ID: Integer)
    var
        Kre_RegTaxNumber: Record Kre_RegTaxNumber;
    begin
        Kre_RegTaxNumber.Get(ID);
        Kre_RegTaxNumber.STATUS := 'Generate';
        Kre_RegTaxNumber.Modify();
    end;

    procedure UpdateStatusToCancel(ID: Integer)
    var
        Kre_RegTaxNumberDetail: Record Kre_RegTaxNumberDetail;
        Kre_RegTaxNumber: Record Kre_RegTaxNumber;
    begin
        Kre_RegTaxNumber.Get(ID);
        Kre_RegTaxNumber.STATUS := 'Cancel';
        Kre_RegTaxNumber.Modify();
        Kre_RegTaxNumberDetail.SetRange(Kre_RegTaxNumberID, Kre_RegTaxNumber.ID);
        Kre_RegTaxNumberDetail.SetFilter(STATUS, '=%1', 'Free');
        Kre_RegTaxNumberDetail.ModifyAll(STATUS, 'Cancel');
    end;

    procedure UpdateTaxNumberLineToCancel(var TransID: Record Kre_RegTaxNumberDetail)
    begin
        if TransID.FindSet then
            repeat
                UpdateTaxNumberLineToCancelPerLine(TransID.ID);
            until TransID.Next() = 0;
    end;

    procedure UpdateTaxNumberLineToCancelPerLine(ID: Integer)
    var
        Kre_RegTaxNumberDetail: Record Kre_RegTaxNumberDetail;
    begin
        if Kre_RegTaxNumberDetail.Get(ID) then begin
            Kre_RegTaxNumberDetail.STATUS := 'Cancel';
            Kre_RegTaxNumberDetail.Modify();
        end
    end;

    procedure UpdateTaxNumberLineToUsed(var TransID: Record Kre_RegTaxNumberDetail)
    begin
        if TransID.FindSet() then
            repeat
                UpdateTaxNumberLineToUsedPerLine(TransID.ID);
            until TransID.Next() = 0;
    end;

    procedure UpdateTaxNumberLineToUsedPerLine(ID: Integer)
    var
        Kre_RegTaxNumberDetail: Record Kre_RegTaxNumberDetail;
    begin
        if Kre_RegTaxNumberDetail.Get(ID) then begin
            Kre_RegTaxNumberDetail.STATUS := 'Used';
            Kre_RegTaxNumberDetail.Modify();
        end
    end;

    procedure GetTaxNumberFree(inv_no: Code[70]; tax_date: date; acc_id: Text[50]): code[20]
    var
        Kre_RegTaxNumber: Record Kre_RegTaxNumber;
        Kre_RegTaxNumberDetail: Record Kre_RegTaxNumberDetail;
        Customer: Record Customer;
        tax_free: Code[20];
        prefix_wapu: Text[3];
        IDTaxNumber: Integer;
    begin
        Kre_RegTaxNumber.SetFilter(FROMDATE, '<=%1', tax_date);
        Kre_RegTaxNumber.SetFilter(TODATE, '>=%1', tax_date);
        Kre_RegTaxNumber.SetFilter(STATUS, '=%1', 'Generate');
        Kre_RegTaxNumber.Ascending();

        if Kre_RegTaxNumber.findset() then
            repeat
                IDTaxNumber := FindTaxNumberLineFree(Kre_RegTaxNumber.ID);
                if IDTaxNumber <> 0 then begin
                    Kre_RegTaxNumberDetail.Get(IDTaxNumber);
                    Customer.SetFilter("No.", '=%1', acc_id);
                    Customer.FindFirst();
                    prefix_wapu := format(Customer.PrefixWAPU);

                    if (prefix_wapu = '0') then
                        prefix_wapu := '010';


                    tax_free := prefix_wapu + Kre_RegTaxNumberDetail.TAXNUMBER;
                    SetTaxNumberLineToUsed(Kre_RegTaxNumberDetail.ID, inv_no);
                    exit(tax_free)
                end;
            until Kre_RegTaxNumber.Next() = 0

        else
            Error('Register tax number period cannot found! ');

    end;

    local procedure SetTaxNumberLineToUsed(ID: Integer; inv_no: Code[70])
    var
        Kre_RegTaxNumberDetail: Record Kre_RegTaxNumberDetail;
    begin
        Kre_RegTaxNumberDetail.Get(ID);
        Kre_RegTaxNumberDetail.Reference := inv_no;
        Kre_RegTaxNumberDetail.STATUS := 'Used';
        Kre_RegTaxNumberDetail.Modify();
    end;

    procedure FindTaxNumberLineFree(ID: Integer): Integer
    var
        Kre_RegTaxNumberDetail: Record Kre_RegTaxNumberDetail;
    begin
        Kre_RegTaxNumberDetail.SetFilter(Kre_RegTaxNumberID, '=%1', ID);
        Kre_RegTaxNumberDetail.SetFilter(STATUS, '=%1', 'Free');
        if Kre_RegTaxNumberDetail.FindFirst() then
            exit(Kre_RegTaxNumberDetail.ID)

    end;

    procedure UpdateTaxNumberLineToFree(var TransID: Record Kre_RegTaxNumberDetail)
    begin
        if TransID.FindSet() then
            repeat
                UpdateTaxNumberLineToFreePerLine(TransID.ID);
            until TransID.Next() = 0;
    end;

    procedure UpdateTaxNumberLineToFreePerLine(ID: Integer)
    var
        Kre_RegTaxNumberDetail: Record Kre_RegTaxNumberDetail;
    begin
        if Kre_RegTaxNumberDetail.Get(ID) then begin
            Kre_RegTaxNumberDetail.STATUS := 'Free';
            Kre_RegTaxNumberDetail.Reference := '';
            Kre_RegTaxNumberDetail.Modify();
        end
    end;


}