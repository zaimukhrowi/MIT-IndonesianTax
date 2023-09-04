table 60000 Kre_RegTaxNumber
{
    LookupPageId = RegisterTaxNumberList;
    fields
    {
        field(1; ID; Integer)
        {
            AutoIncrement = true;
        }
        field(2; FROMDATE; Date)
        {
            Caption = 'FROM DATE';
            NotBlank = true;
        }
        field(3; TODATE; Date)
        {
            Caption = 'TO DATE';
            NotBlank = true;
            trigger OnValidate();
            begin
                if (TODATE < FROMDATE) then
                    Error('To date must greater than From date');

            end;
        }
        field(4; TAX_PREFIKS; Text[16])
        {
            Caption = 'TAX PREFIKS';
            NotBlank = true;
        }
        field(5; TAX_NO_FROM; Integer)
        {
            Caption = 'TAX NO FROM';
            MinValue = 1;
            NotBlank = true;
        }
        field(6; TAX_NO_TO; Integer)
        {
            Caption = 'TAX NO TO';
            NotBlank = true;
            MinValue = 1;
        }
        field(7; STATUS; Text[20])
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

        key(PK2; STATUS)
        {

        }
    }

    trigger OnInsert()
    begin
        STATUS := 'Ready To Use';
    end;

}


