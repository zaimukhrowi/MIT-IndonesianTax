page 60014 EFakturLines
{
    PageType = ListPart;
    SourceTable = Kre_EFakturLines;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    Caption = 'EFaktur Lines';

    layout
    {
        area(Content)
        {
            repeater("EFaktur Lines")
            {
                field(Nama; Rec.Nama)
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field("Harga Satuan"; Rec.Harga_Satuan)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Jumlah Barang"; Rec.Jumlah_Barang)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Harga Total"; Rec.Harga_Total)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Diskon; Rec.Diskon)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(DPP; Rec.DPP)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(PPN; Rec.PPN)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Tarif PPNBM"; Rec.Tarif_PPNBM)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(PPNBM; Rec.PPNBM)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

            }
        }
    }
}