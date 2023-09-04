tableextension 60015 ExtPurchaseLine extends "Purchase Line"
{
    fields
    {
        field(60000; WHTProductPostingGroup; Code[25])
        {
            TableRelation = Kre_MasterPPh.PPhCode;
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
        // field(60006; "Tax Exemption Percentage"; Decimal)
        // {
        //     DataClassification = ToBeClassified;
        // }
        // field(60007; "Tax Exemption Amount"; Decimal)
        // {
        //     DataClassification = ToBeClassified;
        // }
        field(60008; "WHTAmount Additional Currency"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
}