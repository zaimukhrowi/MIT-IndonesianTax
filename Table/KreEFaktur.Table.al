table 60004 Kre_EFaktur
{
    fields
    {
        field(1; ID; Integer)
        {
            AutoIncrement = true;
        }
        field(2; KD_Jenis_Transaksi; Code[2])
        {
            Caption = 'KD Jenis Transaksi';
        }
        field(3; FG_Pengganti; Text[1])
        {
            Caption = 'FG Pengganti';
        }
        field(4; No_Faktur; Text[30])
        {
            Caption = 'No Faktur';
        }
        field(5; Tanggal_Faktur; Date)
        {
            Caption = 'Tanggal Faktur';
        }
        field(6; NPWP_Penjual; Text[30])
        {
            Caption = 'NPWP Penjual';
        }
        field(7; Nama_Penjual; Text[100])
        {
            Caption = 'Nama Penjual';
        }
        field(8; Alamat_Penjual; Text[250])
        {
            Caption = 'Alamat Penjual';
        }
        field(9; NPWP_Lawan_Transaksi; Text[30])
        {
            Caption = 'NPWP Lawan Transaksi';
        }
        field(10; Nama_Lawan_Transaksi; Text[100])
        {
            Caption = 'Nama Lawan Transaksi';
        }
        field(11; Alamat_Lawan_Transaksi; Text[250])
        {
            Caption = 'Alamat Lawan Transaksi';
        }
        field(12; Jumlah_DPP; Decimal)
        {
            Caption = 'Jumlah DPP';
        }
        field(13; Jumlah_PPN; Decimal)
        {
            Caption = 'Jumlah PPN';
        }
        field(14; Jumlah_PPNBM; Decimal)
        {
            Caption = 'Jumlah PPNBM';
        }
        field(15; Status_Approval; Text[100])
        {
            Caption = 'Status Approval';
        }
        field(16; Status_Faktur; Text[100])
        {
            Caption = 'Status Faktur';
        }
        field(17; Referensi; Text[100])
        {
            Caption = 'Referensi';
        }
        field(18; URL; Text[250])
        {
            Caption = 'URL';
        }
        field(19; TAX_EXPORTED; Enum YESNO)
        {
            Caption = 'TAX EXPORTED';
        }

    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }
    trigger OnDelete()
    var
        EFakturLines: Record Kre_EFakturLines;
    // VATEntry:Record "VAT Entry";
    begin
        EFakturLines.SetRange(ID_Kre_EFaktur, Rec.ID);
        if (EFakturLines.FindSet()) then
            repeat
                EFakturLines.Delete(true);
            until (EFakturLines.Next() = 0);


        // VATEntry.Get(Rec, ID);
        // if (VATEntry.FindSet()) then begin
        //     repeat
        //         VATEntry.TAX_SYNCH := 0;
        //         VATEntry.Modify();
        //     until (VATEntry.Next = 0)
        // end;
    end;


}