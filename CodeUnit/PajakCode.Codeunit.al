codeunit 60001 PajakCode
{
    Permissions = TableData "VAT Entry" = RM;
    procedure TaxSynch(StartDate: Date; EndDate: Date)
    var
        TaxSetup: Record Kre_TaxSetup;
        SourceTable: Query KreVATEntry;
        //SourceTable: Record "VAT Entry";
        //MappingSourceTable: Record KRE_VATEntryTaxJour;
        Vendor: Record Vendor;
        Customer: Record Customer;
        CustomerAddress: Record Customer;
        "Posted Purchase Invoice": Record "Purch. Inv. Header";
        PurchLineInv: Record "Purch. Inv. Line";
        "Posted Purchase Credit Memos": Record "Purch. Cr. Memo Hdr.";
        PurchLineCM: Record "Purch. Cr. Memo Line";
        "Posted Sales Invoices": Record "Sales Invoice Header";
        SalesLineInv: Record "Sales Invoice Line";
        "Posted Service Invoices": Record "Service Invoice Header";
        ServiceLineInv: Record "Service Invoice Line";
        "Posted Sales Credit Memos": Record "Sales Cr.Memo Header";
        SalesLineCM: Record "Sales Cr.Memo Line";
        "Posted Service Credit Memos": Record "Service Cr.Memo Header";
        ServiceLineCM: Record "Service Cr.Memo Line";
        // identity: Integer;
        TaxJour: Record KRE_TAXJOUR;
        TaxJourLines: Record KRE_TAXJOURLINES;
        VATGroup: Record "VAT Product Posting Group";
        GeneralLedgerSetup: Record "General Ledger Setup";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        SelisihVAT1: Decimal;
        SelisihVAT2: Decimal;
        SelisihVAT3: Decimal;
        SelisihVAT4: Decimal;
        SelisihVAT5: Decimal;
        SelisihVAT6: Decimal;
        shiptoaddress: Record "Ship-to Address";
        SourceCurrencyCode: Code[10];
        SourceCurrencyAmount: Decimal;
        SourceCurrencyAmountInclVAT: Decimal;
    begin

        if not TaxSetup.FindFirst() then begin
            Error('Please Setup Tax Config first !');
            exit;
        end;
        GeneralLedgerSetup.FindFirst();
        // SourceTable.Reset();
        // SourceTable.SetFilter("Document No.", '<> %1', MappingSourceTable.INVOICENO);
        // SourceTable.SetFilter(Amount, '<> %1', 0);// untuk demo amount pajak 0
        // SourceTable.SetRange(Is_Synch, false);
        // SourceTable.SetFilter(Type, '<> %1', 0);
        // SourceTable.SetFilter(Bill_to_Pay_to_No_, '<> %1', '');
        SourceTable.SetRange(SourceTable.Posting_Date, StartDate, EndDate);
        SourceTable.Open();
        while SourceTable.READ() do begin
            CustomerRetail := false;
            if SourceTable.Type = SourceTable.Type::Sale then
                if Customer.Get(SourceTable.Bill_to_Pay_to_No_) then
                    if Customer."Retail Customer" then
                        CustomerRetail := true;
            TaxJour.LockTable();
            // repeat
            TaxJour.SetFilter(INVOICENO, '=%1', SourceTable.Document_No_);
            if (not TaxJour.FindSet()) and (not CustomerRetail) then begin
                Clear(TaxJour);
                TaxJour.Init();
                TaxJour.INVOICENO := SourceTable.Document_No_;
                TaxJour.INVOICEDATE := SourceTable.Document_Date;
                TaxJour.DOCUMENTNO := SourceTable.External_Document_No_;
                TaxJour."VAT Bus. Posting Group" := SourceTable.VAT_Bus__Posting_Group;
                TaxJour."VAT Calculation Type" := SourceTable.VAT_Calculation_Type;
                TaxJour."VAT Prod. Posting Group" := SourceTable.VAT_Prod__Posting_Group;

                //Get Customer / Vendor
                case SourceTable.Type of
                    SourceTable.Type::Purchase:
                        begin
                            if Vendor.Get(SourceTable.Bill_to_Pay_to_No_) then begin
                                TaxJour.ACCOUNTID := Vendor."No.";
                                GetVendorID(Vendor, TaxJour);
                                TaxJour.NAMA := Vendor.NamaNPWP;
                                TaxJour.ALAMATNPWP := Vendor.AlamatNPWP;
                                TaxJour.TAX_SOURCE := TaxJour.TAX_SOURCE::Purchase;
                            end
                        end;
                    SourceTable.Type::Sale:
                        begin
                            if Customer.Get(SourceTable.Bill_to_Pay_to_No_) then begin
                                TaxJour.ACCOUNTID := Customer."No.";
                                GetCustomerID(Customer, TaxJour);
                                TaxJour.NAMA := Customer.NamaNPWP;
                                //Alamat NPWP pindah ke bawah
                                TaxJour.TAX_SOURCE := TaxJour.TAX_SOURCE::Sales;
                                TaxJour."Kode Transaksi" := CopyStr(Format(Customer.PrefixWAPU), 1, 2);
                            end
                        end;
                end;
                //End of Get Customer / Vendor

                case SourceTable.Document_Type of
                    SourceTable.Document_Type::Invoice:
                        begin
                            TaxJour.IS_CREDITABLE := 1;
                            TaxJour.IS_RETURNITEM := TaxJour.IS_RETURNITEM::NO;
                        end;
                    SourceTable.Document_Type::"Credit Memo":
                        begin
                            TaxJour.IS_CREDITABLE := 0;
                            TaxJour.IS_RETURNITEM := TaxJour.IS_RETURNITEM::YES;
                        end;
                end;

                if TaxSetup.Activate_VAT_In then  //Pajak Masukan
                    if SourceTable.Type = SourceTable.Type::Purchase then begin
                        //Get Tax Number and Tax Date
                        "Posted Purchase Invoice".SetRange("No.", SourceTable.Document_No_);
                        if "Posted Purchase Invoice".FindFirst() then begin
                            "Posted Purchase Invoice".Get(SourceTable.Document_No_);
                            TaxJour.TAXNUMBER := "Posted Purchase Invoice".TAXNUMBER;
                            TaxJour.TAXDATE := "Posted Purchase Invoice".TAXDATE;
                            TaxJour.CURRENCY := "Posted Purchase Invoice"."Currency Code";
                            "Posted Purchase Invoice".CalcFields("Amount Including VAT", Amount);
                            SourceCurrencyAmountInclVAT := "Posted Purchase Invoice"."Amount Including VAT";
                            SourceCurrencyAmount := "Posted Purchase Invoice".Amount;
                        end;
                        //End of Get Tax Number and Tax Date
                        //Get Tax Number and Tax Date
                        "Posted Purchase Credit Memos".SetRange("No.", SourceTable.Document_No_);
                        if "Posted Purchase Credit Memos".FindFirst() then begin
                            "Posted Purchase Credit Memos".Get(SourceTable.Document_No_);
                            TaxJour.RETURN_TAX_NUMBER := "Posted Purchase Credit Memos".RETURN_TAX_NUMBER;
                            TaxJour.RETURN_DATE := "Posted Purchase Credit Memos".RETURN_DATE;
                            TaxJour.RETURN_DOC_NUMBER := "Posted Purchase Credit Memos".RETURN_DOC_NUMBER;
                            TaxJour.CURRENCY := "Posted Purchase Credit Memos"."Currency Code";
                            "Posted Purchase Credit Memos".CalcFields("Amount Including VAT", Amount);
                            SourceCurrencyAmountInclVAT := "Posted Purchase Credit Memos"."Amount Including VAT";
                            SourceCurrencyAmount := "Posted Purchase Credit Memos".Amount;
                        end;
                        //End of Get Tax Number and Tax Date

                        // if GeneralLedgerSetup."LCY Code" <> TaxJour.CURRENCY then begin
                        //     CurrencyExchangeRate.SetRange("Currency Code", TaxJour.CURRENCY);
                        //     CurrencyExchangeRate.SetFilter("Starting Date", '..%1', SourceTable.Posting_Date);
                        //     CurrencyExchangeRate.FindLast();
                        //     TaxJour.DPPAMOUNT := SourceCurrencyAmount * CurrencyExchangeRate."Kre Tax Rate";
                        //     TaxJour.VATAMOUNT := (SourceCurrencyAmountInclVAT - SourceCurrencyAmount) * CurrencyExchangeRate."Kre Tax Rate";
                        //     TaxJour.INVOICEAMOUNT := SourceCurrencyAmountInclVAT * CurrencyExchangeRate."Kre Tax Rate";
                        // end else begin
                        //     TaxJour.DPPAMOUNT := system.ABS(SourceTable.Base);
                        //     TaxJour.VATAMOUNT := system.ABS(SourceTable.Amount);
                        //     TaxJour.INVOICEAMOUNT := SourceCurrencyAmount;
                        // end;
                        TaxJour.TAX_POSTED := TaxJour.TAX_POSTED::NO;
                        TaxJour.TAX_EXPORTED := TaxJour.TAX_EXPORTED::NO;
                        TaxJour.Insert();
                        //insert data vat entry
                        //InsertVATEntryMapping(SourceTable."Document No.");
                        //insert data vat entry
                        //Detail
                        PurchLineInv.Reset();
                        PurchLineInv.SetRange("Document No.", SourceTable.Document_No_);
                        PurchLineInv.SetRange(IsWHTCalc, false);
                        PurchLineInv.SetFilter("Type", '<> %1', PurchLineInv.Type::" ");
                        PurchLineInv.SetFilter("VAT Prod. Posting Group", '<> %1', 'NO VAT');
                        PurchLineInv.SetFilter(Quantity, '> %1', 0);
                        //Validasi VAT Amount Header dgn Line 
                        if PurchLineInv.IsEmpty = false then
                            SelisihVAT1 := ValidasiVATAmountPurchaseLineInv(SourceTable.Document_No_, PurchLineInv);
                        //Validasi VAT Amount Header dgn Line 
                        if PurchLineInv.FindSet() then begin
                            TaxJourLines.LockTable();
                            repeat
                                TaxJourLines.Init();
                                Clear(TaxJourLines.ID);
                                TaxJourLines.KRE_TAXJOURID := GetLastID();
                                TaxJourLines.INVOICELINENO := PurchLineInv."Line No.";
                                TaxJourLines.INVOICENo := SourceTable.Document_No_;
                                TaxJourLines.TYPE := PurchLineInv.Type;
                                TaxJourLines.ITEMID := PurchLineInv."No.";
                                TaxJourLines.DESCRIPTION := PurchLineInv.Description;
                                TaxJourLines.VAT_Bus_Posting_Group := PurchLineInv."VAT Bus. Posting Group";
                                TaxJourLines.VAT_Prod_Posting_Group := PurchLineInv."VAT Prod. Posting Group";
                                TaxJourLines.VAT_Identifier := PurchLineInv."VAT Identifier";
                                TaxJourLines.QTY := system.Round(PurchLineInv.Quantity, 1, '>');
                                // TaxJourLines.TOTAL_AMOUNT := PurchLineInv."Line Amount";
                                if (GeneralLedgerSetup."LCY Code" <> "Posted Purchase Invoice"."Currency Code") and ("Posted Purchase Invoice"."Currency Code" <> '') then begin
                                    CurrencyExchangeRate.SetRange("Currency Code", "Posted Purchase Invoice"."Currency Code");
                                    CurrencyExchangeRate.SetFilter("Starting Date", '..%1', "Posted Purchase Invoice"."Posting Date");
                                    CurrencyExchangeRate.FindLast();
                                    TaxJourLines.DPP_AMOUNT := PurchLineInv."VAT Base Amount" * CurrencyExchangeRate."Kre Tax Rate";
                                    if SelisihVAT1 > 0 then
                                        if PurchLineInv."Line No." = 10000 then
                                            TaxJourLines.VAT_AMOUNT := (((PurchLineInv."VAT Base Amount" * PurchLineInv."VAT %") / 100) - SelisihVAT1) * CurrencyExchangeRate."Kre Tax Rate"
                                        else
                                            TaxJourLines.VAT_AMOUNT := ((PurchLineInv."VAT Base Amount" * PurchLineInv."VAT %") / 100) * CurrencyExchangeRate."Kre Tax Rate"
                                    else
                                        TaxJourLines.VAT_AMOUNT := ((PurchLineInv."VAT Base Amount" * PurchLineInv."VAT %") / 100) * CurrencyExchangeRate."Kre Tax Rate";
                                    TaxJourLines.TOTAL_AMOUNT := PurchLineInv."Amount Including VAT" * CurrencyExchangeRate."Kre Tax Rate";
                                    TaxJourLines.DISCOUNT_AMOUNT := PurchLineInv."Line Discount Amount" * CurrencyExchangeRate."Kre Tax Rate";
                                    TaxJourLines.PRICE := (PurchLineInv."VAT Base Amount" / PurchLineInv.Quantity) * CurrencyExchangeRate."Kre Tax Rate";
                                end else begin
                                    TaxJourLines.PRICE := (PurchLineInv."VAT Base Amount" / PurchLineInv.Quantity);
                                    TaxJourLines.DPP_AMOUNT := PurchLineInv."VAT Base Amount";
                                    if SelisihVAT1 > 0 then
                                        if PurchLineInv."Line No." = 10000 then
                                            TaxJourLines.VAT_AMOUNT := ((PurchLineInv."VAT Base Amount" * PurchLineInv."VAT %") / 100) - SelisihVAT1
                                        else
                                            TaxJourLines.VAT_AMOUNT := ((PurchLineInv."VAT Base Amount" * PurchLineInv."VAT %") / 100)
                                    else
                                        TaxJourLines.VAT_AMOUNT := ((PurchLineInv."VAT Base Amount" * PurchLineInv."VAT %") / 100);
                                    TaxJourLines.TOTAL_AMOUNT := PurchLineInv."Amount Including VAT";
                                    TaxJourLines.DISCOUNT_AMOUNT := PurchLineInv."Line Discount Amount";
                                end;

                                TaxJourLines."Currency Code" := "Posted Purchase Invoice"."Currency Code";
                                TaxJourLines.Insert();
                            until (PurchLineInv.Next() = 0);
                        end;
                        //Detail
                        PurchLineCM.Reset();
                        PurchLineCM.SetRange("Document No.", SourceTable.Document_No_);
                        PurchLineCM.SetRange(IsWHTCalc, false);
                        PurchLineCM.SetFilter("Type", '<> %1', PurchLineCM.Type::" ");
                        PurchLineCM.SetFilter("VAT Prod. Posting Group", '<> %1', 'NO VAT');
                        PurchLineCM.SetFilter(Quantity, '> %1', 0);
                        //Validasi VAT Amount Header dgn Line 
                        if PurchLineCM.IsEmpty = false then
                            SelisihVAT2 := ValidasiVATAmountPurchaseLineCM(SourceTable.Document_No_, PurchLineCM);
                        //Validasi VAT Amount Header dgn Line 
                        if PurchLineCM.FindSet() then begin
                            TaxJourLines.LockTable();
                            repeat
                                TaxJourLines.Init();
                                Clear(TaxJourLines.ID);
                                TaxJourLines.KRE_TAXJOURID := GetLastID();
                                TaxJourLines.INVOICELINENO := PurchLineCM."Line No.";
                                TaxJourLines.INVOICENo := SourceTable.Document_No_;
                                TaxJourLines.TYPE := PurchLineCM.Type;
                                TaxJourLines.ITEMID := PurchLineCM."No.";
                                TaxJourLines.DESCRIPTION := PurchLineCM.Description;
                                TaxJourLines.VAT_Bus_Posting_Group := PurchLineCM."VAT Bus. Posting Group";
                                TaxJourLines.VAT_Prod_Posting_Group := PurchLineCM."VAT Prod. Posting Group";
                                TaxJourLines.VAT_Identifier := PurchLineCM."VAT Identifier";
                                TaxJourLines.QTY := system.Round(PurchLineCM.Quantity, 1, '>');
                                TaxJourLines.DPP_AMOUNT := PurchLineCM."VAT Base Amount";
                                TaxJourLines."Coretax Item Code" := PurchLineCM."Coretax Item Code";
                                TaxJourLines."Coretax Item Description" := PurchLineCM."Coretax Item Description";

                                if (GeneralLedgerSetup."LCY Code" <> "Posted Purchase Credit Memos"."Currency Code") and ("Posted Purchase Credit Memos"."Currency Code" <> '') then begin
                                    CurrencyExchangeRate.SetRange("Currency Code", "Posted Purchase Credit Memos"."Currency Code");
                                    CurrencyExchangeRate.SetFilter("Starting Date", '..%1', "Posted Purchase Credit Memos"."Posting Date");
                                    CurrencyExchangeRate.FindLast();
                                    TaxJourLines.DPP_AMOUNT := PurchLineCM."VAT Base Amount" * CurrencyExchangeRate."Kre Tax Rate";
                                    if SelisihVAT2 > 0 then
                                        if PurchLineCM."Line No." = 10000 then
                                            TaxJourLines.VAT_AMOUNT := (((PurchLineCM."VAT Base Amount" * PurchLineCM."VAT %") / 100) - SelisihVAT2) * CurrencyExchangeRate."Kre Tax Rate"
                                        else
                                            TaxJourLines.VAT_AMOUNT := ((PurchLineCM."VAT Base Amount" * PurchLineCM."VAT %") / 100) * CurrencyExchangeRate."Kre Tax Rate"
                                    else
                                        TaxJourLines.VAT_AMOUNT := ((PurchLineCM."VAT Base Amount" * PurchLineCM."VAT %") / 100) * CurrencyExchangeRate."Kre Tax Rate";
                                    TaxJourLines.TOTAL_AMOUNT := PurchLineCM."Amount Including VAT" * CurrencyExchangeRate."Kre Tax Rate";
                                    TaxJourLines.DISCOUNT_AMOUNT := PurchLineCM."Line Discount Amount" * CurrencyExchangeRate."Kre Tax Rate";
                                    TaxJourLines.PRICE := (PurchLineCM."VAT Base Amount" / PurchLineCM.Quantity) * CurrencyExchangeRate."Kre Tax Rate";
                                end else begin
                                    TaxJourLines.DPP_AMOUNT := PurchLineCM."VAT Base Amount";
                                    if SelisihVAT2 > 0 then
                                        if PurchLineCM."Line No." = 10000 then
                                            TaxJourLines.VAT_AMOUNT := ((PurchLineCM."VAT Base Amount" * PurchLineCM."VAT %") / 100) - SelisihVAT2
                                        else
                                            TaxJourLines.VAT_AMOUNT := ((PurchLineCM."VAT Base Amount" * PurchLineCM."VAT %") / 100)
                                    else
                                        TaxJourLines.VAT_AMOUNT := ((PurchLineCM."VAT Base Amount" * PurchLineCM."VAT %") / 100);
                                    TaxJourLines.TOTAL_AMOUNT := PurchLineCM."Amount Including VAT";
                                    TaxJourLines.DISCOUNT_AMOUNT := PurchLineCM."Line Discount Amount";
                                    TaxJourLines.PRICE := (PurchLineCM."VAT Base Amount" / PurchLineCM.Quantity);
                                end;
                                TaxJourLines."Currency Code" := "Posted Purchase Credit Memos"."Currency Code";
                                TaxJourLines.Insert();
                            until (PurchLineCM.Next() = 0);
                        end;
                    end;

                if TaxSetup.Activate_VAT_Out then  //Pajak Keluaran
                    if SourceTable.Type = SourceTable.Type::Sale then begin
                        //IsNull TaxNumber diambil dari register tax number dan taxdate input manual
                        "Posted Sales Invoices".SetRange("No.", SourceTable.Document_No_);
                        if "Posted Sales Invoices".FindFirst() then begin
                            "Posted Sales Invoices".Get(SourceTable.Document_No_);
                            TaxJour.TAXNUMBER := "Posted Sales Invoices".TAXNUMBER;
                            TaxJour.TAXDATE := "Posted Sales Invoices".TAXDATE;
                            TaxJour.CURRENCY := "Posted Sales Invoices"."Currency Code";
                            //update pajak 5.3
                            if CustomerAddress.Get("Posted Sales Invoices"."Sell-to Customer No.") then
                                if CustomerAddress.NPWPAddressfromShipTo then begin
                                    shiptoaddress.SetRange("Customer No.", "Posted Sales Invoices"."Sell-to Customer No.");
                                    shiptoaddress.SetRange("Code", "Posted Sales Invoices"."Ship-to Code");
                                    if shiptoaddress.FindFirst() then begin
                                        TaxJour.ALAMATNPWP := shiptoaddress.AlamatNPWP;
                                        TaxJour."ID TKU Pembeli" := shiptoaddress."ID TKU";
                                        TaxJour."Ship-to Code" := shiptoaddress.Code;
                                    end;
                                end else begin
                                    TaxJour.ALAMATNPWP := CustomerAddress.AlamatNPWP;
                                    TaxJour."ID TKU Pembeli" := CustomerAddress."ID TKU"
                                end;

                            if "Posted Sales Invoices"."Order No." = '' then
                                TaxJour.Kode_Dokumen_Pendukung := "Posted Sales Invoices"."External Document No."
                            else
                                TaxJour.Kode_Dokumen_Pendukung := "Posted Sales Invoices"."External Document No.";
                            TaxJour."Location Code" := "Posted Sales Invoices"."Location Code";
                            TaxJour."Pre-Assigned No." := "Posted Sales Invoices"."Pre-Assigned No.";
                            "Posted Sales Invoices".CalcFields("Amount Including VAT", Amount);
                            SourceCurrencyAmountInclVAT := "Posted Sales Invoices"."Amount Including VAT";
                            SourceCurrencyAmount := "Posted Sales Invoices".Amount;
                        end;
                        //End of IsNull TaxNumber diambil dari register tax number dan taxdate input manual
                        //retur taxNumber dan retur date input manual
                        "Posted Sales Credit Memos".SetRange("No.", SourceTable.Document_No_);
                        if "Posted Sales Credit Memos".FindFirst() then begin
                            "Posted Sales Credit Memos".Get(SourceTable.Document_No_);
                            TaxJour.RETURN_TAX_NUMBER := "Posted Sales Credit Memos".RETURN_TAX_NUMBER;
                            TaxJour.RETURN_DATE := "Posted Sales Credit Memos".RETURN_DATE;
                            TaxJour.RETURN_DOC_NUMBER := "Posted Sales Credit Memos".RETURN_DOC_NUMBER;
                            TaxJour.CURRENCY := "Posted Sales Credit Memos"."Currency Code";
                            //update pajak 5.3
                            if CustomerAddress.Get("Posted Sales Credit Memos"."Sell-to Customer No.") then
                                if CustomerAddress.NPWPAddressfromShipTo then begin
                                    shiptoaddress.SetRange("Customer No.", "Posted Sales Credit Memos"."Sell-to Customer No.");
                                    shiptoaddress.SetRange("Code", "Posted Sales Credit Memos"."Ship-to Code");
                                    if shiptoaddress.FindFirst() then begin
                                        TaxJour.ALAMATNPWP := shiptoaddress.AlamatNPWP;
                                        TaxJour."ID TKU Pembeli" := shiptoaddress."ID TKU";
                                        TaxJour."Ship-to Code" := shiptoaddress.Code;
                                    end;
                                end else begin
                                    TaxJour.ALAMATNPWP := CustomerAddress.AlamatNPWP;
                                    TaxJour."ID TKU Pembeli" := CustomerAddress."ID TKU"
                                end;
                            "Posted Sales Credit Memos".CalcFields("Amount Including VAT", Amount);
                            SourceCurrencyAmountInclVAT := "Posted Sales Credit Memos"."Amount Including VAT";
                            SourceCurrencyAmount := "Posted Sales Credit Memos".Amount;
                        end;
                        //End of retur taxNumber dan retur date input manual
                        "Posted Service Invoices".SetRange("No.", SourceTable.Document_No_);
                        if "Posted Service Invoices".FindFirst() then begin
                            "Posted Service Invoices".Get(SourceTable.Document_No_);
                            TaxJour.TAXNUMBER := "Posted Service Invoices".TAXNUMBER;
                            TaxJour.TAXDATE := "Posted Service Invoices".TAXDATE;
                            TaxJour.CURRENCY := "Posted Service Invoices"."Currency Code";
                            //update pajak 5.3
                            if CustomerAddress.Get("Posted Service Invoices"."Customer No.") then
                                if CustomerAddress.NPWPAddressfromShipTo then begin
                                    shiptoaddress.SetRange("Customer No.", "Posted Service Invoices"."Customer No.");
                                    shiptoaddress.SetRange("Code", "Posted Service Invoices"."Ship-to Code");
                                    if shiptoaddress.FindFirst() then begin
                                        TaxJour.ALAMATNPWP := shiptoaddress.AlamatNPWP;
                                        TaxJour."ID TKU Pembeli" := shiptoaddress."ID TKU";
                                        TaxJour."Ship-to Code" := shiptoaddress.Code;
                                    end;
                                end else begin
                                    TaxJour.ALAMATNPWP := CustomerAddress.AlamatNPWP;
                                    TaxJour."ID TKU Pembeli" := CustomerAddress."ID TKU"
                                end;

                            if "Posted Sales Invoices"."Order No." = '' then
                                TaxJour.Kode_Dokumen_Pendukung := "Posted Sales Invoices"."External Document No."
                            else
                                TaxJour.Kode_Dokumen_Pendukung := "Posted Sales Invoices"."External Document No.";
                            "Posted Service Invoices".CalcFields("Amount Including VAT", Amount);
                            SourceCurrencyAmountInclVAT := "Posted Service Invoices"."Amount Including VAT";
                            SourceCurrencyAmount := "Posted Service Invoices".Amount;
                        end;
                        //End of retur taxNumber dan retur date input manual
                        "Posted Service Credit Memos".SetRange("No.", SourceTable.Document_No_);
                        if "Posted Service Credit Memos".FindFirst() then begin
                            "Posted Service Credit Memos".Get(SourceTable.Document_No_);
                            TaxJour.RETURN_TAX_NUMBER := "Posted Service Credit Memos".RETURN_TAX_NUMBER;
                            TaxJour.RETURN_DATE := "Posted Service Credit Memos".RETURN_DATE;
                            TaxJour.RETURN_DOC_NUMBER := "Posted Service Credit Memos".RETURN_DOC_NUMBER;
                            TaxJour.CURRENCY := "Posted Service Credit Memos"."Currency Code";
                            "Posted Service Credit Memos".CalcFields("Amount Including VAT", Amount);
                            SourceCurrencyAmountInclVAT := "Posted Service Credit Memos"."Amount Including VAT";
                            SourceCurrencyAmount := "Posted Service Credit Memos".Amount;
                        end;
                        // if GeneralLedgerSetup."LCY Code" <> TaxJour.CURRENCY then begin
                        //     CurrencyExchangeRate.SetRange("Currency Code", TaxJour.CURRENCY);
                        //     CurrencyExchangeRate.SetFilter("Starting Date", '..%1', SourceTable.Posting_Date);
                        //     CurrencyExchangeRate.FindLast();
                        //     VATGroup.Reset();
                        //     VATGroup.SetRange("Code", SourceTable.VAT_Prod__Posting_Group);
                        //     VATGroup.FindFirst();
                        //     if (VATGroup.IS_FORWARDER = true) then
                        //         TaxJour.DPPAMOUNT := (SourceCurrencyAmount / 10) * CurrencyExchangeRate."Kre Tax Rate"
                        //     else
                        //         TaxJour.DPPAMOUNT := SourceCurrencyAmount * CurrencyExchangeRate."Kre Tax Rate";
                        //     TaxJour.VATAMOUNT := (SourceCurrencyAmountInclVAT - SourceCurrencyAmount) * CurrencyExchangeRate."Kre Tax Rate";
                        //     TaxJour.INVOICEAMOUNT := SourceCurrencyAmountInclVAT * CurrencyExchangeRate."Kre Tax Rate";
                        // end else begin
                        //     VATGroup.Reset();
                        //     VATGroup.SetRange("Code", SourceTable.VAT_Prod__Posting_Group);
                        //     VATGroup.FindFirst();
                        //     if (VATGroup.IS_FORWARDER = true) then
                        //         TaxJour.DPPAMOUNT := system.ABS(SourceTable.Base) / 10
                        //     else
                        //         TaxJour.DPPAMOUNT := system.ABS(SourceTable.Base);
                        //     TaxJour.VATAMOUNT := system.ABS(SourceTable.Amount);
                        //     TaxJour.INVOICEAMOUNT := system.ABS(SourceTable.Base + SourceTable.Amount);
                        // end;

                        TaxJour.TAX_POSTED := TaxJour.TAX_POSTED::NO;
                        TaxJour.TAX_EXPORTED := TaxJour.TAX_EXPORTED::NO;
                        TaxJour.Insert();
                        //insert data vat entry
                        //InsertVATEntryMapping(SourceTable."Document No.");
                        //insert data vat entry
                        //Detail
                        SalesLineInv.Reset();
                        SalesLineInv.SetRange("Document No.", SourceTable.Document_No_);
                        SalesLineInv.SetRange(IsWHTCalc, false);
                        SalesLineInv.SetFilter("Type", '<> %1', SalesLineInv.Type::" ");
                        SalesLineInv.SetFilter("VAT Prod. Posting Group", '<> %1', 'NO VAT');
                        SalesLineInv.SetFilter(Quantity, '> %1', 0);
                        //Validasi VAT Amount Header dgn Line 
                        if SalesLineInv.IsEmpty = false then
                            SelisihVAT3 := ValidasiVATAmountSalesLineInv(SourceTable.Document_No_, SalesLineInv);
                        //Validasi VAT Amount Header dgn Line 
                        if SalesLineInv.FindSet() then begin
                            TaxJourLines.LockTable();
                            repeat
                                TaxJourLines.Init();
                                Clear(TaxJourLines.ID);
                                TaxJourLines.KRE_TAXJOURID := GetLastID();
                                TaxJourLines.INVOICELINENO := SalesLineInv."Line No.";
                                TaxJourLines.INVOICENo := SourceTable.Document_No_;
                                TaxJourLines.TYPE := SalesLineInv.Type;
                                TaxJourLines.ITEMID := SalesLineInv."No.";
                                TaxJourLines.DESCRIPTION := SalesLineInv.Description;
                                OnInsertDescriptionOnTaxSynch(TaxJourLines, SalesLineInv);
                                TaxJourLines.VAT_Bus_Posting_Group := SalesLineInv."VAT Bus. Posting Group";
                                TaxJourLines.VAT_Prod_Posting_Group := SalesLineInv."VAT Prod. Posting Group";
                                TaxJourLines.VAT_Identifier := SalesLineInv."VAT Identifier";
                                TaxJourLines.QTY := system.Round(SalesLineInv.Quantity, 1, '>');
                                TaxJourLines."Coretax Item Code" := SalesLineInv."Coretax Item Code";
                                TaxJourLines."Coretax Item Description" := SalesLineInv."Coretax Item Description";

                                if (GeneralLedgerSetup."LCY Code" <> "Posted Sales Invoices"."Currency Code") and ("Posted Sales Invoices"."Currency Code" <> '') then begin
                                    CurrencyExchangeRate.SetRange("Currency Code", "Posted Sales Invoices"."Currency Code");
                                    CurrencyExchangeRate.SetFilter("Starting Date", '..%1', "Posted Sales Invoices"."Posting Date");
                                    CurrencyExchangeRate.FindLast();
                                    VATGroup.Reset();
                                    VATGroup.SetRange("Code", SourceTable.VAT_Prod__Posting_Group);
                                    VATGroup.FindFirst();
                                    if (VATGroup.IS_FORWARDER = true) then
                                        TaxJourLines.DPP_AMOUNT := (SalesLineInv."VAT Base Amount" / 10) * CurrencyExchangeRate."Kre Tax Rate"
                                    else
                                        TaxJourLines.DPP_AMOUNT := SalesLineInv."VAT Base Amount" * CurrencyExchangeRate."Kre Tax Rate";

                                    if SelisihVAT3 > 0 then begin
                                        if SalesLineInv."Line No." = 10000 then
                                            TaxJourLines.VAT_AMOUNT := (((SalesLineInv."VAT Base Amount" * SalesLineInv."VAT %") / 100) - SelisihVAT3) * CurrencyExchangeRate."Kre Tax Rate"
                                        else
                                            TaxJourLines.VAT_AMOUNT := ((SalesLineInv."VAT Base Amount" * SalesLineInv."VAT %") / 100) * CurrencyExchangeRate."Kre Tax Rate";
                                    end
                                    else
                                        TaxJourLines.VAT_AMOUNT := ((SalesLineInv."VAT Base Amount" * SalesLineInv."VAT %") / 100) * CurrencyExchangeRate."Kre Tax Rate";
                                    TaxJourLines.TOTAL_AMOUNT := SalesLineInv."Amount Including VAT" * CurrencyExchangeRate."Kre Tax Rate";
                                    TaxJourLines.DISCOUNT_AMOUNT := SalesLineInv."Line Discount Amount" * CurrencyExchangeRate."Kre Tax Rate";
                                    TaxJourLines.PRICE := (SalesLineInv."VAT Base Amount" / SalesLineInv.Quantity) * CurrencyExchangeRate."Kre Tax Rate";
                                end else begin
                                    VATGroup.Reset();
                                    VATGroup.SetRange("Code", SourceTable.VAT_Prod__Posting_Group);
                                    VATGroup.FindFirst();
                                    if (VATGroup.IS_FORWARDER = true) then
                                        TaxJourLines.DPP_AMOUNT := SalesLineInv."VAT Base Amount" / 10
                                    else
                                        TaxJourLines.DPP_AMOUNT := SalesLineInv."VAT Base Amount";

                                    if SelisihVAT3 > 0 then begin
                                        if SalesLineInv."Line No." = 10000 then
                                            TaxJourLines.VAT_AMOUNT := ((SalesLineInv."VAT Base Amount" * SalesLineInv."VAT %") / 100) - SelisihVAT3
                                        else
                                            TaxJourLines.VAT_AMOUNT := ((SalesLineInv."VAT Base Amount" * SalesLineInv."VAT %") / 100);
                                    end
                                    else
                                        TaxJourLines.VAT_AMOUNT := ((SalesLineInv."VAT Base Amount" * SalesLineInv."VAT %") / 100);
                                    TaxJourLines.TOTAL_AMOUNT := SalesLineInv."Amount Including VAT";
                                    TaxJourLines.PRICE := (SalesLineInv."VAT Base Amount" / SalesLineInv.Quantity);
                                    TaxJourLines.DISCOUNT_AMOUNT := SalesLineInv."Line Discount Amount";
                                end;

                                TaxJourLines."Currency Code" := "Posted Sales Invoices"."Currency Code";
                                TaxJourLines.Insert();
                            until (SalesLineInv.Next() = 0);
                        end;
                        //Detail
                        ServiceLineInv.Reset();
                        ServiceLineInv.SetRange("Document No.", SourceTable.Document_No_);
                        ServiceLineInv.SetFilter("Type", '<> %1', ServiceLineInv.Type::" ");
                        ServiceLineInv.SetFilter("VAT Prod. Posting Group", '<> %1', 'NO VAT');
                        ServiceLineInv.SetFilter(Quantity, '> %1', 0);
                        //Validasi VAT Amount Header dgn Line 
                        if ServiceLineInv.IsEmpty = false then
                            SelisihVAT4 := ValidasiVATAmountServiceLineInv(SourceTable.Document_No_, ServiceLineInv);
                        //Validasi VAT Amount Header dgn Line
                        if ServiceLineInv.FindSet() then begin
                            TaxJourLines.LockTable();
                            repeat
                                TaxJourLines.Init();
                                Clear(TaxJourLines.ID);
                                TaxJourLines.KRE_TAXJOURID := GetLastID();
                                TaxJourLines.INVOICELINENO := ServiceLineInv."Line No.";
                                TaxJourLines.INVOICENo := SourceTable.Document_No_;
                                TaxJourLines.TYPE := SetOptionFromService(ServiceLineInv.Type);
                                TaxJourLines.ITEMID := ServiceLineInv."No.";
                                TaxJourLines.DESCRIPTION := ServiceLineInv.Description;
                                TaxJourLines.VAT_Bus_Posting_Group := ServiceLineInv."VAT Bus. Posting Group";
                                TaxJourLines.VAT_Prod_Posting_Group := ServiceLineInv."VAT Prod. Posting Group";
                                TaxJourLines.VAT_Identifier := ServiceLineInv."VAT Identifier";
                                TaxJourLines.QTY := system.Round(ServiceLineInv.Quantity, 1, '>');

                                if (GeneralLedgerSetup."LCY Code" <> "Posted Service Invoices"."Currency Code") and ("Posted Service Invoices"."Currency Code" <> '') then begin
                                    CurrencyExchangeRate.SetRange("Currency Code", "Posted Service Invoices"."Currency Code");
                                    CurrencyExchangeRate.SetFilter("Starting Date", '..%1', "Posted Service Invoices"."Posting Date");
                                    CurrencyExchangeRate.FindLast();
                                    VATGroup.Reset();
                                    VATGroup.SetRange("Code", SourceTable.VAT_Prod__Posting_Group);
                                    VATGroup.FindFirst();
                                    if (VATGroup.IS_FORWARDER = true) then
                                        TaxJourLines.DPP_AMOUNT := (ServiceLineInv."VAT Base Amount" / 10) * CurrencyExchangeRate."Kre Tax Rate"
                                    else
                                        TaxJourLines.DPP_AMOUNT := ServiceLineInv."VAT Base Amount" * CurrencyExchangeRate."Kre Tax Rate";

                                    if SelisihVAT4 > 0 then begin
                                        if ServiceLineInv."Line No." = 10000 then
                                            TaxJourLines.VAT_AMOUNT := (((ServiceLineInv."VAT Base Amount" * ServiceLineInv."VAT %") / 100) - SelisihVAT4) * CurrencyExchangeRate."Kre Tax Rate"
                                        else
                                            TaxJourLines.VAT_AMOUNT := ((ServiceLineInv."VAT Base Amount" * ServiceLineInv."VAT %") / 100) * CurrencyExchangeRate."Kre Tax Rate";
                                    end
                                    else
                                        TaxJourLines.VAT_AMOUNT := ((ServiceLineInv."VAT Base Amount" * ServiceLineInv."VAT %") / 100) * CurrencyExchangeRate."Kre Tax Rate";
                                    TaxJourLines.TOTAL_AMOUNT := ServiceLineInv."Amount Including VAT" * CurrencyExchangeRate."Kre Tax Rate";
                                    TaxJourLines.DISCOUNT_AMOUNT := ServiceLineInv."Line Discount Amount" * CurrencyExchangeRate."Kre Tax Rate";
                                    TaxJourLines.PRICE := ServiceLineInv."Unit Price" * CurrencyExchangeRate."Kre Tax Rate";
                                end else begin
                                    VATGroup.Reset();
                                    VATGroup.SetRange("Code", SourceTable.VAT_Prod__Posting_Group);
                                    VATGroup.FindFirst();
                                    if (VATGroup.IS_FORWARDER = true) then
                                        TaxJourLines.DPP_AMOUNT := ServiceLineInv."VAT Base Amount" / 10
                                    else
                                        TaxJourLines.DPP_AMOUNT := ServiceLineInv."VAT Base Amount";

                                    if SelisihVAT4 > 0 then begin
                                        if ServiceLineInv."Line No." = 10000 then
                                            TaxJourLines.VAT_AMOUNT := ((ServiceLineInv."VAT Base Amount" * ServiceLineInv."VAT %") / 100) - SelisihVAT4
                                        else
                                            TaxJourLines.VAT_AMOUNT := ((ServiceLineInv."VAT Base Amount" * ServiceLineInv."VAT %") / 100);
                                    end
                                    else
                                        TaxJourLines.VAT_AMOUNT := ((ServiceLineInv."VAT Base Amount" * ServiceLineInv."VAT %") / 100);
                                    TaxJourLines.TOTAL_AMOUNT := ServiceLineInv."Amount Including VAT";
                                    TaxJourLines.DISCOUNT_AMOUNT := ServiceLineInv."Line Discount Amount";
                                    TaxJourLines.PRICE := ServiceLineInv."Unit Price";
                                end;

                                TaxJourLines."Currency Code" := "Posted Service Invoices"."Currency Code";
                                TaxJourLines.Insert();
                            until (ServiceLineInv.Next() = 0);
                        end;
                        //Detail
                        SalesLineCM.Reset();
                        SalesLineCM.SetRange("Document No.", SourceTable.Document_No_);
                        SalesLineCM.SetRange(IsWHTCalc, false);
                        SalesLineCM.SetFilter("Type", '<> %1', SalesLineCM.Type::" ");
                        SalesLineCM.SetFilter("VAT Prod. Posting Group", '<> %1', 'NO VAT');
                        SalesLineCM.SetFilter(Quantity, '> %1', 0);
                        //Validasi VAT Amount Header dgn Line 
                        if SalesLineCM.IsEmpty = false then
                            SelisihVAT5 := ValidasiVATAmountSalesLineCM(SourceTable.Document_No_, SalesLineCM);
                        //Validasi VAT Amount Header dgn Line
                        if SalesLineCM.FindSet() then begin
                            TaxJourLines.LockTable();
                            repeat
                                TaxJourLines.Init();
                                Clear(TaxJourLines.ID);
                                TaxJourLines.KRE_TAXJOURID := GetLastID();
                                TaxJourLines.INVOICELINENO := SalesLineCM."Line No.";
                                TaxJourLines.INVOICENo := SourceTable.Document_No_;
                                TaxJourLines.TYPE := SalesLineCM.Type;
                                TaxJourLines.ITEMID := SalesLineCM."No.";
                                TaxJourLines.DESCRIPTION := SalesLineCM.Description;
                                TaxJourLines.VAT_Bus_Posting_Group := SalesLineCM."VAT Bus. Posting Group";
                                TaxJourLines.VAT_Prod_Posting_Group := SalesLineCM."VAT Prod. Posting Group";
                                TaxJourLines.VAT_Identifier := SalesLineCM."VAT Identifier";
                                TaxJourLines.QTY := system.Round(SalesLineCM.Quantity, 1, '>');

                                if (GeneralLedgerSetup."LCY Code" <> "Posted Sales Credit Memos"."Currency Code") and ("Posted Sales Credit Memos"."Currency Code" <> '') then begin
                                    CurrencyExchangeRate.SetRange("Currency Code", "Posted Sales Credit Memos"."Currency Code");
                                    CurrencyExchangeRate.SetFilter("Starting Date", '..%1', "Posted Sales Credit Memos"."Posting Date");
                                    CurrencyExchangeRate.FindLast();
                                    VATGroup.Reset();
                                    VATGroup.SetRange("Code", SourceTable.VAT_Prod__Posting_Group);
                                    VATGroup.FindFirst();
                                    if (VATGroup.IS_FORWARDER = true) then
                                        TaxJourLines.DPP_AMOUNT := (SalesLineCM."VAT Base Amount" / 10) * CurrencyExchangeRate."Kre Tax Rate"
                                    else
                                        TaxJourLines.DPP_AMOUNT := SalesLineCM."VAT Base Amount" * CurrencyExchangeRate."Kre Tax Rate";

                                    if SelisihVAT5 > 0 then begin
                                        if SalesLineCM."Line No." = 10000 then
                                            TaxJourLines.VAT_AMOUNT := (((SalesLineCM."VAT Base Amount" * SalesLineCM."VAT %") / 100) - SelisihVAT5) * CurrencyExchangeRate."Kre Tax Rate"
                                        else
                                            TaxJourLines.VAT_AMOUNT := ((SalesLineCM."VAT Base Amount" * SalesLineCM."VAT %") / 100) * CurrencyExchangeRate."Kre Tax Rate";
                                    end
                                    else
                                        TaxJourLines.VAT_AMOUNT := ((SalesLineCM."VAT Base Amount" * SalesLineCM."VAT %") / 100) * CurrencyExchangeRate."Kre Tax Rate";
                                    TaxJourLines.TOTAL_AMOUNT := SalesLineCM."Amount Including VAT" * CurrencyExchangeRate."Kre Tax Rate";
                                    TaxJourLines.DISCOUNT_AMOUNT := SalesLineCM."Line Discount Amount" * CurrencyExchangeRate."Kre Tax Rate";
                                    TaxJourLines.PRICE := (SalesLineCM."VAT Base Amount" / SalesLineCM.Quantity) * CurrencyExchangeRate."Kre Tax Rate";
                                end else begin
                                    VATGroup.Reset();
                                    VATGroup.SetRange("Code", SourceTable.VAT_Prod__Posting_Group);
                                    VATGroup.FindFirst();
                                    if (VATGroup.IS_FORWARDER = true) then
                                        TaxJourLines.DPP_AMOUNT := SalesLineCM."VAT Base Amount" / 10
                                    else
                                        TaxJourLines.DPP_AMOUNT := SalesLineCM."VAT Base Amount";

                                    if SelisihVAT5 > 0 then begin
                                        if SalesLineCM."Line No." = 10000 then
                                            TaxJourLines.VAT_AMOUNT := ((SalesLineCM."VAT Base Amount" * SalesLineCM."VAT %") / 100) - SelisihVAT5
                                        else
                                            TaxJourLines.VAT_AMOUNT := ((SalesLineCM."VAT Base Amount" * SalesLineCM."VAT %") / 100);
                                    end
                                    else
                                        TaxJourLines.VAT_AMOUNT := ((SalesLineCM."VAT Base Amount" * SalesLineCM."VAT %") / 100);
                                    TaxJourLines.TOTAL_AMOUNT := SalesLineCM."Amount Including VAT";
                                    TaxJourLines.DISCOUNT_AMOUNT := SalesLineCM."Line Discount Amount";
                                    TaxJourLines.PRICE := (SalesLineCM."VAT Base Amount" / SalesLineCM.Quantity);
                                end;

                                TaxJourLines."Currency Code" := "Posted Sales Credit Memos"."Currency Code";
                                TaxJourLines.Insert();
                            until (SalesLineCM.Next() = 0);
                        end;
                        //Detail
                        ServiceLineCM.Reset();
                        ServiceLineCM.SetRange("Document No.", SourceTable.Document_No_);
                        ServiceLineCM.SetFilter("Type", '<> %1', ServiceLineCM.Type::" ");
                        ServiceLineCM.SetFilter("VAT Prod. Posting Group", '<> %1', 'NO VAT');
                        ServiceLineCM.SetFilter(Quantity, '> %1', 0);
                        //Validasi VAT Amount Header dgn Line 
                        if ServiceLineCM.IsEmpty = false then
                            SelisihVAT6 := ValidasiVATAmountServiceLineCM(SourceTable.Document_No_, ServiceLineCM);
                        //Validasi VAT Amount Header dgn Line
                        if ServiceLineCM.FindSet() then begin
                            TaxJourLines.LockTable();
                            repeat
                                TaxJourLines.Init();
                                Clear(TaxJourLines.ID);
                                TaxJourLines.KRE_TAXJOURID := GetLastID();
                                TaxJourLines.INVOICELINENO := ServiceLineCM."Line No.";
                                TaxJourLines.INVOICENo := SourceTable.Document_No_;
                                TaxJourLines.TYPE := SetOptionFromService(ServiceLineCM.Type);
                                TaxJourLines.ITEMID := ServiceLineCM."No.";
                                TaxJourLines.DESCRIPTION := ServiceLineCM.Description;
                                TaxJourLines.VAT_Bus_Posting_Group := ServiceLineCM."VAT Bus. Posting Group";
                                TaxJourLines.VAT_Prod_Posting_Group := ServiceLineCM."VAT Prod. Posting Group";
                                TaxJourLines.VAT_Identifier := ServiceLineCM."VAT Identifier";
                                TaxJourLines.QTY := system.Round(ServiceLineCM.Quantity, 1, '>');

                                if (GeneralLedgerSetup."LCY Code" <> "Posted Service Credit Memos"."Currency Code") and ("Posted Service Credit Memos"."Currency Code" <> '') then begin
                                    CurrencyExchangeRate.SetRange("Currency Code", "Posted Service Credit Memos"."Currency Code");
                                    CurrencyExchangeRate.SetFilter("Starting Date", '..%1', "Posted Service Credit Memos"."Posting Date");
                                    CurrencyExchangeRate.FindLast();
                                    VATGroup.Reset();
                                    VATGroup.SetRange("Code", SourceTable.VAT_Prod__Posting_Group);
                                    VATGroup.FindFirst();
                                    if (VATGroup.IS_FORWARDER = true) then
                                        TaxJourLines.DPP_AMOUNT := (ServiceLineCM."VAT Base Amount" / 10) * CurrencyExchangeRate."Kre Tax Rate"
                                    else
                                        TaxJourLines.DPP_AMOUNT := ServiceLineCM."VAT Base Amount" * CurrencyExchangeRate."Kre Tax Rate";

                                    if SelisihVAT6 > 0 then begin
                                        if ServiceLineCM."Line No." = 10000 then
                                            TaxJourLines.VAT_AMOUNT := (((ServiceLineCM."VAT Base Amount" * ServiceLineCM."VAT %") / 100) - SelisihVAT6) * CurrencyExchangeRate."Kre Tax Rate"
                                        else
                                            TaxJourLines.VAT_AMOUNT := ((ServiceLineCM."VAT Base Amount" * ServiceLineCM."VAT %") / 100) * CurrencyExchangeRate."Kre Tax Rate";
                                    end
                                    else
                                        TaxJourLines.VAT_AMOUNT := ((ServiceLineCM."VAT Base Amount" * ServiceLineCM."VAT %") / 100) * CurrencyExchangeRate."Kre Tax Rate";
                                    TaxJourLines.TOTAL_AMOUNT := ServiceLineCM."Amount Including VAT" * CurrencyExchangeRate."Kre Tax Rate";
                                    TaxJourLines.DISCOUNT_AMOUNT := ServiceLineCM."Line Discount Amount" * CurrencyExchangeRate."Kre Tax Rate";
                                    TaxJourLines.PRICE := ServiceLineCM."Unit Price" * CurrencyExchangeRate."Kre Tax Rate";
                                end else begin
                                    VATGroup.Reset();
                                    VATGroup.SetRange("Code", SourceTable.VAT_Prod__Posting_Group);
                                    VATGroup.FindFirst();
                                    if (VATGroup.IS_FORWARDER = true) then
                                        TaxJourLines.DPP_AMOUNT := ServiceLineCM."VAT Base Amount" / 10
                                    else
                                        TaxJourLines.DPP_AMOUNT := ServiceLineCM."VAT Base Amount";

                                    if SelisihVAT6 > 0 then begin
                                        if ServiceLineCM."Line No." = 10000 then
                                            TaxJourLines.VAT_AMOUNT := ((ServiceLineCM."VAT Base Amount" * ServiceLineCM."VAT %") / 100) - SelisihVAT6
                                        else
                                            TaxJourLines.VAT_AMOUNT := ((ServiceLineCM."VAT Base Amount" * ServiceLineCM."VAT %") / 100);
                                    end
                                    else
                                        TaxJourLines.VAT_AMOUNT := ((ServiceLineCM."VAT Base Amount" * ServiceLineCM."VAT %") / 100);
                                    TaxJourLines.TOTAL_AMOUNT := ServiceLineCM."Amount Including VAT";
                                    TaxJourLines.DISCOUNT_AMOUNT := ServiceLineCM."Line Discount Amount";
                                    TaxJourLines.PRICE := ServiceLineCM."Unit Price";
                                end;

                                TaxJourLines."Currency Code" := "Posted Service Credit Memos"."Currency Code";
                                TaxJourLines.Insert();
                            until (ServiceLineCM.Next() = 0);
                        end;
                    end;

                //Update flag
                UpdateFlagVATEntry(SourceTable.Document_No_);
                //Update flag   
            end
            else
                if not CustomerRetail then
                    UpdateInvoice(SourceTable.Document_No_);

            // SourceTable.Is_Synch := true;
            // SourceTable.Modify();
            //until SourceTable.Next = 0;

        end;
        SourceTable.Close();

    end;

    procedure TaxSynchForeignCurrency(StartDate: Date; EndDate: Date)
    var
        TaxSetup: Record Kre_TaxSetup;
        SourceTable: Query KreVATEntryForeignCurrency;
        //SourceTable: Record "VAT Entry";
        //MappingSourceTable: Record KRE_VATEntryTaxJour;
        Vendor: Record Vendor;
        Customer: Record Customer;
        CustomerAddress: Record Customer;
        "Posted Purchase Invoice": Record "Purch. Inv. Header";
        PurchLineInv: Record "Purch. Inv. Line";
        "Posted Purchase Credit Memos": Record "Purch. Cr. Memo Hdr.";
        PurchLineCM: Record "Purch. Cr. Memo Line";
        "Posted Sales Invoices": Record "Sales Invoice Header";
        SalesLineInv: Record "Sales Invoice Line";
        "Posted Service Invoices": Record "Service Invoice Header";
        ServiceLineInv: Record "Service Invoice Line";
        "Posted Sales Credit Memos": Record "Sales Cr.Memo Header";
        SalesLineCM: Record "Sales Cr.Memo Line";
        "Posted Service Credit Memos": Record "Service Cr.Memo Header";
        ServiceLineCM: Record "Service Cr.Memo Line";
        // identity: Integer;
        TaxJour: Record KRE_TAXJOUR;
        TaxJourLines: Record KRE_TAXJOURLINES;
        VATGroup: Record "VAT Product Posting Group";
        SelisihVAT1: Decimal;
        SelisihVAT2: Decimal;
        SelisihVAT3: Decimal;
        SelisihVAT4: Decimal;
        SelisihVAT5: Decimal;
        SelisihVAT6: Decimal;
        shiptoaddress: Record "Ship-to Address";
        ExchangeRate: Decimal;
        Exc: Codeunit ExchangeRateIDR;
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        if not TaxSetup.FindFirst() then begin
            Error('Please Setup Tax Config first !');
            exit;
        end;
        // SourceTable.Reset();
        // SourceTable.SetFilter("Document No.", '<> %1', MappingSourceTable.INVOICENO);
        // SourceTable.SetFilter(Amount, '<> %1', 0);// untuk demo amount pajak 0
        // SourceTable.SetRange(Is_Synch, false);
        // SourceTable.SetFilter(Type, '<> %1', 0);
        // SourceTable.SetFilter(Bill_to_Pay_to_No_, '<> %1', '');
        SourceTable.SetRange(SourceTable.Posting_Date, StartDate, EndDate);
        SourceTable.Open();
        while SourceTable.READ() do begin
            CustomerRetail := false;
            if SourceTable.Type = SourceTable.Type::Sale then
                if Customer.Get(SourceTable.Bill_to_Pay_to_No_) then
                    if Customer."Retail Customer" then
                        CustomerRetail := true;
            TaxJour.LockTable();
            // repeat
            TaxJour.SetFilter(INVOICENO, '=%1', SourceTable.Document_No_);
            if (not TaxJour.FindSet()) and (not CustomerRetail) then begin
                Clear(TaxJour);
                TaxJour.Init();
                TaxJour.INVOICENO := SourceTable.Document_No_;
                TaxJour.INVOICEDATE := SourceTable.Document_Date;
                TaxJour.DOCUMENTNO := SourceTable.External_Document_No_;
                TaxJour."VAT Bus. Posting Group" := SourceTable.VAT_Bus__Posting_Group;
                TaxJour."VAT Calculation Type" := SourceTable.VAT_Calculation_Type;
                TaxJour."VAT Prod. Posting Group" := SourceTable.VAT_Prod__Posting_Group;

                //Get Customer / Vendor
                case SourceTable.Type of
                    SourceTable.Type::Purchase:
                        begin
                            if Vendor.Get(SourceTable.Bill_to_Pay_to_No_) then begin
                                TaxJour.ACCOUNTID := Vendor."No.";
                                GetVendorID(Vendor, TaxJour);
                                TaxJour.NAMA := Vendor.NamaNPWP;
                                TaxJour.ALAMATNPWP := Vendor.AlamatNPWP;
                                TaxJour.TAX_SOURCE := TaxJour.TAX_SOURCE::Purchase;
                            end
                        end;
                    SourceTable.Type::Sale:
                        begin
                            if Customer.Get(SourceTable.Bill_to_Pay_to_No_) then begin
                                TaxJour.ACCOUNTID := Customer."No.";
                                GetCustomerID(Customer, TaxJour);
                                TaxJour.NAMA := Customer.NamaNPWP;
                                //Alamat NPWP pindah ke bawah
                                TaxJour.TAX_SOURCE := TaxJour.TAX_SOURCE::Sales;
                            end
                        end;
                end;
                //End of Get Customer / Vendor

                case SourceTable.Document_Type of
                    SourceTable.Document_Type::Invoice:
                        begin
                            TaxJour.IS_CREDITABLE := 1;
                            TaxJour.IS_RETURNITEM := TaxJour.IS_RETURNITEM::NO;
                        end;
                    SourceTable.Document_Type::"Credit Memo":
                        begin
                            TaxJour.IS_CREDITABLE := 0;
                            TaxJour.IS_RETURNITEM := TaxJour.IS_RETURNITEM::YES;
                        end;
                end;

                if TaxSetup.Activate_VAT_In then  //Pajak Masukan
                    if SourceTable.Type = SourceTable.Type::Purchase then begin
                        //Get Tax Number and Tax Date
                        "Posted Purchase Invoice".SetRange("No.", SourceTable.Document_No_);
                        if "Posted Purchase Invoice".FindFirst() then begin
                            "Posted Purchase Invoice".Get(SourceTable.Document_No_);
                            TaxJour.TAXNUMBER := "Posted Purchase Invoice".TAXNUMBER;
                            TaxJour.TAXDATE := "Posted Purchase Invoice".TAXDATE;
                            TaxJour.CURRENCY := "Posted Purchase Invoice"."Currency Code";

                            if "Posted Purchase Invoice"."Order No." = '' then
                                TaxJour.Kode_Dokumen_Pendukung := "Posted Purchase Invoice"."Pre-Assigned No."
                            else
                                TaxJour.Kode_Dokumen_Pendukung := "Posted Purchase Invoice"."Order No.";
                        end;
                        //End of Get Tax Number and Tax Date
                        //Get Tax Number and Tax Date
                        "Posted Purchase Credit Memos".SetRange("No.", SourceTable.Document_No_);
                        if "Posted Purchase Credit Memos".FindFirst() then begin
                            "Posted Purchase Credit Memos".Get(SourceTable.Document_No_);
                            TaxJour.RETURN_TAX_NUMBER := "Posted Purchase Credit Memos".RETURN_TAX_NUMBER;
                            TaxJour.RETURN_DATE := "Posted Purchase Credit Memos".RETURN_DATE;
                            TaxJour.RETURN_DOC_NUMBER := "Posted Purchase Credit Memos".RETURN_DOC_NUMBER;
                            TaxJour.CURRENCY := "Posted Purchase Credit Memos"."Currency Code";
                        end;
                        //End of Get Tax Number and Tax Date
                        TaxJour.DPPAMOUNT := system.ABS(SourceTable.Base);
                        TaxJour.VATAMOUNT := system.ABS(SourceTable.Amount);
                        TaxJour.INVOICEAMOUNT := system.ABS(SourceTable.Base + SourceTable.Amount);
                        TaxJour.TAX_POSTED := TaxJour.TAX_POSTED::NO;
                        TaxJour.TAX_EXPORTED := TaxJour.TAX_EXPORTED::NO;
                        TaxJour.Insert();
                        //insert data vat entry
                        //InsertVATEntryMapping(SourceTable."Document No.");
                        //insert data vat entry
                        //Detail
                        PurchLineInv.Reset();
                        PurchLineInv.SetRange("Document No.", SourceTable.Document_No_);
                        PurchLineInv.SetRange(IsWHTCalc, false);
                        PurchLineInv.SetFilter("Type", '<> %1', PurchLineInv.Type::" ");
                        PurchLineInv.SetFilter("VAT Prod. Posting Group", '<> %1', 'NO VAT');
                        //Validasi VAT Amount Header dgn Line 
                        if PurchLineInv.IsEmpty = false then
                            SelisihVAT1 := ValidasiVATAmountPurchaseLineInvForeign(SourceTable.Document_No_, PurchLineInv);
                        //Validasi VAT Amount Header dgn Line 
                        if PurchLineInv.FindSet() then begin
                            TaxJourLines.LockTable();
                            repeat
                                if TaxSetup."Export to Currency" = "Posted Purchase Invoice"."Currency Code" then
                                    ExchangeRate := 1 else
                                    if "Posted Purchase Invoice"."Currency Code" = '' then
                                        ExchangeRate := Exc.GetExchangeRate(TaxSetup."Export to Currency", GLSetup."LCY Code", "Posted Purchase Invoice"."Posting Date") else
                                        ExchangeRate := Exc.GetExchangeRate(TaxSetup."Export to Currency", "Posted Purchase Invoice"."Currency Code", "Posted Purchase Invoice"."Posting Date");
                                TaxJourLines.Init();
                                Clear(TaxJourLines.ID);
                                TaxJourLines.KRE_TAXJOURID := GetLastID();
                                TaxJourLines.INVOICELINENO := PurchLineInv."Line No.";
                                TaxJourLines.INVOICENo := SourceTable.Document_No_;
                                TaxJourLines.TYPE := PurchLineInv.Type;
                                TaxJourLines.ITEMID := PurchLineInv."No.";
                                TaxJourLines.DESCRIPTION := PurchLineInv.Description;
                                TaxJourLines.VAT_Bus_Posting_Group := PurchLineInv."VAT Bus. Posting Group";
                                TaxJourLines.VAT_Prod_Posting_Group := PurchLineInv."VAT Prod. Posting Group";
                                TaxJourLines.VAT_Identifier := PurchLineInv."VAT Identifier";
                                TaxJourLines.PRICE := PurchLineInv."Direct Unit Cost" / ExchangeRate;
                                TaxJourLines.QTY := system.Round(PurchLineInv.Quantity, 1, '>');
                                TaxJourLines.DISCOUNT_AMOUNT := PurchLineInv."Line Discount Amount" / ExchangeRate;
                                TaxJourLines.DPP_AMOUNT := PurchLineInv."VAT Base Amount" / ExchangeRate;

                                if SelisihVAT1 > 0 then begin
                                    if PurchLineInv."Line No." = 10000 then
                                        TaxJourLines.VAT_AMOUNT := ((PurchLineInv."VAT Base Amount" * PurchLineInv."VAT %") / 100) - SelisihVAT1
                                    else
                                        TaxJourLines.VAT_AMOUNT := ((PurchLineInv."VAT Base Amount" * PurchLineInv."VAT %") / 100);
                                end
                                else
                                    TaxJourLines.VAT_AMOUNT := ((PurchLineInv."VAT Base Amount" * PurchLineInv."VAT %") / 100);
                                TaxJourLines.TOTAL_AMOUNT := (PurchLineInv."Line Amount" / ExchangeRate) + TaxJourLines.VAT_AMOUNT;
                                TaxJourLines."Currency Code" := "Posted Purchase Invoice"."Currency Code";
                                TaxJourLines.Insert();
                            until (PurchLineInv.Next() = 0);
                        end;
                        //Detail
                        PurchLineCM.Reset();
                        PurchLineCM.SetRange("Document No.", SourceTable.Document_No_);
                        PurchLineCM.SetRange(IsWHTCalc, false);
                        PurchLineCM.SetFilter("Type", '<> %1', PurchLineCM.Type::" ");
                        PurchLineCM.SetFilter("VAT Prod. Posting Group", '<> %1', 'NO VAT');
                        //Validasi VAT Amount Header dgn Line 
                        if PurchLineCM.IsEmpty = false then
                            SelisihVAT2 := ValidasiVATAmountPurchaseLineCM(SourceTable.Document_No_, PurchLineCM);
                        //Validasi VAT Amount Header dgn Line 
                        if PurchLineCM.FindSet() then begin
                            TaxJourLines.LockTable();
                            repeat
                                if TaxSetup."Export to Currency" = "Posted Purchase Credit Memos"."Currency Code" then
                                    ExchangeRate := 1 else
                                    if "Posted Purchase Credit Memos"."Currency Code" = '' then
                                        ExchangeRate := Exc.GetExchangeRate(TaxSetup."Export to Currency", GLSetup."LCY Code", "Posted Purchase Credit Memos"."Posting Date") else
                                        ExchangeRate := Exc.GetExchangeRate(TaxSetup."Export to Currency", "Posted Purchase Credit Memos"."Currency Code", "Posted Purchase Credit Memos"."Posting Date");
                                TaxJourLines.Init();
                                Clear(TaxJourLines.ID);
                                TaxJourLines.KRE_TAXJOURID := GetLastID();
                                TaxJourLines.INVOICELINENO := PurchLineCM."Line No.";
                                TaxJourLines.INVOICENo := SourceTable.Document_No_;
                                TaxJourLines.TYPE := PurchLineCM.Type;
                                TaxJourLines.ITEMID := PurchLineCM."No.";
                                TaxJourLines.DESCRIPTION := PurchLineCM.Description;
                                TaxJourLines.VAT_Bus_Posting_Group := PurchLineCM."VAT Bus. Posting Group";
                                TaxJourLines.VAT_Prod_Posting_Group := PurchLineCM."VAT Prod. Posting Group";
                                TaxJourLines.VAT_Identifier := PurchLineCM."VAT Identifier";
                                TaxJourLines.PRICE := PurchLineCM."Direct Unit Cost" / ExchangeRate;
                                TaxJourLines.QTY := system.Round(PurchLineCM.Quantity, 1, '>');
                                TaxJourLines.DISCOUNT_AMOUNT := PurchLineCM."Line Discount Amount" / ExchangeRate;
                                TaxJourLines.DPP_AMOUNT := PurchLineCM."VAT Base Amount" / ExchangeRate;
                                TaxJourLines."Coretax Item Code" := PurchLineCM."Coretax Item Code";
                                TaxJourLines."Coretax Item Description" := PurchLineCM."Coretax Item Description";

                                if SelisihVAT2 > 0 then begin
                                    if PurchLineCM."Line No." = 10000 then
                                        TaxJourLines.VAT_AMOUNT := ((PurchLineCM."VAT Base Amount" / ExchangeRate * PurchLineCM."VAT %") / 100) - SelisihVAT2
                                    else
                                        TaxJourLines.VAT_AMOUNT := ((PurchLineCM."VAT Base Amount" / ExchangeRate * PurchLineCM."VAT %") / 100);
                                end
                                else
                                    TaxJourLines.VAT_AMOUNT := ((PurchLineCM."VAT Base Amount" / ExchangeRate * PurchLineCM."VAT %") / 100);
                                TaxJourLines.TOTAL_AMOUNT := (PurchLineCM."Line Amount" / ExchangeRate) + TaxJourLines.VAT_AMOUNT;
                                TaxJourLines."Currency Code" := "Posted Purchase Credit Memos"."Currency Code";
                                TaxJourLines.Insert();
                            until (PurchLineCM.Next() = 0);
                        end;
                    end;

                if TaxSetup.Activate_VAT_Out then  //Pajak Keluaran
                    if SourceTable.Type = SourceTable.Type::Sale then begin
                        //IsNull TaxNumber diambil dari register tax number dan taxdate input manual
                        "Posted Sales Invoices".SetRange("No.", SourceTable.Document_No_);
                        if "Posted Sales Invoices".FindFirst() then begin
                            "Posted Sales Invoices".Get(SourceTable.Document_No_);
                            TaxJour.TAXNUMBER := "Posted Sales Invoices".TAXNUMBER;
                            TaxJour.CURRENCY := "Posted Sales Invoices"."Currency Code";
                            //update pajak 5.3
                            if CustomerAddress.Get("Posted Sales Invoices"."Sell-to Customer No.") then
                                if CustomerAddress.NPWPAddressfromShipTo then begin
                                    shiptoaddress.SetRange("Customer No.", "Posted Sales Invoices"."Sell-to Customer No.");
                                    shiptoaddress.SetRange("Code", "Posted Sales Invoices"."Ship-to Code");
                                    if shiptoaddress.FindFirst() then begin
                                        TaxJour.ALAMATNPWP := shiptoaddress.AlamatNPWP;
                                        TaxJour."ID TKU Pembeli" := shiptoaddress."ID TKU";
                                        TaxJour."Ship-to Code" := shiptoaddress.Code;
                                    end;
                                end else begin
                                    TaxJour.ALAMATNPWP := CustomerAddress.AlamatNPWP;
                                    TaxJour."ID TKU Pembeli" := CustomerAddress."ID TKU"
                                end;

                            if "Posted Sales Invoices"."Order No." = '' then
                                TaxJour.Kode_Dokumen_Pendukung := "Posted Sales Invoices"."External Document No."
                            else
                                TaxJour.Kode_Dokumen_Pendukung := "Posted Sales Invoices"."External Document No.";
                            TaxJour."Pre-Assigned No." := "Posted Sales Invoices"."Pre-Assigned No.";
                        end;
                        //End of IsNull TaxNumber diambil dari register tax number dan taxdate input manual
                        //retur taxNumber dan retur date input manual
                        "Posted Sales Credit Memos".SetRange("No.", SourceTable.Document_No_);
                        if "Posted Sales Credit Memos".FindFirst() then begin
                            "Posted Sales Credit Memos".Get(SourceTable.Document_No_);
                            TaxJour.RETURN_TAX_NUMBER := "Posted Sales Credit Memos".RETURN_TAX_NUMBER;
                            TaxJour.RETURN_DATE := "Posted Sales Credit Memos".RETURN_DATE;
                            TaxJour.RETURN_DOC_NUMBER := "Posted Sales Credit Memos".RETURN_DOC_NUMBER;
                            TaxJour.CURRENCY := "Posted Sales Credit Memos"."Currency Code";
                            //update pajak 5.3
                            if CustomerAddress.Get("Posted Sales Credit Memos"."Sell-to Customer No.") then
                                if CustomerAddress.NPWPAddressfromShipTo then begin
                                    shiptoaddress.SetRange("Customer No.", "Posted Sales Credit Memos"."Sell-to Customer No.");
                                    shiptoaddress.SetRange("Code", "Posted Sales Credit Memos"."Ship-to Code");
                                    if shiptoaddress.FindFirst() then begin
                                        TaxJour.ALAMATNPWP := shiptoaddress.AlamatNPWP;
                                        TaxJour."ID TKU Pembeli" := shiptoaddress."ID TKU";
                                        TaxJour."Ship-to Code" := shiptoaddress.Code;
                                    end;
                                end else begin
                                    TaxJour.ALAMATNPWP := CustomerAddress.AlamatNPWP;
                                    TaxJour."ID TKU Pembeli" := CustomerAddress."ID TKU"
                                end;
                        end;
                        "Posted Service Invoices".SetRange("No.", SourceTable.Document_No_);
                        if "Posted Service Invoices".FindFirst() then begin
                            "Posted Service Invoices".Get(SourceTable.Document_No_);
                            TaxJour.TAXNUMBER := "Posted Service Invoices".TAXNUMBER;
                            TaxJour.CURRENCY := "Posted Service Invoices"."Currency Code";
                            //update pajak 5.3
                            if CustomerAddress.Get("Posted Service Invoices"."Customer No.") then
                                if CustomerAddress.NPWPAddressfromShipTo then begin
                                    shiptoaddress.SetRange("Customer No.", "Posted Service Invoices"."Customer No.");
                                    shiptoaddress.SetRange("Code", "Posted Service Invoices"."Ship-to Code");
                                    if shiptoaddress.FindFirst() then begin
                                        TaxJour.ALAMATNPWP := shiptoaddress.AlamatNPWP;
                                        TaxJour."ID TKU Pembeli" := shiptoaddress."ID TKU";
                                        TaxJour."Ship-to Code" := shiptoaddress.Code;
                                    end;
                                end else begin
                                    TaxJour.ALAMATNPWP := CustomerAddress.AlamatNPWP;
                                    TaxJour."ID TKU Pembeli" := CustomerAddress."ID TKU"
                                end;

                            if "Posted Sales Invoices"."Order No." = '' then
                                TaxJour.Kode_Dokumen_Pendukung := "Posted Sales Invoices"."External Document No."
                            else
                                TaxJour.Kode_Dokumen_Pendukung := "Posted Sales Invoices"."External Document No.";
                        end;
                        //End of retur taxNumber dan retur date input manual
                        "Posted Service Credit Memos".SetRange("No.", SourceTable.Document_No_);
                        if "Posted Service Credit Memos".FindFirst() then begin
                            "Posted Service Credit Memos".Get(SourceTable.Document_No_);
                            TaxJour.RETURN_TAX_NUMBER := "Posted Service Credit Memos".RETURN_TAX_NUMBER;
                            TaxJour.RETURN_DATE := "Posted Service Credit Memos".RETURN_DATE;
                            TaxJour.RETURN_DOC_NUMBER := "Posted Service Credit Memos".RETURN_DOC_NUMBER;
                            TaxJour.CURRENCY := "Posted Service Credit Memos"."Currency Code";
                        end;
                        VATGroup.Reset();
                        VATGroup.SetRange("Code", SourceTable.VAT_Prod__Posting_Group);
                        VATGroup.FindFirst();
                        if "Posted Sales Invoices"."Currency Code" = TaxSetup."Export to Currency" then begin
                            if (VATGroup.IS_FORWARDER = true) then
                                TaxJour.DPPAMOUNT := system.ABS(SourceTable.BaseIDR) / 10
                            else
                                TaxJour.DPPAMOUNT := system.ABS(SourceTable.BaseIDR);

                            TaxJour.VATAMOUNT := system.ABS(SourceTable.AmountIDR);
                            TaxJour.INVOICEAMOUNT := system.ABS(SourceTable.BaseIDR + SourceTable.AmountIDR);
                        end else begin
                            if (VATGroup.IS_FORWARDER = true) then
                                TaxJour.DPPAMOUNT := system.ABS(SourceTable.Base) / 10
                            else
                                TaxJour.DPPAMOUNT := system.ABS(SourceTable.Base);

                            TaxJour.VATAMOUNT := system.ABS(SourceTable.Amount);
                            TaxJour.INVOICEAMOUNT := system.ABS(SourceTable.Base + SourceTable.Amount);
                        end;

                        TaxJour.TAX_POSTED := TaxJour.TAX_POSTED::NO;
                        TaxJour.TAX_EXPORTED := TaxJour.TAX_EXPORTED::NO;
                        TaxJour.Insert();
                        //insert data vat entry
                        //InsertVATEntryMapping(SourceTable."Document No.");
                        //insert data vat entry
                        //Detail
                        SalesLineInv.Reset();
                        SalesLineInv.SetRange("Document No.", SourceTable.Document_No_);
                        SalesLineInv.SetRange(IsWHTCalc, false);
                        SalesLineInv.SetFilter("Type", '<> %1', SalesLineInv.Type::" ");
                        SalesLineInv.SetFilter("VAT Prod. Posting Group", '<> %1', 'NO VAT');
                        //Validasi VAT Amount Header dgn Line 
                        if SalesLineInv.IsEmpty = false then
                            SelisihVAT3 := ValidasiVATAmountSalesLineInv(SourceTable.Document_No_, SalesLineInv);
                        //Validasi VAT Amount Header dgn Line 
                        if SalesLineInv.FindSet() then begin
                            TaxJourLines.LockTable();
                            repeat
                                if TaxSetup."Export to Currency" = "Posted Sales Invoices"."Currency Code" then
                                    ExchangeRate := 1 else
                                    if "Posted Sales Invoices"."Currency Code" = '' then
                                        ExchangeRate := Exc.GetExchangeRate(TaxSetup."Export to Currency", GLSetup."LCY Code", "Posted Sales Invoices"."Posting Date")
                                    else
                                        ExchangeRate := Exc.GetExchangeRate(TaxSetup."Export to Currency", "Posted Sales Invoices"."Currency Code", "Posted Sales Invoices"."Posting Date");
                                TaxJourLines.Init();
                                Clear(TaxJourLines.ID);
                                TaxJourLines.KRE_TAXJOURID := GetLastID();
                                TaxJourLines.INVOICELINENO := SalesLineInv."Line No.";
                                TaxJourLines.INVOICENo := SourceTable.Document_No_;
                                TaxJourLines.TYPE := SalesLineInv.Type;
                                TaxJourLines.ITEMID := SalesLineInv."No.";
                                TaxJourLines.DESCRIPTION := SalesLineInv.Description;
                                TaxJourLines.VAT_Bus_Posting_Group := SalesLineInv."VAT Bus. Posting Group";
                                TaxJourLines.VAT_Prod_Posting_Group := SalesLineInv."VAT Prod. Posting Group";
                                TaxJourLines.VAT_Identifier := SalesLineInv."VAT Identifier";
                                TaxJourLines.PRICE := SalesLineInv."Unit Price" / ExchangeRate;
                                TaxJourLines.QTY := system.Round(SalesLineInv.Quantity, 1, '>');
                                TaxJourLines.DISCOUNT_AMOUNT := SalesLineInv."Line Discount Amount" / ExchangeRate;
                                TaxJourLines."Coretax Item Code" := SalesLineInv."Coretax Item Code";
                                TaxJourLines."Coretax Item Description" := SalesLineInv."Coretax Item Description";
                                VATGroup.Reset();
                                VATGroup.SetRange("Code", SourceTable.VAT_Prod__Posting_Group);
                                VATGroup.FindFirst();
                                if (VATGroup.IS_FORWARDER = true) then
                                    TaxJourLines.DPP_AMOUNT := SalesLineInv."VAT Base Amount" / ExchangeRate / 10
                                else
                                    TaxJourLines.DPP_AMOUNT := SalesLineInv."VAT Base Amount" / ExchangeRate;

                                if SelisihVAT3 > 0 then begin
                                    if SalesLineInv."Line No." = 10000 then
                                        TaxJourLines.VAT_AMOUNT := ((SalesLineInv."VAT Base Amount" / ExchangeRate * SalesLineInv."VAT %") / 100) - SelisihVAT3
                                    else
                                        TaxJourLines.VAT_AMOUNT := ((SalesLineInv."VAT Base Amount" / ExchangeRate * SalesLineInv."VAT %") / 100);
                                end
                                else
                                    TaxJourLines.VAT_AMOUNT := ((SalesLineInv."VAT Base Amount" / ExchangeRate * SalesLineInv."VAT %") / 100);
                                TaxJourLines.TOTAL_AMOUNT := (SalesLineInv."Line Amount" / ExchangeRate) + TaxJourLines.VAT_AMOUNT;
                                TaxJourLines."Currency Code" := "Posted Sales Invoices"."Currency Code";
                                TaxJourLines.Insert();
                            until (SalesLineInv.Next() = 0);
                        end;
                        //Detail
                        ServiceLineInv.Reset();
                        ServiceLineInv.SetRange("Document No.", SourceTable.Document_No_);
                        ServiceLineInv.SetFilter("Type", '<> %1', ServiceLineInv.Type::" ");
                        ServiceLineInv.SetFilter("VAT Prod. Posting Group", '<> %1', 'NO VAT');
                        //Validasi VAT Amount Header dgn Line 
                        if ServiceLineInv.IsEmpty = false then
                            SelisihVAT4 := ValidasiVATAmountServiceLineInv(SourceTable.Document_No_, ServiceLineInv);
                        //Validasi VAT Amount Header dgn Line
                        if ServiceLineInv.FindSet() then begin
                            TaxJourLines.LockTable();
                            repeat
                                if TaxSetup."Export to Currency" = "Posted Service Invoices"."Currency Code" then
                                    ExchangeRate := 1 else
                                    if "Posted Service Invoices"."Currency Code" = '' then
                                        ExchangeRate := Exc.GetExchangeRate(TaxSetup."Export to Currency", GLSetup."LCY Code", "Posted Service Invoices"."Posting Date") else
                                        ExchangeRate := Exc.GetExchangeRate(TaxSetup."Export to Currency", "Posted Service Invoices"."Currency Code", "Posted Service Invoices"."Posting Date");
                                TaxJourLines.Init();
                                Clear(TaxJourLines.ID);
                                TaxJourLines.KRE_TAXJOURID := GetLastID();
                                TaxJourLines.INVOICELINENO := ServiceLineInv."Line No.";
                                TaxJourLines.INVOICENo := SourceTable.Document_No_;
                                TaxJourLines.TYPE := SetOptionFromService(ServiceLineInv.Type);
                                TaxJourLines.ITEMID := ServiceLineInv."No.";
                                TaxJourLines.DESCRIPTION := ServiceLineInv.Description;
                                TaxJourLines.VAT_Bus_Posting_Group := ServiceLineInv."VAT Bus. Posting Group";
                                TaxJourLines.VAT_Prod_Posting_Group := ServiceLineInv."VAT Prod. Posting Group";
                                TaxJourLines.VAT_Identifier := ServiceLineInv."VAT Identifier";
                                TaxJourLines.PRICE := ServiceLineInv."Unit Price" / ExchangeRate;
                                TaxJourLines.QTY := system.Round(ServiceLineInv.Quantity, 1, '>');
                                TaxJourLines.DISCOUNT_AMOUNT := ServiceLineInv."Line Discount Amount" / ExchangeRate;
                                VATGroup.Reset();
                                VATGroup.SetRange("Code", SourceTable.VAT_Prod__Posting_Group);
                                VATGroup.FindFirst();
                                if (VATGroup.IS_FORWARDER = true) then
                                    TaxJourLines.DPP_AMOUNT := ServiceLineInv."VAT Base Amount" / ExchangeRate / 10
                                else
                                    TaxJourLines.DPP_AMOUNT := ServiceLineInv."VAT Base Amount" / ExchangeRate;

                                if SelisihVAT4 > 0 then begin
                                    if ServiceLineInv."Line No." = 10000 then
                                        TaxJourLines.VAT_AMOUNT := ((ServiceLineInv."VAT Base Amount" / ExchangeRate * ServiceLineInv."VAT %") / 100) - SelisihVAT4
                                    else
                                        TaxJourLines.VAT_AMOUNT := ((ServiceLineInv."VAT Base Amount" / ExchangeRate * ServiceLineInv."VAT %") / 100);
                                end
                                else
                                    TaxJourLines.VAT_AMOUNT := ((ServiceLineInv."VAT Base Amount" / ExchangeRate * ServiceLineInv."VAT %") / 100);
                                TaxJourLines.TOTAL_AMOUNT := (ServiceLineInv."Line Amount" / ExchangeRate) + TaxJourLines.VAT_AMOUNT;
                                TaxJourLines."Currency Code" := "Posted Service Invoices"."Currency Code";
                                TaxJourLines.Insert();
                            until (ServiceLineInv.Next() = 0);
                        end;
                        //Detail
                        SalesLineCM.Reset();
                        SalesLineCM.SetRange("Document No.", SourceTable.Document_No_);
                        SalesLineCM.SetRange(IsWHTCalc, false);
                        SalesLineCM.SetFilter("Type", '<> %1', SalesLineCM.Type::" ");
                        SalesLineCM.SetFilter("VAT Prod. Posting Group", '<> %1', 'NO VAT');
                        //Validasi VAT Amount Header dgn Line 
                        if SalesLineCM.IsEmpty = false then
                            SelisihVAT5 := ValidasiVATAmountSalesLineCM(SourceTable.Document_No_, SalesLineCM);
                        //Validasi VAT Amount Header dgn Line
                        if SalesLineCM.FindSet() then begin
                            TaxJourLines.LockTable();
                            repeat
                                if TaxSetup."Export to Currency" = "Posted Sales Credit Memos"."Currency Code" then
                                    ExchangeRate := 1 else
                                    if "Posted Sales Credit Memos"."Currency Code" = '' then
                                        ExchangeRate := Exc.GetExchangeRate(TaxSetup."Export to Currency", GLSetup."LCY Code", "Posted Sales Credit Memos"."Posting Date") else
                                        ExchangeRate := Exc.GetExchangeRate(TaxSetup."Export to Currency", "Posted Sales Credit Memos"."Currency Code", "Posted Sales Credit Memos"."Posting Date");
                                TaxJourLines.Init();
                                Clear(TaxJourLines.ID);
                                TaxJourLines.KRE_TAXJOURID := GetLastID();
                                TaxJourLines.INVOICELINENO := SalesLineCM."Line No.";
                                TaxJourLines.INVOICENo := SourceTable.Document_No_;
                                TaxJourLines.TYPE := SalesLineCM.Type;
                                TaxJourLines.ITEMID := SalesLineCM."No.";
                                TaxJourLines.DESCRIPTION := SalesLineCM.Description;
                                TaxJourLines.VAT_Bus_Posting_Group := SalesLineCM."VAT Bus. Posting Group";
                                TaxJourLines.VAT_Prod_Posting_Group := SalesLineCM."VAT Prod. Posting Group";
                                TaxJourLines.VAT_Identifier := SalesLineCM."VAT Identifier";
                                TaxJourLines.PRICE := SalesLineCM."Unit Price" / ExchangeRate;
                                TaxJourLines.QTY := system.Round(SalesLineCM.Quantity, 1, '>');

                                TaxJourLines.DISCOUNT_AMOUNT := SalesLineCM."Line Discount Amount" / ExchangeRate;
                                VATGroup.Reset();
                                VATGroup.SetRange("Code", SourceTable.VAT_Prod__Posting_Group);
                                VATGroup.FindFirst();
                                if (VATGroup.IS_FORWARDER = true) then
                                    TaxJourLines.DPP_AMOUNT := SalesLineCM."VAT Base Amount" / ExchangeRate / 10
                                else
                                    TaxJourLines.DPP_AMOUNT := SalesLineCM."VAT Base Amount" / ExchangeRate;

                                if SelisihVAT5 > 0 then begin
                                    if SalesLineCM."Line No." = 10000 then
                                        TaxJourLines.VAT_AMOUNT := ((SalesLineCM."VAT Base Amount" / ExchangeRate * SalesLineCM."VAT %") / 100) - SelisihVAT5
                                    else
                                        TaxJourLines.VAT_AMOUNT := ((SalesLineCM."VAT Base Amount" / ExchangeRate * SalesLineCM."VAT %") / 100);
                                end
                                else
                                    TaxJourLines.VAT_AMOUNT := ((SalesLineCM."VAT Base Amount" / ExchangeRate * SalesLineCM."VAT %") / 100);
                                TaxJourLines.TOTAL_AMOUNT := (SalesLineCM."Line Amount" / ExchangeRate) + TaxJourLines.VAT_AMOUNT;
                                TaxJourLines."Currency Code" := "Posted Sales Credit Memos"."Currency Code";
                                TaxJourLines.Insert();
                            until (SalesLineCM.Next() = 0);
                        end;
                        //Detail
                        ServiceLineCM.Reset();
                        ServiceLineCM.SetRange("Document No.", SourceTable.Document_No_);
                        ServiceLineCM.SetFilter("Type", '<> %1', ServiceLineCM.Type::" ");
                        ServiceLineCM.SetFilter("VAT Prod. Posting Group", '<> %1', 'NO VAT');
                        //Validasi VAT Amount Header dgn Line 
                        if ServiceLineCM.IsEmpty = false then
                            SelisihVAT6 := ValidasiVATAmountServiceLineCM(SourceTable.Document_No_, ServiceLineCM);
                        //Validasi VAT Amount Header dgn Line
                        if ServiceLineCM.FindSet() then begin
                            TaxJourLines.LockTable();
                            repeat
                                if TaxSetup."Export to Currency" = "Posted Service Credit Memos"."Currency Code" then
                                    ExchangeRate := 1 else
                                    if "Posted Service Credit Memos"."Currency Code" = '' then
                                        ExchangeRate := Exc.GetExchangeRate(TaxSetup."Export to Currency", GLSetup."LCY Code", "Posted Service Credit Memos"."Posting Date") else
                                        ExchangeRate := Exc.GetExchangeRate(TaxSetup."Export to Currency", "Posted Service Credit Memos"."Currency Code", "Posted Service Credit Memos"."Posting Date");
                                TaxJourLines.Init();
                                Clear(TaxJourLines.ID);
                                TaxJourLines.KRE_TAXJOURID := GetLastID();
                                TaxJourLines.INVOICELINENO := ServiceLineCM."Line No.";
                                TaxJourLines.INVOICENo := SourceTable.Document_No_;
                                TaxJourLines.TYPE := SetOptionFromService(ServiceLineCM.Type);
                                TaxJourLines.ITEMID := ServiceLineCM."No.";
                                TaxJourLines.DESCRIPTION := ServiceLineCM.Description;
                                TaxJourLines.VAT_Bus_Posting_Group := ServiceLineCM."VAT Bus. Posting Group";
                                TaxJourLines.VAT_Prod_Posting_Group := ServiceLineCM."VAT Prod. Posting Group";
                                TaxJourLines.VAT_Identifier := ServiceLineCM."VAT Identifier";
                                TaxJourLines.PRICE := ServiceLineCM."Unit Price" / ExchangeRate;
                                TaxJourLines.QTY := system.Round(ServiceLineCM.Quantity, 1, '>');
                                TaxJourLines.DISCOUNT_AMOUNT := ServiceLineCM."Line Discount Amount" / ExchangeRate;
                                VATGroup.Reset();
                                VATGroup.SetRange("Code", SourceTable.VAT_Prod__Posting_Group);
                                VATGroup.FindFirst();
                                if (VATGroup.IS_FORWARDER = true) then
                                    TaxJourLines.DPP_AMOUNT := ServiceLineCM."VAT Base Amount" / ExchangeRate / 10
                                else
                                    TaxJourLines.DPP_AMOUNT := ServiceLineCM."VAT Base Amount" / ExchangeRate;

                                if SelisihVAT6 > 0 then begin
                                    if ServiceLineCM."Line No." = 10000 then
                                        TaxJourLines.VAT_AMOUNT := ((ServiceLineCM."VAT Base Amount" / ExchangeRate * ServiceLineCM."VAT %") / 100) - SelisihVAT6
                                    else
                                        TaxJourLines.VAT_AMOUNT := ((ServiceLineCM."VAT Base Amount" / ExchangeRate * ServiceLineCM."VAT %") / 100);
                                end
                                else
                                    TaxJourLines.VAT_AMOUNT := ((ServiceLineCM."VAT Base Amount" / ExchangeRate * ServiceLineCM."VAT %") / 100);
                                TaxJourLines.TOTAL_AMOUNT := (ServiceLineCM."Line Amount" / ExchangeRate) + TaxJourLines.VAT_AMOUNT;
                                TaxJourLines."Currency Code" := "Posted Service Credit Memos"."Currency Code";
                                TaxJourLines.Insert();
                            until (ServiceLineCM.Next() = 0);
                        end;
                    end;

                //Update flag
                UpdateFlagVATEntry(SourceTable.Document_No_);
                //Update flag   
            end
            else
                if not CustomerRetail then
                    UpdateInvoice(SourceTable.Document_No_);

            // SourceTable.Is_Synch := true;
            // SourceTable.Modify();
            //until SourceTable.Next = 0;

        end;
        SourceTable.Close();

    end;

    procedure TaxSynchFixingLine()
    var
        TaxSetup: Record Kre_TaxSetup;
        SourceTable: Query KreVATEntryNotSynch;
        //SourceTable: Record "VAT Entry";
        //MappingSourceTable: Record KRE_VATEntryTaxJour;
        Vendor: Record Vendor;
        Customer: Record Customer;
        CustomerAddress: Record Customer;
        "Posted Purchase Invoice": Record "Purch. Inv. Header";
        PurchLineInv: Record "Purch. Inv. Line";
        "Posted Purchase Credit Memos": Record "Purch. Cr. Memo Hdr.";
        PurchLineCM: Record "Purch. Cr. Memo Line";
        "Posted Sales Invoices": Record "Sales Invoice Header";
        SalesLineInv: Record "Sales Invoice Line";
        ServiceLineInv: Record "Service Invoice Line";
        "Posted Sales Credit Memos": Record "Sales Cr.Memo Header";
        SalesLineCM: Record "Sales Cr.Memo Line";
        "Posted Service Credit Memos": Record "Service Cr.Memo Header";
        ServiceLineCM: Record "Service Cr.Memo Line";
        // identity: Integer;
        TaxJour: Record KRE_TAXJOUR;
        TaxJourLines: Record KRE_TAXJOURLINES;
        VATGroup: Record "VAT Product Posting Group";
        SelisihVAT1: Decimal;
        SelisihVAT2: Decimal;
        SelisihVAT3: Decimal;
        SelisihVAT4: Decimal;
        SelisihVAT5: Decimal;
        SelisihVAT6: Decimal;
        shiptoaddress: Record "Ship-to Address";
    begin

        if not TaxSetup.FindFirst() then begin
            Error('Please Setup Tax Config first !');
            exit;
        end;
        SourceTable.Open();
        while SourceTable.READ() do begin
            // if SourceTable.FindSet() then begin
            TaxJour.LockTable();
            // repeat
            //TaxJour.SetFilter(INVOICENO, '=%1', SourceTable.Document_No_);
            if not TaxJour.FindSet() then begin
                if TaxSetup.Activate_VAT_In then  //Pajak Masukan
                    if SourceTable.Type = SourceTable.Type::Purchase then begin
                        //insert data vat entry
                        //Detail
                        PurchLineInv.Reset();
                        PurchLineInv.SetRange("Document No.", SourceTable.Document_No_);
                        PurchLineInv.SetRange(IsWHTCalc, false);
                        PurchLineInv.SetRange("Type", PurchLineInv.Type::"G/L Account");
                        PurchLineInv.SetFilter("VAT Prod. Posting Group", '<> %1', 'NO VAT');
                        //Validasi VAT Amount Header dgn Line 
                        if PurchLineInv.IsEmpty = false then
                            SelisihVAT1 := ValidasiVATAmountPurchaseLineInv(SourceTable.Document_No_, PurchLineInv);
                        //Validasi VAT Amount Header dgn Line 
                        if PurchLineInv.FindSet() then begin
                            TaxJourLines.LockTable();
                            repeat
                                TaxJourLines.Init();
                                Clear(TaxJourLines.ID);
                                TaxJourLines.KRE_TAXJOURID := GetLastID();
                                TaxJourLines.INVOICELINENO := PurchLineInv."Line No.";
                                TaxJourLines.INVOICENo := SourceTable.Document_No_;
                                TaxJourLines.TYPE := PurchLineInv.Type;
                                TaxJourLines.ITEMID := PurchLineInv."No.";
                                TaxJourLines.DESCRIPTION := PurchLineInv.Description;
                                TaxJourLines.VAT_Bus_Posting_Group := PurchLineInv."VAT Bus. Posting Group";
                                TaxJourLines.VAT_Prod_Posting_Group := PurchLineInv."VAT Prod. Posting Group";
                                TaxJourLines.VAT_Identifier := PurchLineInv."VAT Identifier";
                                TaxJourLines.PRICE := PurchLineInv."Direct Unit Cost";
                                TaxJourLines.QTY := system.Round(PurchLineInv.Quantity, 1, '>');
                                TaxJourLines.TOTAL_AMOUNT := PurchLineInv."Line Amount";
                                TaxJourLines.DISCOUNT_AMOUNT := PurchLineInv."Line Discount Amount";
                                TaxJourLines.DPP_AMOUNT := PurchLineInv."VAT Base Amount";

                                if SelisihVAT1 > 0 then begin
                                    if PurchLineInv."Line No." = 10000 then
                                        TaxJourLines.VAT_AMOUNT := ((PurchLineInv."VAT Base Amount" * PurchLineInv."VAT %") / 100) - SelisihVAT1
                                    else
                                        TaxJourLines.VAT_AMOUNT := ((PurchLineInv."VAT Base Amount" * PurchLineInv."VAT %") / 100);
                                end
                                else
                                    TaxJourLines.VAT_AMOUNT := ((PurchLineInv."VAT Base Amount" * PurchLineInv."VAT %") / 100);

                                TaxJourLines.Insert();
                            until (PurchLineInv.Next() = 0);
                        end;
                        //Detail
                        PurchLineCM.Reset();
                        PurchLineCM.SetRange("Document No.", SourceTable.Document_No_);
                        PurchLineCM.SetRange(IsWHTCalc, false);
                        PurchLineCM.SetFilter("Type", '<> %1', PurchLineCM.Type::" ");
                        PurchLineCM.SetRange("Type", PurchLineInv.Type::"G/L Account");
                        //Validasi VAT Amount Header dgn Line 
                        if PurchLineCM.IsEmpty = false then
                            SelisihVAT2 := ValidasiVATAmountPurchaseLineCM(SourceTable.Document_No_, PurchLineCM);
                        //Validasi VAT Amount Header dgn Line 
                        if PurchLineCM.FindSet() then begin
                            TaxJourLines.LockTable();
                            repeat
                                TaxJourLines.Init();
                                Clear(TaxJourLines.ID);
                                TaxJourLines.KRE_TAXJOURID := GetLastID();
                                TaxJourLines.INVOICELINENO := PurchLineCM."Line No.";
                                TaxJourLines.INVOICENo := SourceTable.Document_No_;
                                TaxJourLines.TYPE := PurchLineCM.Type;
                                TaxJourLines.ITEMID := PurchLineCM."No.";
                                TaxJourLines.DESCRIPTION := PurchLineCM.Description;
                                TaxJourLines.VAT_Bus_Posting_Group := PurchLineCM."VAT Bus. Posting Group";
                                TaxJourLines.VAT_Prod_Posting_Group := PurchLineCM."VAT Prod. Posting Group";
                                TaxJourLines.VAT_Identifier := PurchLineCM."VAT Identifier";
                                TaxJourLines.PRICE := PurchLineCM."Direct Unit Cost";
                                TaxJourLines.QTY := system.Round(PurchLineCM.Quantity, 1, '>');
                                TaxJourLines.TOTAL_AMOUNT := PurchLineCM."Line Amount";
                                TaxJourLines.DISCOUNT_AMOUNT := PurchLineCM."Line Discount Amount";
                                TaxJourLines.DPP_AMOUNT := PurchLineCM."VAT Base Amount";
                                TaxJourLines."Coretax Item Code" := PurchLineCM."Coretax Item Code";
                                TaxJourLines."Coretax Item Description" := PurchLineCM."Coretax Item Description";

                                if SelisihVAT2 > 0 then begin
                                    if PurchLineCM."Line No." = 10000 then
                                        TaxJourLines.VAT_AMOUNT := ((PurchLineCM."VAT Base Amount" * PurchLineCM."VAT %") / 100) - SelisihVAT2
                                    else
                                        TaxJourLines.VAT_AMOUNT := ((PurchLineCM."VAT Base Amount" * PurchLineCM."VAT %") / 100);
                                end
                                else
                                    TaxJourLines.VAT_AMOUNT := ((PurchLineCM."VAT Base Amount" * PurchLineCM."VAT %") / 100);

                                TaxJourLines.Insert();
                            until (PurchLineCM.Next() = 0);
                        end;
                    end;

                if TaxSetup.Activate_VAT_Out then  //Pajak Keluaran
                    if SourceTable.Type = SourceTable.Type::Sale then begin
                        //insert data vat entry
                        //Detail
                        SalesLineInv.Reset();
                        SalesLineInv.SetRange("Document No.", SourceTable.Document_No_);
                        SalesLineInv.SetRange(IsWHTCalc, false);
                        SalesLineInv.SetRange("Type", PurchLineInv.Type::"G/L Account");
                        SalesLineInv.SetFilter("VAT Prod. Posting Group", '<> %1', 'NO VAT');
                        //Validasi VAT Amount Header dgn Line 
                        if SalesLineInv.IsEmpty = false then
                            SelisihVAT3 := ValidasiVATAmountSalesLineInv(SourceTable.Document_No_, SalesLineInv);
                        //Validasi VAT Amount Header dgn Line 
                        if SalesLineInv.FindSet() then begin
                            TaxJourLines.LockTable();
                            repeat
                                TaxJourLines.Init();
                                Clear(TaxJourLines.ID);
                                TaxJourLines.KRE_TAXJOURID := GetLastID();
                                TaxJourLines.INVOICELINENO := SalesLineInv."Line No.";
                                TaxJourLines.INVOICENo := SourceTable.Document_No_;
                                TaxJourLines.TYPE := SalesLineInv.Type;
                                TaxJourLines.ITEMID := SalesLineInv."No.";
                                TaxJourLines.DESCRIPTION := SalesLineInv.Description;
                                TaxJourLines.VAT_Bus_Posting_Group := SalesLineInv."VAT Bus. Posting Group";
                                TaxJourLines.VAT_Prod_Posting_Group := SalesLineInv."VAT Prod. Posting Group";
                                TaxJourLines.VAT_Identifier := SalesLineInv."VAT Identifier";
                                TaxJourLines.PRICE := SalesLineInv."Unit Price";
                                TaxJourLines.QTY := system.Round(SalesLineInv.Quantity, 1, '>');
                                TaxJourLines.TOTAL_AMOUNT := SalesLineInv."Line Amount";
                                TaxJourLines.DISCOUNT_AMOUNT := SalesLineInv."Line Discount Amount";
                                TaxJourLines."Coretax Item Code" := SalesLineInv."Coretax Item Code";
                                TaxJourLines."Coretax Item Description" := SalesLineInv."Coretax Item Description";
                                VATGroup.Reset();
                                VATGroup.SetRange("Code", SourceTable.VAT_Prod__Posting_Group);
                                VATGroup.FindFirst();
                                if (VATGroup.IS_FORWARDER = true) then
                                    TaxJourLines.DPP_AMOUNT := SalesLineInv."VAT Base Amount" / 10
                                else
                                    TaxJourLines.DPP_AMOUNT := SalesLineInv."VAT Base Amount";

                                if SelisihVAT3 > 0 then begin
                                    if SalesLineInv."Line No." = 10000 then
                                        TaxJourLines.VAT_AMOUNT := ((SalesLineInv."VAT Base Amount" * SalesLineInv."VAT %") / 100) - SelisihVAT3
                                    else
                                        TaxJourLines.VAT_AMOUNT := ((SalesLineInv."VAT Base Amount" * SalesLineInv."VAT %") / 100);
                                end
                                else
                                    TaxJourLines.VAT_AMOUNT := ((SalesLineInv."VAT Base Amount" * SalesLineInv."VAT %") / 100);

                                TaxJourLines.Insert();
                            until (SalesLineInv.Next() = 0);
                        end;
                        //Detail
                        ServiceLineInv.Reset();
                        ServiceLineInv.SetRange("Document No.", SourceTable.Document_No_);
                        ServiceLineInv.SetRange("Type", PurchLineInv.Type::"G/L Account");
                        ServiceLineInv.SetFilter("VAT Prod. Posting Group", '<> %1', 'NO VAT');
                        //Validasi VAT Amount Header dgn Line 
                        if ServiceLineInv.IsEmpty = false then
                            SelisihVAT4 := ValidasiVATAmountServiceLineInv(SourceTable.Document_No_, ServiceLineInv);
                        //Validasi VAT Amount Header dgn Line
                        if ServiceLineInv.FindSet() then begin
                            TaxJourLines.LockTable();
                            repeat
                                TaxJourLines.Init();
                                Clear(TaxJourLines.ID);
                                TaxJourLines.KRE_TAXJOURID := GetLastID();
                                TaxJourLines.INVOICELINENO := ServiceLineInv."Line No.";
                                TaxJourLines.INVOICENo := SourceTable.Document_No_;
                                TaxJourLines.TYPE := SetOptionFromService(ServiceLineInv.Type);
                                TaxJourLines.ITEMID := ServiceLineInv."No.";
                                TaxJourLines.DESCRIPTION := ServiceLineInv.Description;
                                TaxJourLines.VAT_Bus_Posting_Group := ServiceLineInv."VAT Bus. Posting Group";
                                TaxJourLines.VAT_Prod_Posting_Group := ServiceLineInv."VAT Prod. Posting Group";
                                TaxJourLines.VAT_Identifier := ServiceLineInv."VAT Identifier";
                                TaxJourLines.PRICE := ServiceLineInv."Unit Price";
                                TaxJourLines.QTY := system.Round(ServiceLineInv.Quantity, 1, '>');
                                TaxJourLines.TOTAL_AMOUNT := ServiceLineInv."Line Amount";
                                TaxJourLines.DISCOUNT_AMOUNT := ServiceLineInv."Line Discount Amount";
                                VATGroup.Reset();
                                VATGroup.SetRange("Code", SourceTable.VAT_Prod__Posting_Group);
                                VATGroup.FindFirst();
                                if (VATGroup.IS_FORWARDER = true) then
                                    TaxJourLines.DPP_AMOUNT := ServiceLineInv."VAT Base Amount" / 10
                                else
                                    TaxJourLines.DPP_AMOUNT := ServiceLineInv."VAT Base Amount";

                                if SelisihVAT4 > 0 then begin
                                    if ServiceLineInv."Line No." = 10000 then
                                        TaxJourLines.VAT_AMOUNT := ((ServiceLineInv."VAT Base Amount" * ServiceLineInv."VAT %") / 100) - SelisihVAT4
                                    else
                                        TaxJourLines.VAT_AMOUNT := ((ServiceLineInv."VAT Base Amount" * ServiceLineInv."VAT %") / 100);
                                end
                                else
                                    TaxJourLines.VAT_AMOUNT := ((ServiceLineInv."VAT Base Amount" * ServiceLineInv."VAT %") / 100);

                                TaxJourLines.Insert();
                            until (ServiceLineInv.Next() = 0);
                        end;
                        //Detail
                        SalesLineCM.Reset();
                        SalesLineCM.SetRange("Document No.", SourceTable.Document_No_);
                        SalesLineCM.SetRange(IsWHTCalc, false);
                        SalesLineCM.SetRange("Type", PurchLineInv.Type::"G/L Account");
                        SalesLineCM.SetFilter("VAT Prod. Posting Group", '<> %1', 'NO VAT');
                        //Validasi VAT Amount Header dgn Line 
                        if SalesLineCM.IsEmpty = false then
                            SelisihVAT5 := ValidasiVATAmountSalesLineCM(SourceTable.Document_No_, SalesLineCM);
                        //Validasi VAT Amount Header dgn Line
                        if SalesLineCM.FindSet() then begin
                            TaxJourLines.LockTable();
                            repeat
                                TaxJourLines.Init();
                                Clear(TaxJourLines.ID);
                                TaxJourLines.KRE_TAXJOURID := GetLastID();
                                TaxJourLines.INVOICELINENO := SalesLineCM."Line No.";
                                TaxJourLines.INVOICENo := SourceTable.Document_No_;
                                TaxJourLines.TYPE := SalesLineCM.Type;
                                TaxJourLines.ITEMID := SalesLineCM."No.";
                                TaxJourLines.DESCRIPTION := SalesLineCM.Description;
                                TaxJourLines.VAT_Bus_Posting_Group := SalesLineCM."VAT Bus. Posting Group";
                                TaxJourLines.VAT_Prod_Posting_Group := SalesLineCM."VAT Prod. Posting Group";
                                TaxJourLines.VAT_Identifier := SalesLineCM."VAT Identifier";
                                TaxJourLines.PRICE := SalesLineCM."Unit Price";
                                TaxJourLines.QTY := system.Round(SalesLineCM.Quantity, 1, '>');
                                TaxJourLines.TOTAL_AMOUNT := SalesLineCM."Line Amount";
                                TaxJourLines.DISCOUNT_AMOUNT := SalesLineCM."Line Discount Amount";
                                VATGroup.Reset();
                                VATGroup.SetRange("Code", SourceTable.VAT_Prod__Posting_Group);
                                VATGroup.FindFirst();
                                if (VATGroup.IS_FORWARDER = true) then
                                    TaxJourLines.DPP_AMOUNT := SalesLineCM."VAT Base Amount" / 10
                                else
                                    TaxJourLines.DPP_AMOUNT := SalesLineCM."VAT Base Amount";

                                if SelisihVAT5 > 0 then begin
                                    if SalesLineCM."Line No." = 10000 then
                                        TaxJourLines.VAT_AMOUNT := ((SalesLineCM."VAT Base Amount" * SalesLineCM."VAT %") / 100) - SelisihVAT5
                                    else
                                        TaxJourLines.VAT_AMOUNT := ((SalesLineCM."VAT Base Amount" * SalesLineCM."VAT %") / 100);
                                end
                                else
                                    TaxJourLines.VAT_AMOUNT := ((SalesLineCM."VAT Base Amount" * SalesLineCM."VAT %") / 100);

                                TaxJourLines.Insert();
                            until (SalesLineCM.Next() = 0);
                        end;
                        //Detail
                        ServiceLineCM.Reset();
                        ServiceLineCM.SetRange("Document No.", SourceTable.Document_No_);
                        ServiceLineCM.SetRange("Type", PurchLineInv.Type::"G/L Account");
                        ServiceLineCM.SetFilter("VAT Prod. Posting Group", '<> %1', 'NO VAT');
                        //Validasi VAT Amount Header dgn Line 
                        if ServiceLineCM.IsEmpty = false then
                            SelisihVAT6 := ValidasiVATAmountServiceLineCM(SourceTable.Document_No_, ServiceLineCM);
                        //Validasi VAT Amount Header dgn Line
                        if ServiceLineCM.FindSet() then begin
                            TaxJourLines.LockTable();
                            repeat
                                TaxJourLines.Init();
                                Clear(TaxJourLines.ID);
                                TaxJourLines.KRE_TAXJOURID := GetLastID();
                                TaxJourLines.INVOICELINENO := ServiceLineCM."Line No.";
                                TaxJourLines.INVOICENo := SourceTable.Document_No_;
                                TaxJourLines.TYPE := SetOptionFromService(ServiceLineCM.Type);
                                TaxJourLines.ITEMID := ServiceLineCM."No.";
                                TaxJourLines.DESCRIPTION := ServiceLineCM.Description;
                                TaxJourLines.VAT_Bus_Posting_Group := ServiceLineCM."VAT Bus. Posting Group";
                                TaxJourLines.VAT_Prod_Posting_Group := ServiceLineCM."VAT Prod. Posting Group";
                                TaxJourLines.VAT_Identifier := ServiceLineCM."VAT Identifier";
                                TaxJourLines.PRICE := ServiceLineCM."Unit Price";
                                TaxJourLines.QTY := system.Round(ServiceLineCM.Quantity, 1, '>');
                                TaxJourLines.TOTAL_AMOUNT := ServiceLineCM."Line Amount";
                                TaxJourLines.DISCOUNT_AMOUNT := ServiceLineCM."Line Discount Amount";
                                VATGroup.Reset();
                                VATGroup.SetRange("Code", SourceTable.VAT_Prod__Posting_Group);
                                VATGroup.FindFirst();
                                if (VATGroup.IS_FORWARDER = true) then
                                    TaxJourLines.DPP_AMOUNT := ServiceLineCM."VAT Base Amount" / 10
                                else
                                    TaxJourLines.DPP_AMOUNT := ServiceLineCM."VAT Base Amount";

                                if SelisihVAT6 > 0 then begin
                                    if ServiceLineCM."Line No." = 10000 then
                                        TaxJourLines.VAT_AMOUNT := ((ServiceLineCM."VAT Base Amount" * ServiceLineCM."VAT %") / 100) - SelisihVAT6
                                    else
                                        TaxJourLines.VAT_AMOUNT := ((ServiceLineCM."VAT Base Amount" * ServiceLineCM."VAT %") / 100);
                                end
                                else
                                    TaxJourLines.VAT_AMOUNT := ((ServiceLineCM."VAT Base Amount" * ServiceLineCM."VAT %") / 100);

                                TaxJourLines.Insert();
                            until (ServiceLineCM.Next() = 0);
                        end;
                    end;
            end;
        end;
        SourceTable.Close();

    end;

    procedure UpdateFlaqExist()
    var
        VATEntry: Record "VAT Entry";
        VATEntry2: Record KRE_VATEntryTaxJour;
    begin
        if VATEntry2.FindSet() then
            repeat
                VATEntry.SetCurrentKey("Document No.");
                VATEntry.SetRange("Document No.", VATEntry2.INVOICENO);
                VATEntry.SetFilter(Amount, '<> %1', 0);
                if VATEntry.FindSet() then begin
                    VATEntry.Is_Synch := true;
                    VATEntry.Modify();
                end;
            until VATEntry2.Next() = 0;
    end;

    local procedure GetLastID(): Integer
    var
        TaxJour1: Record KRE_TAXJOUR;
        ID_free: Integer;
    begin
        TaxJour1.SetCurrentKey(ID);
        TaxJour1.Ascending;
        TaxJour1.FindLast();
        ID_free := TaxJour1.ID;
        exit(ID_free);
    end;

    procedure SetTaxExportedLine(ID: Integer)
    var
        TaxJour1: Record KRE_TAXJOUR;
    begin
        TaxJour1.Get(ID);
        TaxJour1.TAX_EXPORTED := TaxJour1.TAX_EXPORTED::YES;
        TaxJour1.Modify();
    end;


    procedure CheckTransBeforeExport(var Trans: Record KRE_TAXJOUR) Flag: Integer
    var
        normal: Integer;
        retur: Integer;
    begin
        Trans.SetRange(IS_RETURNITEM, Trans.IS_RETURNITEM::NO);
        normal := Trans.Count();
        Trans.SetRange(IS_RETURNITEM, Trans.IS_RETURNITEM::YES);
        retur := Trans.Count();
        if normal > retur then
            exit(0)
        else
            exit(1)
    end;

    procedure TotalTransFilter(var Trans: Record KRE_TAXJOUR; isretur: integer) total: Integer
    begin
        Trans.SetFilter(IS_RETURNITEM, '=%1', isretur);
        total := Trans.Count();
    end;

    procedure SetTaxExported(var Trans: Record KRE_TAXJOUR)
    begin
        if Trans.Find('-') then
            repeat
                SetTaxExportedLine(Trans.ID);
            until Trans.Next = 0;
    end;

    procedure SetPostingPajakTrue(var Trans: Record KRE_TAXJOUR)
    begin
        if Trans.Find('-') then
            repeat
                SetPostingPajakTrueLine(Trans.ID);
            until Trans.Next = 0;
    end;

    procedure SetPostingPajakTrueLine(ID: Integer)
    var
        TaxJour1: Record KRE_TAXJOUR;
        Kre_TaxSetup: Record Kre_TaxSetup;
        RegTaxNumberCode: Codeunit RegTaxNumberCode;
        NotifValidasi: Notification;
        // ValidasiBeforePosting: Text;
        YesNo: Enum YESNO;
        TaxSource: Enum TAX_SOURCE;
    begin
        Kre_TaxSetup.FindFirst();
        TaxJour1.Get(ID);
        if (TaxJour1.TAX_SOURCE = TaxSource::Purchase) then begin
            if (TaxJour1.IS_RETURNITEM = YesNo::YES) then begin
                if (TaxJour1.RETURN_DATE = 0D) OR (TaxJour1.RETURN_DOC_NUMBER = '') OR (TaxJour1.RETURN_TAX_NUMBER = '') then begin
                    NotifValidasi.Message('Posting journal error');
                    NotifValidasi.SCOPE := NOTIFICATIONSCOPE::LocalScope;
                    NotifValidasi.SETDATA('InvNo', TaxJour1.INVOICENO);
                    NotifValidasi.ADDACTION('Invoice : ' + TaxJour1.INVOICENO, CODEUNIT::Notifikasi, 'ValidasiBeforePosting');
                    NotifValidasi.SEND();
                end
            end
            else
                if (TaxJour1.TAXDATE = 0D) OR (TaxJour1.TAXNUMBER = '') then begin
                    NotifValidasi.Message('Posting journal error');
                    NotifValidasi.SCOPE := NOTIFICATIONSCOPE::LocalScope;
                    NotifValidasi.SETDATA('InvNo', TaxJour1.INVOICENO);
                    NotifValidasi.ADDACTION('Invoice : ' + TaxJour1.INVOICENO, CODEUNIT::Notifikasi, 'ValidasiBeforePosting');
                    NotifValidasi.SEND();
                end;

        end else
            if (TaxJour1.IS_RETURNITEM = YesNo::YES) then begin
                if (TaxJour1.RETURN_DATE = 0D) OR (TaxJour1.RETURN_DOC_NUMBER = '') then begin
                    NotifValidasi.Message('Posting journal error');
                    NotifValidasi.SCOPE := NOTIFICATIONSCOPE::LocalScope;
                    NotifValidasi.SETDATA('InvNo', TaxJour1.INVOICENO);
                    NotifValidasi.ADDACTION('Invoice : ' + TaxJour1.INVOICENO, CODEUNIT::Notifikasi, 'ValidasiBeforePosting');
                    NotifValidasi.SEND();
                end
            end
            else
                if TaxJour1.TAXDATE = 0D then begin
                    NotifValidasi.Message('Posting journal error');
                    NotifValidasi.SCOPE := NOTIFICATIONSCOPE::LocalScope;
                    NotifValidasi.SETDATA('InvNo', TaxJour1.INVOICENO);
                    NotifValidasi.ADDACTION('Invoice : ' + TaxJour1.INVOICENO, CODEUNIT::Notifikasi, 'ValidasiBeforePosting');
                    NotifValidasi.SEND();
                end;



        if NotifValidasi.SEND() = true then
            exit
        else begin
            if (TaxJour1.TAX_SOURCE = TaxSource::Sales) and (TaxJour1.TAXNUMBER = '') and (TaxJour1.IS_RETURNITEM = YesNo::NO) then  //hanya journal keluaran normal
                if Kre_TaxSetup."Use Registered Tax Number" then
                    TaxJour1.TAXNUMBER := RegTaxNumberCode.GetTaxNumberFree(TaxJour1.INVOICENO, TaxJour1.TAXDATE, TaxJour1.ACCOUNTID);

            TaxJour1.TAX_POSTED := YesNo::YES;
            TaxJour1.Modify(true);
            NotifValidasi.MESSAGE := 'Posting journal Invoice No: ' + TaxJour1.INVOICENO + ' success';
            NotifValidasi.SCOPE := NOTIFICATIONSCOPE::LocalScope;
            NotifValidasi.SEND();
        end;
    end;

    procedure CheckTransType(var Trans: Record KRE_TAXJOUR)
    begin
        if Trans.Find('-') then
            repeat
                CheckTransTypeLine(Trans.ID);
            until Trans.Next() = 0;
    end;

    procedure CheckTransTypeLine(ID: Integer)
    var
        TaxJour1: Record KRE_TAXJOUR;
        NotifValidasi: Notification;
        YesNo: Enum YESNO;
    begin
        TaxJour1.Get(ID);
        if (TaxJour1.IS_RETURNITEM = YesNo::YES) then
            NotifValidasi.MESSAGE := 'This Inv No: ' + TaxJour1.INVOICENO + ' is retur Jurnal'
        else
            NotifValidasi.MESSAGE := 'This Inv No: ' + TaxJour1.INVOICENO + ' is normal Jurnal';

        NotifValidasi.SCOPE := NOTIFICATIONSCOPE::LocalScope;
        NotifValidasi.SEND();
    end;

    procedure SetOptionFromService(TipeIn: Option) TipeOut: Option
    begin
        case TipeIn of
            0:
                begin
                    TipeOut := 0;
                    exit(TipeOut);
                end;
            1:
                begin
                    TipeOut := 2;
                    exit(TipeOut);
                end;
            2:
                begin
                    TipeOut := 3;
                    exit(TipeOut);
                end;
            3:
                begin
                    TipeOut := 4;
                    exit(TipeOut);
                end;
            4:
                begin
                    TipeOut := 1;
                    exit(TipeOut);
                end;
        end;
    end;

    // local procedure InsertVATEntryMapping(Invoice: Text[50])
    // var
    //     VAT: Record KRE_VATEntryTaxJour;
    //     YesNo: Enum YESNO;
    // begin
    //     vat.Init();
    //     vat.INVOICENO := Invoice;
    //     vat.TAX_SYNCH := YesNo::YES;
    //     vat.Insert();
    // end;

    local procedure UpdateFlagVATEntry(DocNo: Code[20])
    var
        VATEntry: Record "VAT Entry";
    begin
        VATEntry.SetCurrentKey("Document No.");
        VATEntry.SetRange("Document No.", DocNo);
        VATEntry.SetFilter(Amount, '<> %1', 0);
        if VATEntry.FindSet() then begin
            VATEntry.Is_Synch := true;
            VATEntry.Modify();
        end;
    end;

    local procedure UpdateInvoice(No: Code[20]) Success: boolean
    var
        vat1: Record "VAT Entry";
        //line1: Record KRE_TAXJOURLINES;
        TaxJour1: Record KRE_TAXJOUR;
    begin
        vat1.SetRange("Document No.", No);
        vat1.SetFilter(Amount, '<> %1', 0);
        vat1.CalcSums(Base);
        vat1.CalcSums(Amount);
        TaxJour1.SetRange(INVOICENO, No);
        TaxJour1.FindSet();
        TaxJour1.DPPAMOUNT := system.ABS(vat1.Base);
        TaxJour1.VATAMOUNT := system.ABS(vat1.Amount);
        TaxJour1.INVOICEAMOUNT := system.ABS(vat1.Base + vat1.Amount);
        TaxJour1.Modify(true);

        // line1.SetRange(INVOICENO, No);
        // line1.SetFilter(TYPE, '<> %1', 2);

        // if line1.FindSet() then
        //     success := line1.Delete();

    end;

    procedure SetRoundType(Round: Option): Text[1]
    begin
        case Round of
            0:
                exit('=');
            1:
                exit('>');
            2:
                exit('<');
        end;
    end;

    procedure ValidasiVATAmountSalesLineInv(DocNo: Code[20]; var SalesLineInv: Record "Sales Invoice Line"): Decimal
    var
        VATEntry: Record "VAT Entry";
        VATamountHeader: Decimal;
        VATamountLine: Decimal;
    begin
        VATEntry.SetRange("Document No.", DocNo);
        if VATEntry.FindSet() then begin
            VATEntry.CalcSums(Amount);
            VATamountHeader := System.Abs(VATEntry.Amount);

            SalesLineInv.FindSet();
            repeat
                VATamountLine += (SalesLineInv."VAT Base Amount" * SalesLineInv."VAT %") / 100;
            until SalesLineInv.Next() = 0;

            if (VATamountLine - VATamountHeader) > 0 then
                exit(VATamountLine - VATamountHeader)
            else
                exit(0);
        end;
    end;

    local procedure ValidasiVATAmountServiceLineInv(DocNo: Code[20]; var ServiceLineInv: Record "Service Invoice Line"): Decimal
    var
        VATEntry: Record "VAT Entry";
        VATamountHeader: Decimal;
        VATamountLine: Decimal;
    begin
        VATEntry.SetRange("Document No.", DocNo);
        if VATEntry.FindSet() then begin
            VATEntry.CalcSums(Amount);
            VATamountHeader := System.Abs(VATEntry.Amount);

            ServiceLineInv.FindSet();
            repeat
                VATamountLine += (ServiceLineInv."VAT Base Amount" * ServiceLineInv."VAT %") / 100;
            until ServiceLineInv.Next() = 0;

            if (VATamountLine - VATamountHeader) > 0 then
                exit(VATamountLine - VATamountHeader)
            else
                exit(0);
        end;
    end;

    local procedure ValidasiVATAmountSalesLineCM(DocNo: Code[20]; var SalesLineCM: Record "Sales Cr.Memo Line"): Decimal
    var
        VATEntry: Record "VAT Entry";
        VATamountHeader: Decimal;
        VATamountLine: Decimal;
    begin
        VATEntry.SetRange("Document No.", DocNo);
        if VATEntry.FindSet() then begin
            VATEntry.CalcSums(Amount);
            VATamountHeader := System.Abs(VATEntry.Amount);

            SalesLineCM.FindSet();
            repeat
                VATamountLine += (SalesLineCM."VAT Base Amount" * SalesLineCM."VAT %") / 100;
            until SalesLineCM.Next() = 0;

            if (VATamountLine - VATamountHeader) > 0 then
                exit(VATamountLine - VATamountHeader)
            else
                exit(0);
        end;
    end;

    local procedure ValidasiVATAmountServiceLineCM(DocNo: Code[20]; var ServiceLineCM: Record "Service Cr.Memo Line"): Decimal
    var
        VATEntry: Record "VAT Entry";
        VATamountHeader: Decimal;
        VATamountLine: Decimal;
    begin
        VATEntry.SetRange("Document No.", DocNo);
        if VATEntry.FindSet() then begin
            VATEntry.CalcSums(Amount);
            VATamountHeader := System.Abs(VATEntry.Amount);

            ServiceLineCM.FindSet();
            repeat
                VATamountLine += (ServiceLineCM."VAT Base Amount" * ServiceLineCM."VAT %") / 100;
            until ServiceLineCM.Next() = 0;

            if (VATamountLine - VATamountHeader) > 0 then
                exit(VATamountLine - VATamountHeader)
            else
                exit(0);
        end;
    end;

    procedure ValidasiVATAmountPurchaseLineInv(DocNo: Code[20]; var PurchLineInv: Record "Purch. Inv. Line"): Decimal
    var
        VATEntry: Record "VAT Entry";
        VATamountHeader: Decimal;
        VATamountLine: Decimal;
    begin
        VATEntry.SetRange("Document No.", DocNo);
        if VATEntry.FindSet() then begin
            VATEntry.CalcSums(Amount);
            VATamountHeader := System.Abs(VATEntry.Amount);

            PurchLineInv.FindSet();
            repeat
                VATamountLine += (PurchLineInv."VAT Base Amount" * PurchLineInv."VAT %") / 100;
            until PurchLineInv.Next() = 0;

            if (VATamountLine - VATamountHeader) > 0 then
                exit(VATamountLine - VATamountHeader)
            else
                exit(0);
        end
    end;

    procedure ValidasiVATAmountPurchaseLineInvForeign(DocNo: Code[20]; var PurchLineInv: Record "Purch. Inv. Line"): Decimal
    var
        VATEntry: Record "VAT Entry";
        VATamountHeader: Decimal;
        VATamountLine: Decimal;
    begin
        VATEntry.SetRange("Document No.", DocNo);
        if VATEntry.FindSet() then begin
            VATEntry.CalcSums(Amount);
            VATamountHeader := System.Abs(VATEntry."Additional-Currency Amount");

            PurchLineInv.FindSet();
            repeat
                VATamountLine += (PurchLineInv."VAT Base Amount" * PurchLineInv."VAT %") / 100;
            until PurchLineInv.Next() = 0;

            if (VATamountLine - VATamountHeader) > 0 then
                exit(VATamountLine - VATamountHeader)
            else
                exit(0);
        end
    end;

    local procedure ValidasiVATAmountPurchaseLineCM(DocNo: Code[20]; var PurchLineCM: Record "Purch. Cr. Memo Line"): Decimal
    var
        VATEntry: Record "VAT Entry";
        VATamountHeader: Decimal;
        VATamountLine: Decimal;
    begin
        VATEntry.CalcSums(Amount);
        VATamountHeader := System.Abs(VATEntry.Amount);

        PurchLineCM.FindSet();
        repeat
            VATamountLine += (PurchLineCM."VAT Base Amount" * PurchLineCM."VAT %") / 100;
        until PurchLineCM.Next() = 0;

        if (VATamountLine - VATamountHeader) > 0 then
            exit(VATamountLine - VATamountHeader)
        else
            exit(0);
    end;

    local procedure GetCustomerID(var Customer: Record Customer; var TaxJour: Record KRE_TAXJOUR)
    begin
        if Customer."ID Type" = Customer."ID Type"::TIN then begin
            TaxJour.NPWP := Customer.NPWP;
            TaxJour."Jenis ID Pembeli" := TaxJour."Jenis ID Pembeli"::TIN;
            TaxJour."Customer ID" := Customer.NPWP;
        end;
        if Customer."ID Type" = Customer."ID Type"::"National ID" then begin
            TaxJour.NPWP := Customer.NIK;
            TaxJour."Jenis ID Pembeli" := TaxJour."Jenis ID Pembeli"::"National ID";
            TaxJour."Customer ID" := Customer.NIK;
        end;
        if Customer."ID Type" = Customer."ID Type"::Passport then begin
            TaxJour."Jenis ID Pembeli" := TaxJour."Jenis ID Pembeli"::Passport;
            TaxJour."Customer ID" := Customer."Passport No.";
        end;
        if Customer."ID Type" = Customer."ID Type"::"Other ID" then begin
            TaxJour."Jenis ID Pembeli" := TaxJour."Jenis ID Pembeli"::"Other ID";
            TaxJour."Customer ID" := Customer."Other ID";
        end;
    end;

    local procedure GetVendorID(var Vendor: Record Vendor; var TaxJour: Record KRE_TAXJOUR)
    begin
        if Vendor."ID Type" = Vendor."ID Type"::TIN then begin
            TaxJour.NPWP := Vendor.NPWP;
            TaxJour."Jenis ID Penjual" := TaxJour."Jenis ID Penjual"::TIN;
            TaxJour."Vendor ID" := Vendor.NPWP;
        end;
        if Vendor."ID Type" = Vendor."ID Type"::"National ID" then begin
            TaxJour.NPWP := Vendor.NIK;
            TaxJour."Jenis ID Penjual" := TaxJour."Jenis ID Penjual"::"National ID";
            TaxJour."Vendor ID" := Vendor.NIK;
        end;
        if Vendor."ID Type" = Vendor."ID Type"::Passport then begin
            TaxJour."Jenis ID Penjual" := TaxJour."Jenis ID Penjual"::Passport;
            TaxJour."Vendor ID" := Vendor."Passport No.";
        end;
        if Vendor."ID Type" = Vendor."ID Type"::"Other ID" then begin
            TaxJour."Jenis ID Penjual" := TaxJour."Jenis ID Penjual"::"Other ID";
            TaxJour."Vendor ID" := Vendor."Other ID";
        end;
    end;

    procedure InsertTaxExcemptionVAT(var SalesHeader: Record "Sales Header")
    var
        TaxJour: Record KRE_TAXJOUR;
        TaxJourLines: Record KRE_TAXJOURLINES;
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        shiptoaddress: Record "Ship-to Address";
    begin
        TaxJour.SetFilter("Pre-Assigned No.", '=%1', SalesHeader."No.");
        if not TaxJour.FindSet() then begin
            Clear(TaxJour);
            TaxJour.Init();
            //TaxJour.INVOICENO := SalesHeader."No.";
            TaxJour."Pre-Assigned No." := SalesHeader."No.";
            TaxJour.INVOICEDATE := SalesHeader."Document Date";
            TaxJour.DOCUMENTNO := SalesHeader."External Document No.";
            TaxJour.TAXDATE := SalesHeader.TAXDATE;
            TaxJour."VAT Bus. Posting Group" := SalesHeader."VAT Bus. Posting Group";
            TaxJour."VAT Calculation Type" := SalesLine."VAT Calculation Type";
            //TaxJour."VAT Prod. Posting Group" := SalesHeader.VAT_Prod__Posting_Group;
            if Customer.Get(SalesHeader."Sell-to Customer No.") then begin
                TaxJour.ACCOUNTID := Customer."No.";
                GetCustomerID(Customer, TaxJour);
                TaxJour.NAMA := Customer.NamaNPWP;
                if Customer.NPWPAddressfromShipTo then begin
                    shiptoaddress.SetRange("Customer No.", Customer."No.");
                    shiptoaddress.SetRange("Code", SalesHeader."Ship-to Code");
                    if shiptoaddress.FindFirst() then begin
                        TaxJour.ALAMATNPWP := shiptoaddress.AlamatNPWP;
                        TaxJour."ID TKU Pembeli" := shiptoaddress."ID TKU";
                        TaxJour."Ship-to Code" := shiptoaddress.Code;
                    end;
                end else begin
                    TaxJour.ALAMATNPWP := Customer.AlamatNPWP;
                    TaxJour."ID TKU Pembeli" := Customer."ID TKU"
                end;
            end;
            if (SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice) OR (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) then begin
                TaxJour.IS_CREDITABLE := 1;
                TaxJour.IS_RETURNITEM := TaxJour.IS_RETURNITEM::NO;
            end;
            if SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo" then begin
                TaxJour.IS_CREDITABLE := 0;
                TaxJour.IS_RETURNITEM := TaxJour.IS_RETURNITEM::YES;
                TaxJour.RETURN_TAX_NUMBER := SalesHeader.RETURN_TAX_NUMBER;
                TaxJour.RETURN_DATE := SalesHeader.RETURN_DATE;
                TaxJour.RETURN_DOC_NUMBER := SalesHeader.RETURN_DOC_NUMBER;
            end;

            TaxJour.TAX_SOURCE := TaxJour.TAX_SOURCE::Sales;
            TaxJour.TAXNUMBER := SalesHeader.TAXNUMBER;
            TaxJour.CURRENCY := SalesHeader."Currency Code";
            TaxJour.Kode_Dokumen_Pendukung := SalesHeader."External Document No.";
            SalesLine.Reset();
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Is TaxExemption", true);
            SalesLine.SetRange(IsWHTCalc, false);
            SalesLine.CalcSums("Tax Exemption Amount", Amount);
            TaxJour.DPPAMOUNT := system.ABS(SalesLine."Amount");
            TaxJour.VATAMOUNT := system.ABS(SalesLine."Tax Exemption Amount");
            TaxJour.INVOICEAMOUNT := system.ABS(SalesLine."Amount") + system.ABS(SalesLine."Tax Exemption Amount");
            TaxJour.TAX_POSTED := TaxJour.TAX_POSTED::NO;
            TaxJour.TAX_EXPORTED := TaxJour.TAX_EXPORTED::NO;
            TaxJour.Insert();

            SalesLine.Reset();
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Is TaxExemption", true);
            if SalesLine.FindSet() then begin
                TaxJourLines.LockTable();
                repeat
                    TaxJourLines.Init();
                    Clear(TaxJourLines.ID);
                    TaxJourLines.KRE_TAXJOURID := GetLastID();
                    TaxJourLines.INVOICELINENO := SalesLine."Line No.";
                    TaxJourLines.INVOICENo := SalesLine."Document No.";
                    TaxJourLines.TYPE := SalesLine.Type;
                    TaxJourLines.ITEMID := SalesLine."No.";
                    TaxJourLines.DESCRIPTION := SalesLine.Description;
                    TaxJourLines.VAT_Bus_Posting_Group := SalesLine."VAT Bus. Posting Group";
                    TaxJourLines.VAT_Prod_Posting_Group := SalesLine."VAT Prod. Posting Group";
                    TaxJourLines.VAT_Identifier := SalesLine."VAT Identifier";
                    TaxJourLines.PRICE := SalesLine."Unit Price";
                    TaxJourLines.QTY := system.Round(SalesLine.Quantity, 1, '>');
                    TaxJourLines.TOTAL_AMOUNT := SalesLine."Tax Exemption Amount" + SalesLine."Amount";
                    TaxJourLines.DISCOUNT_AMOUNT := SalesLine."Line Discount Amount";
                    TaxJourLines.DPP_AMOUNT := SalesLine."Amount";
                    TaxJourLines.VAT_AMOUNT := SalesLine."Tax Exemption Amount";
                    TaxJourLines."Coretax Item Code" := SalesLine."Coretax Item Code";
                    TaxJourLines."Coretax Item Description" := SalesLine."Coretax Item Description";
                    TaxJourLines.Insert();
                until (SalesLine.Next() = 0);
            end;
        end;
    end;

    procedure InsertTaxExcemptionVATForeignCurrency(var SalesHeader: Record "Sales Header"; Exch: Decimal)
    var
        TaxJour: Record KRE_TAXJOUR;
        TaxJourLines: Record KRE_TAXJOURLINES;
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        shiptoaddress: Record "Ship-to Address";
    begin
        TaxJour.SetFilter("Pre-Assigned No.", '=%1', SalesHeader."No.");
        if not TaxJour.FindSet() then begin
            Clear(TaxJour);
            TaxJour.Init();
            //TaxJour.INVOICENO := SalesHeader."No.";
            TaxJour."Pre-Assigned No." := SalesHeader."No.";
            TaxJour.INVOICEDATE := SalesHeader."Document Date";
            TaxJour.DOCUMENTNO := SalesHeader."External Document No.";
            TaxJour.TAXDATE := SalesHeader.TAXDATE;
            TaxJour."VAT Bus. Posting Group" := SalesHeader."VAT Bus. Posting Group";
            TaxJour."VAT Calculation Type" := SalesLine."VAT Calculation Type";
            //TaxJour."VAT Prod. Posting Group" := SalesHeader.VAT_Prod__Posting_Group;
            if Customer.Get(SalesHeader."Sell-to Customer No.") then begin
                TaxJour.ACCOUNTID := Customer."No.";
                GetCustomerID(Customer, TaxJour);
                TaxJour.NAMA := Customer.NamaNPWP;
                if Customer.NPWPAddressfromShipTo then begin
                    shiptoaddress.SetRange("Customer No.", Customer."No.");
                    shiptoaddress.SetRange("Code", SalesHeader."Ship-to Code");
                    if shiptoaddress.FindFirst() then begin
                        TaxJour.ALAMATNPWP := shiptoaddress.AlamatNPWP;
                        TaxJour."ID TKU Pembeli" := shiptoaddress."ID TKU";
                        TaxJour."Ship-to Code" := shiptoaddress.Code;
                    end;
                end else begin
                    TaxJour.ALAMATNPWP := Customer.AlamatNPWP;
                    TaxJour."ID TKU Pembeli" := Customer."ID TKU"
                end;
            end;
            if (SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice) OR (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) then begin
                TaxJour.IS_CREDITABLE := 1;
                TaxJour.IS_RETURNITEM := TaxJour.IS_RETURNITEM::NO;
            end;
            if SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo" then begin
                TaxJour.IS_CREDITABLE := 0;
                TaxJour.IS_RETURNITEM := TaxJour.IS_RETURNITEM::YES;
                TaxJour.RETURN_TAX_NUMBER := SalesHeader.RETURN_TAX_NUMBER;
                TaxJour.RETURN_DATE := SalesHeader.RETURN_DATE;
                TaxJour.RETURN_DOC_NUMBER := SalesHeader.RETURN_DOC_NUMBER;
            end;

            TaxJour.TAX_SOURCE := TaxJour.TAX_SOURCE::Sales;
            TaxJour.TAXNUMBER := SalesHeader.TAXNUMBER;
            TaxJour.CURRENCY := SalesHeader."Currency Code";
            TaxJour.Kode_Dokumen_Pendukung := SalesHeader."External Document No.";
            SalesLine.Reset();
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Is TaxExemption", true);
            SalesLine.SetRange(IsWHTCalc, false);
            SalesLine.CalcSums("Tax Exemption Amount", Amount);
            TaxJour.DPPAMOUNT := system.ABS(SalesLine."Amount" / Exch);
            TaxJour.VATAMOUNT := system.ABS(SalesLine."Tax Exemption Amount" / Exch);
            TaxJour.INVOICEAMOUNT := system.ABS(SalesLine."Amount" / Exch) + system.ABS(SalesLine."Tax Exemption Amount" / Exch);
            TaxJour.TAX_POSTED := TaxJour.TAX_POSTED::NO;
            TaxJour.TAX_EXPORTED := TaxJour.TAX_EXPORTED::NO;
            TaxJour.Insert();

            SalesLine.Reset();
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Is TaxExemption", true);
            if SalesLine.FindSet() then begin
                TaxJourLines.LockTable();
                repeat
                    TaxJourLines.Init();
                    Clear(TaxJourLines.ID);
                    TaxJourLines.KRE_TAXJOURID := GetLastID();
                    TaxJourLines.INVOICELINENO := SalesLine."Line No.";
                    TaxJourLines.INVOICENo := SalesLine."Document No.";
                    TaxJourLines.TYPE := SalesLine.Type;
                    TaxJourLines.ITEMID := SalesLine."No.";
                    TaxJourLines.DESCRIPTION := SalesLine.Description;
                    TaxJourLines.VAT_Bus_Posting_Group := SalesLine."VAT Bus. Posting Group";
                    TaxJourLines.VAT_Prod_Posting_Group := SalesLine."VAT Prod. Posting Group";
                    TaxJourLines.VAT_Identifier := SalesLine."VAT Identifier";
                    TaxJourLines.PRICE := SalesLine."Unit Price";
                    TaxJourLines.QTY := system.Round(SalesLine.Quantity, 1, '>');
                    TaxJourLines.TOTAL_AMOUNT := (SalesLine."Tax Exemption Amount" / Exch) + (SalesLine."Amount" / Exch);
                    TaxJourLines.DISCOUNT_AMOUNT := SalesLine."Line Discount Amount" / Exch;
                    TaxJourLines.DPP_AMOUNT := SalesLine."Amount" / Exch;
                    TaxJourLines.VAT_AMOUNT := SalesLine."Tax Exemption Amount" / Exch;
                    TaxJourLines."Coretax Item Code" := SalesLine."Coretax Item Code";
                    TaxJourLines."Coretax Item Description" := SalesLine."Coretax Item Description";
                    TaxJourLines.Insert();
                until (SalesLine.Next() = 0);
            end;
        end;
    end;

    procedure InsertTaxExcemptionVATfromPostedSI(var SalesInvHeader: Record "Sales Invoice Header")
    var
        TaxJour: Record KRE_TAXJOUR;
        TaxJourLines: Record KRE_TAXJOURLINES;
        SalesInvLine: Record "Sales Invoice Line";
        Customer: Record Customer;
        shiptoaddress: Record "Ship-to Address";
    begin
        TaxJour.SetFilter(INVOICENO, '=%1', SalesInvHeader."No.");
        if not TaxJour.FindSet() then begin
            Clear(TaxJour);
            TaxJour.Init();
            TaxJour.INVOICENO := SalesInvHeader."No.";
            TaxJour."Pre-Assigned No." := SalesInvHeader."Pre-Assigned No.";
            TaxJour.INVOICEDATE := SalesInvHeader."Document Date";
            TaxJour.DOCUMENTNO := SalesInvHeader."External Document No.";
            TaxJour.TAXDATE := SalesInvHeader.TAXDATE;
            TaxJour."VAT Bus. Posting Group" := SalesInvHeader."VAT Bus. Posting Group";
            TaxJour."VAT Calculation Type" := SalesInvLine."VAT Calculation Type";
            //TaxJour."VAT Prod. Posting Group" := SalesHeader.VAT_Prod__Posting_Group;
            if Customer.Get(SalesInvHeader."Sell-to Customer No.") then begin
                TaxJour.ACCOUNTID := Customer."No.";
                GetCustomerID(Customer, TaxJour);
                TaxJour.NAMA := Customer.NamaNPWP;
                if Customer.NPWPAddressfromShipTo then begin
                    shiptoaddress.SetRange("Customer No.", Customer."No.");
                    shiptoaddress.SetRange("Code", SalesInvHeader."Ship-to Code");
                    if shiptoaddress.FindFirst() then begin
                        TaxJour.ALAMATNPWP := shiptoaddress.AlamatNPWP;
                        TaxJour."ID TKU Pembeli" := shiptoaddress."ID TKU";
                        TaxJour."Ship-to Code" := shiptoaddress.Code;
                    end;
                end else begin
                    TaxJour.ALAMATNPWP := Customer.AlamatNPWP;
                    TaxJour."ID TKU Pembeli" := Customer."ID TKU"
                end;
            end;
            TaxJour.IS_CREDITABLE := 1;
            TaxJour.IS_RETURNITEM := TaxJour.IS_RETURNITEM::NO;
        end;

        TaxJour.TAX_SOURCE := TaxJour.TAX_SOURCE::Sales;
        TaxJour.TAXNUMBER := SalesInvHeader.TAXNUMBER;
        TaxJour.CURRENCY := SalesInvHeader."Currency Code";
        TaxJour.Kode_Dokumen_Pendukung := SalesInvHeader."External Document No.";
        SalesInvLine.Reset();
        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
        SalesInvLine.SetRange(IsWHTCalc, false);
        SalesInvLine.SetRange("Is TaxExemption", true);
        SalesInvLine.CalcSums("Tax Exemption Amount", Amount);
        TaxJour.DPPAMOUNT := system.ABS(SalesInvLine."Amount");
        TaxJour.VATAMOUNT := system.ABS(SalesInvLine."Tax Exemption Amount");
        TaxJour.INVOICEAMOUNT := system.ABS(SalesInvLine."Amount") + system.ABS(SalesInvLine."Tax Exemption Amount");
        TaxJour.TAX_POSTED := TaxJour.TAX_POSTED::NO;
        TaxJour.TAX_EXPORTED := TaxJour.TAX_EXPORTED::NO;
        TaxJour.Insert();

        SalesInvLine.Reset();
        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
        //SalesInvLine.SetRange("Document Type", SalesInvHeader."Document Type");
        SalesInvLine.SetRange("Is TaxExemption", true);
        if SalesInvLine.FindSet() then begin
            TaxJourLines.LockTable();
            repeat
                TaxJourLines.Init();
                Clear(TaxJourLines.ID);
                TaxJourLines.KRE_TAXJOURID := GetLastID();
                TaxJourLines.INVOICELINENO := SalesInvLine."Line No.";
                TaxJourLines.INVOICENo := SalesInvLine."Document No.";
                TaxJourLines.TYPE := SalesInvLine.Type;
                TaxJourLines.ITEMID := SalesInvLine."No.";
                TaxJourLines.DESCRIPTION := SalesInvLine.Description;
                TaxJourLines.VAT_Bus_Posting_Group := SalesInvLine."VAT Bus. Posting Group";
                TaxJourLines.VAT_Prod_Posting_Group := SalesInvLine."VAT Prod. Posting Group";
                TaxJourLines.VAT_Identifier := SalesInvLine."VAT Identifier";
                TaxJourLines.PRICE := SalesInvLine."Unit Price";
                TaxJourLines.QTY := system.Round(SalesInvLine.Quantity, 1, '>');
                TaxJourLines.TOTAL_AMOUNT := SalesInvLine."Tax Exemption Amount" + SalesInvLine."Amount";
                TaxJourLines.DISCOUNT_AMOUNT := SalesInvLine."Line Discount Amount";
                TaxJourLines.DPP_AMOUNT := SalesInvLine."Amount";
                TaxJourLines.VAT_AMOUNT := SalesInvLine."Tax Exemption Amount";
                TaxJourLines."Coretax Item Code" := SalesInvLine."Coretax Item Code";
                TaxJourLines."Coretax Item Description" := SalesInvLine."Coretax Item Description";
                TaxJourLines.Insert();
            until (SalesInvLine.Next() = 0);
        end;
    end;

    procedure InsertTaxExcemptionVATfromPostedSIForeignCurrency(var SalesInvHeader: Record "Sales Invoice Header"; Exch: Decimal)
    var
        TaxJour: Record KRE_TAXJOUR;
        TaxJourLines: Record KRE_TAXJOURLINES;
        SalesInvLine: Record "Sales Invoice Line";
        Customer: Record Customer;
        shiptoaddress: Record "Ship-to Address";
    begin
        TaxJour.SetFilter(INVOICENO, '=%1', SalesInvHeader."No.");
        if not TaxJour.FindSet() then begin
            Clear(TaxJour);
            TaxJour.Init();
            TaxJour.INVOICENO := SalesInvHeader."No.";
            TaxJour."Pre-Assigned No." := SalesInvHeader."Pre-Assigned No.";
            TaxJour.INVOICEDATE := SalesInvHeader."Document Date";
            TaxJour.DOCUMENTNO := SalesInvHeader."External Document No.";
            TaxJour.TAXDATE := SalesInvHeader.TAXDATE;
            TaxJour."VAT Bus. Posting Group" := SalesInvHeader."VAT Bus. Posting Group";
            TaxJour."VAT Calculation Type" := SalesInvLine."VAT Calculation Type";
            //TaxJour."VAT Prod. Posting Group" := SalesHeader.VAT_Prod__Posting_Group;
            if Customer.Get(SalesInvHeader."Sell-to Customer No.") then begin
                TaxJour.ACCOUNTID := Customer."No.";
                GetCustomerID(Customer, TaxJour);
                TaxJour.NAMA := Customer.NamaNPWP;
                if Customer.NPWPAddressfromShipTo then begin
                    shiptoaddress.SetRange("Customer No.", Customer."No.");
                    shiptoaddress.SetRange("Code", SalesInvHeader."Ship-to Code");
                    if shiptoaddress.FindFirst() then begin
                        TaxJour.ALAMATNPWP := shiptoaddress.AlamatNPWP;
                        TaxJour."ID TKU Pembeli" := shiptoaddress."ID TKU";
                        TaxJour."Ship-to Code" := shiptoaddress.Code;
                    end;
                end else begin
                    TaxJour.ALAMATNPWP := Customer.AlamatNPWP;
                    TaxJour."ID TKU Pembeli" := Customer."ID TKU"
                end;
            end;
            TaxJour.IS_CREDITABLE := 1;
            TaxJour.IS_RETURNITEM := TaxJour.IS_RETURNITEM::NO;
        end;

        TaxJour.TAX_SOURCE := TaxJour.TAX_SOURCE::Sales;
        TaxJour.TAXNUMBER := SalesInvHeader.TAXNUMBER;
        TaxJour.CURRENCY := SalesInvHeader."Currency Code";
        TaxJour.Kode_Dokumen_Pendukung := SalesInvHeader."External Document No.";
        SalesInvLine.Reset();
        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
        SalesInvLine.SetRange(IsWHTCalc, false);
        SalesInvLine.SetRange("Is TaxExemption", true);
        SalesInvLine.CalcSums("Tax Exemption Amount", Amount);
        TaxJour.DPPAMOUNT := system.ABS(SalesInvLine."Amount" / Exch);
        TaxJour.VATAMOUNT := system.ABS(SalesInvLine."Tax Exemption Amount" / Exch);
        TaxJour.INVOICEAMOUNT := system.ABS(SalesInvLine."Amount") / Exch + system.ABS(SalesInvLine."Tax Exemption Amount" / Exch);
        TaxJour.TAX_POSTED := TaxJour.TAX_POSTED::NO;
        TaxJour.TAX_EXPORTED := TaxJour.TAX_EXPORTED::NO;
        TaxJour.Insert();

        SalesInvLine.Reset();
        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
        //SalesInvLine.SetRange("Document Type", SalesInvHeader."Document Type");
        SalesInvLine.SetRange("Is TaxExemption", true);
        if SalesInvLine.FindSet() then begin
            TaxJourLines.LockTable();
            repeat
                TaxJourLines.Init();
                Clear(TaxJourLines.ID);
                TaxJourLines.KRE_TAXJOURID := GetLastID();
                TaxJourLines.INVOICELINENO := SalesInvLine."Line No.";
                TaxJourLines.INVOICENo := SalesInvLine."Document No.";
                TaxJourLines.TYPE := SalesInvLine.Type;
                TaxJourLines.ITEMID := SalesInvLine."No.";
                TaxJourLines.DESCRIPTION := SalesInvLine.Description;
                TaxJourLines.VAT_Bus_Posting_Group := SalesInvLine."VAT Bus. Posting Group";
                TaxJourLines.VAT_Prod_Posting_Group := SalesInvLine."VAT Prod. Posting Group";
                TaxJourLines.VAT_Identifier := SalesInvLine."VAT Identifier";
                TaxJourLines.PRICE := SalesInvLine."Unit Price";
                TaxJourLines.QTY := system.Round(SalesInvLine.Quantity, 1, '>');
                TaxJourLines.TOTAL_AMOUNT := (SalesInvLine."Tax Exemption Amount" / Exch) + (SalesInvLine."Amount" / Exch);
                TaxJourLines.DISCOUNT_AMOUNT := SalesInvLine."Line Discount Amount" / Exch;
                TaxJourLines.DPP_AMOUNT := SalesInvLine."Amount" / Exch;
                TaxJourLines.VAT_AMOUNT := SalesInvLine."Tax Exemption Amount" / Exch;
                TaxJourLines."Coretax Item Code" := SalesInvLine."Coretax Item Code";
                TaxJourLines."Coretax Item Description" := SalesInvLine."Coretax Item Description";
                TaxJourLines.Insert();
            until (SalesInvLine.Next() = 0);
        end;
    end;

    procedure InsertTaxExcemptionVATfromPostedCrMm(var SalesInvHeader: Record "Sales Cr.Memo Header")
    var
        TaxJour: Record KRE_TAXJOUR;
        TaxJourLines: Record KRE_TAXJOURLINES;
        SalesInvLine: Record "Sales Cr.Memo Line";
        Customer: Record Customer;
        shiptoaddress: Record "Ship-to Address";
    begin
        TaxJour.SetFilter(INVOICENO, '=%1', SalesInvHeader."No.");
        if not TaxJour.FindSet() then begin
            Clear(TaxJour);
            TaxJour.Init();
            TaxJour.INVOICENO := SalesInvHeader."No.";
            TaxJour."Pre-Assigned No." := SalesInvHeader."Pre-Assigned No.";
            TaxJour.INVOICEDATE := SalesInvHeader."Document Date";
            TaxJour.DOCUMENTNO := SalesInvHeader."External Document No.";
            //TaxJour.TAXDATE := SalesInvHeader.TAXDATE;
            TaxJour."VAT Bus. Posting Group" := SalesInvHeader."VAT Bus. Posting Group";
            TaxJour."VAT Calculation Type" := SalesInvLine."VAT Calculation Type";
            //TaxJour."VAT Prod. Posting Group" := SalesHeader.VAT_Prod__Posting_Group;
            if Customer.Get(SalesInvHeader."Sell-to Customer No.") then begin
                TaxJour.ACCOUNTID := Customer."No.";
                GetCustomerID(Customer, TaxJour);
                TaxJour.NAMA := Customer.NamaNPWP;
                if Customer.NPWPAddressfromShipTo then begin
                    shiptoaddress.SetRange("Customer No.", Customer."No.");
                    shiptoaddress.SetRange("Code", SalesInvHeader."Ship-to Code");
                    if shiptoaddress.FindFirst() then begin
                        TaxJour.ALAMATNPWP := shiptoaddress.AlamatNPWP;
                        TaxJour."ID TKU Pembeli" := shiptoaddress."ID TKU";
                        TaxJour."Ship-to Code" := shiptoaddress.Code;
                    end;
                end else begin
                    TaxJour.ALAMATNPWP := Customer.AlamatNPWP;
                    TaxJour."ID TKU Pembeli" := Customer."ID TKU"
                end;
            end;
            TaxJour.IS_CREDITABLE := 0;
            TaxJour.IS_RETURNITEM := TaxJour.IS_RETURNITEM::YES;
            TaxJour.RETURN_TAX_NUMBER := SalesInvHeader.RETURN_TAX_NUMBER;
            TaxJour.RETURN_DATE := SalesInvHeader.RETURN_DATE;
            TaxJour.RETURN_DOC_NUMBER := SalesInvHeader.RETURN_DOC_NUMBER;

            TaxJour.TAX_SOURCE := TaxJour.TAX_SOURCE::Sales;
            //TaxJour.TAXNUMBER := SalesInvHeader.TAXNUMBER;
            TaxJour.CURRENCY := SalesInvHeader."Currency Code";
            TaxJour.Kode_Dokumen_Pendukung := SalesInvHeader."External Document No.";
            SalesInvLine.Reset();
            SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
            SalesInvLine.SetRange("Is TaxExemption", true);
            SalesInvLine.CalcSums("Tax Exemption Amount", Amount);
            TaxJour.DPPAMOUNT := system.ABS(SalesInvLine."Amount");
            TaxJour.VATAMOUNT := system.ABS(SalesInvLine."Tax Exemption Amount");
            TaxJour.INVOICEAMOUNT := system.ABS(SalesInvLine."Amount") + system.ABS(SalesInvLine."Tax Exemption Amount");
            TaxJour.TAX_POSTED := TaxJour.TAX_POSTED::NO;
            TaxJour.TAX_EXPORTED := TaxJour.TAX_EXPORTED::NO;
            TaxJour.Insert();

            SalesInvLine.Reset();
            SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
            //SalesInvLine.SetRange("Document Type", SalesInvHeader."Document Type");
            SalesInvLine.SetRange("Is TaxExemption", true);
            if SalesInvLine.FindSet() then begin
                TaxJourLines.LockTable();
                repeat
                    TaxJourLines.Init();
                    Clear(TaxJourLines.ID);
                    TaxJourLines.KRE_TAXJOURID := GetLastID();
                    TaxJourLines.INVOICELINENO := SalesInvLine."Line No.";
                    TaxJourLines.INVOICENo := SalesInvLine."Document No.";
                    TaxJourLines.TYPE := SalesInvLine.Type;
                    TaxJourLines.ITEMID := SalesInvLine."No.";
                    TaxJourLines.DESCRIPTION := SalesInvLine.Description;
                    TaxJourLines.VAT_Bus_Posting_Group := SalesInvLine."VAT Bus. Posting Group";
                    TaxJourLines.VAT_Prod_Posting_Group := SalesInvLine."VAT Prod. Posting Group";
                    TaxJourLines.VAT_Identifier := SalesInvLine."VAT Identifier";
                    TaxJourLines.PRICE := SalesInvLine."Unit Price";
                    TaxJourLines.QTY := system.Round(SalesInvLine.Quantity, 1, '>');
                    TaxJourLines.TOTAL_AMOUNT := SalesInvLine."Tax Exemption Amount" + SalesInvLine."Amount";
                    TaxJourLines.DISCOUNT_AMOUNT := SalesInvLine."Line Discount Amount";
                    TaxJourLines.DPP_AMOUNT := SalesInvLine."Amount";
                    TaxJourLines.VAT_AMOUNT := SalesInvLine."Tax Exemption Amount";
                    TaxJourLines.Insert();
                until (SalesInvLine.Next() = 0);
            end;
        end;
    end;

    procedure InsertTaxExcemptionVATfromPostedCrMmForeignCurrency(var SalesInvHeader: Record "Sales Cr.Memo Header"; Exch: decimal)
    var
        TaxJour: Record KRE_TAXJOUR;
        TaxJourLines: Record KRE_TAXJOURLINES;
        SalesInvLine: Record "Sales Cr.Memo Line";
        Customer: Record Customer;
        shiptoaddress: Record "Ship-to Address";
    begin
        TaxJour.SetFilter(INVOICENO, '=%1', SalesInvHeader."No.");
        if not TaxJour.FindSet() then begin
            Clear(TaxJour);
            TaxJour.Init();
            TaxJour.INVOICENO := SalesInvHeader."No.";
            TaxJour."Pre-Assigned No." := SalesInvHeader."Pre-Assigned No.";
            TaxJour.INVOICEDATE := SalesInvHeader."Document Date";
            TaxJour.DOCUMENTNO := SalesInvHeader."External Document No.";
            //TaxJour.TAXDATE := SalesInvHeader.TAXDATE;
            TaxJour."VAT Bus. Posting Group" := SalesInvHeader."VAT Bus. Posting Group";
            TaxJour."VAT Calculation Type" := SalesInvLine."VAT Calculation Type";
            //TaxJour."VAT Prod. Posting Group" := SalesHeader.VAT_Prod__Posting_Group;
            if Customer.Get(SalesInvHeader."Sell-to Customer No.") then begin
                TaxJour.ACCOUNTID := Customer."No.";
                GetCustomerID(Customer, TaxJour);
                TaxJour.NAMA := Customer.NamaNPWP;
                if Customer.NPWPAddressfromShipTo then begin
                    shiptoaddress.SetRange("Customer No.", Customer."No.");
                    shiptoaddress.SetRange("Code", SalesInvHeader."Ship-to Code");
                    if shiptoaddress.FindFirst() then begin
                        TaxJour.ALAMATNPWP := shiptoaddress.AlamatNPWP;
                        TaxJour."ID TKU Pembeli" := shiptoaddress."ID TKU";
                        TaxJour."Ship-to Code" := shiptoaddress.Code;
                    end;
                end else begin
                    TaxJour.ALAMATNPWP := Customer.AlamatNPWP;
                    TaxJour."ID TKU Pembeli" := Customer."ID TKU"
                end;
            end;
            TaxJour.IS_CREDITABLE := 0;
            TaxJour.IS_RETURNITEM := TaxJour.IS_RETURNITEM::YES;
            TaxJour.RETURN_TAX_NUMBER := SalesInvHeader.RETURN_TAX_NUMBER;
            TaxJour.RETURN_DATE := SalesInvHeader.RETURN_DATE;
            TaxJour.RETURN_DOC_NUMBER := SalesInvHeader.RETURN_DOC_NUMBER;

            TaxJour.TAX_SOURCE := TaxJour.TAX_SOURCE::Sales;
            //TaxJour.TAXNUMBER := SalesInvHeader.TAXNUMBER;
            TaxJour.CURRENCY := SalesInvHeader."Currency Code";
            TaxJour.Kode_Dokumen_Pendukung := SalesInvHeader."External Document No.";
            SalesInvLine.Reset();
            SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
            SalesInvLine.SetRange("Is TaxExemption", true);
            SalesInvLine.CalcSums("Tax Exemption Amount", Amount);
            TaxJour.DPPAMOUNT := system.ABS(SalesInvLine."Amount" / Exch);
            TaxJour.VATAMOUNT := system.ABS(SalesInvLine."Tax Exemption Amount" / Exch);
            TaxJour.INVOICEAMOUNT := system.ABS(SalesInvLine."Amount" / Exch) + system.ABS(SalesInvLine."Tax Exemption Amount" / Exch);
            TaxJour.TAX_POSTED := TaxJour.TAX_POSTED::NO;
            TaxJour.TAX_EXPORTED := TaxJour.TAX_EXPORTED::NO;
            TaxJour.Insert();

            SalesInvLine.Reset();
            SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
            //SalesInvLine.SetRange("Document Type", SalesInvHeader."Document Type");
            SalesInvLine.SetRange("Is TaxExemption", true);
            if SalesInvLine.FindSet() then begin
                TaxJourLines.LockTable();
                repeat
                    TaxJourLines.Init();
                    Clear(TaxJourLines.ID);
                    TaxJourLines.KRE_TAXJOURID := GetLastID();
                    TaxJourLines.INVOICELINENO := SalesInvLine."Line No.";
                    TaxJourLines.INVOICENo := SalesInvLine."Document No.";
                    TaxJourLines.TYPE := SalesInvLine.Type;
                    TaxJourLines.ITEMID := SalesInvLine."No.";
                    TaxJourLines.DESCRIPTION := SalesInvLine.Description;
                    TaxJourLines.VAT_Bus_Posting_Group := SalesInvLine."VAT Bus. Posting Group";
                    TaxJourLines.VAT_Prod_Posting_Group := SalesInvLine."VAT Prod. Posting Group";
                    TaxJourLines.VAT_Identifier := SalesInvLine."VAT Identifier";
                    TaxJourLines.PRICE := SalesInvLine."Unit Price";
                    TaxJourLines.QTY := system.Round(SalesInvLine.Quantity, 1, '>');
                    TaxJourLines.TOTAL_AMOUNT := (SalesInvLine."Tax Exemption Amount" / Exch) + (SalesInvLine."Amount" / Exch);
                    TaxJourLines.DISCOUNT_AMOUNT := SalesInvLine."Line Discount Amount" / Exch;
                    TaxJourLines.DPP_AMOUNT := SalesInvLine."Amount" / Exch;
                    TaxJourLines.VAT_AMOUNT := SalesInvLine."Tax Exemption Amount" / Exch;
                    TaxJourLines.Insert();
                until (SalesInvLine.Next() = 0);
            end;
        end;
    end;

    var

        CustomerRetail: Boolean;


    [IntegrationEvent(false, false)]
    procedure OnInsertDescriptionOnTaxSynch(var TaxJourLines: Record KRE_TAXJOURLINES; var SalesLineInv: Record "Sales Invoice Line")
    begin
    end;
}