xmlport 60003 CSVPajakKeluaranRetur
{
    Format = VariableText;
    TextEncoding = WINDOWS;
    UseRequestPage = false;
    Direction = Export;
    TableSeparator = '<NewLine>';
    schema
    {
        textelement(PajakKeluaranRetur)
        {
            tableelement(Header1; Integer)
            {
                SourceTableView = WHERE(Number = CONST(1));
                textelement(RK_Header) { }
                textelement(NPWP2_Header) { }
                textelement(NAMA_Header) { }
                textelement(KD_JENIS_TRANSAKSI_Header) { }
                textelement(FG_PENGGANTI_Header) { }
                textelement(NOMOR_FAKTUR_Header) { }
                textelement(TANGGAL_FAKTUR_Header) { }
                textelement(NOMOR_DOC_RETUR_Header) { }
                // textelement(Notes_Header) { }
                textelement(Keterangan_Tambahan_Header) { }
                textelement(Kode_Dokumen_Pendukung_Header) { }
                textelement(TANGGAL_RETUR_Header) { }
                textelement(MASA_PAJAK_RETUR_Header) { }
                textelement(TAHUN_PAJAK_RETUR_Header) { }
                textelement(NILAI_RETUR_DPP_Header) { }
                textelement(NILAI_RETUR_PPN_Header) { }
                textelement(NILAI_RETUR_PPNBM_Header) { }

            }
            tableelement(TAXJOUR; KRE_TAXJOUR)
            {
                SourceTableView = where(TAX_SOURCE = filter(2), TAX_POSTED = filter(1));
                XmlName = 'KRE_TAXJOUR';
                textattribute(RK)
                {
                    trigger onbeforePassvariable();
                    var
                    begin
                        RK := format('RK');
                    end;
                }

                fieldattribute(NPWP; TAXJOUR.NPWP) { }

                fieldattribute(NAMA; TAXJOUR.NAMA) { }
                textattribute(KD_JENIS_TRANSAKSI)
                {
                    trigger onbeforePassvariable();
                    begin
                        KD_JENIS_TRANSAKSI := format(PADSTR(TAXJOUR.RETURN_TAX_NUMBER, 2));
                    end;
                }
                textattribute(FG_PENGGANTI)
                {
                    trigger onbeforePassvariable();
                    begin
                        FG_PENGGANTI := format(DELSTR(PADSTR(TAXJOUR.RETURN_TAX_NUMBER, 3), 1, 2));
                    end;
                }
                textattribute(NOMOR_FAKTUR)
                {
                    trigger onbeforePassvariable();
                    begin
                        NOMOR_FAKTUR := format(DELCHR(DELSTR(TAXJOUR.RETURN_TAX_NUMBER, 1, 4), '=', '.-'));
                    end;
                }
                textattribute(TANGGAL_FAKTUR)
                {
                    trigger onbeforePassvariable();
                    begin
                        TANGGAL_FAKTUR := format(TAXJOUR.RETURN_DATE, 0, '<Day,2>/<Month,2>/<Year4>');
                    end;
                }
                textattribute(NO_DOKUMEN_RETUR)
                {
                    trigger onbeforePassvariable();
                    begin
                        NO_DOKUMEN_RETUR := format(TAXJOUR.RETURN_DOC_NUMBER);
                    end;
                }
                // textattribute(Notes)
                // {
                //     trigger onbeforePassvariable();
                //     begin
                //         Notes := TAXJOUR.Notes;
                //     end;
                // }
                textattribute(Keterangan_Tambahan)
                {
                    trigger onbeforePassvariable();
                    begin
                        Keterangan_Tambahan := TAXJOUR."Keterangan Tambahan";
                    end;
                }
                textattribute(Kode_Dokumen_Pendukung)
                {
                    trigger onbeforePassvariable();
                    begin
                        Kode_Dokumen_Pendukung := TAXJOUR.Kode_Dokumen_Pendukung;
                    end;
                }
                textattribute(TANGGAL_RETUR)
                {
                    trigger onbeforePassvariable();
                    begin
                        TANGGAL_RETUR := format(TAXJOUR.INVOICEDATE, 0, '<Day,2>/<Month,2>/<Year4>');
                    end;
                }
                textattribute(MASA_PAJAK_RETUR)
                {
                    trigger onbeforePassvariable();
                    begin
                        MASA_PAJAK_RETUR := format(Date2DMY(TAXJOUR.INVOICEDATE, 2));
                    end;
                }
                textattribute(TAHUN_PAJAK_RETUR)
                {
                    trigger onbeforePassvariable();
                    begin
                        TAHUN_PAJAK_RETUR := format(Date2DMY(TAXJOUR.INVOICEDATE, 3));
                    end;
                }

                textattribute(NILAI_RETUR_DPP)
                {
                    trigger onbeforePassvariable();
                    begin
                        NILAI_RETUR_DPP := format(round(TAXJOUR.DPPAMOUNT, AmountPrecision, VATRoundType), 0, 1);
                    end;
                }
                textattribute(NILAI_RETUR_PPN)
                {
                    trigger onbeforePassvariable();
                    begin
                        NILAI_RETUR_PPN := format(round(TAXJOUR.VATAMOUNT, AmountPrecision, VATRoundType), 0, 1);
                    end;
                }
                textattribute(NILAI_RETUR_PPNBM)
                {
                    trigger onbeforePassvariable();
                    begin
                        NILAI_RETUR_PPNBM := format(0);
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
        Filename('PajakKeluaranRetur_' + tgl + '.txt');
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

        RK_Header := 'RK';
        NPWP2_Header := 'NPWP';
        NAMA_Header := 'NAMA';
        KD_JENIS_TRANSAKSI_Header := 'KD_JENIS_TRANSAKSI';
        FG_PENGGANTI_Header := 'FG_PENGGANTI';
        NOMOR_FAKTUR_Header := 'NOMOR_FAKTUR';
        TANGGAL_FAKTUR_Header := 'TANGGAL_FAKTUR';
        NOMOR_DOC_RETUR_Header := 'NOMOR_DOKUMEN_RETUR';
        // Notes_Header := 'NOTES';
        Keterangan_Tambahan_Header := 'KETERANGAN_TAMBAHAN';
        Kode_Dokumen_Pendukung_Header := 'DOKUMEN_PENDUKUNG';
        TANGGAL_RETUR_Header := 'TANGGAL_RETUR';
        MASA_PAJAK_RETUR_Header := 'MASA_PAJAK_RETUR';
        TAHUN_PAJAK_RETUR_Header := 'TAHUN_PAJAK_RETUR';
        NILAI_RETUR_DPP_Header := ' NILAI_RETUR_DPP';
        NILAI_RETUR_PPN_Header := ' NILAI_RETUR_PPN';
        NILAI_RETUR_PPNBM_Header := ' NILAI_RETUR_PPNBM';

    end;

    var
        VATRoundType: Text[1];
        AmountPrecision: Decimal;
}