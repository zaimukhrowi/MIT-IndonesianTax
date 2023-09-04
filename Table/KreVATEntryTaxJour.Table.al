table 60007 KRE_VATEntryTaxJour
{
    DataClassification = AccountData;

    fields
    {
        field(1; ID; Integer)
        {
            AutoIncrement = true;
            DataClassification = AccountData;
        }
        field(2; INVOICENO; Text[50])
        {
            Caption = 'INVOICE NO';
            DataClassification = AccountData;
        }
        field(3; TAX_SYNCH; Enum YESNO)
        {
            Caption = 'TAX SYNCH';
            DataClassification = AccountData;
        }
    }

    keys
    {
        key(PrimaryKey; ID)
        {
            Clustered = true;
        }
    }
}