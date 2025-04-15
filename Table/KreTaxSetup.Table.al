table 60006 Kre_TaxSetup
{
    fields
    {
        field(2; Activate_VAT_In; Boolean)
        {
            Caption = 'Pajak Masukan';
        }
        field(3; Activate_VAT_Out; Boolean)
        {
            Caption = 'Pajak Keluaran';
        }
        field(4; Activate_Scan; Boolean)
        {
            Caption = 'Scan EFaktur';
        }
        field(5; User_EFaktur; Text[100])
        {
            Caption = 'User EFaktur';
        }
        field(6; "VAT Rounding Type"; Option)
        {
            Caption = 'VAT Rounding Type';
            OptionMembers = "=",">","<";
            OptionCaption = 'Nearest,Up,Down';
        }
        field(7; "Amount Decimal Places"; Decimal)
        {
            Caption = 'Amount Decimal Places';
        }
        field(8; Activate_WHT; Boolean)
        {
            Caption = 'PPh';
        }
        field(9; "VAT Retail"; Code[20])
        {
            Caption = 'Pajak Keluaran Digunggung';
            TableRelation = "VAT Business Posting Group".Code;
        }
        field(10; "Admin Fee Account"; Code[20])
        {
            Caption = 'Admin Fee Account';
            TableRelation = "G/L Account"."No.";
            ObsoleteState = Removed;
        }
        field(11; "Currency Used"; Option)
        {
            Caption = 'Currency Used';
            OptionMembers = "Currency Amount","Additional Currency Amount";
            OptionCaption = 'Currency Amount,Additional Currency Amount';
        }
        field(12; "Export to Currency"; Code[20])
        {
            Caption = 'Export to Tax Currency';
            TableRelation = Currency;
        }
        field(17; "Default ID TKU"; Text[22])
        {
            DataClassification = ToBeClassified;
            Caption = 'Default ID TKU';
        }
        field(13; "Tarif PPn Percentage"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Tarif PPn Percentage';
        }
        field(14; "DPP Nilai Lain (A)"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'DPP Nilai Lain (A)';
        }
        field(15; "DPP Nilai Lain (B)"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'DPP Nilai Lain (B)';
        }
        field(16; "Use Registered Tax Number"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Use Registered Tax Number';
        }
    }




}