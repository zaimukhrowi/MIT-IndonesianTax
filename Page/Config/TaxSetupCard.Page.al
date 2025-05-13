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
                    ToolTip = 'Specifies the value of the Pajak Masukan field.';
                }
                field("Pajak Keluaran"; Rec.Activate_VAT_Out)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pajak Keluaran field.';
                }
                field("Scan EFaktur"; Rec.Activate_Scan)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Scan EFaktur field.';
                }
                field(User_EFaktur; Rec.User_EFaktur)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User EFaktur field.';
                }
                field("VAT Rounding Type"; Rec."VAT Rounding Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Rounding Type field.';
                }
                field("Amount Decimal Places"; Rec."Amount Decimal Places")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Decimal Places field.';
                }
                field(PPh; Rec.Activate_WHT)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the PPh field.';
                }
                field("VAT Retail"; Rec."VAT Retail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pajak Keluaran Digunggung field.';
                }
                field("Currency Used"; Rec."Currency Used")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Used field.';
                    // ShowMandatory = true;
                }
                field("Export to Currency"; Rec."Export to Currency")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Export to Tax Currency field.';
                }
                field("Calculate WHT per Line"; Rec."Calculate WHT per Line")
                {
                    ToolTip = 'Specifies the value of the Calculate WHT per Line field.';
                    ApplicationArea = All;
                }
                group(Coretax)
                {
                    Caption = 'Coretax';
                    field("Default ID TKU"; Rec."Default ID TKU")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Default ID TKU field.';
                    }
                    field("Tarif PPn Percentage"; Rec."Tarif PPn Percentage")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Tarif PPn Percentage field.';
                    }
                    field("DPP Nilai Lain (A)"; Rec."DPP Nilai Lain (A)")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the DPP Nilai Lain (A) field.';
                    }
                    field("DPP Nilai Lain (B)"; Rec."DPP Nilai Lain (B)")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the DPP Nilai Lain (B) field.';
                    }

                    field("Use Registered Tax Number"; Rec."Use Registered Tax Number")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Use Registered Tax Number field.';
                    }
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