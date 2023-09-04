xmlport 60004 CSVPajakMasukanEFaktur
{
    Format = VariableText;
    TextEncoding = WINDOWS;
    UseRequestPage = false;
    Direction = Export;
    TableSeparator = '<NewLine>';

    schema
    {
        textelement(PajakMasukan)
        {
            tableelement(Header; Integer)
            {
                SourceTableView = WHERE(Number = CONST(1));
                textelement(FM_Header) { }
                textelement(KD_JENIS_TRANSAKSI_Header) { }
                textelement(FG_PENGGANTI_Header) { }
                textelement(NOMOR_FAKTUR_Header) { }
                textelement(MASA_PAJAK_Header) { }
                textelement(TAHUN_PAJAK_Header) { }
                textelement(TANGGAL_FAKTUR_Header) { }
                textelement(NPWP_Header) { }
                textelement(NAMA_Header) { }
                textelement(ALAMAT_LENGKAP_Header) { }
                textelement(JUMLAH_DPP_Header) { }
                textelement(JUMLAH_PPN_Header) { }
                textelement(JUMLAH_PPNBM_Header) { }
                textelement(IS_CREDITABLE_Header) { }
            }

            tableelement(EFaktur; Kre_EFaktur)
            {
                // SourceTableView = where (TAX_SOURCE = filter (= 1), TAX_POSTED = filter (= 1));

                XmlName = 'TAX';
                textelement(FM)
                {
                    trigger onbeforePassvariable();
                    begin
                        FM := format('FM');
                    end;
                }
                textelement(KD_JENIS_TRANSAKSI)
                {
                    trigger onbeforePassvariable();
                    begin
                        KD_JENIS_TRANSAKSI := EFaktur.KD_Jenis_Transaksi;
                    end;
                }
                textelement(FG_PENGGANTI)
                {
                    trigger onbeforePassvariable();
                    begin
                        FG_PENGGANTI := EFaktur.FG_Pengganti;
                    end;
                }

                textelement(NOMOR_FAKTUR)
                {
                    trigger onbeforePassvariable();
                    begin
                        NOMOR_FAKTUR := EFaktur.No_Faktur;
                    end;
                }
                textelement(MASA_PAJAK)
                {
                    trigger onbeforePassvariable();
                    begin
                        MASA_PAJAK := format(Date2DMY(EFaktur.Tanggal_Faktur, 2));
                    end;
                }
                textelement(TAHUN_PAJAK)
                {
                    trigger onbeforePassvariable();
                    begin
                        TAHUN_PAJAK := format(Date2DMY(EFaktur.Tanggal_Faktur, 3));
                    end;
                }
                textelement(TANGGAL_FAKTUR)
                {
                    trigger onbeforePassvariable();
                    begin
                        TANGGAL_FAKTUR := format(EFaktur.Tanggal_Faktur, 0, '<Day,2>/<Month,2>/<Year4>');
                    end;
                }

                fieldelement(NPWP; EFaktur.NPWP_Penjual) { }

                fieldelement(NAMA; EFaktur.Nama_Penjual) { }

                fieldelement(ALAMAT_LENGKAP; EFaktur.Alamat_Penjual) { }

                textelement(JUMLAH_DPP)
                {
                    trigger onbeforePassvariable();
                    begin
                        JUMLAH_DPP := format(round(EFaktur.Jumlah_DPP, AmountPrecision, VATRoundType), 0, 1);
                    end;
                }
                textelement(JUMLAH_PPN)
                {
                    trigger onbeforePassvariable();
                    begin
                        JUMLAH_PPN := format(round(EFaktur.Jumlah_PPN, AmountPrecision, VATRoundType), 0, 1);
                    end;
                }
                textelement(JUMLAH_PPNBM)
                {
                    trigger onbeforePassvariable();
                    begin
                        JUMLAH_PPNBM := format(round(EFaktur.Jumlah_PPNBM, AmountPrecision, VATRoundType), 0, 1);
                    end;
                }

                textelement(IS_CREDITABLE)
                {
                    trigger onbeforePassvariable();
                    begin
                        IS_CREDITABLE := format(1);
                    end;
                }
            }
        }
    }

    trigger OnPreXmlPort();
    var
        tgl: Text[11];
    begin
        tgl := format(Today(), 0, '<Day,2><Month,2><Year4>');
        Filename('PajakMasukan_' + tgl + '.txt');
    end;

    trigger OnInitXmlPort();
    var
        TaxSetup: Record Kre_TaxSetup;
        pajakcode: Codeunit PajakCode;
    // place: Text[5];
    // presc: Decimal;

    begin
        TaxSetup.FindFirst();
        VATRoundType := pajakcode.SetRoundType(TaxSetup."VAT Rounding Type");
        // place := GenLedgerSetup."Amount Decimal Places";
        // Evaluate(presc, PadStr(place, 1));
        AmountPrecision := TaxSetup."Amount Decimal Places";

        FM_Header := 'FM';
        KD_JENIS_TRANSAKSI_Header := 'KD_JENIS_TRANSAKSI';
        FG_PENGGANTI_Header := 'FG_PENGGANTI';
        NOMOR_FAKTUR_Header := 'NOMOR_FAKTUR';
        MASA_PAJAK_Header := 'MASA_PAJAK';
        TAHUN_PAJAK_Header := 'TAHUN_PAJAK';
        TANGGAL_FAKTUR_Header := 'TANGGAL_FAKTUR';
        NPWP_Header := 'NPWP';
        NAMA_Header := 'NAMA';
        ALAMAT_LENGKAP_Header := 'ALAMAT_LENGKAP';
        JUMLAH_DPP_Header := 'JUMLAH_DPP';
        JUMLAH_PPN_Header := 'JUMLAH_PPN';
        JUMLAH_PPNBM_Header := 'JUMLAH_PPNBM';
        IS_CREDITABLE_Header := 'IS_CREDITABLE';
    end;

    var
        VATRoundType: Text[1];
        AmountPrecision: Decimal;
}

