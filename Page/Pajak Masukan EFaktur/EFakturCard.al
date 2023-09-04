page 60013 EFakturCard
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = Kre_EFaktur;
    DelayedInsert = true;
    InsertAllowed = false;
    ModifyAllowed = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Kode Jenis Transaksi"; Rec.KD_Jenis_Transaksi)
                {
                    ApplicationArea = All;
                    // Editable = false;
                }
                field("FG Pengganti"; Rec.FG_Pengganti)
                {
                    ApplicationArea = All;
                    // Editable = false;
                }
                field("No Faktur"; Rec.No_Faktur)
                {
                    ApplicationArea = All;
                    // Editable = false;
                }
                field("Tanggal Faktur"; Rec.Tanggal_Faktur)
                {
                    ApplicationArea = All;
                    // Editable = false;
                }
                field("NPWP Penjual"; Rec.NPWP_Penjual)
                {
                    ApplicationArea = All;
                    // Editable = false;
                }
                field("Nama Penjual"; Rec.Nama_Penjual)
                {
                    ApplicationArea = All;
                    // Editable = false;
                    MultiLine = true;
                }
                field("Alamat Penjual"; Rec.Alamat_Penjual)
                {
                    ApplicationArea = All;
                    // Editable = false;
                    MultiLine = true;
                }
                field("NPWP Lawan Transaksi"; Rec.NPWP_Lawan_Transaksi)
                {
                    ApplicationArea = All;
                    // Editable = false;
                }
                field("Nama Lawan Transaksi"; Rec.Nama_Lawan_Transaksi)
                {
                    ApplicationArea = All;
                    // Editable = false;
                    MultiLine = true;
                }
                field("Alamat Lawan Transaksi"; Rec.Alamat_Lawan_Transaksi)
                {
                    ApplicationArea = All;
                    // Editable = false;
                    MultiLine = true;
                }
                field("Status Faktur"; Rec.Status_Faktur)
                {
                    ApplicationArea = All;
                    // Editable = false;
                }
                field(Referensi; Rec.Referensi)
                {
                    ApplicationArea = All;
                    // Editable = false;
                }

            }
            group("Details")
            {
                field("Jumlah DPP"; Rec.Jumlah_DPP)
                {
                    ApplicationArea = All;
                    // Editable = false;
                }
                field("Jumlah PPN"; Rec.Jumlah_PPN)
                {
                    ApplicationArea = All;
                    // Editable = false;
                }
                field("Jumlah PPNBM"; Rec.Jumlah_PPNBM)
                {
                    ApplicationArea = All;
                    // Editable = false;
                }
                field("Status Approval"; Rec.Status_Approval)
                {
                    ApplicationArea = All;
                    // Editable = false;
                    MultiLine = true;
                }

            }
            part("EFaktur Lines"; EFakturLines)
            {
                SubPageLink = ID_Kre_EFaktur = field(ID);
                UpdatePropagation = SubPart;
                Visible = true;
                ApplicationArea = All;

            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Export Efaktur")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = ExportFile;
                trigger OnAction()
                var
                    EFaktur: Record Kre_EFaktur;
                    ImportEfaktur: Codeunit ImportEfaktur;
                begin
                    EFaktur.Reset();
                    EFaktur.SetRange(ID, Rec.ID);
                    Xmlport.Run(60004, false, false, EFaktur);
                    ImportEfaktur.SetTaxExported(EFaktur);
                end;
            }
        }
    }
}