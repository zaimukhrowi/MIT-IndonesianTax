tableextension 60000 ExtVendor extends Vendor
{
    fields
    {
        field(60000; NPWP; Code[16])
        {
            Caption = 'NPWP';
        }
        field(60001; NamaNPWP; Text[250])
        {
            Caption = 'Nama NPWP';
        }
        field(60002; AlamatNPWP; Text[500])
        {
            Caption = 'Alamat NPWP';
        }
        field(60003; ISPKP; Boolean)
        {
            Caption = 'Is PKP';
        }
        field(60004; ISPPH; Boolean)
        {
            Caption = 'Is WHT';
        }
        field(60005; NIK; Code[16])
        {
            Caption = 'NIK';
        }
        field(60006; WHTProductPostingGroup; Code[25])
        {
            Caption = 'WHT Product Posting Group';
            TableRelation = Kre_MasterPPh.PPhCode;
        }
        field(60007; ISNPWP; Boolean)
        {
            Caption = 'Is NPWP';
        }
        field(60008; NITKU; Text[22])
        {
            DataClassification = ToBeClassified;
        }
        field(60014; "ID Type"; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'ID Type';
            OptionMembers = "TIN","National ID","Passport","Other ID";
            OptionCaption = 'TIN,National ID,Passport,Other ID';
        }
        field(60015; "Passport No."; Text[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Passport No.';
        }
        field(60016; "Other ID"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Other ID';
        }
    }
}