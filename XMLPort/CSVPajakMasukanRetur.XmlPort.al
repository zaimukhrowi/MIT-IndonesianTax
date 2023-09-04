xmlport 60002 CSVPajakMasukanRetur
{
    Format = VariableText;
    TextEncoding = WINDOWS;
    UseRequestPage = false;
    Direction = Export;
    TableSeparator = '<NewLine>';
    schema
    {
        textelement(PajakMasukanRetur)
        {
            tableelement(Header1; Integer)
            {
                SourceTableView = WHERE(Number = CONST(1));
                textelement(RM_Header) { }
                textelement(NPWP_Header) { }
                textelement(NAMA_Header) { }
                textelement(KD_JENIS_TRANSAKSI_Header) { }
                textelement(FG_PENGGANTI_Header) { }
                textelement(NOMOR_FAKTUR_Header) { }
                textelement(TANGGAL_FAKTUR_Header) { }
                textelement(IS_CREDITABLE_Header) { }
                textelement(NOMOR_DOKUMEN_RETUR_Header) { }
                textelement(TANGGAL_RETUR_Header) { }
                textelement(MASA_PAJAK_RETUR_Header) { }
                textelement(TAHUN_PAJAK_RETUR_Header) { }
                textelement(NILAI_RETUR_DPP_Header) { }
                textelement(NILAI_RETUR_PPN_Header) { }
                textelement(NILAI_RETUR_PPNBM_Header) { }

            }

            tableelement(TAXJOUR; KRE_TAXJOUR)
            {
                SourceTableView = where(TAX_SOURCE = filter(1), TAX_POSTED = filter(1));
                XmlName = 'KRE_TAXJOUR';
                textattribute(RM)
                {
                    trigger onbeforePassvariable();
                    begin
                        RM := format('RM');
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
                textattribute(IS_CREDITABLE)
                {
                    trigger onbeforePassvariable();
                    begin
                        IS_CREDITABLE := format(0);
                    end;
                }
                textattribute(NOMOR_DOKUMEN_RETUR)
                {
                    trigger onbeforePassvariable();
                    begin
                        NOMOR_DOKUMEN_RETUR := format(TAXJOUR.RETURN_DOC_NUMBER);
                    end;
                }
                textattribute(TANGGAL_RETUR)
                {
                    trigger onbeforePassvariable();
                    begin
                        TANGGAL_RETUR := format(TAXJOUR.RETURN_DATE, 0, '<Day,2>/<Month,2>/<Year4>');
                    end;
                }
                textattribute(MASA_PAJAK_RETUR)
                {
                    trigger onbeforePassvariable();
                    begin
                        MASA_PAJAK_RETUR := format(Date2DMY(TAXJOUR.RETURN_DATE, 2));
                    end;
                }
                textattribute(TAHUN_PAJAK_RETUR)
                {
                    trigger onbeforePassvariable();
                    begin
                        TAHUN_PAJAK_RETUR := format(Date2DMY(TAXJOUR.RETURN_DATE, 3));
                    end;
                }
                textattribute(NILAI_RETUR_DPP)
                {
                    trigger onbeforePassvariable();
                    begin
                        NILAI_RETUR_DPP := format(Round(TAXJOUR.DPPAMOUNT, AmountPrecision, VATRoundType), 0, 1);
                    end;
                }
                textattribute(NILAI_RETUR_PPN)
                {
                    trigger onbeforePassvariable();
                    begin
                        NILAI_RETUR_PPN := format(Round(TAXJOUR.VATAMOUNT, AmountPrecision, VATRoundType), 0, 1);
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
        Filename('PajakMasukanRetur_' + tgl + '.txt');
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

        RM_Header := 'RM';
        NPWP_Header := 'NPWP';
        NAMA_Header := 'NAMA';
        KD_JENIS_TRANSAKSI_Header := 'KD_JENIS_TRANSAKSI';
        FG_PENGGANTI_Header := 'FG_PENGGANTI';
        NOMOR_FAKTUR_Header := 'NOMOR_FAKTUR';
        TANGGAL_FAKTUR_Header := 'TANGGAL_FAKTUR';
        IS_CREDITABLE_Header := 'IS_CREDITABLE';
        NOMOR_DOKUMEN_RETUR_Header := 'NOMOR_DOKUMEN_RETUR';
        TANGGAL_RETUR_Header := 'TANGGAL_RETUR';
        MASA_PAJAK_RETUR_Header := 'MASA_PAJAK_RETUR';
        TAHUN_PAJAK_RETUR_Header := 'TAHUN_PAJAK_RETUR';
        NILAI_RETUR_DPP_Header := 'NILAI_RETUR_DPP';
        NILAI_RETUR_PPN_Header := 'NILAI_RETUR_PPN';
        NILAI_RETUR_PPNBM_Header := 'NILAI_RETUR_PPNBM';

    end;

    var
        VATRoundType: Text[1];
        AmountPrecision: Decimal;
}