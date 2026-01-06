tableextension 60016 ExtGenJournalLinePI extends "Gen. Journal Line"
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
        }
        field(60002; WHTAmount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(60003; IsWHTCalc; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(60004; "WHTAmount Additional Currency"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(60005; "WHT Source Type"; Enum "Sales Line Type")
        {
            DataClassification = ToBeClassified;
        }
        field(60006; "WHT Source No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(60007; "WHT Source Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
}