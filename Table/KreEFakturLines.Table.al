table 60005 Kre_EFakturLines
{
    fields
    {
        field(1; ID; Integer)
        {
            AutoIncrement = true;
        }
        field(2; ID_Kre_EFaktur; Integer)
        {
            TableRelation = KRE_TAXJOUR;
        }
        field(3; Nama; Text[250])
        {
            Caption = 'Nama';
        }
        field(4; Harga_Satuan; Decimal)
        {
            Caption = 'Harga Satuan';
        }
        field(5; Jumlah_Barang; Integer)
        {
            Caption = 'Jumlah Barang';
        }
        field(6; Harga_Total; Decimal)
        {
            Caption = 'Harga Total';
        }
        field(7; Diskon; Decimal)
        {
            Caption = 'Diskon';
        }
        field(8; DPP; Decimal)
        {
            Caption = 'DPP';
        }
        field(9; PPN; Decimal)
        {
            Caption = 'PPN';
        }
        field(10; Tarif_PPNBM; Decimal)
        {
            Caption = 'Tarif PPNBM';
        }
        field(11; PPNBM; Decimal)
        {
            Caption = 'PPNBM';
        }

    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }


}