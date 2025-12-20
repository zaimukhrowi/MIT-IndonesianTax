pageextension 60001 ExtVendor extends "Vendor Card"
{
    layout
    {
        addafter("Invoice Disc. Code")
        {
            group("Indonesian Tax")
            {
                field("ID Type"; Rec."ID Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ID Type field.';
                    trigger OnValidate()
                    begin
                        case Rec."ID Type" of
                            Rec."ID Type"::TIN:
                                SetMandatory(true, false, false, false);
                            Rec."ID Type"::"National ID":
                                SetMandatory(false, true, false, false);
                            Rec."ID Type"::Passport:
                                SetMandatory(false, false, true, false);
                            Rec."ID Type"::"Other ID":
                                SetMandatory(false, false, false, true);
                        end;
                    end;
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
                field("Passport No."; Rec."Passport No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Passport No. field.';
                    ShowMandatory = Passportmandatory;
                }
                field("Other ID"; Rec."Other ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Other ID field.';
                    ShowMandatory = Othermandatory;
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
                field(NITKU; Rec.NITKU)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NITKU field.';
                    Caption = 'NITKU';
                }

            }
        }
    }
    local procedure EnableNIK()
    begin
        if Rec.ISPKP = true then begin
            NIKenabled := false;
            NPWPenabled := true;
        end
        else begin
            NIKenabled := true;
            NPWPenabled := false;
        end;
    end;

    local procedure SetMandatory(NPWP: Boolean; NIK: Boolean; Passport: Boolean; Other: Boolean)
    begin
        NIKmandatory := NIK;
        NPWPmandatory := NPWP;
        Passportmandatory := Passport;
        Othermandatory := Other;
    end;

    trigger OnAfterGetRecord()
    begin
        case Rec."ID Type" of
            Rec."ID Type"::TIN:
                SetMandatory(true, false, false, false);
            Rec."ID Type"::"National ID":
                SetMandatory(false, true, false, false);
            Rec."ID Type"::Passport:
                SetMandatory(false, false, true, false);
            Rec."ID Type"::"Other ID":
                SetMandatory(false, false, false, true);
        end;
    end;

    var
        NIKenabled: Boolean;
        NIKmandatory: Boolean;
        NPWPenabled: Boolean;
        NPWPmandatory: Boolean;
        Passportmandatory: Boolean;
        Othermandatory: Boolean;

}
