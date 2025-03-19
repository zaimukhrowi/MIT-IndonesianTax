tableextension 60022 ExtShiptoAddress extends "Ship-to Address"
{
    fields
    {
        field(60000; AlamatNPWP; Text[500])
        {
            Caption = 'Nama NPWP';
        }
        field(60001; "ID TKU"; Text[22])
        {
            DataClassification = ToBeClassified;
            Caption = 'ID TKU';
        }
    }
}
