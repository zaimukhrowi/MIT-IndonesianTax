page 60016 TaxSetupCard
{
    PageType = StandardDialog;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = Kre_TaxSetup;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Pajak Masukan"; Rec.Activate_VAT_In)
                {
                    ApplicationArea = All;
                }
                field("Pajak Keluaran"; Rec.Activate_VAT_Out)
                {
                    ApplicationArea = All;
                }
                field("Scan EFaktur"; Rec.Activate_Scan)
                {
                    ApplicationArea = All;
                }
                field(User_EFaktur; Rec.User_EFaktur)
                {
                    ApplicationArea = All;
                }
                field("VAT Rounding Type"; Rec."VAT Rounding Type")
                {
                    ApplicationArea = All;
                }
                field("Amount Decimal Places"; Rec."Amount Decimal Places")
                {
                    ApplicationArea = All;
                }
                field(PPh; Rec.Activate_WHT)
                {
                    ApplicationArea = All;
                }
                field("VAT Retail"; Rec."VAT Retail")
                {
                    ApplicationArea = All;
                }
                field("Currency Used"; Rec."Currency Used")
                {
                    ApplicationArea = All;
                    // ShowMandatory = true;
                }
                field("Export to Currency"; Rec."Export to Currency")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
            }
        }

    }

    trigger OnInit()
    begin
        if not Rec.FindSet() then begin
            Rec.Init();
            Rec.Activate_VAT_In := false;
            Rec.Activate_VAT_Out := false;
            Rec.Activate_Scan := false;
            Rec.User_EFaktur := 'Admin';
            Rec."VAT Rounding Type" := Rec."VAT Rounding Type"::"=";
            Rec."Amount Decimal Places" := 1;
            Rec.Activate_WHT := false;
            Rec.Insert();
        end;
    end;

    // var
    //     TaxSetup: Record Kre_TaxSetup;
}