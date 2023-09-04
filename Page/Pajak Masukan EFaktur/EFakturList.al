page 60012 EFakturList
{
    PageType = List;
    SourceTable = Kre_EFaktur;
    SourceTableView = sorting(ID) order(ascending);
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Pajak Masukan from EFaktur';
    CardPageId = EFakturCard;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(PajakMasukanEFaktur)
            {
                field(SELECT; Rec.ID)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Kode Jenis Transaksi"; Rec.KD_Jenis_Transaksi)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("FG Pengganti"; Rec.FG_Pengganti)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("No Faktur"; Rec.No_Faktur)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Tanggal Faktur"; Rec.Tanggal_Faktur)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("NPWP Penjual"; Rec.NPWP_Penjual)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Nama Penjual"; Rec.Nama_Penjual)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Alamat Penjual"; Rec.Alamat_Penjual)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("NPWP Lawan Transaksi"; Rec.NPWP_Lawan_Transaksi)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Nama Lawan Transaksi"; Rec.Nama_Lawan_Transaksi)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Alamat Lawan Transaksi"; Rec.Alamat_Lawan_Transaksi)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Jumlah DPP"; Rec.Jumlah_DPP)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Jumlah PPN"; Rec.Jumlah_PPN)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Jumlah PPNBM"; Rec.Jumlah_PPNBM)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Status Approval"; Rec.Status_Approval)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Status Faktur"; Rec.Status_Faktur)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Referensi; Rec.Referensi)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Creation)
        {
            action("Scan EFaktur")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = BarCode;
                RunObject = page GetEFaktur;
                RunPageMode = Create;

            }
        }
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
                    if EFaktur.Count() = 0 then
                        Message('No Data')

                    else begin
                        EFaktur.Reset();
                        CurrPage.SetSelectionFilter(EFaktur);
                        Xmlport.Run(60004, false, false, EFaktur);
                        ImportEfaktur.SetTaxExported(EFaktur);
                    end;
                end;
            }
        }
    }
}