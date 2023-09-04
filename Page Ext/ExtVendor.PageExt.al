pageextension 60001 ExtVendor extends "Vendor Card"
{
    layout
    {
        addafter("Invoice Disc. Code")
        {
            group("Indonesian Tax")
            {
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
