tableextension 60025 "Kre Unit of Measure" extends "Unit of Measure"
{
    fields
    {
        field(60000; "Kre Coretax Code"; Text[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Coretax Code';
            TableRelation = "Kre Tax Unit of Measure";
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