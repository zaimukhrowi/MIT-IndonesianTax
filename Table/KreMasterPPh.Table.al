table 60008 Kre_MasterPPh
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; PPhCode; Code[25])
        {
            DataClassification = ToBeClassified;
            Width = 25;
        }
        field(2; Description; Text[250])
        {
            DataClassification = ToBeClassified;
            Width = 200;
        }
        field(3; Percentage; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
        }
        field(7; "Percentage Up"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
        }
        field(4; "G/L Account"; Code[25])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No." where(IsPPh = filter(true));
            ObsoleteState = Removed;
            ObsoleteReason = 'take out from version 5.0';
        }
        field(5; "Sales WHT Account"; Code[25])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No." where(IsPPh = filter(true));
        }
        field(6; "Purchase WHT Account"; Code[25])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No." where(IsPPh = filter(true));
        }
        field(8; "Purch. WHT Account (Gross Up)"; Code[25])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No." where(IsPPh = filter(true));
        }
    }

    keys
    {
        key(PK; PPhCode)
        {
            Clustered = true;
        }
    }

}