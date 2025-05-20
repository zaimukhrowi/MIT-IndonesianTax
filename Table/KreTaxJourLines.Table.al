table 60003 KRE_TAXJOURLINES
{
    fields
    {
        field(1; ID; Integer)
        {
            AutoIncrement = true;
        }
        field(2; KRE_TAXJOURID; Integer)
        {
            TableRelation = KRE_TAXJOUR;
        }
        field(3; INVOICELINENO; Integer)
        {
            Caption = 'LINE NO';
        }
        field(4; INVOICENO; Text[50])
        {
            Caption = 'INVOICE NO';
        }
        field(5; TYPE; Option)
        {
            Caption = 'TYPE';
            OptionMembers = "","G/L Account","Item","Resource","Fixed Asset","Charge (Item)";
        }
        field(6; ITEMID; Text[25])
        {
            Caption = 'ITEM ID';
        }
        field(7; DESCRIPTION; Text[100])
        {
            Caption = 'DESCRIPTION';
        }
        field(8; VAT_Bus_Posting_Group; Text[25])
        {
            Caption = 'VAT Bus Posting Group';
        }
        field(9; VAT_Prod_Posting_Group; Text[25])
        {
            Caption = 'VAT Prod Posting Group';
        }
        field(10; VAT_Identifier; Text[25])
        {
            Caption = 'VAT Identifier';
        }
        field(11; PRICE; decimal)
        {
            Caption = 'PRICE';
        }
        field(12; QTY; Integer)
        {
            Caption = 'QUANTITY';
        }
        field(13; TOTAL_AMOUNT; Decimal)
        {
            Caption = 'TOTAL AMOUNT';
        }
        field(14; DISCOUNT_AMOUNT; decimal)
        {
            Caption = 'DISCOUNT AMOUNT';
        }
        field(15; DPP_AMOUNT; Decimal)
        {
            Caption = 'DPP AMOUNT';
        }
        field(16; VAT_AMOUNT; Decimal)
        {
            Caption = 'VAT AMOUNT';
        }
        field(17; "Coretax Item Code"; Text[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Coretax Item Code';
        }
        field(18; "Coretax Item Description"; Text[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Coretax Item Description';
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