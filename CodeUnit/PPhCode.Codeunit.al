codeunit 60006 PPhCode
{
    Permissions = TableData "G/L Entry" = RM, TableData Kre_MasterPPh = RIM, Tabledata "Purch. Rcpt. Line" = RIMD;

    procedure UpdateGLEntryWHT(EntryNo: Integer)
    var
        SalesInv: Record "Sales Invoice Line";
        SalesCrMm: Record "Sales Cr.Memo Line";
        PurchInv: Record "Purch. Inv. Line";
        PurchCrMm: Record "Purch. Cr. Memo Line";
        GJLine: Record "Gen. Journal Line";
        GLE: Record "G/L Entry";
        SIH: Record "Sales Invoice Header";
        PIH: Record "Purch. Inv. Header";
        SCH: Record "Sales Cr.Memo Header";
        PCH: Record "Purch. Cr. Memo Hdr.";
        TaxSetup: Record Kre_TaxSetup;
        Currency: Code[10];
    // GLS: Codeunit 12;
    begin
        TaxSetup.FindFirst();
        GLE.SetRange("Entry No.", EntryNo);
        if GLE.FindSet() then begin
            case GLE."Gen. Posting Type" of
                GLE."Gen. Posting Type"::Sale:
                    begin
                        case GLE."Document Type" of
                            GLE."Document Type"::Invoice:
                                begin
                                    if SIH.Get(GLE."Document No.") then
                                        Currency := SIH."Currency Code";
                                    SalesInv.SetRange("Document No.", GLE."Document No.");
                                    SalesInv.SetRange("No.", GLE."G/L Account No.");
                                    if TaxSetup."Currency Used" = TaxSetup."Currency Used"::"Additional Currency Amount" then begin
                                        if Currency = TaxSetup."Export to Currency" then
                                            SalesInv.SetRange(Amount, GLE."Additional-Currency Amount" * -1);
                                    end
                                    else
                                        SalesInv.SetRange(Amount, GLE.Amount * -1);


                                    if SalesInv.FindSet() then begin
                                        GLE.WHTProductPostingGroup := SalesInv.WHTProductPostingGroup;
                                        GLE.WHTPercentage := SalesInv.WHTPercentage;
                                        GLE.WHTAmount := SalesInv.WHTAmount;
                                        GLE."WHTAmount Additional Currency" := SalesInv."WHTAmount Additional Currency";
                                        GLE.Modify();
                                    end;
                                end;
                            GLE."Document Type"::"Credit Memo":
                                begin
                                    if SCH.Get(GLE."Document No.") then
                                        Currency := SCH."Currency Code";
                                    SalesCrMm.SetRange("Document No.", GLE."Document No.");
                                    SalesCrMm.SetRange("No.", GLE."G/L Account No.");

                                    if TaxSetup."Currency Used" = TaxSetup."Currency Used"::"Additional Currency Amount" then begin
                                        if Currency = TaxSetup."Export to Currency" then
                                            SalesCrMm.SetRange(Amount, GLE."Additional-Currency Amount" * -1);
                                    end
                                    else
                                        SalesCrMm.SetRange(Amount, GLE.Amount * -1);

                                    if SalesCrMm.FindSet() then begin
                                        GLE.WHTProductPostingGroup := SalesCrMm.WHTProductPostingGroup;
                                        GLE.WHTPercentage := SalesCrMm.WHTPercentage;
                                        GLE.WHTAmount := SalesCrMm.WHTAmount;
                                        GLE."WHTAmount Additional Currency" := SalesCrMm."WHTAmount Additional Currency";
                                        GLE.Modify();
                                    end;
                                end;
                            else
                        end;
                    end;
                GLE."Gen. Posting Type"::Purchase:
                    begin
                        case GLE."Document Type" of
                            GLE."Document Type"::Invoice:
                                begin
                                    if PIH.Get(GLE."Document No.") then
                                        Currency := PIH."Currency Code";
                                    PurchInv.SetRange("Document No.", GLE."Document No.");
                                    PurchInv.SetRange("No.", GLE."G/L Account No.");
                                    if TaxSetup."Currency Used" = TaxSetup."Currency Used"::"Additional Currency Amount" then begin
                                        if Currency = TaxSetup."Export to Currency" then
                                            PurchInv.SetRange(Amount, GLE."Additional-Currency Amount");
                                    end
                                    else
                                        PurchInv.SetRange(Amount, GLE.Amount);
                                    if PurchInv.FindSet() then begin
                                        GLE.WHTProductPostingGroup := PurchInv.WHTProductPostingGroup;
                                        GLE.WHTPercentage := PurchInv.WHTPercentage;
                                        GLE.WHTAmount := PurchInv.WHTAmount;
                                        GLE."WHTAmount Additional Currency" := PurchInv."WHTAmount Additional Currency";
                                        GLE.Modify();
                                    end;
                                end;

                            GLE."Document Type"::"Credit Memo":
                                begin
                                    if PCH.Get(GLE."Document No.") then
                                        Currency := PCH."Currency Code";
                                    PurchCrMm.SetRange("Document No.", GLE."Document No.");
                                    PurchCrMm.SetRange("No.", GLE."G/L Account No.");
                                    if TaxSetup."Currency Used" = TaxSetup."Currency Used"::"Additional Currency Amount" then begin
                                        if Currency = TaxSetup."Export to Currency" then
                                            PurchCrMm.SetRange(Amount, GLE."Additional-Currency Amount");
                                    end
                                    else
                                        PurchCrMm.SetRange(Amount, GLE.Amount);
                                    if PurchCrMm.FindSet() then begin
                                        GLE.WHTProductPostingGroup := PurchCrMm.WHTProductPostingGroup;
                                        GLE.WHTPercentage := PurchCrMm.WHTPercentage;
                                        GLE.WHTAmount := PurchCrMm.WHTAmount;
                                        GLE."WHTAmount Additional Currency" := PurchCrMm."WHTAmount Additional Currency";
                                        GLE.Modify();
                                    end;
                                end;
                            else
                        end;
                    end;
            //tidak jd dipakai,sudah dipindah onfaterposting
            // GLE."Gen. Posting Type"::" ":
            //     begin
            //         case GLE."Document Type" of
            //             GLE."Document Type"::Payment:
            //                 begin
            //                     GJLine.SetRange("Document No.", GLE."Document No.");
            //                     GJLine.SetRange("Account No.", GLE."G/L Account No.");
            //                     GJLine.SetRange(Amount, GLE.Amount * -1);

            //                     if GJLine.FindSet() then begin
            //                         GLE.WHTProductPostingGroup := GJLine.WHTProductPostingGroup;
            //                         GLE.WHTPercentage := GJLine.WHTPercentage;
            //                         GLE.WHTAmount := GJLine.WHTAmount;
            //                         GLE.Modify();
            //                     end;
            //                 end;
            //             else
            //         end;
            //     end;
            // else
            end;
        end;
    end;

    procedure PPhSynch(StartDate: Date; EndDate: Date)
    var
        TaxSetup: Record Kre_TaxSetup;
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
        GLEntryPerDocNo: Record "G/L Entry";
        VATEntry: Record "VAT Entry";
        Vendor: Record Vendor;
        Customer: Record Customer;
        VendorLedger: Record "Vendor Ledger Entry";
        CustLedger: Record "Cust. Ledger Entry";
        VLedgerPerCloseNo: Record "Vendor Ledger Entry";
        CLedgerPerCloseNo: Record "Cust. Ledger Entry";
        WHTTrans: Record KreWHTTrans;
        SalesInvHeader: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";

    begin
        if TaxSetup.FindSet() then
            if TaxSetup.Activate_WHT then begin
                GLAccount.SetRange(IsPPh, true);
                if GLAccount.FindSet() then
                    repeat
                        // Clear(GLEntry);
                        GLEntry.SetRange("Posting Date", StartDate, EndDate);
                        GLEntry.SetRange("G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(WHTProductPostingGroup, '<> %1', '');
                        // GLEntry.SetRange("Source Code", 'PURCHASES', 'SALES');
                        if GLEntry.FindSet() then
                            repeat
                                if GLEntry."Source Code" = 'PURCHASES' then begin
                                    WHTTrans.SetFilter("Document No", '= %1', GLEntry."Document No.");
                                    //WHTTrans.SetFilter("Entry No", '= %1', GLEntry."Entry No.");
                                    WHTTrans.SetRange(WHTProductPostingGroup, GLEntry.WHTProductPostingGroup);
                                    if not WHTTrans.FindSet() then begin
                                        clear(WHTTrans);
                                        WHTTrans.Init();
                                        WHTTrans."Posting Date" := GLEntry."Posting Date";
                                        WHTTrans."Bukti Potong Date" := GLEntry."Posting Date";
                                        WHTTrans."Source Code" := GLEntry."Source Code";
                                        WHTTrans."Document Type" := GLEntry."Document Type";
                                        WHTTrans."Document No" := GLEntry."Document No.";
                                        // WHTTrans."PPh Code" := GLEntry.WHTProductPostingGroup;
                                        WHTTrans.WHTProductPostingGroup := GLEntry.WHTProductPostingGroup;
                                        WHTTrans.WHTPercentage := GLEntry.WHTPercentage;
                                        if GLEntry."Document Type" = GLEntry."Document Type"::"Credit Memo" then
                                            WHTTrans.WHTAmount := GLEntry.WHTAmount * -1
                                        else
                                            WHTTrans.WHTAmount := GLEntry.WHTAmount;
                                        WHTTrans."G/L Account No" := GLEntry."G/L Account No.";
                                        WHTTrans."G/L Account Name" := GLAccount.Name;
                                        WHTTrans.Description := GLEntry.Description;
                                        WHTTrans.Quantity := GLEntry.Quantity;

                                        //CASE
                                        case GLEntry."Document Type" of
                                            GLEntry."Document Type"::Payment: // Payment (order) 
                                                begin
                                                    WHTTrans.Amount := System.Abs(GLEntry.Amount);
                                                    GLEntryPerDocNo.SetRange("Document No.", GLEntry."Document No.");
                                                    GLEntryPerDocNo.SetFilter("Source Type", '%1 | %2', GLEntryPerDocNo."Source Type"::Customer, GLEntryPerDocNo."Source Type"::Vendor);
                                                    GLEntryPerDocNo.FindFirst();
                                                    case GLEntryPerDocNo."Source Type" of
                                                        GLEntryPerDocNo."Source Type"::Vendor://Vendor
                                                            begin
                                                                VendorLedger.SetRange("Document Type", GLEntry."Document Type");
                                                                VendorLedger.SetRange("Document No.", GLEntry."Document No.");
                                                                VendorLedger.SetRange("Posting Date", GLEntry."Posting Date");
                                                                if VendorLedger.FindSet() then begin
                                                                    WHTTrans."Source Type" := WHTTrans."Source Type"::Vendor;
                                                                    WHTTrans."Source No" := VendorLedger."Vendor No.";
                                                                    // 9-12-2022
                                                                    WHTTrans."Entry No Ledger Entry Vend" := VendorLedger."Entry No.";
                                                                    Vendor.SetRange("No.", VendorLedger."Vendor No.");
                                                                    if Vendor.FindFirst() then begin
                                                                        //if Vendor.ISPKP = true then
                                                                        WHTTrans.NPWP := Vendor.NPWP;
                                                                        //else
                                                                        WHTTrans.NIK := Vendor.NIK;
                                                                        WHTTrans.Nama := Vendor.NamaNPWP;
                                                                        WHTTrans."Alamat NPWP" := Vendor.AlamatNPWP;
                                                                    end;
                                                                    Clear(VATEntry);
                                                                    if VendorLedger."Applies-to Doc. No." = '' then begin
                                                                        WHTTrans."DPP Amount" := 0;
                                                                        WHTTrans."VAT Amount" := 0;
                                                                    end else begin
                                                                        VLedgerPerCloseNo.SetRange("Closed by Entry No.", VendorLedger."Entry No.");
                                                                        VLedgerPerCloseNo.FindSet();
                                                                        VATEntry.SetRange("Document No.", VLedgerPerCloseNo."Document No.");
                                                                        VATEntry.FindSet();
                                                                        WHTTrans."DPP Amount" := System.Abs(VATEntry.Base);
                                                                        WHTTrans."VAT Amount" := System.Abs(VATEntry.Amount);
                                                                    end;
                                                                    WHTTrans."VAT Type" := VATEntry.Type;
                                                                end;
                                                            end;
                                                    end;
                                                end;
                                            GLEntry."Document Type"::Invoice: //Invoice
                                                begin
                                                    WHTTrans."Source Type" := GLEntry."Source Type";
                                                    WHTTrans."Source No" := GLEntry."Source No.";

                                                    Clear(VATEntry);
                                                    VATEntry.SetRange("Document Type", GLEntry."Document Type");
                                                    VATEntry.SetRange("Document No.", GLEntry."Document No.");
                                                    VATEntry.SetRange("Posting Date", GLEntry."Posting Date");
                                                    VATEntry.SetFilter(Amount, '<> %1', 0);
                                                    if VATEntry.FindSet() then begin
                                                        VATEntry.CalcSums(Base);
                                                        VATEntry.CalcSums(Amount);
                                                        WHTTrans."VAT Amount" := System.Abs(VATEntry.Amount);
                                                        //WHTTrans."DPP Amount" := System.Abs(VATEntry.Base); pindah ke bawah                                                
                                                        WHTTrans."VAT Type" := VATEntry.Type;
                                                    end;
                                                    case GLEntry."Source Type" of
                                                        GLEntry."Source Type"::Vendor://Vendor
                                                            begin
                                                                VendorLedger.SetRange("Document Type", GLEntry."Document Type");
                                                                VendorLedger.SetRange("Document No.", GLEntry."Document No.");
                                                                VendorLedger.SetRange("Posting Date", GLEntry."Posting Date");
                                                                if VendorLedger.FindSet() then
                                                                    // 9-12-2022
                                                                    WHTTrans."Entry No Ledger Entry Vend" := VendorLedger."Entry No.";
                                                                Vendor.SetRange("No.", GLEntry."Source No.");
                                                                if Vendor.FindSet() then begin
                                                                    WHTTrans.NPWP := Vendor.NPWP;
                                                                    WHTTrans.Nama := Vendor.NamaNPWP;
                                                                    WHTTrans."Alamat NPWP" := Vendor.AlamatNPWP;
                                                                end;
                                                                PurchInvHeader.SetRange("No.", GLEntry."Document No.");
                                                                if PurchInvHeader.FindSet() then begin
                                                                    WHTTrans."Invoice Date" := PurchInvHeader."Document Date";
                                                                    WHTTrans."Order No" := PurchInvHeader."Order No.";
                                                                    WHTTrans.TAXNUMBER := PurchInvHeader.TAXNUMBER;
                                                                end;
                                                                //perhitungan gross up
                                                                //if CheckGrossUpExistInLine(GLEntry."Document No.") = true then begin
                                                                PurchInvLine.SetRange("Document No.", GLEntry."Document No.");
                                                                PurchInvLine.SetFilter(WHTProductPostingGroup, '<> %1', '');
                                                                PurchInvLine.SetRange(IsWHTCalc, false);
                                                                if PurchInvLine.FindSet() then begin
                                                                    PurchInvLine.CalcSums(Amount, "Amount Including VAT");
                                                                    WHTTrans.Amount := System.Abs(PurchInvLine."Amount Including VAT");
                                                                    WHTTrans."DPP Amount" := System.Abs(PurchInvLine."Amount");
                                                                end;
                                                                //end else
                                                                //   WHTTrans.Amount := System.Abs(GLEntry.Amount);
                                                            end;
                                                    end;
                                                end;

                                            GLEntry."Document Type"::"Credit Memo": //Cr memo
                                                begin
                                                    WHTTrans.Amount := System.Abs(GLEntry.Amount);
                                                    WHTTrans."Source Type" := GLEntry."Source Type";
                                                    WHTTrans."Source No" := GLEntry."Source No.";
                                                    Clear(VATEntry);
                                                    VATEntry.SetRange("Document Type", GLEntry."Document Type");
                                                    VATEntry.SetRange("Document No.", GLEntry."Document No.");
                                                    VATEntry.SetRange("Posting Date", GLEntry."Posting Date");
                                                    VATEntry.SetFilter(Amount, '<> %1', 0);
                                                    if VATEntry.FindSet() then begin
                                                        VATEntry.CalcSums(Base);
                                                        VATEntry.CalcSums(Amount);
                                                        WHTTrans."DPP Amount" := System.Abs(VATEntry.Base);
                                                        WHTTrans."VAT Amount" := System.Abs(VATEntry.Amount);
                                                        WHTTrans."VAT Type" := VATEntry.Type;
                                                    end;
                                                    case GLEntry."Source Type" of
                                                        GLEntry."Source Type"::Vendor://Vendor
                                                            begin
                                                                VendorLedger.SetRange("Document Type", GLEntry."Document Type");
                                                                VendorLedger.SetRange("Document No.", GLEntry."Document No.");
                                                                VendorLedger.SetRange("Posting Date", GLEntry."Posting Date");
                                                                if VendorLedger.FindSet() then
                                                                    // 9-12-2022
                                                                    WHTTrans."Entry No Ledger Entry Vend" := VendorLedger."Entry No.";
                                                                Vendor.SetRange("No.", GLEntry."Source No.");
                                                                if Vendor.FindSet() then begin
                                                                    WHTTrans.NPWP := Vendor.NPWP;
                                                                    WHTTrans.Nama := Vendor.NamaNPWP;
                                                                    WHTTrans."Alamat NPWP" := Vendor.AlamatNPWP;
                                                                end;
                                                            end;
                                                    end;
                                                end;
                                        end;
                                        WHTTrans."Entry No" := GLEntry."Entry No.";
                                        WHTTrans."External Doc No" := GLEntry."External Document No.";
                                        WHTTrans."Global Dimension 1" := GLEntry."Global Dimension 1 Code";
                                        WHTTrans."Global Dimension 2" := GLEntry."Global Dimension 2 Code";
                                        WHTTrans."Dimension Set ID" := GLEntry."Dimension Set ID";
                                        WHTTrans."Gen. Posting Type" := GLEntry."Gen. Posting Type";
                                        WHTTrans."Gen. Bus. Posting Group" := GLEntry."Gen. Bus. Posting Group";
                                        WHTTrans."Gen. Prod. Posting Group" := GLEntry."Gen. Prod. Posting Group";
                                        WHTTrans."VAT Bus. Posting Group" := GLEntry."VAT Bus. Posting Group";
                                        WHTTrans."VAT Prod. Posting Group" := GLEntry."VAT Prod. Posting Group";
                                        WHTTrans.Insert();
                                    end;
                                end else begin
                                    if GLEntry."Source Code" = 'SALES' then begin
                                        WHTTrans.SetFilter("Document No", '= %1', GLEntry."Document No.");
                                        //WHTTrans.SetFilter("Entry No", '= %1', GLEntry."Entry No.");
                                        WHTTrans.SetRange(WHTProductPostingGroup, GLEntry.WHTProductPostingGroup);
                                        if not WHTTrans.FindSet() then begin
                                            clear(WHTTrans);
                                            WHTTrans.Init();
                                            WHTTrans."Posting Date" := GLEntry."Posting Date";
                                            WHTTrans."Bukti Potong Date" := GLEntry."Posting Date";
                                            WHTTrans."Source Code" := GLEntry."Source Code";
                                            WHTTrans."Document Type" := GLEntry."Document Type";
                                            WHTTrans."Document No" := GLEntry."Document No.";
                                            // WHTTrans."PPh Code" := GLEntry.WHTProductPostingGroup;
                                            WHTTrans.WHTProductPostingGroup := GLEntry.WHTProductPostingGroup;
                                            WHTTrans.WHTPercentage := GLEntry.WHTPercentage;
                                            if GLEntry."Document Type" = GLEntry."Document Type"::"Credit Memo" then
                                                WHTTrans.WHTAmount := GLEntry.WHTAmount * -1
                                            else
                                                WHTTrans.WHTAmount := GLEntry.WHTAmount;
                                            WHTTrans."G/L Account No" := GLEntry."G/L Account No.";
                                            WHTTrans."G/L Account Name" := GLAccount.Name;
                                            WHTTrans.Description := GLEntry.Description;
                                            WHTTrans.Quantity := GLEntry.Quantity;
                                            //WHTTrans.Amount := System.Abs(GLEntry.Amount);
                                            //CASE
                                            case GLEntry."Document Type" of
                                                GLEntry."Document Type"::Payment: // Payment (order) 
                                                    begin
                                                        WHTTrans.Amount := System.Abs(GLEntry.Amount);
                                                        GLEntryPerDocNo.SetRange("Document No.", GLEntry."Document No.");
                                                        GLEntryPerDocNo.SetFilter("Source Type", '%1 | %2', GLEntryPerDocNo."Source Type"::Customer, GLEntryPerDocNo."Source Type"::Vendor);
                                                        GLEntryPerDocNo.FindFirst();
                                                        case GLEntryPerDocNo."Source Type" of
                                                            GLEntryPerDocNo."Source Type"::Customer://Customer
                                                                begin
                                                                    CustLedger.SetRange("Document Type", GLEntry."Document Type");
                                                                    CustLedger.SetRange("Document No.", GLEntry."Document No.");
                                                                    CustLedger.SetRange("Posting Date", GLEntry."Posting Date");
                                                                    if CustLedger.FindFirst() then begin
                                                                        WHTTrans."Source Type" := WHTTrans."Source Type"::Customer;
                                                                        WHTTrans."Source No" := CustLedger."Customer No.";
                                                                        // 9-12-2022
                                                                        WHTTrans."Entry No Ledger Entry Cust" := CustLedger."Entry No.";
                                                                        Customer.SetRange("No.", CustLedger."Customer No.");
                                                                        if Customer.FindFirst() then begin
                                                                            //if Customer.ISPKP = true then
                                                                            WHTTrans.NPWP := Customer.NPWP;
                                                                            // else
                                                                            WHTTrans.NIK := Customer.NIK;
                                                                            WHTTrans.Nama := Customer.NamaNPWP;
                                                                            WHTTrans."Alamat NPWP" := Customer.AlamatNPWP;
                                                                        end;
                                                                        Clear(VATEntry);
                                                                        if CustLedger."Applies-to Doc. No." = '' then begin
                                                                            WHTTrans."DPP Amount" := 0;
                                                                            WHTTrans."VAT Amount" := 0;
                                                                        end else begin
                                                                            CLedgerPerCloseNo.SetRange("Closed by Entry No.", CustLedger."Entry No.");
                                                                            CLedgerPerCloseNo.FindSet();
                                                                            VATEntry.SetRange("Document No.", CLedgerPerCloseNo."Document No.");
                                                                            VATEntry.FindSet();
                                                                            WHTTrans."DPP Amount" := System.Abs(VATEntry.Base);
                                                                            WHTTrans."VAT Amount" := System.Abs(VATEntry.Amount);
                                                                        end;
                                                                        WHTTrans."VAT Type" := VATEntry.Type;
                                                                    end;
                                                                end;
                                                        end;
                                                    end;
                                                GLEntry."Document Type"::Invoice: //Invoice
                                                    begin
                                                        WHTTrans."Source Type" := GLEntry."Source Type";
                                                        WHTTrans."Source No" := GLEntry."Source No.";
                                                        Clear(VATEntry);
                                                        VATEntry.SetRange("Document Type", GLEntry."Document Type");
                                                        VATEntry.SetRange("Document No.", GLEntry."Document No.");
                                                        VATEntry.SetRange("Posting Date", GLEntry."Posting Date");
                                                        VATEntry.SetFilter(Amount, '<> %1', 0);
                                                        if VATEntry.FindSet() then begin
                                                            VATEntry.CalcSums(Base);
                                                            VATEntry.CalcSums(Amount);
                                                            //WHTTrans."DPP Amount" := System.Abs(VATEntry.Base);
                                                            WHTTrans."VAT Amount" := System.Abs(VATEntry.Amount);
                                                            WHTTrans."VAT Type" := VATEntry.Type;
                                                        end;
                                                        case GLEntry."Source Type" of
                                                            GLEntry."Source Type"::Customer://Customer
                                                                begin
                                                                    CustLedger.SetRange("Document Type", GLEntry."Document Type");
                                                                    CustLedger.SetRange("Document No.", GLEntry."Document No.");
                                                                    CustLedger.SetRange("Posting Date", GLEntry."Posting Date");
                                                                    if CustLedger.FindFirst() then
                                                                        // 9-12-2022
                                                                        WHTTrans."Entry No Ledger Entry Cust" := CustLedger."Entry No.";
                                                                    Customer.SetRange("No.", GLEntry."Source No.");
                                                                    if Customer.FindSet() then begin
                                                                        WHTTrans.NPWP := Customer.NPWP;
                                                                        WHTTrans.Nama := Customer.NamaNPWP;
                                                                        WHTTrans."Alamat NPWP" := Customer.AlamatNPWP;
                                                                    end;
                                                                    SalesInvHeader.SetRange("No.", GLEntry."Document No.");
                                                                    if SalesInvHeader.FindSet() then begin
                                                                        WHTTrans."Invoice Date" := SalesInvHeader."Document Date";
                                                                        WHTTrans."Order No" := SalesInvHeader."Order No.";
                                                                        WHTTrans.TAXNUMBER := SalesInvHeader.TAXNUMBER;
                                                                    end;

                                                                    SalesInvLine.SetRange("Document No.", GLEntry."Document No.");
                                                                    SalesInvLine.SetRange(IsWHTCalc, false);
                                                                    SalesInvLine.SetRange(WHTProductPostingGroup, GLEntry.WHTProductPostingGroup);
                                                                    if SalesInvLine.FindSet() then begin
                                                                        SalesInvLine.CalcSums(Amount, "Amount Including VAT");
                                                                        WHTTrans.Amount := System.Abs(SalesInvLine."Amount Including VAT");
                                                                        WHTTrans."DPP Amount" := System.Abs(SalesInvLine."Amount");
                                                                    end
                                                                end;
                                                        end;
                                                    end;

                                                GLEntry."Document Type"::"Credit Memo": //Cr memo
                                                    begin
                                                        WHTTrans.Amount := System.Abs(GLEntry.Amount);
                                                        WHTTrans."Source Type" := GLEntry."Source Type";
                                                        WHTTrans."Source No" := GLEntry."Source No.";
                                                        Clear(VATEntry);
                                                        VATEntry.SetRange("Document Type", GLEntry."Document Type");
                                                        VATEntry.SetRange("Document No.", GLEntry."Document No.");
                                                        VATEntry.SetRange("Posting Date", GLEntry."Posting Date");
                                                        VATEntry.SetFilter(Amount, '<> %1', 0);
                                                        if VATEntry.FindSet() then begin
                                                            VATEntry.CalcSums(Base);
                                                            VATEntry.CalcSums(Amount);
                                                            WHTTrans."DPP Amount" := System.Abs(VATEntry.Base);
                                                            WHTTrans."VAT Amount" := System.Abs(VATEntry.Amount);
                                                            WHTTrans."VAT Type" := VATEntry.Type;
                                                        end;
                                                        case GLEntry."Source Type" of
                                                            GLEntry."Source Type"::Customer://Customer
                                                                begin
                                                                    CustLedger.SetRange("Document Type", GLEntry."Document Type");
                                                                    CustLedger.SetRange("Document No.", GLEntry."Document No.");
                                                                    CustLedger.SetRange("Posting Date", GLEntry."Posting Date");
                                                                    if CustLedger.FindFirst() then
                                                                        // 9-12-2022
                                                                        WHTTrans."Entry No Ledger Entry Cust" := CustLedger."Entry No.";
                                                                    Customer.SetRange("No.", GLEntry."Source No.");
                                                                    if Customer.FindSet() then begin
                                                                        WHTTrans.NPWP := Customer.NPWP;
                                                                        WHTTrans.Nama := Customer.NamaNPWP;
                                                                        WHTTrans."Alamat NPWP" := Customer.AlamatNPWP;
                                                                    end;
                                                                end;
                                                        end;
                                                    end;
                                            end;
                                            WHTTrans."Entry No" := GLEntry."Entry No.";
                                            WHTTrans."External Doc No" := GLEntry."External Document No.";
                                            WHTTrans."Global Dimension 1" := GLEntry."Global Dimension 1 Code";
                                            WHTTrans."Global Dimension 2" := GLEntry."Global Dimension 2 Code";
                                            WHTTrans."Dimension Set ID" := GLEntry."Dimension Set ID";
                                            WHTTrans."Gen. Posting Type" := GLEntry."Gen. Posting Type";
                                            WHTTrans."Gen. Bus. Posting Group" := GLEntry."Gen. Bus. Posting Group";
                                            WHTTrans."Gen. Prod. Posting Group" := GLEntry."Gen. Prod. Posting Group";
                                            WHTTrans."VAT Bus. Posting Group" := GLEntry."VAT Bus. Posting Group";
                                            WHTTrans."VAT Prod. Posting Group" := GLEntry."VAT Prod. Posting Group";
                                            WHTTrans.Insert();
                                        end;
                                    end else begin
                                        if GLEntry."Source Code" = 'CASHRECJNL' then begin
                                            WHTTrans.SetFilter("Document No", '= %1', GLEntry."Document No.");
                                            //WHTTrans.SetFilter("Entry No", '= %1', GLEntry."Entry No.");
                                            WHTTrans.SetRange(WHTProductPostingGroup, GLEntry.WHTProductPostingGroup);
                                            if not WHTTrans.FindSet() then begin
                                                clear(WHTTrans);
                                                WHTTrans.Init();
                                                WHTTrans."Posting Date" := GLEntry."Posting Date";
                                                WHTTrans."Bukti Potong Date" := GLEntry."Posting Date";
                                                WHTTrans."Source Code" := GLEntry."Source Code";
                                                WHTTrans."Document Type" := GLEntry."Document Type";
                                                WHTTrans."Document No" := GLEntry."Document No.";
                                                // WHTTrans."PPh Code" := GLEntry.WHTProductPostingGroup;
                                                WHTTrans.WHTProductPostingGroup := GLEntry.WHTProductPostingGroup;
                                                WHTTrans.WHTPercentage := GLEntry.WHTPercentage;
                                                if GLEntry."Document Type" = GLEntry."Document Type"::"Credit Memo" then
                                                    WHTTrans.WHTAmount := GLEntry.WHTAmount * -1
                                                else
                                                    WHTTrans.WHTAmount := GLEntry.WHTAmount;
                                                WHTTrans."G/L Account No" := GLEntry."G/L Account No.";
                                                WHTTrans."G/L Account Name" := GLAccount.Name;
                                                WHTTrans.Description := GLEntry.Description;
                                                WHTTrans.Quantity := GLEntry.Quantity;
                                                WHTTrans.Amount := System.Abs(GLEntry.Amount);
                                                //CASE
                                                case GLEntry."Document Type" of
                                                    GLEntry."Document Type"::Payment: // CASH REC
                                                        begin
                                                            GLEntryPerDocNo.SetRange("Document No.", GLEntry."Document No.");
                                                            GLEntryPerDocNo.SetFilter("Source Type", '%1 | %2', GLEntryPerDocNo."Source Type"::Customer, GLEntryPerDocNo."Source Type"::Vendor);
                                                            GLEntryPerDocNo.FindFirst();
                                                            case GLEntryPerDocNo."Source Type" of
                                                                GLEntryPerDocNo."Source Type"::Customer://Customer
                                                                    begin
                                                                        CustLedger.SetRange("Document Type", GLEntry."Document Type");
                                                                        CustLedger.SetRange("Document No.", GLEntry."Document No.");
                                                                        CustLedger.SetRange("Posting Date", GLEntry."Posting Date");
                                                                        if CustLedger.FindFirst() then begin
                                                                            WHTTrans."Source Type" := WHTTrans."Source Type"::Customer;
                                                                            WHTTrans."Source No" := CustLedger."Customer No.";
                                                                            // 9-12-2022
                                                                            WHTTrans."Entry No Ledger Entry Cust" := CustLedger."Entry No.";
                                                                            Customer.SetRange("No.", CustLedger."Customer No.");
                                                                            if Customer.FindFirst() then begin
                                                                                //if Customer.ISPKP = true then
                                                                                WHTTrans.NPWP := Customer.NPWP;
                                                                                // else
                                                                                WHTTrans.NIK := Customer.NIK;
                                                                                WHTTrans.Nama := Customer.NamaNPWP;
                                                                                WHTTrans."Alamat NPWP" := Customer.AlamatNPWP;
                                                                            end;
                                                                            Clear(VATEntry);
                                                                            if CustLedger."Applies-to Doc. No." = '' then begin
                                                                                WHTTrans."DPP Amount" := 0;
                                                                                WHTTrans."VAT Amount" := 0;
                                                                            end else begin
                                                                                CLedgerPerCloseNo.SetRange("Closed by Entry No.", CustLedger."Entry No.");
                                                                                CLedgerPerCloseNo.FindSet();
                                                                                VATEntry.SetRange("Document No.", CLedgerPerCloseNo."Document No.");
                                                                                VATEntry.FindSet();
                                                                                WHTTrans."DPP Amount" := System.Abs(VATEntry.Base);
                                                                                WHTTrans."VAT Amount" := System.Abs(VATEntry.Amount);
                                                                            end;
                                                                            WHTTrans."VAT Type" := VATEntry.Type;
                                                                        end;
                                                                    end;
                                                            end;
                                                        end;
                                                end;
                                                WHTTrans."Entry No" := GLEntry."Entry No.";
                                                WHTTrans."External Doc No" := GLEntry."External Document No.";
                                                WHTTrans."Global Dimension 1" := GLEntry."Global Dimension 1 Code";
                                                WHTTrans."Global Dimension 2" := GLEntry."Global Dimension 2 Code";
                                                WHTTrans."Dimension Set ID" := GLEntry."Dimension Set ID";
                                                WHTTrans."Gen. Posting Type" := GLEntry."Gen. Posting Type";
                                                WHTTrans."Gen. Bus. Posting Group" := GLEntry."Gen. Bus. Posting Group";
                                                WHTTrans."Gen. Prod. Posting Group" := GLEntry."Gen. Prod. Posting Group";
                                                WHTTrans."VAT Bus. Posting Group" := GLEntry."VAT Bus. Posting Group";
                                                WHTTrans."VAT Prod. Posting Group" := GLEntry."VAT Prod. Posting Group";
                                                WHTTrans.Insert();
                                            end;
                                        end;
                                    end;
                                end;
                            until GLEntry.Next() = 0;
                    until GLAccount.Next() = 0;
            end;
    end;

    procedure PPhSynchForeignCurrency(StartDate: Date; EndDate: Date)
    var
        TaxSetup: Record Kre_TaxSetup;
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
        GLEntryPerDocNo: Record "G/L Entry";
        VATEntry: Record "VAT Entry";
        Vendor: Record Vendor;
        Customer: Record Customer;
        VendorLedger: Record "Vendor Ledger Entry";
        CustLedger: Record "Cust. Ledger Entry";
        VLedgerPerCloseNo: Record "Vendor Ledger Entry";
        CLedgerPerCloseNo: Record "Cust. Ledger Entry";
        WHTTrans: Record KreWHTTrans;
        SalesInvHeader: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        ExchangeRate: Decimal;
        Exc: Codeunit ExchangeRateIDR;
    begin

        if TaxSetup.FindSet() then
            if TaxSetup.Activate_WHT then begin
                GLAccount.SetRange(IsPPh, true);
                if GLAccount.FindSet() then
                    repeat
                        // Clear(GLEntry);
                        GLEntry.SetRange("Posting Date", StartDate, EndDate);
                        GLEntry.SetRange("G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(WHTProductPostingGroup, '<> %1', '');
                        // GLEntry.SetRange("Source Code", 'PURCHASES', 'SALES');
                        if GLEntry.FindSet() then
                            repeat
                                if GLEntry."Source Code" = 'PURCHASES' then begin
                                    WHTTrans.SetFilter("Document No", '= %1', GLEntry."Document No.");
                                    //WHTTrans.SetFilter("Entry No", '= %1', GLEntry."Entry No.");
                                    WHTTrans.SetRange(WHTProductPostingGroup, GLEntry.WHTProductPostingGroup);
                                    if not WHTTrans.FindSet() then begin
                                        clear(WHTTrans);
                                        WHTTrans.Init();
                                        WHTTrans."Posting Date" := GLEntry."Posting Date";
                                        WHTTrans."Bukti Potong Date" := GLEntry."Posting Date";
                                        WHTTrans."Source Code" := GLEntry."Source Code";
                                        WHTTrans."Document Type" := GLEntry."Document Type";
                                        WHTTrans."Document No" := GLEntry."Document No.";
                                        // WHTTrans."PPh Code" := GLEntry.WHTProductPostingGroup;
                                        WHTTrans.WHTProductPostingGroup := GLEntry.WHTProductPostingGroup;
                                        WHTTrans.WHTPercentage := GLEntry.WHTPercentage;
                                        if GLEntry."Document Type" = GLEntry."Document Type"::"Credit Memo" then
                                            WHTTrans.WHTAmount := GLEntry."WHTAmount Additional Currency" * -1
                                        else
                                            WHTTrans.WHTAmount := GLEntry."WHTAmount Additional Currency";
                                        WHTTrans."G/L Account No" := GLEntry."G/L Account No.";
                                        WHTTrans."G/L Account Name" := GLAccount.Name;
                                        WHTTrans.Description := GLEntry.Description;
                                        WHTTrans.Quantity := GLEntry.Quantity;

                                        //CASE
                                        case GLEntry."Document Type" of
                                            GLEntry."Document Type"::Payment: // Payment (order) 
                                                begin
                                                    WHTTrans.Amount := System.Abs(GLEntry."Additional-Currency Amount");
                                                    GLEntryPerDocNo.SetRange("Document No.", GLEntry."Document No.");
                                                    GLEntryPerDocNo.SetFilter("Source Type", '%1 | %2', GLEntryPerDocNo."Source Type"::Customer, GLEntryPerDocNo."Source Type"::Vendor);
                                                    GLEntryPerDocNo.FindFirst();
                                                    case GLEntryPerDocNo."Source Type" of
                                                        GLEntryPerDocNo."Source Type"::Vendor://Vendor
                                                            begin
                                                                VendorLedger.SetRange("Document Type", GLEntry."Document Type");
                                                                VendorLedger.SetRange("Document No.", GLEntry."Document No.");
                                                                VendorLedger.SetRange("Posting Date", GLEntry."Posting Date");
                                                                if VendorLedger.FindSet() then begin
                                                                    WHTTrans."Source Type" := WHTTrans."Source Type"::Vendor;
                                                                    WHTTrans."Source No" := VendorLedger."Vendor No.";
                                                                    // 9-12-2022
                                                                    WHTTrans."Entry No Ledger Entry Vend" := VendorLedger."Entry No.";
                                                                    Vendor.SetRange("No.", VendorLedger."Vendor No.");
                                                                    if Vendor.FindFirst() then begin
                                                                        //if Vendor.ISPKP = true then
                                                                        WHTTrans.NPWP := Vendor.NPWP;
                                                                        //else
                                                                        WHTTrans.NIK := Vendor.NIK;
                                                                        WHTTrans.Nama := Vendor.NamaNPWP;
                                                                        WHTTrans."Alamat NPWP" := Vendor.AlamatNPWP;
                                                                    end;
                                                                    Clear(VATEntry);
                                                                    if VendorLedger."Applies-to Doc. No." = '' then begin
                                                                        WHTTrans."DPP Amount" := 0;
                                                                        WHTTrans."VAT Amount" := 0;
                                                                    end else begin
                                                                        VLedgerPerCloseNo.SetRange("Closed by Entry No.", VendorLedger."Entry No.");
                                                                        VLedgerPerCloseNo.FindSet();
                                                                        VATEntry.SetRange("Document No.", VLedgerPerCloseNo."Document No.");
                                                                        VATEntry.FindSet();
                                                                        WHTTrans."DPP Amount" := System.Abs(VATEntry."Additional-Currency Base");
                                                                        WHTTrans."VAT Amount" := System.Abs(VATEntry."Additional-Currency Amount");
                                                                    end;
                                                                    WHTTrans."VAT Type" := VATEntry.Type;
                                                                end;
                                                            end;
                                                    end;
                                                end;
                                            GLEntry."Document Type"::Invoice: //Invoice
                                                begin
                                                    WHTTrans."Source Type" := GLEntry."Source Type";
                                                    WHTTrans."Source No" := GLEntry."Source No.";

                                                    Clear(VATEntry);
                                                    VATEntry.SetRange("Document Type", GLEntry."Document Type");
                                                    VATEntry.SetRange("Document No.", GLEntry."Document No.");
                                                    VATEntry.SetRange("Posting Date", GLEntry."Posting Date");
                                                    VATEntry.SetFilter(Amount, '<> %1', 0);
                                                    if VATEntry.FindSet() then begin
                                                        VATEntry.CalcSums("Additional-Currency Base");
                                                        VATEntry.CalcSums("Additional-Currency Amount");
                                                        WHTTrans."VAT Amount" := System.Abs(VATEntry."Additional-Currency Amount");
                                                        //WHTTrans."DPP Amount" := System.Abs(VATEntry.Base); pindah ke bawah                                                
                                                        WHTTrans."VAT Type" := VATEntry.Type;
                                                    end;
                                                    case GLEntry."Source Type" of
                                                        GLEntry."Source Type"::Vendor://Vendor
                                                            begin
                                                                VendorLedger.SetRange("Document Type", GLEntry."Document Type");
                                                                VendorLedger.SetRange("Document No.", GLEntry."Document No.");
                                                                VendorLedger.SetRange("Posting Date", GLEntry."Posting Date");
                                                                if VendorLedger.FindSet() then
                                                                    // 9-12-2022
                                                                    WHTTrans."Entry No Ledger Entry Vend" := VendorLedger."Entry No.";
                                                                Vendor.SetRange("No.", GLEntry."Source No.");
                                                                if Vendor.FindSet() then begin
                                                                    WHTTrans.NPWP := Vendor.NPWP;
                                                                    WHTTrans.Nama := Vendor.NamaNPWP;
                                                                    WHTTrans."Alamat NPWP" := Vendor.AlamatNPWP;
                                                                end;
                                                                PurchInvHeader.SetRange("No.", GLEntry."Document No.");
                                                                if PurchInvHeader.FindSet() then begin
                                                                    WHTTrans."Invoice Date" := PurchInvHeader."Document Date";
                                                                    WHTTrans."Order No" := PurchInvHeader."Order No.";
                                                                    WHTTrans.TAXNUMBER := PurchInvHeader.TAXNUMBER;
                                                                end;
                                                                //perhitungan gross up
                                                                //if CheckGrossUpExistInLine(GLEntry."Document No.") = true then begin
                                                                PurchInvLine.SetRange("Document No.", GLEntry."Document No.");
                                                                PurchInvLine.SetFilter(WHTProductPostingGroup, '<> %1', '');
                                                                PurchInvLine.SetRange(IsWHTCalc, false);
                                                                if PurchInvLine.FindSet() then begin
                                                                    ExchangeRate := Exc.GetExchangeRate(TaxSetup."Export to Currency", PurchInvHeader."Currency Code", PurchInvHeader."Posting Date");
                                                                    PurchInvLine.CalcSums(Amount, "Amount Including VAT");
                                                                    WHTTrans.Amount := System.Abs(PurchInvLine."Amount Including VAT") / ExchangeRate;
                                                                    WHTTrans."DPP Amount" := System.Abs(PurchInvLine."Amount") / ExchangeRate;
                                                                end;
                                                                //end else
                                                                //   WHTTrans.Amount := System.Abs(GLEntry.Amount);
                                                            end;
                                                    end;
                                                end;

                                            GLEntry."Document Type"::"Credit Memo": //Cr memo
                                                begin
                                                    WHTTrans.Amount := System.Abs(GLEntry."Additional-Currency Amount");
                                                    WHTTrans."Source Type" := GLEntry."Source Type";
                                                    WHTTrans."Source No" := GLEntry."Source No.";
                                                    Clear(VATEntry);
                                                    VATEntry.SetRange("Document Type", GLEntry."Document Type");
                                                    VATEntry.SetRange("Document No.", GLEntry."Document No.");
                                                    VATEntry.SetRange("Posting Date", GLEntry."Posting Date");
                                                    VATEntry.SetFilter(Amount, '<> %1', 0);
                                                    if VATEntry.FindSet() then begin
                                                        VATEntry.CalcSums("Additional-Currency Base");
                                                        VATEntry.CalcSums("Additional-Currency Amount");
                                                        WHTTrans."DPP Amount" := System.Abs(VATEntry."Additional-Currency Base");
                                                        WHTTrans."VAT Amount" := System.Abs(VATEntry."Additional-Currency Amount");
                                                        WHTTrans."VAT Type" := VATEntry.Type;
                                                    end;
                                                    case GLEntry."Source Type" of
                                                        GLEntry."Source Type"::Vendor://Vendor
                                                            begin
                                                                VendorLedger.SetRange("Document Type", GLEntry."Document Type");
                                                                VendorLedger.SetRange("Document No.", GLEntry."Document No.");
                                                                VendorLedger.SetRange("Posting Date", GLEntry."Posting Date");
                                                                if VendorLedger.FindSet() then
                                                                    // 9-12-2022
                                                                    WHTTrans."Entry No Ledger Entry Vend" := VendorLedger."Entry No.";
                                                                Vendor.SetRange("No.", GLEntry."Source No.");
                                                                if Vendor.FindSet() then begin
                                                                    WHTTrans.NPWP := Vendor.NPWP;
                                                                    WHTTrans.Nama := Vendor.NamaNPWP;
                                                                    WHTTrans."Alamat NPWP" := Vendor.AlamatNPWP;
                                                                end;
                                                            end;
                                                    end;
                                                end;
                                        end;
                                        WHTTrans."Entry No" := GLEntry."Entry No.";
                                        WHTTrans."External Doc No" := GLEntry."External Document No.";
                                        WHTTrans."Global Dimension 1" := GLEntry."Global Dimension 1 Code";
                                        WHTTrans."Global Dimension 2" := GLEntry."Global Dimension 2 Code";
                                        WHTTrans."Dimension Set ID" := GLEntry."Dimension Set ID";
                                        WHTTrans."Gen. Posting Type" := GLEntry."Gen. Posting Type";
                                        WHTTrans."Gen. Bus. Posting Group" := GLEntry."Gen. Bus. Posting Group";
                                        WHTTrans."Gen. Prod. Posting Group" := GLEntry."Gen. Prod. Posting Group";
                                        WHTTrans."VAT Bus. Posting Group" := GLEntry."VAT Bus. Posting Group";
                                        WHTTrans."VAT Prod. Posting Group" := GLEntry."VAT Prod. Posting Group";
                                        WHTTrans.Insert();
                                    end;
                                end else begin
                                    if GLEntry."Source Code" = 'SALES' then begin
                                        WHTTrans.SetFilter("Document No", '= %1', GLEntry."Document No.");
                                        //WHTTrans.SetFilter("Entry No", '= %1', GLEntry."Entry No.");
                                        WHTTrans.SetRange(WHTProductPostingGroup, GLEntry.WHTProductPostingGroup);
                                        if not WHTTrans.FindSet() then begin
                                            clear(WHTTrans);
                                            WHTTrans.Init();
                                            WHTTrans."Posting Date" := GLEntry."Posting Date";
                                            WHTTrans."Bukti Potong Date" := GLEntry."Posting Date";
                                            WHTTrans."Source Code" := GLEntry."Source Code";
                                            WHTTrans."Document Type" := GLEntry."Document Type";
                                            WHTTrans."Document No" := GLEntry."Document No.";
                                            // WHTTrans."PPh Code" := GLEntry.WHTProductPostingGroup;
                                            WHTTrans.WHTProductPostingGroup := GLEntry.WHTProductPostingGroup;
                                            WHTTrans.WHTPercentage := GLEntry.WHTPercentage;
                                            if GLEntry."Document Type" = GLEntry."Document Type"::"Credit Memo" then
                                                WHTTrans.WHTAmount := GLEntry."WHTAmount Additional Currency" * -1
                                            else
                                                WHTTrans.WHTAmount := GLEntry."WHTAmount Additional Currency";
                                            WHTTrans."G/L Account No" := GLEntry."G/L Account No.";
                                            WHTTrans."G/L Account Name" := GLAccount.Name;
                                            WHTTrans.Description := GLEntry.Description;
                                            WHTTrans.Quantity := GLEntry.Quantity;
                                            //WHTTrans.Amount := System.Abs(GLEntry.Amount);
                                            //CASE
                                            case GLEntry."Document Type" of
                                                GLEntry."Document Type"::Payment: // Payment (order) 
                                                    begin
                                                        WHTTrans.Amount := System.Abs(GLEntry."Additional-Currency Amount");
                                                        GLEntryPerDocNo.SetRange("Document No.", GLEntry."Document No.");
                                                        GLEntryPerDocNo.SetFilter("Source Type", '%1 | %2', GLEntryPerDocNo."Source Type"::Customer, GLEntryPerDocNo."Source Type"::Vendor);
                                                        GLEntryPerDocNo.FindFirst();
                                                        case GLEntryPerDocNo."Source Type" of
                                                            GLEntryPerDocNo."Source Type"::Customer://Customer
                                                                begin
                                                                    CustLedger.SetRange("Document Type", GLEntry."Document Type");
                                                                    CustLedger.SetRange("Document No.", GLEntry."Document No.");
                                                                    CustLedger.SetRange("Posting Date", GLEntry."Posting Date");
                                                                    if CustLedger.FindFirst() then begin
                                                                        WHTTrans."Source Type" := WHTTrans."Source Type"::Customer;
                                                                        WHTTrans."Source No" := CustLedger."Customer No.";
                                                                        // 9-12-2022
                                                                        WHTTrans."Entry No Ledger Entry Cust" := CustLedger."Entry No.";
                                                                        Customer.SetRange("No.", CustLedger."Customer No.");
                                                                        if Customer.FindFirst() then begin
                                                                            //if Customer.ISPKP = true then
                                                                            WHTTrans.NPWP := Customer.NPWP;
                                                                            // else
                                                                            WHTTrans.NIK := Customer.NIK;
                                                                            WHTTrans.Nama := Customer.NamaNPWP;
                                                                            WHTTrans."Alamat NPWP" := Customer.AlamatNPWP;
                                                                        end;
                                                                        Clear(VATEntry);
                                                                        if CustLedger."Applies-to Doc. No." = '' then begin
                                                                            WHTTrans."DPP Amount" := 0;
                                                                            WHTTrans."VAT Amount" := 0;
                                                                        end else begin
                                                                            CLedgerPerCloseNo.SetRange("Closed by Entry No.", CustLedger."Entry No.");
                                                                            CLedgerPerCloseNo.FindSet();
                                                                            VATEntry.SetRange("Document No.", CLedgerPerCloseNo."Document No.");
                                                                            VATEntry.FindSet();
                                                                            WHTTrans."DPP Amount" := System.Abs(VATEntry."Additional-Currency Base");
                                                                            WHTTrans."VAT Amount" := System.Abs(VATEntry."Additional-Currency Amount");
                                                                        end;
                                                                        WHTTrans."VAT Type" := VATEntry.Type;
                                                                    end;
                                                                end;
                                                        end;
                                                    end;
                                                GLEntry."Document Type"::Invoice: //Invoice
                                                    begin
                                                        WHTTrans."Source Type" := GLEntry."Source Type";
                                                        WHTTrans."Source No" := GLEntry."Source No.";
                                                        Clear(VATEntry);
                                                        VATEntry.SetRange("Document Type", GLEntry."Document Type");
                                                        VATEntry.SetRange("Document No.", GLEntry."Document No.");
                                                        VATEntry.SetRange("Posting Date", GLEntry."Posting Date");
                                                        VATEntry.SetFilter(Amount, '<> %1', 0);
                                                        if VATEntry.FindSet() then begin
                                                            VATEntry.CalcSums("Additional-Currency Base");
                                                            VATEntry.CalcSums("Additional-Currency Amount");
                                                            //WHTTrans."DPP Amount" := System.Abs(VATEntry.Base);
                                                            WHTTrans."VAT Amount" := System.Abs(VATEntry."Additional-Currency Amount");
                                                            WHTTrans."VAT Type" := VATEntry.Type;
                                                        end;
                                                        case GLEntry."Source Type" of
                                                            GLEntry."Source Type"::Customer://Customer
                                                                begin
                                                                    CustLedger.SetRange("Document Type", GLEntry."Document Type");
                                                                    CustLedger.SetRange("Document No.", GLEntry."Document No.");
                                                                    CustLedger.SetRange("Posting Date", GLEntry."Posting Date");
                                                                    if CustLedger.FindFirst() then
                                                                        // 9-12-2022
                                                                        WHTTrans."Entry No Ledger Entry Cust" := CustLedger."Entry No.";
                                                                    Customer.SetRange("No.", GLEntry."Source No.");
                                                                    if Customer.FindSet() then begin
                                                                        WHTTrans.NPWP := Customer.NPWP;
                                                                        WHTTrans.Nama := Customer.NamaNPWP;
                                                                        WHTTrans."Alamat NPWP" := Customer.AlamatNPWP;
                                                                    end;
                                                                    SalesInvHeader.SetRange("No.", GLEntry."Document No.");
                                                                    if SalesInvHeader.FindSet() then begin
                                                                        WHTTrans."Invoice Date" := SalesInvHeader."Document Date";
                                                                        WHTTrans."Order No" := SalesInvHeader."Order No.";
                                                                        WHTTrans.TAXNUMBER := SalesInvHeader.TAXNUMBER;
                                                                    end;

                                                                    SalesInvLine.SetRange("Document No.", GLEntry."Document No.");
                                                                    SalesInvLine.SetRange(IsWHTCalc, false);
                                                                    SalesInvLine.SetRange(WHTProductPostingGroup, GLEntry.WHTProductPostingGroup);
                                                                    if SalesInvLine.FindSet() then begin
                                                                        ExchangeRate := Exc.GetExchangeRate(TaxSetup."Export to Currency", SalesInvHeader."Currency Code", SalesInvHeader."Posting Date");
                                                                        SalesInvLine.CalcSums(Amount, "Amount Including VAT");
                                                                        WHTTrans.Amount := System.Abs(SalesInvLine."Amount Including VAT") / ExchangeRate;
                                                                        WHTTrans."DPP Amount" := System.Abs(SalesInvLine."Amount") / ExchangeRate;
                                                                        ;
                                                                    end
                                                                end;
                                                        end;
                                                    end;

                                                GLEntry."Document Type"::"Credit Memo": //Cr memo
                                                    begin
                                                        WHTTrans.Amount := System.Abs(GLEntry."Additional-Currency Amount");
                                                        WHTTrans."Source Type" := GLEntry."Source Type";
                                                        WHTTrans."Source No" := GLEntry."Source No.";
                                                        Clear(VATEntry);
                                                        VATEntry.SetRange("Document Type", GLEntry."Document Type");
                                                        VATEntry.SetRange("Document No.", GLEntry."Document No.");
                                                        VATEntry.SetRange("Posting Date", GLEntry."Posting Date");
                                                        VATEntry.SetFilter(Amount, '<> %1', 0);
                                                        if VATEntry.FindSet() then begin
                                                            VATEntry.CalcSums("Additional-Currency Base");
                                                            VATEntry.CalcSums("Additional-Currency Amount");
                                                            WHTTrans."DPP Amount" := System.Abs(VATEntry."Additional-Currency Base");
                                                            WHTTrans."VAT Amount" := System.Abs(VATEntry."Additional-Currency Amount");
                                                            WHTTrans."VAT Type" := VATEntry.Type;
                                                        end;
                                                        case GLEntry."Source Type" of
                                                            GLEntry."Source Type"::Customer://Customer
                                                                begin
                                                                    CustLedger.SetRange("Document Type", GLEntry."Document Type");
                                                                    CustLedger.SetRange("Document No.", GLEntry."Document No.");
                                                                    CustLedger.SetRange("Posting Date", GLEntry."Posting Date");
                                                                    if CustLedger.FindFirst() then
                                                                        // 9-12-2022
                                                                        WHTTrans."Entry No Ledger Entry Cust" := CustLedger."Entry No.";
                                                                    Customer.SetRange("No.", GLEntry."Source No.");
                                                                    if Customer.FindSet() then begin
                                                                        WHTTrans.NPWP := Customer.NPWP;
                                                                        WHTTrans.Nama := Customer.NamaNPWP;
                                                                        WHTTrans."Alamat NPWP" := Customer.AlamatNPWP;
                                                                    end;
                                                                end;
                                                        end;
                                                    end;
                                            end;
                                            WHTTrans."Entry No" := GLEntry."Entry No.";
                                            WHTTrans."External Doc No" := GLEntry."External Document No.";
                                            WHTTrans."Global Dimension 1" := GLEntry."Global Dimension 1 Code";
                                            WHTTrans."Global Dimension 2" := GLEntry."Global Dimension 2 Code";
                                            WHTTrans."Dimension Set ID" := GLEntry."Dimension Set ID";
                                            WHTTrans."Gen. Posting Type" := GLEntry."Gen. Posting Type";
                                            WHTTrans."Gen. Bus. Posting Group" := GLEntry."Gen. Bus. Posting Group";
                                            WHTTrans."Gen. Prod. Posting Group" := GLEntry."Gen. Prod. Posting Group";
                                            WHTTrans."VAT Bus. Posting Group" := GLEntry."VAT Bus. Posting Group";
                                            WHTTrans."VAT Prod. Posting Group" := GLEntry."VAT Prod. Posting Group";
                                            WHTTrans.Insert();
                                        end;
                                    end else begin
                                        if GLEntry."Source Code" = 'CASHRECJNL' then begin
                                            WHTTrans.SetFilter("Document No", '= %1', GLEntry."Document No.");
                                            //WHTTrans.SetFilter("Entry No", '= %1', GLEntry."Entry No.");
                                            WHTTrans.SetRange(WHTProductPostingGroup, GLEntry.WHTProductPostingGroup);
                                            if not WHTTrans.FindSet() then begin
                                                clear(WHTTrans);
                                                WHTTrans.Init();
                                                WHTTrans."Posting Date" := GLEntry."Posting Date";
                                                WHTTrans."Bukti Potong Date" := GLEntry."Posting Date";
                                                WHTTrans."Source Code" := GLEntry."Source Code";
                                                WHTTrans."Document Type" := GLEntry."Document Type";
                                                WHTTrans."Document No" := GLEntry."Document No.";
                                                // WHTTrans."PPh Code" := GLEntry.WHTProductPostingGroup;
                                                WHTTrans.WHTProductPostingGroup := GLEntry.WHTProductPostingGroup;
                                                WHTTrans.WHTPercentage := GLEntry.WHTPercentage;
                                                if GLEntry."Document Type" = GLEntry."Document Type"::"Credit Memo" then
                                                    WHTTrans.WHTAmount := GLEntry."WHTAmount Additional Currency" * -1
                                                else
                                                    WHTTrans.WHTAmount := GLEntry."WHTAmount Additional Currency";
                                                WHTTrans."G/L Account No" := GLEntry."G/L Account No.";
                                                WHTTrans."G/L Account Name" := GLAccount.Name;
                                                WHTTrans.Description := GLEntry.Description;
                                                WHTTrans.Quantity := GLEntry.Quantity;
                                                WHTTrans.Amount := System.Abs(GLEntry."Additional-Currency Amount");
                                                //CASE
                                                case GLEntry."Document Type" of
                                                    GLEntry."Document Type"::Payment: // CASH REC
                                                        begin
                                                            GLEntryPerDocNo.SetRange("Document No.", GLEntry."Document No.");
                                                            GLEntryPerDocNo.SetFilter("Source Type", '%1 | %2', GLEntryPerDocNo."Source Type"::Customer, GLEntryPerDocNo."Source Type"::Vendor);
                                                            GLEntryPerDocNo.FindFirst();
                                                            case GLEntryPerDocNo."Source Type" of
                                                                GLEntryPerDocNo."Source Type"::Customer://Customer
                                                                    begin
                                                                        CustLedger.SetRange("Document Type", GLEntry."Document Type");
                                                                        CustLedger.SetRange("Document No.", GLEntry."Document No.");
                                                                        CustLedger.SetRange("Posting Date", GLEntry."Posting Date");
                                                                        if CustLedger.FindFirst() then begin
                                                                            WHTTrans."Source Type" := WHTTrans."Source Type"::Customer;
                                                                            WHTTrans."Source No" := CustLedger."Customer No.";
                                                                            // 9-12-2022
                                                                            WHTTrans."Entry No Ledger Entry Cust" := CustLedger."Entry No.";
                                                                            Customer.SetRange("No.", CustLedger."Customer No.");
                                                                            if Customer.FindFirst() then begin
                                                                                //if Customer.ISPKP = true then
                                                                                WHTTrans.NPWP := Customer.NPWP;
                                                                                // else
                                                                                WHTTrans.NIK := Customer.NIK;
                                                                                WHTTrans.Nama := Customer.NamaNPWP;
                                                                                WHTTrans."Alamat NPWP" := Customer.AlamatNPWP;
                                                                            end;
                                                                            Clear(VATEntry);
                                                                            if CustLedger."Applies-to Doc. No." = '' then begin
                                                                                WHTTrans."DPP Amount" := 0;
                                                                                WHTTrans."VAT Amount" := 0;
                                                                            end else begin
                                                                                CLedgerPerCloseNo.SetRange("Closed by Entry No.", CustLedger."Entry No.");
                                                                                CLedgerPerCloseNo.FindSet();
                                                                                VATEntry.SetRange("Document No.", CLedgerPerCloseNo."Document No.");
                                                                                VATEntry.FindSet();
                                                                                WHTTrans."DPP Amount" := System.Abs(VATEntry."Additional-Currency Base");
                                                                                WHTTrans."VAT Amount" := System.Abs(VATEntry."Additional-Currency Amount");
                                                                            end;
                                                                            WHTTrans."VAT Type" := VATEntry.Type;
                                                                        end;
                                                                    end;
                                                            end;
                                                        end;
                                                end;
                                                WHTTrans."Entry No" := GLEntry."Entry No.";
                                                WHTTrans."External Doc No" := GLEntry."External Document No.";
                                                WHTTrans."Global Dimension 1" := GLEntry."Global Dimension 1 Code";
                                                WHTTrans."Global Dimension 2" := GLEntry."Global Dimension 2 Code";
                                                WHTTrans."Dimension Set ID" := GLEntry."Dimension Set ID";
                                                WHTTrans."Gen. Posting Type" := GLEntry."Gen. Posting Type";
                                                WHTTrans."Gen. Bus. Posting Group" := GLEntry."Gen. Bus. Posting Group";
                                                WHTTrans."Gen. Prod. Posting Group" := GLEntry."Gen. Prod. Posting Group";
                                                WHTTrans."VAT Bus. Posting Group" := GLEntry."VAT Bus. Posting Group";
                                                WHTTrans."VAT Prod. Posting Group" := GLEntry."VAT Prod. Posting Group";
                                                WHTTrans.Insert();
                                            end;
                                        end;
                                    end;
                                end;
                            until GLEntry.Next() = 0;
                    until GLAccount.Next() = 0;
            end;
    end;

    procedure PPhSynch2Row(StartDate: Date; EndDate: Date)
    var
        TaxSetup: Record Kre_TaxSetup;
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
        GLEntryPerDocNo: Record "G/L Entry";
        VATEntry: Record "VAT Entry";
        Vendor: Record Vendor;
        Customer: Record Customer;
        VendorLedger: Record "Vendor Ledger Entry";
        CustLedger: Record "Cust. Ledger Entry";
        VLedgerPerCloseNo: Record "Vendor Ledger Entry";
        CLedgerPerCloseNo: Record "Cust. Ledger Entry";
        WHTTrans: Record KreWHTTrans;
        SalesInvHeader: Record "Sales Invoice Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchInvLine2Row: Record "Purch. Inv. Line";
        SalesInvLine: Record "Sales Invoice Line";
        SalesInvLine2Row: Record "Sales Invoice Line";

    begin
        if TaxSetup.FindSet() then
            if TaxSetup.Activate_WHT then begin
                GLAccount.SetRange(IsPPh, true);
                if GLAccount.FindSet() then
                    repeat
                        // Clear(GLEntry);
                        GLEntry.SetRange("Posting Date", StartDate, EndDate);
                        GLEntry.SetRange("G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(WHTProductPostingGroup, '= %1', '');
                        // GLEntry.SetRange("Source Code", 'PURCHASES', 'SALES');
                        if GLEntry.FindSet() then
                            repeat
                                PurchInvLine2Row.SetRange("Document No.", GLEntry."Document No.");
                                PurchInvLine2Row.SetRange("No.", GLAccount."No.");
                                PurchInvLine2Row.SetRange(IsWHTCalc, false);
                                if PurchInvLine2Row.FindSet() then
                                    repeat

                                        WHTTrans.SetRange(WHTAmount, System.Abs(PurchInvLine2Row.WHTAmount));
                                        WHTTrans.SetRange(WHTProductPostingGroup, PurchInvLine2Row.WHTProductPostingGroup);

                                        if WHTTrans.IsEmpty then begin
                                            clear(WHTTrans);

                                            WHTTrans.Init();
                                            WHTTrans."Posting Date" := GLEntry."Posting Date";
                                            WHTTrans."Bukti Potong Date" := GLEntry."Posting Date";
                                            WHTTrans."Source Code" := GLEntry."Source Code";
                                            WHTTrans."Document Type" := GLEntry."Document Type";
                                            WHTTrans."Document No" := GLEntry."Document No.";
                                            // WHTTrans."PPh Code" := GLEntry.WHTProductPostingGroup;
                                            // WHTTrans."PPh Code" := GLEntry.WHTProductPostingGroup;
                                            WHTTrans.WHTPercentage := PurchInvLine2Row.WHTPercentage;
                                            if GLEntry."Document Type" = GLEntry."Document Type"::"Credit Memo" then
                                                WHTTrans.WHTAmount := PurchInvLine2Row.WHTAmount * -1
                                            else
                                                WHTTrans."G/L Account No" := GLEntry."G/L Account No.";
                                            WHTTrans."G/L Account Name" := GLAccount.Name;
                                            WHTTrans.Description := GLEntry.Description;
                                            WHTTrans.Quantity := GLEntry.Quantity;
                                            WHTTrans.Amount := System.Abs(PurchInvLine2Row."Line Amount");
                                            //CASE
                                            case GLEntry."Document Type" of
                                                GLEntry."Document Type"::Payment: // Payment (order) 
                                                    begin
                                                        GLEntryPerDocNo.SetFilter("Source Type", '%1 | %2', GLEntryPerDocNo."Source Type"::Customer, GLEntryPerDocNo."Source Type"::Vendor);
                                                        GLEntryPerDocNo.FindFirst();
                                                        case GLEntryPerDocNo."Source Type" of
                                                            GLEntryPerDocNo."Source Type"::Vendor://Vendor
                                                                begin
                                                                    begin
                                                                        VendorLedger.SetRange("Document No.", GLEntry."Document No.");
                                                                        VendorLedger.SetRange("Posting Date", GLEntry."Posting Date");
                                                                        if VendorLedger.FindSet() then begin
                                                                            WHTTrans."Source Type" := WHTTrans."Source Type"::Vendor;
                                                                            WHTTrans."Source No" := VendorLedger."Vendor No.";
                                                                            // 9-12-2022
                                                                            Vendor.SetRange("No.", VendorLedger."Vendor No.");
                                                                            if Vendor.FindFirst() then begin
                                                                                //if Vendor.ISPKP = true then
                                                                                //else
                                                                                WHTTrans.Nama := Vendor.NamaNPWP;
                                                                                WHTTrans."Alamat NPWP" := Vendor.AlamatNPWP;
                                                                            end;
                                                                        end;
                                                                        Clear(VATEntry);
                                                                        if VendorLedger."Applies-to Doc. No." = '' then begin
                                                                            WHTTrans."DPP Amount" := 0;
                                                                            WHTTrans."VAT Amount" := 0;
                                                                        end else begin
                                                                            VLedgerPerCloseNo.SetRange("Closed by Entry No.", VendorLedger."Entry No.");
                                                                            VLedgerPerCloseNo.FindSet();
                                                                            VATEntry.SetRange("Document No.", VLedgerPerCloseNo."Document No.");
                                                                            VATEntry.FindSet();
                                                                            WHTTrans."DPP Amount" := System.Abs(VATEntry.Base);
                                                                            WHTTrans."VAT Amount" := System.Abs(VATEntry.Amount);
                                                                        end;
                                                                        WHTTrans."VAT Type" := VATEntry.Type;
                                                                    end;
                                                                end;
                                                        end;
                                                    end;
                                                GLEntry."Document Type"::Invoice: //Invoice
                                                    begin
                                                        WHTTrans."Source Type" := GLEntry."Source Type";
                                                        WHTTrans."Source No" := GLEntry."Source No.";

                                                        Clear(VATEntry);
                                                        VATEntry.SetRange("Document Type", GLEntry."Document Type");
                                                        VATEntry.SetRange("Document No.", GLEntry."Document No.");
                                                        VATEntry.SetRange("Posting Date", GLEntry."Posting Date");
                                                        VATEntry.SetFilter(Amount, '<> %1', 0);
                                                        if VATEntry.FindSet() then begin
                                                            VATEntry.CalcSums(Base);
                                                            VATEntry.CalcSums(Amount);
                                                            //WHTTrans."DPP Amount" := System.Abs(VATEntry.Base);
                                                            WHTTrans."VAT Amount" := System.Abs(VATEntry.Amount);
                                                            WHTTrans."VAT Type" := VATEntry.Type;
                                                        end;
                                                        case GLEntry."Source Type" of
                                                            GLEntry."Source Type"::Vendor://Vendor
                                                                begin
                                                                    VendorLedger.SetRange("Document Type", GLEntry."Document Type");
                                                                    VendorLedger.SetRange("Document No.", GLEntry."Document No.");
                                                                    VendorLedger.SetRange("Posting Date", GLEntry."Posting Date");
                                                                    if VendorLedger.FindSet() then
                                                                        // 9-12-2022
                                                                        WHTTrans."Entry No Ledger Entry Vend" := VendorLedger."Entry No.";
                                                                    Vendor.SetRange("No.", GLEntry."Source No.");
                                                                    if Vendor.FindSet() then begin
                                                                        WHTTrans.NPWP := Vendor.NPWP;
                                                                        WHTTrans.Nama := Vendor.NamaNPWP;
                                                                        WHTTrans."Alamat NPWP" := Vendor.AlamatNPWP;
                                                                    end;
                                                                    PurchInvHeader.SetRange("No.", GLEntry."Document No.");
                                                                    if PurchInvHeader.FindSet() then begin
                                                                        WHTTrans."Invoice Date" := PurchInvHeader."Document Date";
                                                                        WHTTrans."Order No" := PurchInvHeader."Order No.";
                                                                        WHTTrans.TAXNUMBER := PurchInvHeader.TAXNUMBER;
                                                                    end;
                                                                    //perhitungan gross up
                                                                    //if CheckGrossUpExistInLine(GLEntry."Document No.") = true then begin
                                                                    PurchInvLine.SetRange("Document No.", GLEntry."Document No.");
                                                                    PurchInvLine.SetRange(IsWHTCalc, false);
                                                                    if PurchInvLine.FindSet() then begin
                                                                        PurchInvLine.CalcSums(Amount, "Amount Including VAT");
                                                                        WHTTrans.Amount := System.Abs(PurchInvLine."Amount Including VAT");
                                                                        WHTTrans."DPP Amount" := System.Abs(PurchInvLine.Amount);
                                                                    end;
                                                                    //end else
                                                                    //WHTTrans.Amount := System.Abs(GLEntry.Amount);
                                                                end;
                                                        end;
                                                    end;
                                            end;
                                            WHTTrans."External Doc No" := GLEntry."External Document No.";
                                            WHTTrans."Global Dimension 1" := GLEntry."Global Dimension 1 Code";
                                            WHTTrans."Global Dimension 2" := GLEntry."Global Dimension 2 Code";
                                            WHTTrans."Dimension Set ID" := GLEntry."Dimension Set ID";
                                            WHTTrans."Gen. Posting Type" := GLEntry."Gen. Posting Type";
                                            WHTTrans."Gen. Bus. Posting Group" := GLEntry."Gen. Bus. Posting Group";
                                            WHTTrans."Gen. Prod. Posting Group" := GLEntry."Gen. Prod. Posting Group";
                                            WHTTrans."VAT Bus. Posting Group" := GLEntry."VAT Bus. Posting Group";
                                            WHTTrans."VAT Prod. Posting Group" := GLEntry."VAT Prod. Posting Group";
                                            WHTTrans.Insert();

                                        end;
                                    until PurchInvLine2Row.Next() = 0

                                else begin
                                    SalesInvLine2Row.SetRange("Document No.", GLEntry."Document No.");
                                    SalesInvLine2Row.SetRange("No.", GLAccount."No.");
                                    SalesInvLine2Row.SetRange(IsWHTCalc, false);
                                    if SalesInvLine2Row.FindSet() then
                                        repeat
                                            WHTTrans.SetRange(WHTAmount, System.Abs(PurchInvLine2Row.WHTAmount));
                                            WHTTrans.SetRange(WHTProductPostingGroup, SalesInvLine2Row.WHTProductPostingGroup);

                                            if WHTTrans.IsEmpty() then begin
                                                clear(WHTTrans);

                                                WHTTrans.Init();
                                                WHTTrans."Posting Date" := GLEntry."Posting Date";
                                                WHTTrans."Bukti Potong Date" := GLEntry."Posting Date";
                                                WHTTrans."Source Code" := GLEntry."Source Code";
                                                WHTTrans."Document Type" := GLEntry."Document Type";
                                                WHTTrans."Document No" := GLEntry."Document No.";
                                                // WHTTrans."PPh Code" := GLEntry.WHTProductPostingGroup;
                                                // WHTTrans."PPh Code" := GLEntry.WHTProductPostingGroup;
                                                WHTTrans.WHTPercentage := SalesInvLine2Row.WHTPercentage;
                                                if GLEntry."Document Type" = GLEntry."Document Type"::"Credit Memo" then
                                                    WHTTrans.WHTAmount := SalesInvLine2Row.WHTAmount * -1
                                                else
                                                    WHTTrans."G/L Account No" := GLEntry."G/L Account No.";
                                                WHTTrans."G/L Account Name" := GLAccount.Name;
                                                WHTTrans.Description := GLEntry.Description;
                                                WHTTrans.Quantity := GLEntry.Quantity;
                                                WHTTrans.Amount := System.Abs(SalesInvLine2Row."Line Amount");

                                                //CASE
                                                case GLEntry."Document Type" of
                                                    GLEntry."Document Type"::Payment: // Payment (order) 
                                                        begin
                                                            WHTTrans.Amount := System.Abs(SalesInvLine2Row."Line Amount");
                                                            GLEntryPerDocNo.SetRange("Document No.", GLEntry."Document No.");
                                                            GLEntryPerDocNo.SetFilter("Source Type", '%1 | %2', GLEntryPerDocNo."Source Type"::Customer, GLEntryPerDocNo."Source Type"::Vendor);
                                                            GLEntryPerDocNo.FindFirst();
                                                            case GLEntryPerDocNo."Source Type" of
                                                                GLEntryPerDocNo."Source Type"::Customer://Customer
                                                                    begin
                                                                        CustLedger.SetRange("Document Type", GLEntry."Document Type");
                                                                        CustLedger.SetRange("Document No.", GLEntry."Document No.");
                                                                        CustLedger.SetRange("Posting Date", GLEntry."Posting Date");
                                                                        if CustLedger.FindFirst() then begin
                                                                            WHTTrans."Source Type" := WHTTrans."Source Type"::Customer;
                                                                            WHTTrans."Source No" := CustLedger."Customer No.";
                                                                            // 9-12-2022
                                                                            WHTTrans."Entry No Ledger Entry Cust" := CustLedger."Entry No.";
                                                                            Customer.SetRange("No.", CustLedger."Customer No.");
                                                                            if Customer.FindFirst() then begin
                                                                                //if Customer.ISPKP = true then
                                                                                WHTTrans.NPWP := Customer.NPWP;
                                                                                // else
                                                                                WHTTrans.NIK := Customer.NIK;
                                                                                WHTTrans.Nama := Customer.NamaNPWP;
                                                                                WHTTrans."Alamat NPWP" := Customer.AlamatNPWP;
                                                                            end;
                                                                            Clear(VATEntry);
                                                                            if CustLedger."Applies-to Doc. No." = '' then begin
                                                                                WHTTrans."DPP Amount" := 0;
                                                                                WHTTrans."VAT Amount" := 0;
                                                                            end else begin
                                                                                CLedgerPerCloseNo.SetRange("Closed by Entry No.", CustLedger."Entry No.");
                                                                                CLedgerPerCloseNo.FindSet();
                                                                                VATEntry.SetRange("Document No.", CLedgerPerCloseNo."Document No.");
                                                                                VATEntry.FindSet();
                                                                                WHTTrans."DPP Amount" := System.Abs(VATEntry.Base);
                                                                                WHTTrans."VAT Amount" := System.Abs(VATEntry.Amount);
                                                                            end;
                                                                            WHTTrans."VAT Type" := VATEntry.Type;
                                                                        end;
                                                                    end;
                                                            end;
                                                        end;
                                                    GLEntry."Document Type"::Invoice: //Invoice
                                                        begin
                                                            begin
                                                                WHTTrans."Source Type" := GLEntry."Source Type";
                                                                WHTTrans."Source No" := GLEntry."Source No.";

                                                                Clear(VATEntry);
                                                                VATEntry.SetRange("Document Type", GLEntry."Document Type");
                                                                VATEntry.SetRange("Document No.", GLEntry."Document No.");
                                                                VATEntry.SetRange("Posting Date", GLEntry."Posting Date");
                                                                VATEntry.SetFilter(Amount, '<> %1', 0);
                                                                if VATEntry.FindSet() then begin
                                                                    VATEntry.CalcSums(Base);
                                                                    VATEntry.CalcSums(Amount);
                                                                    //WHTTrans."DPP Amount" := System.Abs(        /BWneAmount" := System.Abs(VATEntry.Base);
                                                                    WHTTrans."VAT Amount" := System.Abs(VATEntry.Amount);
                                                                    WHTTrans."VAT Type" := VATEntry.Type;
                                                                    case GLEntry."Source Type" of
                                                                        GLEntry."Source Type"::Customer://Customer
                                                                            begin
                                                                                CustLedger.SetRange("Document Type", GLEntry."Document Type");
                                                                                CustLedger.SetRange("Document No.", GLEntry."Document No.");
                                                                                CustLedger.SetRange("Posting Date", GLEntry."Posting Date");
                                                                                if CustLedger.FindFirst() then
                                                                                    WHTTrans."Entry No Ledger Entry Cust" := CustLedger."Entry No.";
                                                                                //9-12-2022("No.", GLEntry."Source No.");
                                                                                if Customer.FindSet() then begin
                                                                                    WHTTrans.NPWP := Customer.NPWP;
                                                                                    WHTTrans.Nama := Customer.NamaNPWP;
                                                                                    WHTTrans."Alamat NPWP" := Customer.AlamatNPWP;
                                                                                    SalesInvHeader.SetRange("No.", GLEntry."Document No.");
                                                                                    if SalesInvHeader.FindSet() then begin
                                                                                        WHTTrans."Invoice Date" := SalesInvHeader."Document Date";
                                                                                        WHTTrans."Order No" := SalesInvHeader."Order No.";
                                                                                        WHTTrans.TAXNUMBER := SalesInvHeader.TAXNUMBER;
                                                                                    end;
                                                                                    SalesInvLine.SetRange("Document No.", GLEntry."Document No.");
                                                                                    SalesInvLine.SetRange(IsWHTCalc, false);
                                                                                    if SalesInvLine.FindSet() then begin
                                                                                        SalesInvLine.CalcSums(Amount, "Amount Including VAT");
                                                                                        WHTTrans.Amount := System.Abs(SalesInvLine."Amount Including VAT");
                                                                                        WHTTrans."DPP Amount" := System.Abs(SalesInvLine.Amount);
                                                                                    end;
                                                                                end;
                                                                            end;
                                                                    end;
                                                                    WHTTrans."Entry No" := GLEntry."Entry No.";
                                                                    WHTTrans."External Doc No" := GLEntry."External Document No.";
                                                                    WHTTrans."Global Dimension 1" := GLEntry."Global Dimension 1 Code";
                                                                    WHTTrans."Global Dimension 2" := GLEntry."Global Dimension 2 Code";
                                                                    WHTTrans."Dimension Set ID" := GLEntry."Dimension Set ID";
                                                                    WHTTrans."Gen. Posting Type" := GLEntry."Gen. Posting Type";
                                                                    WHTTrans."Gen. Bus. Posting Group" := GLEntry."Gen. Bus. Posting Group";
                                                                    WHTTrans."Gen. Prod. Posting Group" := GLEntry."Gen. Prod. Posting Group";
                                                                    WHTTrans."VAT Bus. Posting Group" := GLEntry."VAT Bus. Posting Group";
                                                                    WHTTrans."VAT Prod. Posting Group" := GLEntry."VAT Prod. Posting Group";
                                                                    WHTTrans.Insert();

                                                                end;
                                                            end;
                                                        end;
                                                end;
                                            end;
                                        until SalesInvLine2Row.Next() = 0;
                                end;
                            until GLEntry.Next() = 0;

                    until GLAccount.Next() = 0;
            end;

    end;

    procedure PPhSynch2RowForeignCurrency(StartDate: Date; EndDate: Date)
    var
        TaxSetup: Record Kre_TaxSetup;
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
        GLEntryPerDocNo: Record "G/L Entry";
        VATEntry: Record "VAT Entry";
        Vendor: Record Vendor;
        Customer: Record Customer;
        VendorLedger: Record "Vendor Ledger Entry";
        CustLedger: Record "Cust. Ledger Entry";
        VLedgerPerCloseNo: Record "Vendor Ledger Entry";
        CLedgerPerCloseNo: Record "Cust. Ledger Entry";
        WHTTrans: Record KreWHTTrans;
        SalesInvHeader: Record "Sales Invoice Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchInvLine2Row: Record "Purch. Inv. Line";
        SalesInvLine: Record "Sales Invoice Line";
        SalesInvLine2Row: Record "Sales Invoice Line";
        ExchangeRate: Decimal;
        Exc: Codeunit ExchangeRateIDR;
    begin
        if TaxSetup.FindSet() then
            if TaxSetup.Activate_WHT then begin
                GLAccount.SetRange(IsPPh, true);
                if GLAccount.FindSet() then
                    repeat
                        // Clear(GLEntry);
                        GLEntry.SetRange("Posting Date", StartDate, EndDate);
                        GLEntry.SetRange("G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(WHTProductPostingGroup, '= %1', '');
                        // GLEntry.SetRange("Source Code", 'PURCHASES', 'SALES');
                        if GLEntry.FindSet() then
                            repeat
                                PurchInvLine2Row.SetRange("Document No.", GLEntry."Document No.");
                                PurchInvLine2Row.SetRange("No.", GLAccount."No.");
                                PurchInvLine2Row.SetRange(IsWHTCalc, false);
                                if PurchInvLine2Row.FindSet() then begin
                                    PurchInvHeader.Get(PurchInvLine2Row."Document No.");
                                    repeat

                                        WHTTrans.SetRange(WHTAmount, System.Abs(PurchInvLine2Row."WHTAmount Additional Currency"));
                                        WHTTrans.SetRange(WHTProductPostingGroup, PurchInvLine2Row.WHTProductPostingGroup);

                                        if WHTTrans.IsEmpty then begin
                                            clear(WHTTrans);

                                            WHTTrans.Init();
                                            WHTTrans."Posting Date" := GLEntry."Posting Date";
                                            WHTTrans."Bukti Potong Date" := GLEntry."Posting Date";
                                            WHTTrans."Source Code" := GLEntry."Source Code";
                                            WHTTrans."Document Type" := GLEntry."Document Type";
                                            WHTTrans."Document No" := GLEntry."Document No.";
                                            // WHTTrans."PPh Code" := GLEntry.WHTProductPostingGroup;
                                            // WHTTrans."PPh Code" := GLEntry.WHTProductPostingGroup;
                                            WHTTrans.WHTPercentage := PurchInvLine2Row.WHTPercentage;
                                            if GLEntry."Document Type" = GLEntry."Document Type"::"Credit Memo" then
                                                WHTTrans.WHTAmount := PurchInvLine2Row."WHTAmount Additional Currency" * -1
                                            else
                                                WHTTrans."G/L Account No" := GLEntry."G/L Account No.";
                                            WHTTrans."G/L Account Name" := GLAccount.Name;
                                            WHTTrans.Description := GLEntry.Description;
                                            WHTTrans.Quantity := GLEntry.Quantity;
                                            ExchangeRate := Exc.GetExchangeRate(TaxSetup."Export to Currency", PurchInvHeader."Currency Code", PurchInvHeader."Posting Date");
                                            WHTTrans.Amount := System.Abs(PurchInvLine2Row."Line Amount" / ExchangeRate);
                                            //CASE
                                            case GLEntry."Document Type" of
                                                GLEntry."Document Type"::Payment: // Payment (order) 
                                                    begin
                                                        GLEntryPerDocNo.SetFilter("Source Type", '%1 | %2', GLEntryPerDocNo."Source Type"::Customer, GLEntryPerDocNo."Source Type"::Vendor);
                                                        GLEntryPerDocNo.FindFirst();
                                                        case GLEntryPerDocNo."Source Type" of
                                                            GLEntryPerDocNo."Source Type"::Vendor://Vendor
                                                                begin
                                                                    begin
                                                                        VendorLedger.SetRange("Document No.", GLEntry."Document No.");
                                                                        VendorLedger.SetRange("Posting Date", GLEntry."Posting Date");
                                                                        if VendorLedger.FindSet() then begin
                                                                            WHTTrans."Source Type" := WHTTrans."Source Type"::Vendor;
                                                                            WHTTrans."Source No" := VendorLedger."Vendor No.";
                                                                            // 9-12-2022
                                                                            Vendor.SetRange("No.", VendorLedger."Vendor No.");
                                                                            if Vendor.FindFirst() then begin
                                                                                //if Vendor.ISPKP = true then
                                                                                //else
                                                                                WHTTrans.Nama := Vendor.NamaNPWP;
                                                                                WHTTrans."Alamat NPWP" := Vendor.AlamatNPWP;
                                                                            end;
                                                                        end;
                                                                        Clear(VATEntry);
                                                                        if VendorLedger."Applies-to Doc. No." = '' then begin
                                                                            WHTTrans."DPP Amount" := 0;
                                                                            WHTTrans."VAT Amount" := 0;
                                                                        end else begin
                                                                            VLedgerPerCloseNo.SetRange("Closed by Entry No.", VendorLedger."Entry No.");
                                                                            VLedgerPerCloseNo.FindSet();
                                                                            VATEntry.SetRange("Document No.", VLedgerPerCloseNo."Document No.");
                                                                            VATEntry.FindSet();
                                                                            WHTTrans."DPP Amount" := System.Abs(VATEntry."Additional-Currency Base");
                                                                            WHTTrans."VAT Amount" := System.Abs(VATEntry."Additional-Currency Amount");
                                                                        end;
                                                                        WHTTrans."VAT Type" := VATEntry.Type;
                                                                    end;
                                                                end;
                                                        end;
                                                    end;
                                                GLEntry."Document Type"::Invoice: //Invoice
                                                    begin
                                                        WHTTrans."Source Type" := GLEntry."Source Type";
                                                        WHTTrans."Source No" := GLEntry."Source No.";

                                                        Clear(VATEntry);
                                                        VATEntry.SetRange("Document Type", GLEntry."Document Type");
                                                        VATEntry.SetRange("Document No.", GLEntry."Document No.");
                                                        VATEntry.SetRange("Posting Date", GLEntry."Posting Date");
                                                        VATEntry.SetFilter(Amount, '<> %1', 0);
                                                        if VATEntry.FindSet() then begin
                                                            VATEntry.CalcSums(Base);
                                                            VATEntry.CalcSums(Amount);
                                                            //WHTTrans."DPP Amount" := System.Abs(VATEntry.Base);
                                                            WHTTrans."VAT Amount" := System.Abs(VATEntry."Additional-Currency Amount");
                                                            WHTTrans."VAT Type" := VATEntry.Type;
                                                        end;
                                                        case GLEntry."Source Type" of
                                                            GLEntry."Source Type"::Vendor://Vendor
                                                                begin
                                                                    VendorLedger.SetRange("Document Type", GLEntry."Document Type");
                                                                    VendorLedger.SetRange("Document No.", GLEntry."Document No.");
                                                                    VendorLedger.SetRange("Posting Date", GLEntry."Posting Date");
                                                                    if VendorLedger.FindSet() then
                                                                        // 9-12-2022
                                                                        WHTTrans."Entry No Ledger Entry Vend" := VendorLedger."Entry No.";
                                                                    Vendor.SetRange("No.", GLEntry."Source No.");
                                                                    if Vendor.FindSet() then begin
                                                                        WHTTrans.NPWP := Vendor.NPWP;
                                                                        WHTTrans.Nama := Vendor.NamaNPWP;
                                                                        WHTTrans."Alamat NPWP" := Vendor.AlamatNPWP;
                                                                    end;
                                                                    PurchInvHeader.SetRange("No.", GLEntry."Document No.");
                                                                    if PurchInvHeader.FindSet() then begin
                                                                        WHTTrans."Invoice Date" := PurchInvHeader."Document Date";
                                                                        WHTTrans."Order No" := PurchInvHeader."Order No.";
                                                                        WHTTrans.TAXNUMBER := PurchInvHeader.TAXNUMBER;
                                                                    end;
                                                                    //perhitungan gross up
                                                                    //if CheckGrossUpExistInLine(GLEntry."Document No.") = true then begin
                                                                    PurchInvLine.SetRange("Document No.", GLEntry."Document No.");
                                                                    PurchInvLine.SetRange(IsWHTCalc, false);
                                                                    if PurchInvLine.FindSet() then begin
                                                                        PurchInvLine.CalcSums(Amount, "Amount Including VAT");
                                                                        ExchangeRate := Exc.GetExchangeRate(TaxSetup."Export to Currency", PurchInvHeader."Currency Code", PurchInvHeader."Posting Date");
                                                                        WHTTrans.Amount := System.Abs(PurchInvLine."Amount Including VAT" / ExchangeRate);
                                                                        WHTTrans."DPP Amount" := System.Abs(PurchInvLine.Amount / ExchangeRate);
                                                                    end;
                                                                    //end else
                                                                    //WHTTrans.Amount := System.Abs(GLEntry.Amount);
                                                                end;
                                                        end;
                                                    end;
                                            end;
                                            WHTTrans."External Doc No" := GLEntry."External Document No.";
                                            WHTTrans."Global Dimension 1" := GLEntry."Global Dimension 1 Code";
                                            WHTTrans."Global Dimension 2" := GLEntry."Global Dimension 2 Code";
                                            WHTTrans."Dimension Set ID" := GLEntry."Dimension Set ID";
                                            WHTTrans."Gen. Posting Type" := GLEntry."Gen. Posting Type";
                                            WHTTrans."Gen. Bus. Posting Group" := GLEntry."Gen. Bus. Posting Group";
                                            WHTTrans."Gen. Prod. Posting Group" := GLEntry."Gen. Prod. Posting Group";
                                            WHTTrans."VAT Bus. Posting Group" := GLEntry."VAT Bus. Posting Group";
                                            WHTTrans."VAT Prod. Posting Group" := GLEntry."VAT Prod. Posting Group";
                                            WHTTrans.Insert();

                                        end;
                                    until PurchInvLine2Row.Next() = 0

                                end else begin
                                    SalesInvLine2Row.SetRange("Document No.", GLEntry."Document No.");
                                    SalesInvLine2Row.SetRange("No.", GLAccount."No.");
                                    SalesInvLine2Row.SetRange(IsWHTCalc, false);
                                    if SalesInvLine2Row.FindSet() then
                                        repeat
                                            WHTTrans.SetRange(WHTAmount, System.Abs(SalesInvLine2Row."WHTAmount Additional Currency"));
                                            WHTTrans.SetRange(WHTProductPostingGroup, SalesInvLine2Row.WHTProductPostingGroup);

                                            if WHTTrans.IsEmpty() then begin
                                                clear(WHTTrans);

                                                WHTTrans.Init();
                                                WHTTrans."Posting Date" := GLEntry."Posting Date";
                                                WHTTrans."Bukti Potong Date" := GLEntry."Posting Date";
                                                WHTTrans."Source Code" := GLEntry."Source Code";
                                                WHTTrans."Document Type" := GLEntry."Document Type";
                                                WHTTrans."Document No" := GLEntry."Document No.";
                                                // WHTTrans."PPh Code" := GLEntry.WHTProductPostingGroup;
                                                // WHTTrans."PPh Code" := GLEntry.WHTProductPostingGroup;
                                                WHTTrans.WHTPercentage := SalesInvLine2Row.WHTPercentage;
                                                if GLEntry."Document Type" = GLEntry."Document Type"::"Credit Memo" then
                                                    WHTTrans.WHTAmount := SalesInvLine2Row."WHTAmount Additional Currency" * -1
                                                else
                                                    WHTTrans."G/L Account No" := GLEntry."G/L Account No.";
                                                WHTTrans."G/L Account Name" := GLAccount.Name;
                                                WHTTrans.Description := GLEntry.Description;
                                                WHTTrans.Quantity := GLEntry.Quantity;
                                                ExchangeRate := Exc.GetExchangeRate(TaxSetup."Export to Currency", SalesInvHeader."Currency Code", SalesInvHeader."Posting Date");
                                                WHTTrans.Amount := System.Abs(SalesInvLine2Row."Line Amount" / ExchangeRate);

                                                //CASE
                                                case GLEntry."Document Type" of
                                                    GLEntry."Document Type"::Payment: // Payment (order) 
                                                        begin
                                                            WHTTrans.Amount := System.Abs(SalesInvLine2Row."Line Amount");
                                                            GLEntryPerDocNo.SetRange("Document No.", GLEntry."Document No.");
                                                            GLEntryPerDocNo.SetFilter("Source Type", '%1 | %2', GLEntryPerDocNo."Source Type"::Customer, GLEntryPerDocNo."Source Type"::Vendor);
                                                            GLEntryPerDocNo.FindFirst();
                                                            case GLEntryPerDocNo."Source Type" of
                                                                GLEntryPerDocNo."Source Type"::Customer://Customer
                                                                    begin
                                                                        CustLedger.SetRange("Document Type", GLEntry."Document Type");
                                                                        CustLedger.SetRange("Document No.", GLEntry."Document No.");
                                                                        CustLedger.SetRange("Posting Date", GLEntry."Posting Date");
                                                                        if CustLedger.FindFirst() then begin
                                                                            WHTTrans."Source Type" := WHTTrans."Source Type"::Customer;
                                                                            WHTTrans."Source No" := CustLedger."Customer No.";
                                                                            // 9-12-2022
                                                                            WHTTrans."Entry No Ledger Entry Cust" := CustLedger."Entry No.";
                                                                            Customer.SetRange("No.", CustLedger."Customer No.");
                                                                            if Customer.FindFirst() then begin
                                                                                //if Customer.ISPKP = true then
                                                                                WHTTrans.NPWP := Customer.NPWP;
                                                                                // else
                                                                                WHTTrans.NIK := Customer.NIK;
                                                                                WHTTrans.Nama := Customer.NamaNPWP;
                                                                                WHTTrans."Alamat NPWP" := Customer.AlamatNPWP;
                                                                            end;
                                                                            Clear(VATEntry);
                                                                            if CustLedger."Applies-to Doc. No." = '' then begin
                                                                                WHTTrans."DPP Amount" := 0;
                                                                                WHTTrans."VAT Amount" := 0;
                                                                            end else begin
                                                                                CLedgerPerCloseNo.SetRange("Closed by Entry No.", CustLedger."Entry No.");
                                                                                CLedgerPerCloseNo.FindSet();
                                                                                VATEntry.SetRange("Document No.", CLedgerPerCloseNo."Document No.");
                                                                                VATEntry.FindSet();
                                                                                WHTTrans."DPP Amount" := System.Abs(VATEntry."Additional-Currency Base");
                                                                                WHTTrans."VAT Amount" := System.Abs(VATEntry."Additional-Currency Amount");
                                                                            end;
                                                                            WHTTrans."VAT Type" := VATEntry.Type;
                                                                        end;
                                                                    end;
                                                            end;
                                                        end;
                                                    GLEntry."Document Type"::Invoice: //Invoice
                                                        begin
                                                            begin
                                                                WHTTrans."Source Type" := GLEntry."Source Type";
                                                                WHTTrans."Source No" := GLEntry."Source No.";

                                                                Clear(VATEntry);
                                                                VATEntry.SetRange("Document Type", GLEntry."Document Type");
                                                                VATEntry.SetRange("Document No.", GLEntry."Document No.");
                                                                VATEntry.SetRange("Posting Date", GLEntry."Posting Date");
                                                                VATEntry.SetFilter(Amount, '<> %1', 0);
                                                                if VATEntry.FindSet() then begin
                                                                    VATEntry.CalcSums(Base);
                                                                    VATEntry.CalcSums(Amount);
                                                                    //WHTTrans."DPP Amount" := System.Abs(        /BWneAmount" := System.Abs(VATEntry.Base);
                                                                    WHTTrans."VAT Amount" := System.Abs(VATEntry."Additional-Currency Amount");
                                                                    WHTTrans."VAT Type" := VATEntry.Type;
                                                                    case GLEntry."Source Type" of
                                                                        GLEntry."Source Type"::Customer://Customer
                                                                            begin
                                                                                CustLedger.SetRange("Document Type", GLEntry."Document Type");
                                                                                CustLedger.SetRange("Document No.", GLEntry."Document No.");
                                                                                CustLedger.SetRange("Posting Date", GLEntry."Posting Date");
                                                                                if CustLedger.FindFirst() then
                                                                                    WHTTrans."Entry No Ledger Entry Cust" := CustLedger."Entry No.";
                                                                                //9-12-2022("No.", GLEntry."Source No.");
                                                                                if Customer.FindSet() then begin
                                                                                    WHTTrans.NPWP := Customer.NPWP;
                                                                                    WHTTrans.Nama := Customer.NamaNPWP;
                                                                                    WHTTrans."Alamat NPWP" := Customer.AlamatNPWP;
                                                                                    SalesInvHeader.SetRange("No.", GLEntry."Document No.");
                                                                                    if SalesInvHeader.FindSet() then begin
                                                                                        WHTTrans."Invoice Date" := SalesInvHeader."Document Date";
                                                                                        WHTTrans."Order No" := SalesInvHeader."Order No.";
                                                                                        WHTTrans.TAXNUMBER := SalesInvHeader.TAXNUMBER;
                                                                                    end;
                                                                                    SalesInvLine.SetRange("Document No.", GLEntry."Document No.");
                                                                                    SalesInvLine.SetRange(IsWHTCalc, false);
                                                                                    if SalesInvLine.FindSet() then begin
                                                                                        SalesInvLine.CalcSums(Amount, "Amount Including VAT");
                                                                                        ExchangeRate := Exc.GetExchangeRate(TaxSetup."Export to Currency", SalesInvHeader."Currency Code", SalesInvHeader."Posting Date");
                                                                                        WHTTrans.Amount := System.Abs(SalesInvLine."Amount Including VAT" / ExchangeRate);
                                                                                        WHTTrans."DPP Amount" := System.Abs(SalesInvLine.Amount / ExchangeRate);
                                                                                    end;
                                                                                end;
                                                                            end;
                                                                    end;
                                                                    WHTTrans."Entry No" := GLEntry."Entry No.";
                                                                    WHTTrans."External Doc No" := GLEntry."External Document No.";
                                                                    WHTTrans."Global Dimension 1" := GLEntry."Global Dimension 1 Code";
                                                                    WHTTrans."Global Dimension 2" := GLEntry."Global Dimension 2 Code";
                                                                    WHTTrans."Dimension Set ID" := GLEntry."Dimension Set ID";
                                                                    WHTTrans."Gen. Posting Type" := GLEntry."Gen. Posting Type";
                                                                    WHTTrans."Gen. Bus. Posting Group" := GLEntry."Gen. Bus. Posting Group";
                                                                    WHTTrans."Gen. Prod. Posting Group" := GLEntry."Gen. Prod. Posting Group";
                                                                    WHTTrans."VAT Bus. Posting Group" := GLEntry."VAT Bus. Posting Group";
                                                                    WHTTrans."VAT Prod. Posting Group" := GLEntry."VAT Prod. Posting Group";
                                                                    WHTTrans.Insert();

                                                                end;
                                                            end;
                                                        end;
                                                end;
                                            end;
                                        until SalesInvLine2Row.Next() = 0;
                                end;
                            until GLEntry.Next() = 0;

                    until GLAccount.Next() = 0;
            end;
    end;

    procedure UpdateSalesLineAmount(DocNo: Code[20])
    var
        SOLine: Query KreSalesLineWHT;
    begin
        SOLine.SetRange(Document_No_, DocNo);
        SOLine.SetRange(IsWHTCalc, false);
        SOLine.Open;
        while SOLine.Read do
            if SOLine.Sales_WHT_Account = '' then
                Error('Sales WHT Account %1 not found !', SOLine.WHTProductPostingGroup)
            else
                InsertSalesLine(SOLine.No_, DocNo, SOLine.Document_Type, SOLine.Sales_WHT_Account, SOLine.G_L_Account_Name, SOLine.Sum_Line_Amount, SOLine.Sum_Line_Amount_Additional_Currency, SOLine.Dimension_Set_ID,
            SOLine.Unit_of_Measure_Code, SOLine.Currency_Code, SOLine.Sell_to_Customer_No_, SOLine.Bill_to_Customer_No_, SOLine.Shipment_Date,
            SOLine.Gen__Bus__Posting_Group, SOLine.Gen__Prod__Posting_Group, SOLine.VAT_Bus__Posting_Group, SOLine.VAT_Prod__Posting_Group, SOLine.Type,
            SOLine.WHTProductPostingGroup, SOLine.WHTPercentage)
    end;

    procedure UpdatePurchaseLineAmount(DocNo: Code[20])
    var
        PLine: Query KrePurchaseLineWHT;
    begin
        PLine.SetRange(Document_No_, DocNo);
        PLine.SetRange(IsWHTCalc, false);
        PLine.SetRange(IsGrossUp, false);
        PLine.Open;
        while PLine.Read do
            if PLine.Purchase_WHT_Account = '' then
                Error('Purchase WHT Account %1 not found !', PLine.WHTProductPostingGroup)
            else
                InsertPurchaseLine(PLine.No_, DocNo, PLine.Document_Type, PLine.Purchase_WHT_Account, PLine.G_L_Account_Name, PLine.Sum_Line_Amount, PLine.Sum_Line_Amount_Additional_Currency, PLine.Dimension_Set_ID,
                 PLine.Unit_of_Measure_Code, PLine.Currency_Code, PLine.Buy_from_Vendor_No_, PLine.Pay_to_Vendor_No_, PLine.Planned_Receipt_Date,
                 PLine.Gen__Bus__Posting_Group, PLine.Gen__Prod__Posting_Group, PLine.VAT_Bus__Posting_Group, PLine.VAT_Prod__Posting_Group, PLine.Type,
                   PLine.WHTProductPostingGroup, PLine.WHTPercentage)
    end;

    procedure UpdatePurchaseLineAmountGrossUp(DocNo: Code[20])
    var
        PLine: Query KrePurchaseLineWHT;
    begin
        PLine.SetRange(Document_No_, DocNo);
        PLine.SetRange(IsWHTCalc, false);
        PLine.SetRange(IsGrossUp, true);
        PLine.Open;
        while PLine.Read do
            if PLine.Purchase_WHT_Account = '' then
                Error('Purchase WHT Account %1 not found !', PLine.WHTProductPostingGroup)
            else
                InsertPurchaseLineGrossUp(PLine.No_, DocNo, PLine.Document_Type, PLine.Purchase_WHT_Account, PLine.G_L_Account_Name, PLine.Sum_Amount, PLine.Dimension_Set_ID,
                 PLine.Unit_of_Measure_Code, PLine.Currency_Code, PLine.Buy_from_Vendor_No_, PLine.Pay_to_Vendor_No_, PLine.Planned_Receipt_Date,
                 PLine.Gen__Bus__Posting_Group, PLine.Gen__Prod__Posting_Group, PLine.VAT_Bus__Posting_Group, PLine.VAT_Prod__Posting_Group, PLine.Type,
                   PLine.WHTProductPostingGroup, PLine.WHTPercentage)
    end;

    procedure UpdateGenJourLineAmount(DocNo: Code[20])
    var
        GJLine: Query KreCashReceiptLineWHT;
    begin
        GJLine.SetRange(Document_No_, DocNo);
        GJLine.SetRange(IsWHTCalc, false);
        GJLine.Open;
        while GJLine.Read do
            if GJLine.Sales_WHT_Account = '' then
                Error('Sales WHT Account %1 not found !', GJLine.WHTProductPostingGroup)
            else
                InsertGJLine(GJLine.Account_No_, DocNo, GJLine.Document_Type, GJLine.Sales_WHT_Account, GJLine.G_L_Account_Name, GJLine.Sum_Line_Amount, GJLine.Sum_Line_Amount_Additional_Currency, GJLine.Dimension_Set_ID,
                GJLine.Source_Code, GJLine.Journal_Template_Name, GJLine.Journal_Batch_Name, GJLine.Posting_Date, GJLine.Account_Type, GJLine.Currency_Code,
                  GJLine.WHTProductPostingGroup, GJLine.WHTPercentage)
    end;

    procedure UpdateGenJourLineAmountRetrieve(DocNo: Code[20];
                Journal_Template_Name: Code[10];
                Journal_Batch_Name: Code[10];
                Source_Code: Code[10];
                PSI_No: Code[20])
    var
        SInvLine: Query KreCashReceiptLineWHTRetrieve;
        SInvHeader: Record "Sales Invoice Header";
        Exchange: Codeunit ExchangeRateIDR;
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.FindFirst();
        SInvHeader.Get(PSI_No);
        SInvLine.SetRange(Document_No_, PSI_No);
        SInvLine.Open;
        while SInvLine.Read do
            InsertGJLineRerieve(DocNo, SInvLine.Sales_WHT_Account, SInvLine.G_L_Account_Name, SInvLine.Sum_Line_Amount, SInvLine.Dimension_Set_ID,
            SInvLine.Posting_Date, SInvHeader."Currency Code", SInvLine.WHTProductPostingGroup, SInvLine.WHTPercentage, Journal_Template_Name, Journal_Batch_Name, Source_Code, SInvHeader."Currency Factor")
    end;

    local procedure GetLastSNoLine(DocNo: Code[20]): Integer
    var
        SOLine: Record "Sales Line";
    begin
        SOLine.SetRange("Document No.", DocNo);
        SOLine.FindLast();
        exit(SOLine."Line No." + 10000);
    end;

    local procedure GetLastPNoLine(DocNo: Code[20]): Integer
    var
        PLine: Record "purchase Line";
    begin
        PLine.SetRange("Document No.", DocNo);
        PLine.FindLast();
        exit(PLine."Line No." + 10000);
    end;

    local procedure GetLastGJNoLine(DocNo: Code[20]; Journal_Template_Name: Code[10]; Source_Code: Code[10]; Journal_Batch_Name: Code[10]): Integer
    var
        GJLine: Record "Gen. Journal Line";
    begin
        GJLine.SetRange("Document No.", DocNo);
        GJLine.SetRange("Journal Template Name", Journal_Template_Name);
        GJLine.SetRange("Source Code", Source_Code);
        GJLine.SetRange("Journal Batch Name", Journal_Batch_Name);
        GJLine.FindLast();
        exit(GJLine."Line No." + 10000);
    end;

    local procedure InsertSalesLine(No: Code[20]; DocNo: Code[20]; DocType: Enum "Sales Document Type"; GLNo: Code[20];
                                                                                GLName: Text[100];
                                                                                SumLineAmount: Decimal;
                                                                                  SumLineAmount_Add_Cur: Decimal;
                                                                                DimSetID: Integer;
                                                                                Unitcode: Code[10];
                                                                                Currency_Code: Code[10];
                                                                                Sell_to_Customer_No_: Code[20];
                                                                                Bill_to_Customer_No_: Code[20];
                                                                                Shipment_Date: Date;
                                                                                Gen__Bus__Posting_Group: Code[20];
                                                                                Gen__Prod__Posting_Group: Code[20];
                                                                                VAT_Bus__Posting_Group: Code[20];
                                                                                VAT_Prod__Posting_Group: Code[20]; Type: Enum "Sales Line Type";
                                                                                    WHTProductPostingGroup: Code[25];
                                                                                    WHTPercentage: Decimal)
    var
        SOLine: Record "Sales Line";
        ShortcutDimCode: array[8] of Code[8];
        GLAccount: Record "G/L Account";
        Item: Record Item;
        Description: Text[100];
    begin
        case Type of
            Type::"G/L Account":
                if GLAccount.Get(No) then
                    Description := GLAccount.Name;

            Type::Item:
                if Item.Get(No) then
                    Description := Item.Description;
        end;
        Dim.GetShortcutDimensions(DimSetID, ShortcutDimCode);
        SOLine.Init();
        SOLine."Document Type" := DocType;
        SOLine."Document No." := DocNo;
        SOLine.Description := StrSubstNo('%1 - %2', GLName, Description);
        SOLine."Line No." := GetLastSNoLine(DocNo);
        SOLine.Type := SOLine.Type::"G/L Account";
        SOLine."Line Amount" := SumLineAmount * -1;
        SOLine."Unit Price" := SumLineAmount * -1;
        SOLine.Amount := SumLineAmount * -1;
        SOLine."Amount Including VAT" := SumLineAmount * -1;
        SOLine."VAT Base Amount" := SumLineAmount * -1;
        SOLine."Dimension Set ID" := DimSetID;
        SOLine."Shortcut Dimension 1 Code" := ShortcutDimCode[1];
        SOLine."Shortcut Dimension 2 Code" := ShortcutDimCode[2];
        SOLine."No." := GLNo;
        SOLine.Quantity := 1;
        if DocType = SOLine."Document Type"::"Credit Memo" then begin
            SOLine."Qty. to Ship" := 0;
            SOLine."Return Qty. to Receive" := 1;
        end else begin
            SOLine."Qty. to Ship" := 1;
            SOLine."Return Qty. to Receive" := 0;
        end;
        SOLine."Qty. to Invoice" := 1;
        SOLine."Unit of Measure Code" := Unitcode;
        SOLine."Unit Price" := SumLineAmount * -1;
        SOLine."Currency Code" := Currency_Code;
        SOLine."Sell-to Customer No." := Sell_to_Customer_No_;
        SOLine."Bill-to Customer No." := Bill_to_Customer_No_;
        SOLine."Shipment Date" := Shipment_Date;
        SOLine."Gen. Bus. Posting Group" := Gen__Bus__Posting_Group;
        SOLine."Gen. Prod. Posting Group" := Gen__Prod__Posting_Group;
        SOLine."VAT Bus. Posting Group" := VAT_Bus__Posting_Group;
        SOLine."VAT Prod. Posting Group" := VAT_Prod__Posting_Group;
        SOLine.WHTProductPostingGroup := WHTProductPostingGroup;
        SOLine.WHTPercentage := WHTPercentage;
        SOLine.WHTAmount := SumLineAmount;
        SOLine."WHTAmount Additional Currency" := SumLineAmount_Add_Cur;
        SOLine.IsWHTCalc := true;
        SOLine.Insert();
    end;

    local procedure InsertPurchaseLine(No: Code[20]; DocNo: Code[20]; DocType: Enum "Purchase Document Type"; GLNo: Code[20];
                                                                                   GLName: Text[100];
                                                                                   SumLineAmount: Decimal;
                                                                                    SumLineAmount_Add_Cur: Decimal;
                                                                                   DimSetID: Integer;
                                                                                   Unitcode: Code[10];
                                                                                   Currency_Code: Code[10];
                                                                                   Buy_from_Vendor_No_: Code[20];
                                                                                   Pay_to_Vendor_No_: Code[20];
                                                                                   Planned_Receipt_Date: Date;
                                                                                   Gen__Bus__Posting_Group: Code[20];
                                                                                   Gen__Prod__Posting_Group: Code[20];
                                                                                   VAT_Bus__Posting_Group: Code[20];
                                                                                   VAT_Prod__Posting_Group: Code[20]; Type: Enum "Purchase Line Type";
                                                                                       WHTProductPostingGroup: Code[25];
                                                                                       WHTPercentage: Decimal)
    var
        PLine: Record "Purchase Line";
        ShortcutDimCode: array[8] of Code[8];
        GLAccount: Record "G/L Account";
        Item: Record Item;
        Description: Text[100];
    begin
        case Type of
            Type::"G/L Account":
                if GLAccount.Get(No) then
                    Description := GLAccount.Name;

            Type::Item:
                if Item.Get(No) then
                    Description := Item.Description;
        end;
        PLine.Init();
        PLine."Document Type" := DocType;
        PLine."Document No." := DocNo;
        PLine.Description := StrSubstNo('%1 - %2', GLName, Description);
        PLine."Line No." := GetLastPNoLine(DocNo);
        PLine.Type := PLine.Type::"G/L Account";
        PLine."Line Amount" := SumLineAmount * -1;
        PLine."Direct Unit Cost" := SumLineAmount * -1;
        PLine.Amount := SumLineAmount * -1;
        PLine."Amount Including VAT" := SumLineAmount * -1;
        PLine."VAT Base Amount" := SumLineAmount * -1;
        PLine."Dimension Set ID" := DimSetID;
        PLine."Shortcut Dimension 1 Code" := ShortcutDimCode[1];
        PLine."Shortcut Dimension 2 Code" := ShortcutDimCode[2];
        PLine."No." := GLNo;
        PLine.Quantity := 1;
        if DocType = PLine."Document Type"::"Credit Memo" then begin
            PLine."Qty. to Receive" := 0;
            PLine."Return Qty. to Ship" := 1;
        end else begin
            PLine."Qty. to Receive" := 1;
            PLine."Return Qty. to Ship" := 0;
        end;
        PLine."Qty. to Invoice" := 1;
        PLine."Unit of Measure Code" := Unitcode;
        PLine."Unit Cost" := SumLineAmount * -1;
        PLine."Currency Code" := Currency_Code;
        PLine."Buy-from Vendor No." := Buy_from_Vendor_No_;
        PLine."Pay-to Vendor No." := Pay_to_Vendor_No_;
        PLine."Planned Receipt Date" := Planned_Receipt_Date;
        PLine."Gen. Bus. Posting Group" := Gen__Bus__Posting_Group;
        PLine."Gen. Prod. Posting Group" := Gen__Prod__Posting_Group;
        PLine."VAT Bus. Posting Group" := VAT_Bus__Posting_Group;
        PLine."VAT Prod. Posting Group" := VAT_Prod__Posting_Group;
        PLine.WHTProductPostingGroup := WHTProductPostingGroup;
        PLine.WHTPercentage := WHTPercentage;
        PLine.WHTAmount := SumLineAmount;
        PLine."WHTAmount Additional Currency" := SumLineAmount_Add_Cur;
        PLine.IsWHTCalc := true;
        PLine.Insert();
    end;

    local procedure InsertPurchaseLineGrossUp(No: Code[20]; DocNo: Code[20]; DocType: Enum "Purchase Document Type"; GLNo: Code[20];
                                                                                          GLName: Text[100];
                                                                                          SumLineAmount: Decimal;
                                                                                          DimSetID: Integer;
                                                                                          Unitcode: Code[10];
                                                                                          Currency_Code: Code[10];
                                                                                          Buy_from_Vendor_No_: Code[20];
                                                                                          Pay_to_Vendor_No_: Code[20];
                                                                                          Planned_Receipt_Date: Date;
                                                                                          Gen__Bus__Posting_Group: Code[20];
                                                                                          Gen__Prod__Posting_Group: Code[20];
                                                                                          VAT_Bus__Posting_Group: Code[20];
                                                                                          VAT_Prod__Posting_Group: Code[20]; Type: Enum "Purchase Line Type";
                                                                                              WHTProductPostingGroup: Code[25];
                                                                                              WHTPercentage: Decimal)
    var
        PLine: Record "Purchase Line";
        ShortcutDimCode: array[8] of Code[8];
        WHTGross: Decimal;
        GLAccount: Record "G/L Account";
        Item: Record Item;
        Description: Text[100];
    begin
        WHTGross := (SumLineAmount / ((100 - WHTPercentage) / 100)) - SumLineAmount;
        case Type of
            Type::"G/L Account":
                if GLAccount.Get(No) then
                    Description := GLAccount.Name;

            Type::Item:
                if Item.Get(No) then
                    Description := Item.Description;
        end;
        PLine.Init();
        PLine."Document Type" := DocType;
        PLine."Document No." := DocNo;
        PLine.Description := StrSubstNo('%1 - %2', GLName, Description);
        PLine."Line No." := GetLastPNoLine(DocNo);
        PLine.Type := PLine.Type::"G/L Account";
        PLine."Line Amount" := WHTGross * -1;
        PLine."Direct Unit Cost" := WHTGross * -1;
        PLine.Amount := WHTGross * -1;
        PLine."Amount Including VAT" := WHTGross * -1;
        PLine."VAT Base Amount" := WHTGross * -1;
        PLine."Dimension Set ID" := DimSetID;
        PLine."Shortcut Dimension 1 Code" := ShortcutDimCode[1];
        PLine."Shortcut Dimension 2 Code" := ShortcutDimCode[2];
        PLine."No." := GLNo;
        PLine.Quantity := 1;
        if DocType = PLine."Document Type"::"Credit Memo" then begin
            PLine."Qty. to Receive" := 0;
            PLine."Return Qty. to Ship" := 1;
        end else begin
            PLine."Qty. to Receive" := 1;
            PLine."Return Qty. to Ship" := 0;
        end;
        PLine."Qty. to Invoice" := 1;
        PLine."Unit of Measure Code" := Unitcode;
        PLine."Unit Cost" := WHTGross * -1;
        PLine."Currency Code" := Currency_Code;
        PLine."Buy-from Vendor No." := Buy_from_Vendor_No_;
        PLine."Pay-to Vendor No." := Pay_to_Vendor_No_;
        PLine."Planned Receipt Date" := Planned_Receipt_Date;
        PLine."Gen. Bus. Posting Group" := Gen__Bus__Posting_Group;
        PLine."Gen. Prod. Posting Group" := Gen__Prod__Posting_Group;
        PLine."VAT Bus. Posting Group" := VAT_Bus__Posting_Group;
        PLine."VAT Prod. Posting Group" := VAT_Prod__Posting_Group;
        PLine.WHTProductPostingGroup := WHTProductPostingGroup;
        PLine.WHTPercentage := WHTPercentage;
        PLine.WHTAmount := WHTGross;
        PLine.IsWHTCalc := true;
        PLine.Insert();
    end;

    local procedure InsertGJLine(Account_No: Code[20]; DocNo: Code[20]; DocType: Enum "Gen. Journal Document Type"; GLNo: Code[20];
                                                                                     GLName: Text[100];
                                                                                     SumLineAmount: Decimal;
                                                                                     SumLineAmount_Add_Cur: Decimal;
                                                                                     DimSetID: Integer;
                                                                                     Source_Code: Code[10];
                                                                                     Journal_Template_Name: Code[10];
                                                                                     Journal_Batch_Name: Code[10];
                                                                                     Posting_Date: Date;
                                                                                     Account_Type: Enum "Gen. Journal Account Type";
                                                                                     Currency_Code: Code[10];
                                                                                     WHTProductPostingGroup: Code[25];
                                                                                     WHTPercentage: Decimal)
    var
        GJLine: Record "Gen. Journal Line";
        ShortcutDimCode: array[8] of Code[8];
        GLAccount: Record "G/L Account";
        Vendor: Record Vendor;
        Customer: Record Customer;
        Description: Text[100];
    begin
        case Account_Type of
            Account_Type::"G/L Account":
                if GLAccount.Get(Account_No) then
                    Description := GLAccount.Name;
            Account_Type::Vendor:
                if Vendor.Get(Account_No) then
                    Description := Vendor.Name;
            Account_Type::Customer:
                if Customer.Get(Account_No) then
                    Description := Customer.Name;
        end;
        GJLine.Init();
        GJLine."Posting Date" := Posting_Date;
        GJLine."Document Type" := GJLine."Document Type"::Payment;
        GJLine."Document No." := DocNo;
        GJLine.Description := StrSubstNo('%1 - %2', GLName, Description);
        GJLine."Line No." := GetLastGJNoLine(DocNo, Journal_Template_Name, Source_Code, Journal_Batch_Name);
        GJLine."Account Type" := GJLine."Account Type"::"G/L Account";
        GJLine."Amount" := Abs(SumLineAmount);
        GJLine."Amount (LCY)" := Abs(SumLineAmount);
        GJLine."Dimension Set ID" := DimSetID;
        GJLine."Shortcut Dimension 1 Code" := ShortcutDimCode[1];
        GJLine."Shortcut Dimension 2 Code" := ShortcutDimCode[2];
        GJLine."Account No." := GLNo;
        GJLine."Journal Template Name" := Journal_Template_Name;
        GJLine."Source Code" := Source_Code;
        GJLine."Journal Batch Name" := Journal_Batch_Name;
        GJLine."Currency Code" := Currency_Code;
        GJLine.Quantity := 1;
        GJLine.WHTProductPostingGroup := WHTProductPostingGroup;
        GJLine.WHTPercentage := WHTPercentage;
        GJLine.WHTAmount := SumLineAmount;
        GJLine."WHTAmount Additional Currency" := SumLineAmount_Add_Cur;
        GJLine.IsWHTCalc := true;
        GJLine.Insert();
    end;

    local procedure InsertGJLineRerieve(DocNo: Code[20]; GLNo: Code[20]; GLName: Text[100]; SumLineAmount: Decimal; DimSetID: Integer; Posting_Date: Date; Currency_Code: Code[10];
     WHTProductPostingGroup: Code[25]; WHTPercentage: Decimal; Journal_Template_Name: Code[10]; Journal_Batch_Name: Code[10]; Source_Code: Code[10]; Currency_Factor: Decimal)
    var
        GJLine: Record "Gen. Journal Line";
        ShortcutDimCode: array[8] of Code[8];
        GLAccount: Record "G/L Account";
        Vendor: Record Vendor;
        Customer: Record Customer;
        Description: Text[100];
        DocType: Enum "Gen. Journal Document Type";
        Account_Type: Enum "Gen. Journal Account Type";
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.FindFirst();
        case Account_Type of
            Account_Type::"G/L Account":
                if GLAccount.Get(GLNo) then
                    Description := GLAccount.Name;
        end;
        GJLine.Init();
        GJLine."Account Type" := GJLine."Account Type"::"G/L Account";
        GJLine."Posting Date" := Posting_Date;
        GJLine."Document Type" := GJLine."Document Type"::Payment;
        GJLine."Document No." := DocNo;
        GJLine.Description := StrSubstNo('%1 - %2', GLName, Description);
        GJLine."Line No." := GetLastGJNoLine(DocNo, Journal_Template_Name, Source_Code, Journal_Batch_Name);
        GJLine."Account Type" := GJLine."Account Type"::"G/L Account";
        GJLine."Amount" := Abs(SumLineAmount);

        if GLSetup."LCY Code" <> Currency_Code then
            GJLine."Amount (LCY)" := Abs(SumLineAmount) / Currency_Factor
        else
            GJLine."Amount (LCY)" := Abs(SumLineAmount);

        GJLine."Dimension Set ID" := DimSetID;
        GJLine."Shortcut Dimension 1 Code" := ShortcutDimCode[1];
        GJLine."Shortcut Dimension 2 Code" := ShortcutDimCode[2];
        GJLine."Account No." := GLNo;
        GJLine."Journal Template Name" := Journal_Template_Name;
        GJLine."Source Code" := Source_Code;
        GJLine."Journal Batch Name" := Journal_Batch_Name;
        GJLine."Currency Code" := Currency_Code;
        GJLine."Currency Factor" := Currency_Factor;
        GJLine.Quantity := 1;
        GJLine.WHTProductPostingGroup := WHTProductPostingGroup;
        GJLine.WHTPercentage := WHTPercentage;
        GJLine.WHTAmount := Abs(SumLineAmount);
        GJLine.IsWHTCalc := true;
        GJLine.Insert();
    end;

    procedure GetNPWP(ID: Integer)
    var
        WHT: Record KreWHTTrans;
    begin
        WHT.SetRange("Source Type", ID);
        WHT.FindSet();
        repeat
            if ID = 1 then
                GetNPWPCustomer(WHT.ID)
            else
                GetNPWPVendor(WHT.ID);
        until WHT.Next() = 0;
    end;

    procedure GetNPWPCustomer(ID: Integer)
    var
        WHT: Record KreWHTTrans;
        Cust: Record Customer;
    begin
        WHT.SetRange(ID, ID);
        if WHT.FindSet() then begin
            Cust.SetRange("No.", WHT."Source No");
            Cust.FindSet();
            WHT.NPWP := Cust.NPWP;
            WHT."Alamat NPWP" := Cust.AlamatNPWP;
            WHT.Nama := Cust.NamaNPWP;
            WHT.Modify();
        end;
    end;

    procedure GetNPWPVendor(ID: Integer)
    var
        WHT: Record KreWHTTrans;
        Vend: Record Vendor;
    begin
        WHT.SetRange(ID, ID);
        if WHT.FindSet() then begin
            Vend.SetRange("No.", WHT."Source No");
            if Vend.FindFirst() then begin
                WHT.NPWP := Vend.NPWP;
                WHT."Alamat NPWP" := Vend.AlamatNPWP;
                WHT.Nama := Vend.NamaNPWP;
                WHT.Modify();
            end
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order Subform", 'OnAfterNoOnAfterValidate', '', false, false)]
    local procedure HandledCustomerWHTPO(sender: Page "Purchase Order Subform";

    var
        PurchaseLine: Record "Purchase Line";

    var
        xPurchaseLine: Record "Purchase Line")
    begin
        PH.Reset();
        Vendor.Reset();
        Kre_MasterPPh.Reset();
        if PH.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") then
            if Vendor.Get(PH."Buy-from Vendor No.") then
                if Vendor.ISPPH = true then
                    if Vendor.ISNPWP = true then
                        if Kre_MasterPPh.Get(Vendor.WHTProductPostingGroup) then begin
                            PurchaseLine.WHTProductPostingGroup := Vendor.WHTProductPostingGroup;
                            PurchaseLine.WHTPercentage := Kre_MasterPPh.Percentage;
                            sender.Update();
                        end else begin
                            if Kre_MasterPPh.Get(Vendor.WHTProductPostingGroup) then begin
                                PurchaseLine.WHTProductPostingGroup := Vendor.WHTProductPostingGroup;
                                PurchaseLine.WHTPercentage := Kre_MasterPPh."Percentage Up";
                                sender.Update();
                            end;
                        end;
        // if PurchaseLine."Gross Up" = false then begin
        //     if Kre_MasterPPh.Get(PurchaseLine.WHTProductPostingGroup) then begin
        //         PurchaseLine.WHTPercentage := Kre_MasterPPh.Percentage;
        //         PurchaseLine.WHTAmount := (PurchaseLine.WHTPercentage / 100) * PurchaseLine."Line Amount";
        //     end;
        // end else begin
        //     if Kre_MasterPPh.Get(PurchaseLine.WHTProductPostingGroup) then begin
        //         PurchaseLine.WHTPercentage := Kre_MasterPPh."Percentage Up";
        //         PurchaseLine.WHTAmount := (PurchaseLine.WHTPercentage / 100) * PurchaseLine."Line Amount";
        //     end;
        // end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purch. Invoice Subform", 'OnAfterNoOnAfterValidate', '', false, false)]
    local procedure HandledCustomerWHTPI(sender: Page "Purch. Invoice Subform";

    var
        PurchaseLine: Record "Purchase Line";

    var
        xPurchaseLine: Record "Purchase Line")
    begin
        PH.Reset();
        Vendor.Reset();
        Kre_MasterPPh.Reset();
        if PH.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") then
            if Vendor.Get(PH."Buy-from Vendor No.") then
                if Vendor.ISPPH = true then
                    if Vendor.ISNPWP = true then
                        if Kre_MasterPPh.Get(Vendor.WHTProductPostingGroup) then begin
                            PurchaseLine.WHTProductPostingGroup := Vendor.WHTProductPostingGroup;
                            PurchaseLine.WHTPercentage := Kre_MasterPPh.Percentage;
                            sender.Update();
                        end else begin
                            if Kre_MasterPPh.Get(Vendor.WHTProductPostingGroup) then begin
                                PurchaseLine.WHTProductPostingGroup := Vendor.WHTProductPostingGroup;
                                PurchaseLine.WHTPercentage := Kre_MasterPPh."Percentage Up";
                                sender.Update();
                            end;
                        end;
        // if PurchaseLine."Gross Up" = false then begin
        //     if Kre_MasterPPh.Get(PurchaseLine.WHTProductPostingGroup) then begin
        //         PurchaseLine.WHTPercentage := Kre_MasterPPh.Percentage;
        //         PurchaseLine.WHTAmount := (PurchaseLine.WHTPercentage / 100) * PurchaseLine."Line Amount";
        //     end;
        // end else begin
        //     if Kre_MasterPPh.Get(PurchaseLine.WHTProductPostingGroup) then begin
        //         PurchaseLine.WHTPercentage := Kre_MasterPPh."Percentage Up";
        //         PurchaseLine.WHTAmount := (PurchaseLine.WHTPercentage / 100) * PurchaseLine."Line Amount";
        //     end;
        // end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purch. Cr. Memo Subform", 'OnAfterNoOnAfterValidate', '', false, false)]
    local procedure HandledCustomerWHTPCM(sender: Page "Purch. Cr. Memo Subform";

    var
        PurchaseLine: Record "Purchase Line";

    var
        xPurchaseLine: Record "Purchase Line")
    begin
        PH.Reset();
        Vendor.Reset();
        Kre_MasterPPh.Reset();
        if PH.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") then
            if Vendor.Get(PH."Buy-from Vendor No.") then
                if Vendor.ISPPH = true then
                    if Vendor.ISNPWP = true then
                        if Kre_MasterPPh.Get(Vendor.WHTProductPostingGroup) then begin
                            PurchaseLine.WHTProductPostingGroup := Vendor.WHTProductPostingGroup;
                            PurchaseLine.WHTPercentage := Kre_MasterPPh.Percentage;
                            sender.Update();
                        end else begin
                            if Kre_MasterPPh.Get(Vendor.WHTProductPostingGroup) then begin
                                PurchaseLine.WHTProductPostingGroup := Vendor.WHTProductPostingGroup;
                                PurchaseLine.WHTPercentage := Kre_MasterPPh."Percentage Up";
                                sender.Update();
                            end;
                        end;
        // if PurchaseLine."Gross Up" = false then begin
        //     if Kre_MasterPPh.Get(PurchaseLine.WHTProductPostingGroup) then begin
        //         PurchaseLine.WHTPercentage := Kre_MasterPPh.Percentage;
        //         PurchaseLine.WHTAmount := (PurchaseLine.WHTPercentage / 100) * PurchaseLine."Line Amount";
        //     end;
        // end else begin
        //     if Kre_MasterPPh.Get(PurchaseLine.WHTProductPostingGroup) then begin
        //         PurchaseLine.WHTPercentage := Kre_MasterPPh."Percentage Up";
        //         PurchaseLine.WHTAmount := (PurchaseLine.WHTPercentage / 100) * PurchaseLine."Line Amount";
        //     end;
        // end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order Subform", 'OnAfterNoOnAfterValidate', '', false, false)]
    local procedure HandledCustomerWHTSO(sender: Page "Sales Order Subform";

    var
        SalesLine: Record "Sales Line";
        xSalesLine: Record "Sales Line")
    begin
        SH.Reset();
        Customer.Reset();
        Kre_MasterPPh.Reset();
        if SH.Get(SalesLine."Document Type", SalesLine."Document No.") then
            if Customer.Get(SH."Sell-to Customer No.") then
                if Customer.ISPPH = true then
                    if Customer.ISNPWP = true then
                        if Kre_MasterPPh.Get(Customer.WHTProductPostingGroup) then begin
                            SalesLine.WHTProductPostingGroup := Customer.WHTProductPostingGroup;
                            SalesLine.WHTPercentage := Kre_MasterPPh."Percentage";
                            sender.Update();
                        end else begin
                            if Kre_MasterPPh.Get(Customer.WHTProductPostingGroup) then begin
                                SalesLine.WHTProductPostingGroup := Customer.WHTProductPostingGroup;
                                SalesLine.WHTPercentage := Kre_MasterPPh."Percentage Up";
                                sender.Update();
                            end;
                        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice Subform", 'OnAfterNoOnAfterValidate', '', false, false)]
    local procedure HandledCustomerWHTSI(sender: Page "Sales Invoice Subform";

    var
        SalesLine: Record "Sales Line";
        xSalesLine: Record "Sales Line")
    begin
        SH.Reset();
        Customer.Reset();
        Kre_MasterPPh.Reset();
        if SH.Get(SalesLine."Document Type", SalesLine."Document No.") then
            if Customer.Get(SH."Sell-to Customer No.") then
                if Customer.ISPPH = true then
                    if Customer.ISNPWP = true then
                        if Kre_MasterPPh.Get(Customer.WHTProductPostingGroup) then begin
                            SalesLine.WHTProductPostingGroup := Customer.WHTProductPostingGroup;
                            SalesLine.WHTPercentage := Kre_MasterPPh."Percentage";
                            sender.Update();
                        end else begin
                            if Kre_MasterPPh.Get(Customer.WHTProductPostingGroup) then begin
                                SalesLine.WHTProductPostingGroup := Customer.WHTProductPostingGroup;
                                SalesLine.WHTPercentage := Kre_MasterPPh."Percentage Up";
                                sender.Update();
                            end;
                        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Cr. Memo Subform", 'OnAfterNoOnAfterValidate', '', false, false)]
    local procedure HandledCustomerWHTSCM(sender: Page "Sales Cr. Memo Subform";

    var
        SalesLine: Record "Sales Line";
        xSalesLine: Record "Sales Line")
    begin
        SH.Reset();
        Customer.Reset();
        Kre_MasterPPh.Reset();
        if SH.Get(SalesLine."Document Type", SalesLine."Document No.") then
            if Customer.Get(SH."Sell-to Customer No.") then
                if Customer.ISPPH = true then
                    if Customer.ISNPWP = true then
                        if Kre_MasterPPh.Get(Customer.WHTProductPostingGroup) then begin
                            SalesLine.WHTProductPostingGroup := Customer.WHTProductPostingGroup;
                            SalesLine.WHTPercentage := Kre_MasterPPh."Percentage";
                            sender.Update();
                        end else begin
                            if Kre_MasterPPh.Get(Customer.WHTProductPostingGroup) then begin
                                SalesLine.WHTProductPostingGroup := Customer.WHTProductPostingGroup;
                                SalesLine.WHTPercentage := Kre_MasterPPh."Percentage Up";
                                sender.Update();
                            end;
                        end;
    end;

    procedure InsertTaxExcemptionWHT(var PurchHeader: Record "Purchase Header")
    var
        WHTTrans: Record KreWHTTrans;
        PurchLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        PurchLine.SetRange("Is TaxExemption", true);
        if PurchLine.FindSet() then
            repeat
                WHTTrans.SetFilter("Document No", '= %1', PurchLine."Document No.");
                WHTTrans.SetFilter("Entry No", '= %1', PurchLine."Line No.");
                if not WHTTrans.FindSet() then begin
                    clear(WHTTrans);
                    WHTTrans.Init();
                    WHTTrans."Posting Date" := PurchHeader."Posting Date";
                    WHTTrans."Bukti Potong Date" := PurchHeader."Posting Date";
                    WHTTrans."Source Code" := 'PURCHASES';
                    WHTTrans."Document Type" := PurchLine."Document Type";
                    //WHTTrans."Document No" := PurchLine."Document No.";
                    WHTTrans."Pre-Assigned No." := PurchLine."Document No.";
                    WHTTrans.WHTProductPostingGroup := PurchLine.WHTProductPostingGroup;
                    WHTTrans.WHTPercentage := PurchLine.WHTPercentage;
                    WHTTrans.WHTAmount := PurchLine.WHTAmount;
                    WHTTrans."G/L Account No" := PurchLine."No.";
                    WHTTrans."G/L Account Name" := PurchLine.Description;
                    WHTTrans.Description := PurchLine.Description;
                    WHTTrans.Quantity := PurchLine.Quantity;
                    WHTTrans."Source Type" := WHTTrans."Source Type"::Vendor;
                    WHTTrans."Source No" := PurchHeader."Buy-from Vendor No.";
                    WHTTrans.Amount := System.Abs(PurchLine.Amount);
                    WHTTrans."DPP Amount" := System.Abs(PurchLine."Line Amount");
                    WHTTrans."VAT Amount" := System.Abs(PurchLine."VAT Base Amount");
                    WHTTrans."VAT Type" := WHTTrans."VAT Type"::Purchase;
                    if Vendor.Get(PurchHeader."Buy-from Vendor No.") then begin
                        WHTTrans.NPWP := Vendor.NPWP;
                        WHTTrans.Nama := Vendor.NamaNPWP;
                        WHTTrans."Alamat NPWP" := Vendor.AlamatNPWP;
                    end;
                    WHTTrans."Invoice Date" := PurchHeader."Document Date";
                    WHTTrans."Order No" := PurchHeader."No.";
                    WHTTrans.TAXNUMBER := PurchHeader.TAXNUMBER;
                    WHTTrans."Entry No" := PurchLine."Line No.";
                    //WHTTrans."External Doc No" := PurchHeader."External Document No.";
                    WHTTrans."Global Dimension 1" := PurchHeader."Shortcut Dimension 1 Code";
                    WHTTrans."Global Dimension 2" := PurchHeader."Shortcut Dimension 2 Code";
                    WHTTrans."Dimension Set ID" := PurchHeader."Dimension Set ID";
                    WHTTrans."Gen. Posting Type" := WHTTrans."Gen. Posting Type"::Purchase;
                    WHTTrans."Gen. Bus. Posting Group" := PurchHeader."Gen. Bus. Posting Group";
                    WHTTrans."Gen. Prod. Posting Group" := PurchLine."Gen. Prod. Posting Group";
                    WHTTrans."VAT Bus. Posting Group" := PurchHeader."VAT Bus. Posting Group";
                    WHTTrans."VAT Prod. Posting Group" := PurchLine."VAT Prod. Posting Group";
                    WHTTrans.Insert();
                end;
            until PurchLine.Next() = 0;
    end;

    procedure InsertTaxExcemptionWHTPostedPI(var PurchHeader: Record "Purch. Inv. Header")
    var
        WHTTrans: Record KreWHTTrans;
        PurchLine: Record "Purch. Inv. Line";
        Vendor: Record Vendor;
    begin
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        PurchLine.SetRange("Is TaxExemption", true);
        if PurchLine.FindSet() then
            repeat
                WHTTrans.SetFilter("Document No", '= %1', PurchLine."Document No.");
                WHTTrans.SetFilter("Entry No", '= %1', PurchLine."Line No.");
                if not WHTTrans.FindSet() then begin
                    clear(WHTTrans);
                    WHTTrans.Init();
                    WHTTrans."Posting Date" := PurchHeader."Posting Date";
                    WHTTrans."Bukti Potong Date" := PurchHeader."Posting Date";
                    WHTTrans."Source Code" := 'PURCHASES';
                    //WHTTrans."Document Type" := PurchLine."Document Type";
                    //WHTTrans."Document No" := PurchLine."Document No.";
                    WHTTrans."Pre-Assigned No." := PurchLine."Document No.";
                    WHTTrans.WHTProductPostingGroup := PurchLine.WHTProductPostingGroup;
                    WHTTrans.WHTPercentage := PurchLine.WHTPercentage;
                    WHTTrans.WHTAmount := PurchLine.WHTAmount;
                    WHTTrans."G/L Account No" := PurchLine."No.";
                    WHTTrans."G/L Account Name" := PurchLine.Description;
                    WHTTrans.Description := PurchLine.Description;
                    WHTTrans.Quantity := PurchLine.Quantity;
                    WHTTrans."Source Type" := WHTTrans."Source Type"::Vendor;
                    WHTTrans."Source No" := PurchHeader."Buy-from Vendor No.";
                    WHTTrans.Amount := System.Abs(PurchLine.Amount);
                    WHTTrans."DPP Amount" := System.Abs(PurchLine."Line Amount");
                    WHTTrans."VAT Amount" := System.Abs(PurchLine."VAT Base Amount");
                    WHTTrans."VAT Type" := WHTTrans."VAT Type"::Purchase;
                    if Vendor.Get(PurchHeader."Buy-from Vendor No.") then begin
                        WHTTrans.NPWP := Vendor.NPWP;
                        WHTTrans.Nama := Vendor.NamaNPWP;
                        WHTTrans."Alamat NPWP" := Vendor.AlamatNPWP;
                    end;
                    WHTTrans."Invoice Date" := PurchHeader."Document Date";
                    WHTTrans."Order No" := PurchHeader."No.";
                    WHTTrans.TAXNUMBER := PurchHeader.TAXNUMBER;
                    WHTTrans."Entry No" := PurchLine."Line No.";
                    //WHTTrans."External Doc No" := PurchHeader."External Document No.";
                    WHTTrans."Global Dimension 1" := PurchHeader."Shortcut Dimension 1 Code";
                    WHTTrans."Global Dimension 2" := PurchHeader."Shortcut Dimension 2 Code";
                    WHTTrans."Dimension Set ID" := PurchHeader."Dimension Set ID";
                    WHTTrans."Gen. Posting Type" := WHTTrans."Gen. Posting Type"::Purchase;
                    WHTTrans."Gen. Bus. Posting Group" := PurchHeader."Gen. Bus. Posting Group";
                    WHTTrans."Gen. Prod. Posting Group" := PurchLine."Gen. Prod. Posting Group";
                    WHTTrans."VAT Bus. Posting Group" := PurchHeader."VAT Bus. Posting Group";
                    WHTTrans."VAT Prod. Posting Group" := PurchLine."VAT Prod. Posting Group";
                    WHTTrans.Insert();
                end;
            until PurchLine.Next() = 0;
    end;

    procedure InsertTaxExcemptionWHTPostedCrmMm(var PurchHeader: Record "Purch. Cr. Memo Hdr.")
    var
        WHTTrans: Record KreWHTTrans;
        PurchLine: Record "Purch. Cr. Memo Line";
        Vendor: Record Vendor;
    begin
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        PurchLine.SetRange("Is TaxExemption", true);
        if PurchLine.FindSet() then
            repeat
                WHTTrans.SetFilter("Document No", '= %1', PurchLine."Document No.");
                WHTTrans.SetFilter("Entry No", '= %1', PurchLine."Line No.");
                if not WHTTrans.FindSet() then begin
                    clear(WHTTrans);
                    WHTTrans.Init();
                    WHTTrans."Posting Date" := PurchHeader."Posting Date";
                    WHTTrans."Bukti Potong Date" := PurchHeader."Posting Date";
                    WHTTrans."Source Code" := 'PURCHASES';
                    //WHTTrans."Document Type" := PurchLine."Document Type";
                    //WHTTrans."Document No" := PurchLine."Document No.";
                    WHTTrans."Pre-Assigned No." := PurchLine."Document No.";
                    WHTTrans.WHTProductPostingGroup := PurchLine.WHTProductPostingGroup;
                    WHTTrans.WHTPercentage := PurchLine.WHTPercentage;
                    WHTTrans.WHTAmount := PurchLine.WHTAmount;
                    WHTTrans."G/L Account No" := PurchLine."No.";
                    WHTTrans."G/L Account Name" := PurchLine.Description;
                    WHTTrans.Description := PurchLine.Description;
                    WHTTrans.Quantity := PurchLine.Quantity;
                    WHTTrans."Source Type" := WHTTrans."Source Type"::Vendor;
                    WHTTrans."Source No" := PurchHeader."Buy-from Vendor No.";
                    WHTTrans.Amount := System.Abs(PurchLine.Amount);
                    WHTTrans."DPP Amount" := System.Abs(PurchLine."Line Amount");
                    WHTTrans."VAT Amount" := System.Abs(PurchLine."VAT Base Amount");
                    WHTTrans."VAT Type" := WHTTrans."VAT Type"::Purchase;
                    if Vendor.Get(PurchHeader."Buy-from Vendor No.") then begin
                        WHTTrans.NPWP := Vendor.NPWP;
                        WHTTrans.Nama := Vendor.NamaNPWP;
                        WHTTrans."Alamat NPWP" := Vendor.AlamatNPWP;
                    end;
                    WHTTrans."Invoice Date" := PurchHeader."Document Date";
                    WHTTrans."Order No" := PurchHeader."No.";
                    WHTTrans.TAXNUMBER := PurchHeader.TAXNUMBER;
                    WHTTrans."Entry No" := PurchLine."Line No.";
                    //WHTTrans."External Doc No" := PurchHeader."External Document No.";
                    WHTTrans."Global Dimension 1" := PurchHeader."Shortcut Dimension 1 Code";
                    WHTTrans."Global Dimension 2" := PurchHeader."Shortcut Dimension 2 Code";
                    WHTTrans."Dimension Set ID" := PurchHeader."Dimension Set ID";
                    WHTTrans."Gen. Posting Type" := WHTTrans."Gen. Posting Type"::Purchase;
                    WHTTrans."Gen. Bus. Posting Group" := PurchHeader."Gen. Bus. Posting Group";
                    WHTTrans."Gen. Prod. Posting Group" := PurchLine."Gen. Prod. Posting Group";
                    WHTTrans."VAT Bus. Posting Group" := PurchHeader."VAT Bus. Posting Group";
                    WHTTrans."VAT Prod. Posting Group" := PurchLine."VAT Prod. Posting Group";
                    WHTTrans.Insert();
                end;
            until PurchLine.Next() = 0;
    end;

    // procedure InsertTaxExcemptionWHTGrossUp(var PurchHeader: Record "Purchase Header")
    // var
    //     WHTTrans: Record KreWHTTrans;
    //     PurchLine: Record "Purchase Line";
    //     Vendor: Record Vendor;
    // begin
    //     PurchLine.SetRange("Document No.", PurchHeader."No.");
    //     PurchLine.SetRange("Is TaxExemption", true);
    //     if PurchLine.FindSet() then
    //         repeat
    //             WHTTrans.SetFilter("Document No", '= %1', PurchLine."Document No.");
    //             WHTTrans.SetFilter("Entry No", '= %1', PurchLine."Line No.");
    //             if not WHTTrans.FindSet() then begin
    //                 clear(WHTTrans);
    //                 WHTTrans.Init();
    //                 WHTTrans."Posting Date" := PurchHeader."Posting Date";
    //                 WHTTrans."Bukti Potong Date" := PurchHeader."Posting Date";
    //                 WHTTrans."Source Code" := 'PURCHASES';
    //                 WHTTrans."Document Type" := PurchLine."Document Type";
    //                 //WHTTrans."Document No" := PurchLine."Document No.";
    //                 WHTTrans."Pre-Assigned No." := PurchLine."Document No.";
    //                 WHTTrans.WHTProductPostingGroup := PurchLine.WHTProductPostingGroup;
    //                 WHTTrans.WHTPercentage := PurchLine.WHTPercentage;
    //                 WHTTrans.WHTAmount := PurchLine.WHTAmount;
    //                 WHTTrans."G/L Account No" := PurchLine."No.";
    //                 WHTTrans."G/L Account Name" := PurchLine.Description;
    //                 WHTTrans.Description := PurchLine.Description;
    //                 WHTTrans.Quantity := PurchLine.Quantity;
    //                 WHTTrans."Source Type" := WHTTrans."Source Type"::Vendor;
    //                 WHTTrans."Source No" := PurchHeader."Buy-from Vendor No.";
    //                 WHTTrans.Amount := System.Abs(PurchLine.Amount);
    //                 WHTTrans."DPP Amount" := System.Abs(PurchLine."Line Amount");
    //                 WHTTrans."VAT Amount" := System.Abs(PurchLine."VAT Base Amount");
    //                 WHTTrans."VAT Type" := WHTTrans."VAT Type"::Purchase;
    //                 if Vendor.Get(PurchHeader."Buy-from Vendor No.") then begin
    //                     WHTTrans.NPWP := Vendor.NPWP;
    //                     WHTTrans.Nama := Vendor.NamaNPWP;
    //                     WHTTrans."Alamat NPWP" := Vendor.AlamatNPWP;
    //                 end;
    //                 WHTTrans."Invoice Date" := PurchHeader."Document Date";
    //                 WHTTrans."Order No" := PurchHeader."No.";
    //                 WHTTrans.TAXNUMBER := PurchHeader.TAXNUMBER;
    //                 WHTTrans."Entry No" := PurchLine."Line No.";
    //                 //WHTTrans."External Doc No" := PurchHeader."External Document No.";
    //                 WHTTrans."Global Dimension 1" := PurchHeader."Shortcut Dimension 1 Code";
    //                 WHTTrans."Global Dimension 2" := PurchHeader."Shortcut Dimension 2 Code";
    //                 WHTTrans."Dimension Set ID" := PurchHeader."Dimension Set ID";
    //                 WHTTrans."Gen. Posting Type" := WHTTrans."Gen. Posting Type"::Purchase;
    //                 WHTTrans."Gen. Bus. Posting Group" := PurchHeader."Gen. Bus. Posting Group";
    //                 WHTTrans."Gen. Prod. Posting Group" := PurchLine."Gen. Prod. Posting Group";
    //                 WHTTrans."VAT Bus. Posting Group" := PurchHeader."VAT Bus. Posting Group";
    //                 WHTTrans."VAT Prod. Posting Group" := PurchLine."VAT Prod. Posting Group";
    //                 WHTTrans.Insert();
    //             end;
    //         until PurchLine.Next() = 0;
    // end;
    procedure CheckGrossUpExistInLine(DocNo: Code[20]): Boolean
    Var
        PurchLine: Record "Purchase Line";

    begin
        PurchLine.SetRange("Document No.", DocNo);
        PurchLine.SetRange("Gross Up", true);
        if PurchLine.IsEmpty() then
            exit(false) else
            exit(true);
    end;

    procedure UpdateLineNo(No: code[20])
    var
        PurchReceiptLine: Record "Purch. Rcpt. Line";
        TempPurchReceiptLine: Record "Purch. Rcpt. Line" temporary;
        NewPurchReceiptLine: Record "Purch. Rcpt. Line";
        LineNo: Integer;
    begin
        LineNo := 10000;
        PurchReceiptLine.SetRange("Document No.", No);
        if PurchReceiptLine.Findset() then
            repeat
                TempPurchReceiptLine.TransferFields(PurchReceiptLine);
                TempPurchReceiptLine."Line No." := LineNo;
                TempPurchReceiptLine.Insert(true);
                LineNo := LineNo + 10000;
                PurchReceiptLine.Delete;

            until PurchReceiptLine.Next() = 0;

        if TempPurchReceiptLine.Findset() then
            repeat
                NewPurchReceiptLine.TransferFields(TempPurchReceiptLine);
                NewPurchReceiptLine.Insert(true);
            until TempPurchReceiptLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post (Yes/No)", 'OnBeforeConfirmPost', '', false, false)]
    local procedure OnBeforeConfirmPost(var SalesHeader: Record "Sales Header"; var DefaultOption: Integer; var Result: Boolean; var IsHandled: Boolean)
    var
        TaxJour: Record KRE_TAXJOUR;
        SalesInvLine: Record "Sales Line";
    begin
        SalesInvLine.SetRange("Document No.", SalesHeader."No.");
        SalesInvLine.SetRange("Is TaxExemption", true);
        if SalesInvLine.FindFirst() then begin
            TaxJour.SetRange("Pre-Assigned No.", SalesHeader."No.");
            if TaxJour.IsEmpty then
                Error('Don''t forget to post VAT');
        end
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post (Yes/No)", 'OnBeforeConfirmPostProcedure', '', false, false)]
    local procedure OnBeforeConfirmPostProcedure(var PurchaseHeader: Record "Purchase Header"; var DefaultOption: Integer; var Result: Boolean; var IsHandled: Boolean)
    var
        WHTTrans: Record KreWHTTrans;
        PurchInvLine: Record "Purchase Line";
    begin
        PurchInvLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchInvLine.SetRange("Is TaxExemption", true);
        if PurchInvLine.FindFirst() then begin
            WHTTrans.SetRange("Pre-Assigned No.", PurchaseHeader."No.");
            if WHTTrans.IsEmpty then
                Error('Don''t forget to post WHT');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesInvHeaderInsert', '', false, false)]
    local procedure OnAfterPostSI(var SalesInvHeader: Record "Sales Invoice Header"; SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; WhseShip: Boolean; WhseReceive: Boolean; var TempWhseShptHeader: Record "Warehouse Shipment Header"; var TempWhseRcptHeader: Record "Warehouse Receipt Header"; PreviewMode: Boolean)
    var
        TaxJour: Record KRE_TAXJOUR;
    begin
        TaxJour.SetRange("Pre-Assigned No.", SalesHeader."No.");
        if TaxJour.FindSet() then begin
            TaxJour.INVOICENO := SalesInvHeader."No.";
            TaxJour.Modify();
        end
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPurchInvHeaderInsert', '', false, false)]
    local procedure OnAfterPostPI(var PurchInvHeader: Record "Purch. Inv. Header"; var PurchHeader: Record "Purchase Header"; PreviewMode: Boolean)
    var
        WHTTrans: Record KreWHTTrans;
    begin
        WHTTrans.SetRange("Pre-Assigned No.", PurchHeader."No.");
        if WHTTrans.FindSet() then begin
            WHTTrans."Document No" := PurchInvHeader."No.";
            WHTTrans.Modify();
        end
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitGLEntry', '', false, false)]
    local procedure OnAfterPostGJL(var GLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line"; Amount: Decimal; AddCurrAmount: Decimal; UseAddCurrAmount: Boolean; var CurrencyFactor: Decimal; var GLRegister: Record "G/L Register")
    begin
        GLEntry.WHTProductPostingGroup := GenJournalLine.WHTProductPostingGroup;
        GLEntry.WHTPercentage := GenJournalLine.WHTPercentage;
        GLEntry.WHTAmount := GenJournalLine.WHTAmount;
    end;

    var
        Dim: Codeunit DimensionManagement;
        SalesPost: Codeunit 80;
        PurchasePost: Codeunit 90;
        GenJourLinePost: Codeunit 12;
        PH: Record "Purchase Header";
        Vendor: Record Vendor;
        SH: Record "Sales Header";
        Customer: Record Customer;
        Kre_MasterPPh: Record Kre_MasterPPh;
}