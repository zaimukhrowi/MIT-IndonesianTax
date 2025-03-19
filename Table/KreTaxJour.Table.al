table 60002 KRE_TAXJOUR
{
    Permissions = tabledata 254 = RIMD;
    fields
    {
        field(1; ID; Integer)
        {
            AutoIncrement = true;
            Caption = 'ID';
        }
        field(2; TAXNUMBER; Code[19])
        {
            Caption = 'TAX NUMBER';
        }
        field(3; TAXDATE; Date)
        {
            Caption = 'TAX DATE';
        }
        field(4; INVOICENO; Text[50])
        {
            Caption = 'DOCUMENT NO';
        }
        field(5; INVOICEDATE; Date)
        {
            Caption = 'INVOICE DATE';
        }
        field(6; DOCUMENTNO; Text[50])
        {
            Caption = 'INVOICE NO';
        }
        field(7; ACCOUNTID; Text[50])
        {
            Caption = 'ACCOUNT NO';
        }
        field(8; NPWP; Text[16])
        {
            Caption = 'NPWP';
        }
        field(9; NAMA; Text[250])
        {
            Caption = 'NAMA';
        }
        field(10; ALAMATNPWP; Text[500])
        {
            Caption = 'ALAMAT NPWP';
        }
        field(11; CURRENCY; Text[3])
        {
            Caption = 'CURRENCY';
        }
        field(12; DPPAMOUNT; Decimal)
        {
            Caption = 'DPP AMOUNT';
        }
        field(13; VATAMOUNT; Decimal)
        {
            Caption = 'VAT AMOUNT';
        }
        field(14; INVOICEAMOUNT; Decimal)
        {
            Caption = 'INVOICE AMOUNT';
        }
        field(15; IS_CREDITABLE; Integer)
        {
            Caption = 'IS CREDITABLE';
        }
        field(16; TAX_SOURCE; Enum TAX_SOURCE)
        {
            Caption = 'TAX SOURCE';
        }
        field(17; IS_RETURNITEM; Enum YESNO)
        {
            Caption = 'IS RETURN ITEM';
        }
        field(18; RETURN_TAX_NUMBER; Text[19])
        {
            Caption = 'RETURN TAX NUMBER';
        }
        field(19; RETURN_DOC_NUMBER; Text[50])
        {
            Caption = 'RETURN DOC NUMBER';
        }
        field(20; RETURN_DATE; Date)
        {
            Caption = 'RETURN DATE';
        }
        field(21; TAX_POSTED; Enum YESNO)
        {
            Caption = 'TAX POSTED';
        }
        field(22; TAX_EXPORTED; Enum YESNO)
        {
            Caption = 'TAX EXPORTED';
        }
        field(23; "VAT Bus. Posting Group"; Text[20])
        {
            Caption = 'VAT Bus. Posting Group';
        }
        field(24; "VAT Prod. Posting Group"; Text[20])
        {
            Caption = 'VAT Prod. Posting Group';
        }
        field(25; "VAT Calculation Type"; Option)
        {
            Caption = 'VAT Calculation Type';
            OptionMembers = "Normal VAT","Reverse Charge VAT","Full VAT","Sales Tax";
        }
        field(26; FG_Pengganti; Enum YESNO)
        {
            Caption = 'FG Pengganti';
        }
        field(27; Kode_Dokumen_Pendukung; Code[20])
        {
            Caption = 'Kode Dokumen Pendukung';
        }
        field(28; TAX_Cancelled; Enum YESNO)
        {
            Caption = 'Tax Cancelled';
        }
        field(29; "Pre-Assigned No."; Code[20])
        {
            Caption = 'Pre-Assigned No.';
        }
        field(30; Notes; Text[250])
        {
            Caption = 'Notes';
        }
        field(31; "Keterangan Tambahan"; Text[250])
        {
            Caption = 'Keterangan Tambahan';
        }
        field(32; "Kode Transaksi"; Text[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'TRANSACTION CODE';
        }
        field(33; "Location Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'LOCATION CODE';
        }
        field(34; "Jenis ID Pembeli"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = TIN,"National ID",Passport,"Other ID";
            OptionCaption = 'TIN,National ID,Passport,Other ID';
            Caption = 'Jenis ID Pembeli';
        }
        field(35; "ID TKU Pembeli"; Text[22])
        {
            DataClassification = ToBeClassified;
            Caption = 'ID TKU Pembeli';
        }
        field(36; "Ship-to Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Ship-to Code';
        }


    }
    keys
    {
        key(PrimaryKey; ID)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        TAXJOURLINES: Record KRE_TAXJOURLINES;
        VATEntry2: Record "VAT Entry";
        VATEntry: Record KRE_VATEntryTaxJour;
    begin
        TAXJOURLINES.SetRange(KRE_TAXJOURID, Rec.ID);
        if (TAXJOURLINES.FindSet()) then
            repeat
                TAXJOURLINES.Delete(true);
            until (TAXJOURLINES.Next() = 0);

        VATEntry.SetRange(INVOICENO, rec.INVOICENO);
        if (VATEntry.FindSet()) then
            repeat
                VATEntry.Delete(true)
            until (VATEntry.Next() = 0);

        VATEntry2.SetRange("Document No.", Rec.INVOICENO);
        if VATEntry2.FindSet() then begin
            VATEntry2.Is_Synch := false;
            VATEntry2.Modify();
        end;


    end;

}
