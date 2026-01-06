tableextension 60021 ExtPurchCrMmLine extends "Purch. Cr. Memo Line"
{
    fields
    {
        field(60000; WHTProductPostingGroup; Code[25])
        {
            DataClassification = ToBeClassified;
        }
        field(60001; WHTPercentage; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
        }
        field(60002; WHTAmount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(60003; IsWHTCalc; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(60004; "Gross Up"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(60005; "Is TaxExemption"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(60006; "Tax Exemption Percentage"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(60007; "Tax Exemption Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(60008; "WHTAmount Additional Currency"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(60009; "Coretax Item Code"; Text[10])
        {
            DataClassification = ToBeClassified;
        }
        field(60010; "Coretax Item Description"; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(60011; "WHT Source Type"; Enum "Sales Line Type")
        {
            DataClassification = ToBeClassified;
        }
        field(60012; "WHT Source No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
}