table 60010 "Kre Tax Additional Info"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Tax Additional Info";

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Code';

        }
        field(2; "Additional Info"; Text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'Additional Info';
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
        fieldgroup(DropDown; Code, "Additional Info") { }
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