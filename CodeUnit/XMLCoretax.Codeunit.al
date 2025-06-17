codeunit 60007 "XML Coretax"
{
    trigger OnRun()
    begin

    end;

    procedure SynchronizeCustomer()
    var
        KRE_TAXJOUR: Record KRE_TAXJOUR;
        Customer: Record Customer;
        ShiptoAddress: Record "Ship-to Address";
    begin
        KRE_TAXJOUR.Reset();
        KRE_TAXJOUR.SetRange(KRE_TAXJOUR.TAX_SOURCE, KRE_TAXJOUR.TAX_SOURCE::Sales);
        KRE_TAXJOUR.SetRange(KRE_TAXJOUR.TAX_POSTED, KRE_TAXJOUR.TAX_POSTED::YES);
        if KRE_TAXJOUR.FindSet() then begin
            repeat
                if (KRE_TAXJOUR."Customer ID" = '') or (KRE_TAXJOUR."ID TKU Pembeli" = '') or (KRE_TAXJOUR.NPWP = '') then begin
                    Customer.Get(KRE_TAXJOUR.ACCOUNTID);
                    case KRE_TAXJOUR."Jenis ID Pembeli" of
                        KRE_TAXJOUR."Jenis ID Pembeli"::TIN:
                            begin
                                KRE_TAXJOUR."Customer ID" := Customer.NPWP;
                                KRE_TAXJOUR.NPWP := Customer.NPWP;
                            end;
                        KRE_TAXJOUR."Jenis ID Pembeli"::"National ID":
                            begin
                                KRE_TAXJOUR."Customer ID" := Customer.NIK;
                                KRE_TAXJOUR.NPWP := Customer.NIK;
                            end;
                        KRE_TAXJOUR."Jenis ID Pembeli"::Passport:
                            KRE_TAXJOUR."Customer ID" := Customer."Passport No.";
                        KRE_TAXJOUR."Jenis ID Pembeli"::"Other ID":
                            KRE_TAXJOUR."Customer ID" := Customer."Other ID";
                    end;
                    KRE_TAXJOUR."Kode Transaksi" := CopyStr(Format(Customer.PrefixWAPU), 1, 2);
                    if KRE_TAXJOUR."Ship-to Code" <> '' then begin
                        ShiptoAddress.Get(Customer."No.", KRE_TAXJOUR."Ship-to Code");
                        KRE_TAXJOUR.ALAMATNPWP := ShiptoAddress.AlamatNPWP;
                        KRE_TAXJOUR."ID TKU Pembeli" := ShiptoAddress."ID TKU";
                    end else begin
                        KRE_TAXJOUR.ALAMATNPWP := Customer.AlamatNPWP;
                        KRE_TAXJOUR."ID TKU Pembeli" := Customer."ID TKU";
                    end;
                    KRE_TAXJOUR.Modify(true);
                end
            until KRE_TAXJOUR.Next() = 0;
            Message('Synchronize Success');
        end;
    end;

    procedure CreateXMLSalesOrder(var KRE_TAXJOUR: Record KRE_TAXJOUR)
    var
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        TempBlob: Codeunit "Temp Blob";
        ListOfTaxInvoice: XmlElement;
        TaxInvoice: XmlElement;
        TaxInvoiceBulk: XmlElement;
        TIN: XmlElement;
        XmlDoc: XmlDocument;
        InS: InStream;
        OutS: OutStream;
        FileName: Text;
        XMLDataClear: Text;
        XmlData: Text;
        XMLDataClearest: Text;
        Declaration: XmlDeclaration;
        XmlWriteOptions: XmlWriteOptions;
    begin
        XmlDoc := XmlDocument.Create();
        Declaration := XmlDeclaration.Create('1.0', 'utf-8', 'yes');
        XmlDoc.SetDeclaration(Declaration);
        TaxInvoiceBulk := XmlElement.Create('TaxInvoiceBulk');

        GetTIN();
        TIN := XmlElement.Create('TIN');
        TIN.Add(GetTIN());
        TaxInvoiceBulk.Add(TIN);

        ListOfTaxInvoice := XmlElement.Create('ListOfTaxInvoice');
        if KRE_TAXJOUR.FindSet() then
            repeat
                if KRE_TAXJOUR.IS_RETURNITEM = KRE_TAXJOUR.IS_RETURNITEM::NO then begin
                    TaxInvoice := XmlElement.Create('TaxInvoice');
                    TaxInvoice(TaxInvoice, KRE_TAXJOUR);
                    ListOfTaxInvoice.Add(TaxInvoice);
                    KRE_TAXJOUR.TAX_EXPORTED := KRE_TAXJOUR.TAX_EXPORTED::YES;
                    KRE_TAXJOUR.Modify(true);
                end;
            until KRE_TAXJOUR.Next() = 0;


        TaxInvoiceBulk.Add(ListOfTaxInvoice);
        XmlDoc.Add(TaxInvoiceBulk);
        TempBlob.CreateInStream(InS);
        TempBlob.CreateOutStream(OutS);
        XmlDoc.WriteTo(XmlData);
        XMLDataClear := XmlData.Replace(' standalone="yes"', '');
        XMLDataClearest := SelectionFilterManagement.ReplaceString(XMLDataClear, ' />', '/>');
        XMLDataClearest := XMLDataClearest.Replace('<TaxInvoiceBulk>', '<TaxInvoiceBulk xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">');

        OutS.WriteText(XMLDataClearest);
        InS.ReadText(XMLDataClearest);
        FileName := 'FK_' + UserId + '_' + Format(CurrentDateTime) + '.XML';
        DownloadFromStream(InS, '', '', '', FileName);
    end;

    local procedure GetTIN(): Text
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.FindFirst();
        exit(CompanyInformation."VAT Registration No.");
    end;

    local procedure TaxInvoice(var TaxInvoice: XmlElement; var KRE_TAXJOUR: Record KRE_TAXJOUR)
    var
        KreTaxSetup: Record Kre_TaxSetup;
        Location: Record Location;
        Customer: Record Customer;
        AddInfo: XmlElement;
        BuyerAdress: XmlElement;
        BuyerCountry: XmlElement;
        BuyerDocument: XmlElement;
        BuyerDocumentNumber: XmlElement;
        BuyerEmail: XmlElement;
        BuyerIDTKU: XmlElement;
        BuyerName: XmlElement;
        BuyerTin: XmlElement;
        CustomDoc: XmlElement;
        CustomDocMonthYear: XmlElement;
        FacilityStamp: XmlElement;
        ListOfGoodService: XmlElement;
        RefDesc: XmlElement;
        SellerIDTKU: XmlElement;
        TaxInvoiceDate: XmlElement;
        TaxInvoiceOpt: XmlElement;
        TrxCode: XmlElement;
    begin
        KreTaxSetup.FindFirst();
        KreTaxSetup.TestField("Tarif PPn Percentage");
        KreTaxSetup.TestField("DPP Nilai Lain (A)");
        KreTaxSetup.TestField("DPP Nilai Lain (B)");

        TaxInvoiceDate := XmlElement.Create('TaxInvoiceDate');
        TaxInvoiceDate.Add(KRE_TAXJOUR.TAXDATE);

        TaxInvoiceOpt := XmlElement.Create('TaxInvoiceOpt');
        TaxInvoiceOpt.Add('Normal');

        TrxCode := XmlElement.Create('TrxCode');
        if StrLen(KRE_TAXJOUR."Kode Transaksi") <> 2 then
            Error('Prefix in Customer %1 is blank', KRE_TAXJOUR.ACCOUNTID);
        TrxCode.Add(KRE_TAXJOUR."Kode Transaksi");

        if (KRE_TAXJOUR."Kode Transaksi" = '07') or (KRE_TAXJOUR."Kode Transaksi" = '08') then
            if (KRE_TAXJOUR."Keterangan Tambahan" = '') or (KRE_TAXJOUR."Cap Fasilitas" = '') then
                Error('Keterangan Tambahan & Cap Fasilitas must be filled for transaction type 07 or 08');

        AddInfo := XmlElement.Create('AddInfo');
        AddInfo.Add(KRE_TAXJOUR."Keterangan Tambahan");

        CustomDoc := XmlElement.Create('CustomDoc');
        CustomDoc.Add(KRE_TAXJOUR.Kode_Dokumen_Pendukung);

        CustomDocMonthYear := XmlElement.Create('CustomDocMonthYear');
        CustomDocMonthYear.Add(Format(KRE_TAXJOUR.INVOICEDATE, 0, '<Month,2><Year4>'));

        RefDesc := XmlElement.Create('RefDesc');
        RefDesc.Add(KRE_TAXJOUR.INVOICENO);

        FacilityStamp := XmlElement.Create('FacilityStamp');
        FacilityStamp.Add(KRE_TAXJOUR."Cap Fasilitas");

        SellerIDTKU := XmlElement.Create('SellerIDTKU');
        if Location.Get(KRE_TAXJOUR."Location Code") then begin
            if Location."Kre ID TKU" <> '' then
                SellerIDTKU.Add(Location."Kre ID TKU")
            else
                Error(StrSubstNo('ID TKU for Location %1 is Blank', KRE_TAXJOUR."Location Code"));
        end else begin
            if KreTaxSetup."Default ID TKU" = '' then
                Error('Default ID TKU in Tax Setup Card must be filled')
            else
                SellerIDTKU.Add(KreTaxSetup."Default ID TKU")
        end;

        BuyerTin := XmlElement.Create('BuyerTin');
        if KRE_TAXJOUR."Jenis ID Pembeli" <> KRE_TAXJOUR."Jenis ID Pembeli"::TIN then
            BuyerTin.Add('0000000000000000')
        else begin
            if KRE_TAXJOUR.NPWP = '' then
                Error('NPWP for Customer %1 is blank', KRE_TAXJOUR.ACCOUNTID);
            if StrLen(KRE_TAXJOUR.NPWP) = 15 then
                BuyerTin.Add('0' + KRE_TAXJOUR.NPWP)
            else
                BuyerTin.Add(KRE_TAXJOUR.NPWP)
        end;

        BuyerDocument := XmlElement.Create('BuyerDocument');
        BuyerDocument.Add(Format(KRE_TAXJOUR."Jenis ID Pembeli"));

        Customer.Get(KRE_TAXJOUR.ACCOUNTID);
        BuyerCountry := XmlElement.Create('BuyerCountry');
        BuyerCountry.Add(Customer."Country/Region Code");

        BuyerDocumentNumber := XmlElement.Create('BuyerDocumentNumber');
        if KRE_TAXJOUR."Jenis ID Pembeli" = KRE_TAXJOUR."Jenis ID Pembeli"::TIN then
            BuyerDocumentNumber.Add('-')
        else
            BuyerDocumentNumber.Add(KRE_TAXJOUR."Customer ID");

        BuyerName := XmlElement.Create('BuyerName');
        BuyerName.Add(KRE_TAXJOUR.NAMA);

        BuyerAdress := XmlElement.Create('BuyerAdress');
        if KRE_TAXJOUR.ALAMATNPWP = '' then
            Error('Alamat NPWP for Customer %1 is blank', KRE_TAXJOUR.ACCOUNTID);
        BuyerAdress.Add(KRE_TAXJOUR.ALAMATNPWP);

        BuyerEmail := XmlElement.Create('BuyerEmail');
        BuyerEmail.Add(Customer."E-Mail");

        BuyerIDTKU := XmlElement.Create('BuyerIDTKU');
        if KRE_TAXJOUR."ID TKU Pembeli" = '' then
            Error('ID TKU Pembeli for Customer %1 is blank', KRE_TAXJOUR.ACCOUNTID);
        BuyerIDTKU.Add(KRE_TAXJOUR."ID TKU Pembeli");

        TaxInvoice.Add(TaxInvoiceDate);
        TaxInvoice.Add(TaxInvoiceOpt);
        TaxInvoice.Add(TrxCode);
        TaxInvoice.Add(AddInfo);
        TaxInvoice.Add(CustomDoc);
        TaxInvoice.Add(CustomDocMonthYear);
        TaxInvoice.Add(RefDesc);
        TaxInvoice.Add(FacilityStamp);
        TaxInvoice.Add(SellerIDTKU);
        TaxInvoice.Add(BuyerTin);
        TaxInvoice.Add(BuyerDocument);
        TaxInvoice.Add(BuyerCountry);
        TaxInvoice.Add(BuyerDocumentNumber);
        TaxInvoice.Add(BuyerName);
        TaxInvoice.Add(BuyerAdress);
        TaxInvoice.Add(BuyerEmail);
        TaxInvoice.Add(BuyerIDTKU);

        ListOfGoodService := XmlElement.Create('ListOfGoodService');
        ListOfGoodService(KRE_TAXJOUR, ListOfGoodService);

        TaxInvoice.Add(ListOfGoodService);
    end;

    local procedure ListOfGoodService(var KRE_TAXJOUR: Record KRE_TAXJOUR; var ListOfGoodService: XmlElement)
    var
        Item: Record Item;
        KRE_TAXJOURLINES: Record KRE_TAXJOURLINES;
        Kre_TaxSetup: Record Kre_TaxSetup;
        SalesInvoiceLine: Record "Sales Invoice Line";
        UnitofMeasure: Record "Unit of Measure";
        VATPostingSetup: Record "VAT Posting Setup";
        Code: XmlElement;
        GoodService: XmlElement;
        Name: XmlElement;
        Opt: XmlElement;
        OtherTaxBase: XmlElement;
        Price: XmlElement;
        Qty: XmlElement;
        STLG: XmlElement;
        STLGRate: XmlElement;
        TaxBase: XmlElement;
        TotalDiscount: XmlElement;
        Unit: XmlElement;
        VAT: XmlElement;
        VATRate: XmlElement;
        Kre_TaxSetupRecref: RecordRef;
        PPn: Decimal;
    begin
        Kre_TaxSetup.FindFirst();
        KRE_TAXJOURLINES.SetRange(KRE_TAXJOURID, KRE_TAXJOUR.ID);
        if KRE_TAXJOURLINES.FindSet() then
            repeat
                GoodService := XmlElement.Create('GoodService');
                Opt := XmlElement.Create('Opt');
                Unit := XmlElement.Create('Unit');

                if SalesInvoiceLine.Get(KRE_TAXJOURLINES.INVOICENO, KRE_TAXJOURLINES.INVOICELINENO) then
                    if UnitofMeasure.Get(SalesInvoiceLine."Unit of Measure Code") then begin
                        if UnitofMeasure."Kre Coretax Code" <> '' then
                            Unit.Add(UnitofMeasure."Kre Coretax Code")
                        else
                            Error('Coretax Code in UOM %1 is blank', UnitofMeasure.Code);
                    end else
                        Unit.Add('UM.0018');

                if Item.Get(KRE_TAXJOURLINES.ITEMID) then begin
                    if Item."Kre Item Type" = Item."Kre Item Type"::A then
                        Opt.Add('A')
                    else
                        Opt.Add('B');
                end else
                    Opt.Add('B');

                Code := XmlElement.Create('Code');
                if KRE_TAXJOURLINES."Coretax Item Code" <> '' then
                    Code.Add(KRE_TAXJOURLINES."Coretax Item Code")
                else
                    if Item."Coretax Code" <> '' then
                        Code.Add(Item."Coretax Code")
                    else
                        Code.Add('000000');

                Name := XmlElement.Create('Name');
                Name.Add(KRE_TAXJOURLINES.DESCRIPTION);

                Kre_TaxSetupRecref.GetTable(Kre_TaxSetup);
                Price := XmlElement.Create('Price');
                Price.Add(format(Round(KRE_TAXJOURLINES.PRICE, Kre_TaxSetup."Amount Decimal Places", SelectStr(Kre_TaxSetup."VAT Rounding Type" + 1, Kre_TaxSetupRecref.Field(6).OptionMembers)), 0, 1));

                Qty := XmlElement.Create('Qty');
                Qty.Add(KRE_TAXJOURLINES.QTY);

                TotalDiscount := XmlElement.Create('TotalDiscount');
                TotalDiscount.Add(format(Round(KRE_TAXJOURLINES.DISCOUNT_AMOUNT, Kre_TaxSetup."Amount Decimal Places", SelectStr(Kre_TaxSetup."VAT Rounding Type" + 1, Kre_TaxSetupRecref.Field(6).OptionMembers)), 0, 1));

                TaxBase := XmlElement.Create('TaxBase');
                TaxBase.Add(format(Round(KRE_TAXJOURLINES.DPP_AMOUNT, Kre_TaxSetup."Amount Decimal Places", SelectStr(Kre_TaxSetup."VAT Rounding Type" + 1, Kre_TaxSetupRecref.Field(6).OptionMembers)), 0, 1));

                OtherTaxBase := XmlElement.Create('OtherTaxBase');
                OtherTaxBase.Add(format(Round(Kre_TaxSetup."DPP Nilai Lain (A)" / Kre_TaxSetup."DPP Nilai Lain (B)" * KRE_TAXJOURLINES.DPP_AMOUNT, Kre_TaxSetup."Amount Decimal Places", SelectStr(Kre_TaxSetup."VAT Rounding Type" + 1, Kre_TaxSetupRecref.Field(6).OptionMembers)), 0, 1));

                VATRate := XmlElement.Create('VATRate');
                // VATPostingSetup.Reset();
                // VATPostingSetup.SetRange("VAT Identifier", KRE_TAXJOURLINES.VAT_Identifier);
                if Kre_TaxSetup."Tarif PPn Percentage" <> 0 then
                    VATRate.Add(Kre_TaxSetup."Tarif PPn Percentage")
                else
                    Error('Tarif PPn is 0 in Tax Setup');

                PPn := (Kre_TaxSetup."DPP Nilai Lain (A)" / Kre_TaxSetup."DPP Nilai Lain (B)" * KRE_TAXJOURLINES.DPP_AMOUNT) * Kre_TaxSetup."Tarif PPn Percentage" / 100;
                VAT := XmlElement.Create('VAT');
                VAT.Add(format(Round(PPn, Kre_TaxSetup."Amount Decimal Places", SelectStr(Kre_TaxSetup."VAT Rounding Type" + 1, Kre_TaxSetupRecref.Field(6).OptionMembers)), 0, 1));

                STLGRate := XmlElement.Create('STLGRate');
                STLGRate.Add(0);

                STLG := XmlElement.Create('STLG');
                STLG.Add(0);
                GoodService.Add(Opt);
                GoodService.Add(Code);
                GoodService.Add(Name);
                GoodService.Add(Unit);
                GoodService.Add(Price);
                GoodService.Add(Qty);
                GoodService.Add(TotalDiscount);
                GoodService.Add(TaxBase);
                GoodService.Add(OtherTaxBase);
                GoodService.Add(VATRate);
                GoodService.Add(VAT);
                GoodService.Add(STLGRate);
                GoodService.Add(STLG);
                ListOfGoodService.Add(GoodService);
            until KRE_TAXJOURLINES.Next() = 0;
    end;

    procedure CreateXMLSalesReturn(var
                                       KRE_TAXJOUR: Record KRE_TAXJOUR)
    var
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        TempBlob: Codeunit "Temp Blob";
        OutputReturnDataList: XmlElement;
        OutputReturnData: XmlElement;
        OutputSpecialDocReturn: XmlElement;
        TIN: XmlElement;
        XmlDoc: XmlDocument;
        InS: InStream;
        OutS: OutStream;
        FileName: Text;
        XMLDataClear: Text;
        XmlData: Text;
        XMLDataClearest: Text;
        Declaration: XmlDeclaration;
        XmlWriteOptions: XmlWriteOptions;
        KreTaxJournalperCustomer: Query "Kre Tax Journal per Customer";
    begin
        XmlDoc := XmlDocument.Create();
        Declaration := XmlDeclaration.Create('1.0', 'utf-8', 'yes');
        XmlDoc.SetDeclaration(Declaration);
        OutputSpecialDocReturn := XmlElement.Create('OutputSpecialDocReturn');

        GetTIN();
        TIN := XmlElement.Create('TIN');
        TIN.Add(GetTIN());
        OutputSpecialDocReturn.Add(TIN);

        OutputReturnDataList := XmlElement.Create('OutputReturnDataList');
        if KRE_TAXJOUR.FindSet() then
            repeat
                if KRE_TAXJOUR.IS_RETURNITEM = KRE_TAXJOUR.IS_RETURNITEM::YES then begin
                    OutputReturnData := XmlElement.Create('OutputReturnData');
                    OutputReturnData(OutputReturnData, KRE_TAXJOUR);
                    OutputReturnDataList.Add(OutputReturnData);
                    KRE_TAXJOUR.TAX_EXPORTED := KRE_TAXJOUR.TAX_EXPORTED::YES;
                    KRE_TAXJOUR.Modify(true);
                end;
            until KRE_TAXJOUR.Next() = 0;


        OutputSpecialDocReturn.Add(OutputReturnDataList);
        XmlDoc.Add(OutputSpecialDocReturn);
        TempBlob.CreateInStream(InS);
        TempBlob.CreateOutStream(OutS);
        XmlDoc.WriteTo(XmlData);
        XMLDataClear := XmlData.Replace(' standalone="yes"', '');
        XMLDataClearest := SelectionFilterManagement.ReplaceString(XMLDataClear, ' />', '/>');
        XMLDataClearest := XMLDataClearest.Replace('<OutputSpecialDocReturn>', '<OutputSpecialDocReturn xsi:noNamespaceSchemaLocation="schema.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">');

        OutS.WriteText(XMLDataClearest);
        InS.ReadText(XMLDataClearest);
        FileName := 'Retur Dok Lain_' + UserId + '_' + Format(CurrentDateTime) + '.XML';
        DownloadFromStream(InS, '', '', '', FileName);
    end;

    local procedure OutputReturnData(var OutputReturnData: XmlElement; var KRE_TAXJOUR: Record KRE_TAXJOUR)
    var
        KreTaxSetup: Record Kre_TaxSetup;
        ReturnTaxBase: XmlElement;
        BuyerAddress: XmlElement;
        TransactionType: XmlElement;
        DocumentType: XmlElement;
        TransactionDocument: XmlElement;
        BuyerTaxpayerName: XmlElement;
        BuyerTIN: XmlElement;
        ReturnVAT: XmlElement;
        DocumentDate: XmlElement;
        ReturnSTLG: XmlElement;
        ReturnDocumentNumber: XmlElement;
        ReturnDate: XmlElement;
        DocumentNumber: XmlElement;
        TransactionDetail: XmlElement;
    begin
        DocumentNumber := XmlElement.Create('DocumentNumber');
        DocumentNumber.Add(KRE_TAXJOUR.RETURN_DOC_NUMBER);

        ReturnDocumentNumber := XmlElement.Create('ReturnDocumentNumber');
        ReturnDocumentNumber.Add(KRE_TAXJOUR.INVOICENO);

        TransactionType := XmlElement.Create('TransactionType');
        TransactionType.Add('01');

        DocumentType := XmlElement.Create('DocumentType');
        DocumentType.Add('01');

        TransactionDetail := XmlElement.Create('TransactionDetail');
        if StrLen(KRE_TAXJOUR."Kode Transaksi") <> 2 then
            Error('Prefix in Customer %1 is blank', KRE_TAXJOUR.ACCOUNTID);
        TransactionDetail.Add(KRE_TAXJOUR."Kode Transaksi");

        TransactionDocument := XmlElement.Create('TransactionDocument');
        TransactionDocument.Add('01');

        DocumentDate := XmlElement.Create('DocumentDate');
        DocumentDate.Add(Format(KRE_TAXJOUR.RETURN_DATE, 0, '<Day,2>-<Month,2>-20<Year,2>'));

        BuyerTIN := XmlElement.Create('BuyerTIN');
        if KRE_TAXJOUR."Jenis ID Pembeli" <> KRE_TAXJOUR."Jenis ID Pembeli"::TIN then
            BuyerTin.Add('0000000000000000')
        else begin
            if KRE_TAXJOUR.NPWP = '' then
                Error('NPWP for Customer %1 is blank', KRE_TAXJOUR.ACCOUNTID);
            if StrLen(KRE_TAXJOUR.NPWP) = 15 then
                BuyerTin.Add('0' + KRE_TAXJOUR.NPWP)
            else
                BuyerTin.Add(KRE_TAXJOUR.NPWP)
        end;

        BuyerTaxpayerName := XmlElement.Create('BuyerTaxpayerName');
        BuyerTaxpayerName.Add(KRE_TAXJOUR.NAMA);

        BuyerAddress := XmlElement.Create('BuyerAddress');
        if KRE_TAXJOUR.ALAMATNPWP = '' then
            Error('Alamat NPWP for Customer %1 is blank', KRE_TAXJOUR.ACCOUNTID);
        BuyerAddress.Add(KRE_TAXJOUR.ALAMATNPWP);

        ReturnTaxBase := XmlElement.Create('ReturnTaxBase');
        ReturnTaxBase.Add(KRE_TAXJOUR.DPPAMOUNT);

        ReturnVAT := XmlElement.Create('ReturnVAT');
        ReturnVAT.Add(KRE_TAXJOUR.VATAMOUNT);

        ReturnSTLG := XmlElement.Create('ReturnSTLG');
        ReturnSTLG.Add('0');

        OutputReturnData.Add(DocumentNumber);
        OutputReturnData.Add(ReturnDocumentNumber);
        OutputReturnData.Add(TransactionType);
        OutputReturnData.Add(DocumentType);
        OutputReturnData.Add(TransactionDetail);
        OutputReturnData.Add(TransactionDocument);
        OutputReturnData.Add(DocumentDate);
        OutputReturnData.Add(BuyerTIN);
        OutputReturnData.Add(BuyerTaxpayerName);
        OutputReturnData.Add(BuyerAddress);
        OutputReturnData.Add(ReturnTaxBase);
        OutputReturnData.Add(ReturnVAT);
        OutputReturnData.Add(ReturnSTLG);
    end;

    procedure CreateXMLPurchaseReturn(var KRE_TAXJOUR: Record KRE_TAXJOUR)
    var
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        TempBlob: Codeunit "Temp Blob";
        InputReturnDataList: XmlElement;
        InputReturnData: XmlElement;
        InputTaxInvoiceReturn: XmlElement;
        TIN: XmlElement;
        XmlDoc: XmlDocument;
        InS: InStream;
        OutS: OutStream;
        FileName: Text;
        XMLDataClear: Text;
        XmlData: Text;
        XMLDataClearest: Text;
        Declaration: XmlDeclaration;
        XmlWriteOptions: XmlWriteOptions;
    begin
        XmlDoc := XmlDocument.Create();
        Declaration := XmlDeclaration.Create('1.0', 'utf-8', 'yes');
        XmlDoc.SetDeclaration(Declaration);
        InputTaxInvoiceReturn := XmlElement.Create('InputTaxInvoiceReturn');

        GetTIN();
        TIN := XmlElement.Create('TIN');
        TIN.Add(GetTIN());
        InputTaxInvoiceReturn.Add(TIN);

        InputReturnDataList := XmlElement.Create('InputReturnDataList');
        if KRE_TAXJOUR.FindSet() then
            repeat
                if KRE_TAXJOUR.IS_RETURNITEM = KRE_TAXJOUR.IS_RETURNITEM::YES then begin
                    InputReturnData := XmlElement.Create('InputReturnData');
                    InputReturnData(InputReturnData, KRE_TAXJOUR);
                    InputReturnDataList.Add(InputReturnData);
                    KRE_TAXJOUR.TAX_EXPORTED := KRE_TAXJOUR.TAX_EXPORTED::YES;
                    KRE_TAXJOUR.Modify(true);
                end;
            until KRE_TAXJOUR.Next() = 0;


        InputTaxInvoiceReturn.Add(InputReturnDataList);
        XmlDoc.Add(InputTaxInvoiceReturn);
        TempBlob.CreateInStream(InS);
        TempBlob.CreateOutStream(OutS);
        XmlDoc.WriteTo(XmlData);
        XMLDataClear := XmlData.Replace(' standalone="yes"', '');
        XMLDataClearest := SelectionFilterManagement.ReplaceString(XMLDataClear, ' />', '/>');
        XMLDataClearest := XMLDataClearest.Replace('<InputTaxInvoiceReturn>', '<InputTaxInvoiceReturn xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">');

        OutS.WriteText(XMLDataClearest);
        InS.ReadText(XMLDataClearest);
        FileName := 'PM Return_' + UserId + '_' + Format(CurrentDateTime) + '.XML';
        DownloadFromStream(InS, '', '', '', FileName);
    end;

    local procedure InputReturnData(var InputReturnData: XmlElement; var KRE_TAXJOUR: Record KRE_TAXJOUR)
    var
        KreTaxSetup: Record Kre_TaxSetup;
        Location: Record Location;
        Kre_TaxSetupRecref: RecordRef;
        BuyerAddress: XmlElement;
        BuyerCountry: XmlElement;
        BuyerDocument: XmlElement;
        SellerTIN: XmlElement;
        BuyerEmail: XmlElement;
        BuyerIDTKU: XmlElement;
        BuyerName: XmlElement;
        BuyerTin: XmlElement;
        ReturnVAT: XmlElement;
        ReturnSTLG: XmlElement;
        FacilityStamp: XmlElement;
        ListOfGoodService: XmlElement;
        InvoiceNumber: XmlElement;
        SellerIDTKU: XmlElement;
        ReturnDate: XmlElement;
        ReturnTaxBase: XmlElement;
        ReturnOtherTaxBase: XmlElement;
        TrxCode: XmlElement;
        TransactionDocumentData: XmlElement;
        TransactionDetailsData: XmlElement;
        FooterRow: XmlElement;
        ReturnTaxBaseTotal: XmlElement;
        ReturnOtherTaxBaseTotal: XmlElement;
        ReturnVATTotal: XmlElement;
        ReturnSTLGTotal: XmlElement;
    begin
        KreTaxSetup.FindFirst();
        KreTaxSetup.TestField("Tarif PPn Percentage");
        KreTaxSetup.TestField("DPP Nilai Lain (A)");
        KreTaxSetup.TestField("DPP Nilai Lain (B)");
        KRE_TAXJOUR.TestField(NPWP);
        Kre_TaxSetupRecref.GetTable(KreTaxSetup);

        TransactionDocumentData := XmlElement.Create('TransactionDocumentData');

        InvoiceNumber := XmlElement.Create('InvoiceNumber');
        InvoiceNumber.Add(KRE_TAXJOUR.TAXNUMBER);

        SellerTIN := XmlElement.Create('SellerTIN');
        if StrLen(KRE_TAXJOUR.NPWP) = 15 then
            SellerTIN.Add('0' + KRE_TAXJOUR.NPWP)
        else
            SellerTIN.Add(KRE_TAXJOUR.NPWP);

        ReturnDate := XmlElement.Create('ReturnDate');
        ReturnDate.Add(Format(KRE_TAXJOUR.RETURN_DATE, 0, '<Day,2>-<Month,2>-20<Year,2>'));

        ReturnTaxBase := XmlElement.Create('ReturnTaxBase');
        ReturnTaxBase.Add(Round(KRE_TAXJOUR.DPPAMOUNT, KreTaxSetup."Amount Decimal Places", SelectStr(KreTaxSetup."VAT Rounding Type" + 1, Kre_TaxSetupRecref.Field(6).OptionMembers)));

        ReturnOtherTaxBase := XmlElement.Create('ReturnOtherTaxBase');
        // ReturnOtherTaxBase.Add(Round(KreTaxSetup."DPP Nilai Lain (A)" / KreTaxSetup."DPP Nilai Lain (B)" * KRE_TAXJOUR.DPPAMOUNT, KreTaxSetup."Amount Decimal Places", SelectStr(KreTaxSetup."VAT Rounding Type" + 1, Kre_TaxSetupRecref.Field(6).OptionMembers)));
        ReturnOtherTaxBase.Add(Round(KRE_TAXJOUR.DPPAMOUNT, KreTaxSetup."Amount Decimal Places", SelectStr(KreTaxSetup."VAT Rounding Type" + 1, Kre_TaxSetupRecref.Field(6).OptionMembers)));

        ReturnVAT := XmlElement.Create('ReturnVAT');
        ReturnVAT.Add(Round(KRE_TAXJOUR.VATAMOUNT, KreTaxSetup."Amount Decimal Places", SelectStr(KreTaxSetup."VAT Rounding Type" + 1, Kre_TaxSetupRecref.Field(6).OptionMembers)));

        ReturnSTLG := XmlElement.Create('ReturnSTLG');
        ReturnSTLG.Add(0);

        TransactionDocumentData.Add(InvoiceNumber);
        TransactionDocumentData.Add(SellerTIN);
        TransactionDocumentData.Add(ReturnDate);
        TransactionDocumentData.Add(ReturnTaxBase);
        TransactionDocumentData.Add(ReturnOtherTaxBase);
        TransactionDocumentData.Add(ReturnVAT);
        TransactionDocumentData.Add(ReturnSTLG);

        TransactionDetailsData := XmlElement.Create('TransactionDetailsData');
        CreateRows(KRE_TAXJOUR, KreTaxSetup, Kre_TaxSetupRecref, TransactionDetailsData);

        FooterRow := XmlElement.Create('FooterRow');

        ReturnTaxBaseTotal := XmlElement.Create('ReturnTaxBaseTotal');
        ReturnTaxBaseTotal.Add(Round(KRE_TAXJOUR.DPPAMOUNT, KreTaxSetup."Amount Decimal Places", SelectStr(KreTaxSetup."VAT Rounding Type" + 1, Kre_TaxSetupRecref.Field(6).OptionMembers)));

        ReturnOtherTaxBaseTotal := XmlElement.Create('ReturnOtherTaxBaseTotal');
        // ReturnOtherTaxBaseTotal.Add(Round(KreTaxSetup."DPP Nilai Lain (A)" / KreTaxSetup."DPP Nilai Lain (B)" * KRE_TAXJOUR.DPPAMOUNT, KreTaxSetup."Amount Decimal Places", SelectStr(KreTaxSetup."VAT Rounding Type" + 1, Kre_TaxSetupRecref.Field(6).OptionMembers)));
        ReturnOtherTaxBaseTotal.Add(Round(KRE_TAXJOUR.DPPAMOUNT, KreTaxSetup."Amount Decimal Places", SelectStr(KreTaxSetup."VAT Rounding Type" + 1, Kre_TaxSetupRecref.Field(6).OptionMembers)));

        ReturnVATTotal := XmlElement.Create('ReturnVATTotal');
        ReturnVATTotal.Add(Round(KRE_TAXJOUR.VATAMOUNT, KreTaxSetup."Amount Decimal Places", SelectStr(KreTaxSetup."VAT Rounding Type" + 1, Kre_TaxSetupRecref.Field(6).OptionMembers)));

        ReturnSTLGTotal := XmlElement.Create('ReturnSTLGTotal');
        ReturnSTLGTotal.Add(0);

        FooterRow.Add(ReturnTaxBaseTotal);
        FooterRow.Add(ReturnOtherTaxBaseTotal);
        FooterRow.Add(ReturnVATTotal);
        FooterRow.Add(ReturnSTLGTotal);

        TransactionDetailsData.Add(FooterRow);

        InputReturnData.Add(TransactionDocumentData);
        InputReturnData.Add(TransactionDetailsData);
    end;

    local procedure CreateRows(var KRE_TAXJOUR: Record KRE_TAXJOUR; var KreTaxSetup: Record Kre_TaxSetup; var Kre_TaxSetupRecref: RecordRef; var TransactionDetailsData: XmlElement)
    var
        KRE_TAXJOURLINES: Record KRE_TAXJOURLINES;
        Item: Record Item;
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        UnitofMeasure: Record "Unit of Measure";
        Rows: XmlElement;
        Type: XmlElement;
        Name: XmlElement;
        Code: XmlElement;
        Quantity: XmlElement;
        Unit: XmlElement;
        UnitPrice: XmlElement;
        STLGRate: XmlElement;
        ReturnQuantity: XmlElement;
        ReturnDiscount: XmlElement;
        ReturnTaxBase: XmlElement;
        ReturnOtherTaxBase: XmlElement;
        ReturnOtherTaxBaseCheck: XmlElement;
        ReturnVAT: XmlElement;
        ReturnSTLG: XmlElement;
    begin
        Kre_TaxSetupRecref.GetTable(KreTaxSetup);
        KRE_TAXJOURLINES.SetRange(KRE_TAXJOURID, KRE_TAXJOUR.ID);
        if KRE_TAXJOURLINES.FindSet() then
            repeat
                Rows := XmlElement.Create('Rows');
                Type := XmlElement.Create('Type');
                Unit := XmlElement.Create('Unit');

                if Item.Get(KRE_TAXJOURLINES.ITEMID) then begin
                    if Item.Type = Item.Type::Inventory then begin
                        Type.Add('A');
                        if PurchCrMemoLine.Get(KRE_TAXJOURLINES.INVOICENO, KRE_TAXJOURLINES.INVOICELINENO) then
                            if UnitofMeasure.Get(PurchCrMemoLine."Unit of Measure Code") then begin
                                if UnitofMeasure."Kre Coretax Code" <> '' then
                                    Unit.Add(UnitofMeasure."Kre Coretax Code")
                                else
                                    Error('Coretax Code in UOM %1 is blank', UnitofMeasure.Code);
                            end else
                                Error(StrSubstNo('Unit of Measure %1 is not found', PurchCrMemoLine."Unit of Measure Code"));
                    end else begin
                        Type.Add('B');
                        Unit.Add('UM.0018');
                    end;
                end else begin
                    Type.Add('B');
                    Unit.Add('UM.0018');
                end;

                Name := XmlElement.Create('Name');
                Name.Add(KRE_TAXJOURLINES."Coretax Item Description");

                Code := XmlElement.Create('Code');
                if KRE_TAXJOURLINES."Coretax Item Code" <> '' then
                    Code.Add(KRE_TAXJOURLINES."Coretax Item Code")
                else begin
                    if Item."Coretax Code" <> '' then
                        Code.Add(Item."Coretax Code")
                    else
                        Code.Add('000000');
                end;

                Quantity := XmlElement.Create('Quantity');
                Quantity.Add(KRE_TAXJOURLINES.QTY);

                UnitPrice := XmlElement.Create('UnitPrice');
                UnitPrice.Add(format(Round(KRE_TAXJOURLINES.PRICE, KreTaxSetup."Amount Decimal Places", SelectStr(KreTaxSetup."VAT Rounding Type" + 1, Kre_TaxSetupRecref.Field(6).OptionMembers)), 0, 1));

                STLGRate := XmlElement.Create('STLGRate');
                STLGRate.Add(0);

                ReturnQuantity := XmlElement.Create('ReturnQuantity');
                ReturnQuantity.Add(KRE_TAXJOURLINES.QTY);

                ReturnDiscount := XmlElement.Create('ReturnDiscount');
                ReturnDiscount.Add(format(Round(KRE_TAXJOURLINES.DISCOUNT_AMOUNT, KreTaxSetup."Amount Decimal Places", SelectStr(KreTaxSetup."VAT Rounding Type" + 1, Kre_TaxSetupRecref.Field(6).OptionMembers)), 0, 1));

                ReturnTaxBase := XmlElement.Create('ReturnTaxBase');
                ReturnTaxBase.Add(format(Round(KRE_TAXJOURLINES.DPP_AMOUNT, KreTaxSetup."Amount Decimal Places", SelectStr(KreTaxSetup."VAT Rounding Type" + 1, Kre_TaxSetupRecref.Field(6).OptionMembers)), 0, 1));

                ReturnOtherTaxBase := XmlElement.Create('ReturnOtherTaxBase');
                // ReturnOtherTaxBase.Add(format(Round(Kre_TaxSetup."DPP Nilai Lain (A)" / Kre_TaxSetup."DPP Nilai Lain (B)" * KRE_TAXJOURLINES.DPP_AMOUNT, Kre_TaxSetup."Amount Decimal Places", SelectStr(Kre_TaxSetup."VAT Rounding Type" + 1, Kre_TaxSetupRecref.Field(6).OptionMembers)), 0, 1));
                ReturnOtherTaxBase.Add(0);

                ReturnOtherTaxBaseCheck := XmlElement.Create('ReturnOtherTaxBaseCheck');
                ReturnOtherTaxBaseCheck.Add('false');

                ReturnVAT := XmlElement.Create('ReturnVAT');
                ReturnVAT.Add(Round(KRE_TAXJOURLINES.VAT_AMOUNT, KreTaxSetup."Amount Decimal Places", SelectStr(KreTaxSetup."VAT Rounding Type" + 1, Kre_TaxSetupRecref.Field(6).OptionMembers)));

                ReturnSTLG := XmlElement.Create('ReturnSTLG');
                ReturnSTLG.Add(0);

                Rows.Add(Type);
                Rows.Add(Name);
                Rows.Add(Code);
                Rows.Add(Quantity);
                Rows.Add(Unit);
                Rows.Add(UnitPrice);
                Rows.Add(STLGRate);
                Rows.Add(ReturnQuantity);
                Rows.Add(ReturnDiscount);
                Rows.Add(ReturnTaxBase);
                Rows.Add(ReturnOtherTaxBase);
                Rows.Add(ReturnOtherTaxBaseCheck);
                Rows.Add(ReturnVAT);
                Rows.Add(ReturnSTLG);

                TransactionDetailsData.Add(Rows);
            until KRE_TAXJOURLINES.Next() = 0;
    end;

}