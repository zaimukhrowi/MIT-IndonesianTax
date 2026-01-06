tableextension 60027 "Kre Currency Exchange Rate" extends "Currency Exchange Rate"
{
    fields
    {
        field(60000; "Kre Tax Rate"; Decimal)
        {
            DataClassification = ToBeClassified;
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