tableextension 60026 ExtItem extends Item
{
    fields
    {
        field(60000; "Coretax Code"; Text[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Coretax Code';
        }
        field(60001; "Kre Item Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "A","B";
            OptionCaption = 'Barang,Jasa';
            Caption = 'Item Type';
        }
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;
}