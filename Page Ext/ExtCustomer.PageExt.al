pageextension 60000 ExtCustomer extends "Customer Card"
{
    layout
    {
        addafter("Copy Sell-to Addr. to Qte From")
        {
            group("Indonesian Tax")
            {
                field("Retail Customer"; Rec."Retail Customer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Retail Customer field.';
                }
                field(ISPKP; Rec.ISPKP)
                {
                    ApplicationArea = All;
                    Caption = 'is PKP ?';
                    ToolTip = 'is PKP ?';
                    trigger OnValidate()
                    begin
                        EnableNIK();
                    end;
                }
                field(ISPPH; Rec.ISPPH)
                {
                    ApplicationArea = All;
                    Caption = 'is WHT ?';
                    ToolTip = 'is WHT ?';
                }
                field(ISNPWP; Rec.ISNPWP)
                {
                    ApplicationArea = All;
                    Caption = 'is NPWP ?';
                    ToolTip = 'is NPWP ?';
                }
                field(NIK; Rec.NIK)
                {
                    ApplicationArea = All;
                    Caption = 'NIK';
                    ToolTip = 'NIK';
                    Enabled = NIKenabled;
                    Importance = Additional;
                    ShowMandatory = NIKmandatory;
                }
                field(WHTProductPostingGroup; Rec.WHTProductPostingGroup)
                {
                    ApplicationArea = All;
                    Caption = 'WHT Product Posting Group';
                    ToolTip = 'WHT Product Posting Group';
                }
                field("NPWP"; Rec.NPWP)
                {
                    ApplicationArea = All;
                    Caption = 'NPWP';
                    ToolTip = 'NPWP';
                    Enabled = NPWPenabled;
                    Importance = Additional;
                    ShowMandatory = NPWPmandatory;
                }
                field("ID TKU"; Rec."ID TKU")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ID TKU field.';
                }
                field("Nama NPWP"; Rec.NamaNPWP)
                {
                    ApplicationArea = All;
                    Caption = 'Nama NPWP';
                    ToolTip = 'Nama NPWP';
                }
                field("Alamat NPWP"; Rec.AlamatNPWP)
                {
                    ApplicationArea = All;
                    Caption = 'Alamat NPWP';
                    ToolTip = 'Alamat NPWP';
                    MultiLine = true;
                }
                field(NPWPAddressfromShipTo; Rec.NPWPAddressfromShipTo)
                {
                    ApplicationArea = All;
                    Caption = 'NPWP Address from Ship To';
                    ToolTip = 'NPWP Address from Ship To';
                }
                field("Is WAPU?"; Rec.IsWAPU)
                {
                    ApplicationArea = All;
                    Caption = 'Is WAPU ?';
                    ToolTip = 'Is WAPU ?';
                }
                field("Prefix WAPU"; Rec.PrefixWAPU)
                {
                    ApplicationArea = All;
                    Caption = 'Prefix';
                    ToolTip = 'Prefix';
                }
                field("Tax Digunggung?"; Rec.Digunggung)
                {
                    ApplicationArea = All;
                    Caption = 'Tax Digunggung ?';
                    ToolTip = 'Tax Digunggung ?';
                }
            }
        }
    }
    local procedure EnableNIK()
    begin
        if Rec.ISPKP = true then begin
            NIKenabled := false;
            NIKmandatory := false;
            NPWPenabled := true;
            NPWPmandatory := true;
        end
        else begin
            NIKenabled := true;
            NIKmandatory := true;
            NPWPenabled := false;
            NPWPmandatory := false;
        end;
    end;

    var
        NIKenabled: Boolean;
        NIKmandatory: Boolean;
        NPWPenabled: Boolean;
        NPWPmandatory: Boolean;
}
