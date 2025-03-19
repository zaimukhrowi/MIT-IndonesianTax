tableextension 60001 ExtCustomer extends Customer
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
        field(60003; IsWAPU; Boolean)
        {
            Caption = 'Is WAPU';
        }
        field(60004; PrefixWAPU; enum WAPU)
        {
            Caption = 'Prefix';
        }
        field(60005; Digunggung; Boolean)
        {
            Caption = 'Tax Digunggung';
        }
        field(60007; ISPKP; Boolean)
        {
            Caption = 'Is PKP';
        }
        field(60008; ISPPH; Boolean)
        {
            Caption = 'Is WHT';
        }
        field(60009; NIK; Code[16])
        {
            Caption = 'NIK';
        }
        field(60006; WHTProductPostingGroup; Code[25])
        {
            Caption = 'WHT Product Posting Group';
            TableRelation = Kre_MasterPPh.PPhCode;
        }
        field(60010; NPWPAddressfromShipTo; Boolean)
        {
            Caption = 'NPWP Address from Ship To';
        }
        field(60011; ISNPWP; Boolean)
        {
            Caption = 'Is NPWP';
        }
        field(60012; "ID TKU"; Text[22])
        {
            DataClassification = ToBeClassified;
            Caption = 'ID TKU';
        }
    }
}
