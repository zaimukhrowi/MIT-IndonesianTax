tableextension 60024 ExtLocation extends Location
{
    fields
    {
        field(60000; "Kre ID TKU"; Text[22])
        {
            DataClassification = ToBeClassified;
            Caption = 'ID TKU';
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