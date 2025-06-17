table 60013 "Kre Coretax Item"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Code; Text[6])
        {
            DataClassification = ToBeClassified;

        }
        field(2; Description; Text[1000])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}