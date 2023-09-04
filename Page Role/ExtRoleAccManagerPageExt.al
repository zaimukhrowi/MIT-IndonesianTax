pageextension 60008 AccountingManager extends "Accounting Manager Role Center"
{

    actions
    {
        addlast(Sections)
        {
            group("Pajak Indonesia")
            {
                action("Register Tax Number")
                {
                    RunObject = page RegisterTaxNumberList;
                    ApplicationArea = All;
                }
                action("Tax Synchronize")
                {
                    RunObject = page TaxSycnh;
                    ApplicationArea = All;
                }
                action("Pajak Masukan")
                {
                    RunObject = page PajakMasukanList;
                    ApplicationArea = All;
                }
                action("Pajak Masukan Posted")
                {
                    RunObject = page PostedPajakMasukanList;
                    ApplicationArea = All;
                }
                action("Pajak Keluaran")
                {
                    RunObject = page PajakKeluaranList;
                    ApplicationArea = All;
                }
                action("Pajak Keluaran Digunggung")
                {
                    RunObject = page PajakKeluaranDigunggungList;
                    ApplicationArea = All;
                }
                action("Pajak Keluaran Posted")
                {
                    RunObject = page PostedPajakKeluaranList;
                    ApplicationArea = All;
                }
                action("Scan EFaktur")
                {
                    RunObject = page EFakturList;
                    ApplicationArea = All;
                }
                action("Tax Setup")
                {
                    RunObject = page TaxSetupCard;
                    ApplicationArea = All;
                }
                action("PPh Masukan")
                {
                    RunObject = page PPhMasukanList;
                    ApplicationArea = All;
                }
                action("PPh Keluaran")
                {
                    RunObject = page PPhKeluaranList;
                    ApplicationArea = All;
                }
                action("WHT Product Posting Group")
                {
                    RunObject = page SetupPPhList;
                    ApplicationArea = All;
                }
            }
        }
    }
}