tableextension 60026 ExtItem extends Item
{
    fields
    {
        field(60000; "Coretax Code"; Text[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Coretax Code';
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