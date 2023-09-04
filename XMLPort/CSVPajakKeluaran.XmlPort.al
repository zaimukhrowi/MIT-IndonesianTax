xmlport 60001 CSVPajakKeluaran
{
    Format = VariableText;
    TextEncoding = WINDOWS;
    UseRequestPage = false;
    Direction = Export;
    TableSeparator = '<NewLine>';
    schema
    {
        textelement(PajakKeluaran)
        {
            tableelement(Header1; Integer)
            {
                SourceTableView = WHERE(Number = CONST(1));
                textelement(FK_Header) { }
                textelement(KD_JENIS_TRANSAKSI_Header) { }
                textelement(FG_PENGGANTI_Header) { }
                textelement(NOMOR_FAKTUR_Header) { }
                textelement(MASA_PAJAK_Header) { }
                textelement(TAHUN_PAJAK_Header) { }
                textelement(TANGGAL_FAKTUR_Header) { }
                textelement(NPWP2_Header) { }
                textelement(NAMA_Header) { }
                textelement(ALAMAT_LENGKAP_Header) { }
                textelement(JUMLAH_DPP_Header) { }
                textelement(JUMLAH_PPN_Header) { }
                textelement(JUMLAH_PPNBM_Header) { }
                textelement(ID_KETERANGAN_TAMBAHAN_Header) { }
                textelement(FG_Uang_Muka_Header) { }
                textelement(Uang_Muka_DPP_Header) { }
                textelement(Uang_Muka_PPN_Header) { }
                textelement(Uang_Muka_PPNBM_Header) { }
                textelement(Referensi_Header) { }
                textelement(Keterangan_Tambahan_Header) { }
                textelement(Kode_Dokumen_Pendukung_Header) { }
            }

            tableelement(Header2; Integer)
            {
                SourceTableView = WHERE(Number = CONST(1));
                textelement(LT_Header) { }
                textelement(NPWP_Header) { }
                textelement(NAME_Header) { }
                textelement(JALAN_Header) { }
                textelement(BLOK_Header) { }
                textelement(NOMOR_Header) { }
                textelement(RT_Header) { }
                textelement(RW_Header) { }
                textelement(KECAMATAN_Header) { }
                textelement(KELURAHAN_Header) { }
                textelement(KABUPATEN_Header) { }
                textelement(PROPINSI_Header) { }
                textelement(KODE_POS_Header) { }
                textelement(NOMOR_TELEPON_Header) { }
            }

            tableelement(Header3; Integer)
            {
                SourceTableView = WHERE(Number = CONST(1));
                textelement(OF_Header) { }
                textelement(KODE_OBJEK_Header) { }
                textelement(NAMA2_Header) { }
                textelement(HARGA_SATUAN_Header) { }
                textelement(JUMLAH_BARANG_Header) { }
                textelement(HARGA_TOTAL_Header) { }
                textelement(DISKON_Header) { }
                textelement(DPP_Header) { }
                textelement(PPN_Header) { }
                textelement(TARIF_PPNBM_Header) { }
                textelement(PPNPBM_Header) { }
            }

            tableelement(TAXJOUR; KRE_TAXJOUR)
            {
                SourceTableView = where(TAX_SOURCE = filter(2), TAX_POSTED = filter(1));
                XmlName = 'KRE_TAXJOUR';

                textelement(FK)
                {
                    trigger onbeforePassvariable();
                    var
                    begin
                        FK := format('FK');
                    end;
                }
                textelement(KD_JENIS_TRANSAKSI)
                {
                    trigger onbeforePassvariable();
                    begin
                        KD_JENIS_TRANSAKSI := format(PADSTR(TAXJOUR.TAXNUMBER, 2));
                    end;
                }
                textelement(FG_PENGGANTI)
                {
                    trigger onbeforePassvariable();
                    begin
                        FG_PENGGANTI := format(DELSTR(PADSTR(TAXJOUR.TAXNUMBER, 3), 1, 2));
                    end;
                }
                textelement(NOMOR_FAKTUR)
                {
                    trigger onbeforePassvariable();
                    begin
                        NOMOR_FAKTUR := format(DELCHR(DELSTR(TAXJOUR.TAXNUMBER, 1, 4), '=', '.-'));
                    end;
                }

                textelement(MASA_PAJAK)
                {
                    trigger onbeforePassvariable();
                    begin
                        MASA_PAJAK := format(Date2DMY(TAXJOUR.TAXDATE, 2));
                    end;
                }
                textelement(TAHUN_PAJAK)
                {
                    trigger onbeforePassvariable();
                    begin
                        TAHUN_PAJAK := format(Date2DMY(TAXJOUR.TAXDATE, 3));
                    end;
                }
                textelement(TANGGAL_FAKTUR)
                {
                    trigger onbeforePassvariable();
                    begin
                        TANGGAL_FAKTUR := format(TAXJOUR.TAXDATE, 0, '<Day,2>/<Month,2>/<Year4>');
                    end;
                }
                textelement(NPWP2)
                {
                    trigger onbeforePassvariable();
                    begin
                        NPWP2 := format(TAXJOUR.NPWP);
                    end;
                }

                textelement(NAMA2)
                {
                    trigger onbeforePassvariable();
                    begin
                        NAMA2 := format(TAXJOUR.NAMA);
                    end;
                }

                textelement(ALAMAT_LENGKAP)
                {
                    trigger onbeforePassvariable();
                    begin
                        ALAMAT_LENGKAP := format(TAXJOUR.ALAMATNPWP);
                    end;
                }

                textelement(JUMLAH_DPP)
                {
                    trigger onbeforePassvariable();
                    begin
                        JUMLAH_DPP := format(Round(TAXJOUR.DPPAMOUNT, AmountPrecision, VATRoundType), 0, 1);
                    end;
                }
                textelement(JUMLAH_PPN)
                {
                    trigger onbeforePassvariable();
                    begin
                        JUMLAH_PPN := format(Round(TAXJOUR.VATAMOUNT, AmountPrecision, VATRoundType), 0, 1);
                    end;
                }
                textelement(JUMLAH_PPNBM)
                {
                    trigger onbeforePassvariable();
                    begin
                        JUMLAH_PPNBM := format(0);
                    end;
                }
                textelement(ID_KETERANGAN_TAMBAHAN)
                {
                    trigger onbeforePassvariable();
                    begin
                        ID_KETERANGAN_TAMBAHAN := format('');
                    end;
                }
                textelement(FG_Uang_Muka)
                {
                    trigger onbeforePassvariable();
                    begin
                        FG_Uang_Muka := format(0);
                    end;
                }
                textelement(Uang_Muka_DPP)
                {
                    trigger onbeforePassvariable();
                    begin
                        Uang_Muka_DPP := format(0);
                    end;
                }
                textelement(Uang_muka_PPN)
                {
                    trigger onbeforePassvariable();
                    begin
                        Uang_muka_PPN := format(0);
                    end;
                }
                textelement(Uang_muka_PPNBM)
                {
                    trigger onbeforePassvariable();
                    begin
                        Uang_muka_PPNBM := format(0);
                    end;
                }
                textelement(Referensi)
                {
                    trigger onbeforePassvariable();
                    begin
                        Referensi := format(TAXJOUR.INVOICENO);
                    end;
                }
                // textelement(Notes)
                // {
                //     trigger onbeforePassvariable();
                //     begin
                //         Notes := TAXJOUR.Notes;
                //     end;
                // }
                textelement(Keterangan_Tambahan)
                {
                    trigger onbeforePassvariable();
                    begin
                        Keterangan_Tambahan := TAXJOUR."Keterangan Tambahan";
                    end;
                }
                textelement(Kode_Dokumen_Pendukung)
                {
                    trigger onbeforePassvariable();
                    begin
                        Kode_Dokumen_Pendukung := format(TAXJOUR.Kode_Dokumen_Pendukung);
                    end;
                }
                tableelement(Dummy; Integer)
                {
                    SourceTableView = WHERE(Number = CONST(1));
                }
                tableelement(Company; "Company Information")
                {
                    XmlName = 'Company';
                    textelement(FAPR)
                    {
                        trigger onbeforePassvariable();
                        begin
                            FAPR := format('FAPR');
                        end;
                    }
                    textelement(COMPANY_NAME)
                    {
                        trigger onbeforePassvariable();
                        begin
                            COMPANY_NAME := format(Company.Name);
                        end;
                    }
                    textelement(ALAMAT)
                    {
                        trigger onbeforePassvariable();
                        begin
                            ALAMAT := format(Company.Address);
                        end;
                    }
                    textelement(USER)
                    {
                        trigger onbeforePassvariable();
                        begin
                            USER := format(Setup.User_EFaktur);
                        end;
                    }
                    textelement(CITY)
                    {
                        trigger onbeforePassvariable();
                        begin
                            CITY := format(Company.City);
                        end;
                    }
                    textelement(TS)
                    {
                        trigger onbeforePassvariable();
                        begin
                            TS := format(Company."Created DateTime", 0, '<Year4><Month,2><Day,2><Hours24,2><Minutes,2><Seconds,2>');

                        end;
                    }
                    textelement(Comma_dummy)
                    {
                        trigger onbeforePassvariable()
                        begin
                            FieldDelimiter('');
                        end;
                    }
                }
                tableelement(Customer; Customer)
                {
                    XmlName = 'Customer';
                    LinkTable = TAXJOUR;
                    LinkFields = "No." = FIELD(ACCOUNTID), ISPKP = filter(true);

                    textelement(LT)
                    {
                        trigger onbeforePassvariable();
                        begin
                            LT := format('LT');
                            FieldDelimiter('"');
                        end;
                    }
                    textelement(NPWP)
                    {
                        trigger onbeforePassvariable();
                        begin
                            NPWP := format(TAXJOUR.NPWP);
                        end;
                    }
                    textelement(NAME)
                    {
                        trigger onbeforePassvariable();
                        begin
                            NAME := format(TAXJOUR.NAMA);
                        end;
                    }
                    textelement(JALAN)
                    {
                        trigger onbeforePassvariable();
                        begin
                            JALAN := format(TAXJOUR.AlamatNPWP);
                        end;
                    }
                    textelement(BLOK)
                    {
                        trigger onbeforePassvariable();
                        begin
                            BLOK := format('-');
                        end;
                    }
                    textelement(NOMOR)
                    {
                        trigger onbeforePassvariable();
                        begin
                            NOMOR := format('-');
                        end;
                    }
                    textelement(RT)
                    {
                        trigger onbeforePassvariable();
                        begin
                            RT := format('-');
                        end;
                    }
                    textelement(RW)
                    {
                        trigger onbeforePassvariable();
                        begin
                            RW := format('-');
                        end;
                    }
                    textelement(KECAMATAN)
                    {
                        trigger onbeforePassvariable();
                        begin
                            KECAMATAN := format('-');
                        end;
                    }
                    textelement(KELURAHAN)
                    {
                        trigger onbeforePassvariable();
                        begin
                            KELURAHAN := format('-');
                        end;
                    }
                    textelement(KABUPATEN)
                    {
                        trigger onbeforePassvariable();
                        begin
                            KABUPATEN := format('-');
                        end;
                    }
                    textelement(PROPINSI)
                    {
                        trigger onbeforePassvariable();
                        begin
                            PROPINSI := format('-');
                        end;
                    }
                    textelement(KODE_POS)
                    {
                        trigger onbeforePassvariable();
                        begin
                            KODE_POS := format('-');
                        end;
                    }
                    textelement(NOMOR_TELEPON)
                    {
                        trigger onbeforePassvariable();
                        begin
                            NOMOR_TELEPON := format('-');
                        end;
                    }

                }
                tableelement(KRE_TAXJOURLINES; KRE_TAXJOURLINES)
                {
                    XmlName = 'KRE_TAXJOURLINES';
                    LinkTable = TAXJOUR;
                    LinkFields = KRE_TAXJOURID = FIELD(ID);
                    textelement(O)
                    {
                        trigger onbeforePassvariable();
                        begin
                            O := format('OF');
                        end;
                    }
                    textelement(KODE_OBJEK)
                    {
                        trigger onbeforePassvariable();
                        begin
                            KODE_OBJEK := format(KRE_TAXJOURLINES.ITEMID);
                        end;
                    }
                    textelement(NAMA)
                    {
                        trigger onbeforePassvariable();
                        begin
                            NAMA := format(KRE_TAXJOURLINES.DESCRIPTION);
                        end;
                    }
                    textelement(HARGA_SATUAN)
                    {
                        trigger onbeforePassvariable();
                        begin
                            HARGA_SATUAN := format(Round(KRE_TAXJOURLINES.PRICE, AmountPrecision, VATRoundType), 0, 1);
                        end;
                    }
                    textelement(JUMLAH_BARANG)
                    {
                        trigger onbeforePassvariable();
                        begin
                            JUMLAH_BARANG := format(KRE_TAXJOURLINES.QTY);
                        end;
                    }
                    textelement(HARGA_TOTAL)
                    {
                        trigger onbeforePassvariable();
                        begin
                            HARGA_TOTAL := format(Round(KRE_TAXJOURLINES.TOTAL_AMOUNT, AmountPrecision, VATRoundType), 0, 1);
                        end;
                    }

                    textelement(DISKON)
                    {
                        trigger onbeforePassvariable();
                        begin
                            DISKON := format(Round(KRE_TAXJOURLINES.DISCOUNT_AMOUNT, AmountPrecision, VATRoundType), 0, 1);
                        end;
                    }
                    textelement(DPP)
                    {
                        trigger onbeforePassvariable();
                        begin
                            DPP := format(Round(KRE_TAXJOURLINES.DPP_AMOUNT, AmountPrecision, VATRoundType), 0, 1);
                        end;
                    }
                    textelement(PPN)
                    {
                        trigger onbeforePassvariable();
                        begin
                            PPN := format(Round(KRE_TAXJOURLINES.VAT_AMOUNT, AmountPrecision, VATRoundType), 0, 1);
                        end;
                    }
                    textelement(TARIF_PPNBM)
                    {
                        trigger onbeforePassvariable();
                        begin
                            TARIF_PPNBM := format(0);
                        end;
                    }
                    textelement(PPNBM)
                    {
                        trigger onbeforePassvariable();
                        begin
                            PPNBM := format(0);
                        end;
                    }

                }

            }
        }
    }

    trigger OnPreXmlPort();
    var
        tgl: Text[11];
    begin
        tgl := format(Today(), 0, '<Day,2><Month,2><Year4>');
        Filename('PajakKeluaran_' + tgl + '.txt');
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
        Setup.FindFirst();

        FK_Header := 'FK';
        KD_JENIS_TRANSAKSI_Header := 'KD_JENIS_TRANSAKSI';
        FG_PENGGANTI_Header := 'FG_PENGGANTI';
        NOMOR_FAKTUR_Header := 'NOMOR_FAKTUR';
        MASA_PAJAK_Header := 'MASA_PAJAK';
        TAHUN_PAJAK_Header := 'TAHUN_PAJAK';
        TANGGAL_FAKTUR_Header := 'TANGGAL_FAKTUR';
        NPWP2_Header := 'NPWP';
        NAMA_Header := 'NAMA';
        ALAMAT_LENGKAP_Header := 'ALAMAT_LENGKAP';
        JUMLAH_DPP_Header := 'JUMLAH_DPP';
        JUMLAH_PPN_Header := 'JUMLAH_PPN';
        JUMLAH_PPNBM_Header := 'JUMLAH_PPNBM';
        ID_KETERANGAN_TAMBAHAN_Header := 'ID_KETERANGAN_TAMBAHAN';
        FG_Uang_Muka_Header := 'FG_UANG_MUKA';
        Uang_Muka_DPP_Header := 'UANG_MUKA_DPP';
        Uang_Muka_PPN_Header := 'UANG_MUKA_PPN';
        Uang_Muka_PPNBM_Header := 'UANG_MUKA_PPNBM';
        Referensi_Header := 'REFERENSI';
        // Notes_Header := 'NOTES';
        Keterangan_Tambahan_Header := 'KETERANGAN_TAMBAHAN';
        Kode_Dokumen_Pendukung_Header := 'KODE_DOKUMEN_PENDUKUNG';

        LT_Header := 'LT';
        NPWP_Header := 'NPWP';
        NAME_Header := 'NAMA';
        JALAN_Header := 'JALAN';
        BLOK_Header := 'BLOK';
        NOMOR_Header := 'NOMOR';
        RT_Header := 'RT';
        RW_Header := 'RW';
        KECAMATAN_Header := 'KECAMATAN';
        KELURAHAN_Header := 'KELURAHAN';
        KABUPATEN_Header := 'KABUPATEN';
        PROPINSI_Header := 'PROPINSI';
        KODE_POS_Header := 'KODE_POS';
        NOMOR_TELEPON_Header := 'NOMOR_TELEPON';

        OF_Header := 'OF';
        KODE_OBJEK_Header := 'KODE_OBJEK';
        NAMA2_Header := 'NAMA';
        HARGA_SATUAN_Header := 'HARGA_SATUAN';
        JUMLAH_BARANG_Header := 'JUMLAH_BARANG';
        HARGA_TOTAL_Header := 'HARGA_TOTAL';
        DISKON_Header := 'DISKON';
        DPP_Header := 'DPP';
        PPN_Header := 'PPN';
        TARIF_PPNBM_Header := 'TARIF_PPNBM';
        PPNPBM_Header := 'PPNBM';
    end;

    var
        Setup: Record Kre_TaxSetup;
        VATRoundType: Text[1];
        AmountPrecision: Decimal;
}