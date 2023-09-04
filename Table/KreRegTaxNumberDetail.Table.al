table 60001 Kre_RegTaxNumberDetail
{
    fields
    {
        field(1; ID; Integer)
        {
            AutoIncrement = true;
        }
        field(2; Kre_RegTaxNumberID; Integer)
        {
            TableRelation = Kre_RegTaxNumber;
        }
        field(3; TAXNUMBER; Code[19])
        {
            Caption = 'TAX NUMBER';
        }
        field(4; Reference; Text[70])
        {
            Caption = 'REFERENCE';
        }
        field(5; STATUS; Text[20])
        {
            Caption = 'STATUS';
        }
    }

    keys
    {
        key(PrimaryKey; ID)
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(Dropdown; ID, TAXNUMBER) { }
    }

    trigger OnModify()
    begin
        if (STATUS = 'Cancel') then
            STATUS := 'cancel'

        else
            STATUS := 'Used'

    end;
}