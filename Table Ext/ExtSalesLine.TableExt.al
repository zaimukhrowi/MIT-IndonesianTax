tableextension 60014 ExtSalesLine extends "Sales Line"
{
    fields
    {
        field(60000; WHTProductPostingGroup; Code[25])
        {
            TableRelation = Kre_MasterPPh.PPhCode;
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                "WHT Source Type" := Type;
                "WHT Source No." := "No.";
            end;
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

            trigger OnLookup()
            var
                KreCoretaxItem: Record "Kre Coretax Item";
            begin
                Clear(KreCoretaxItem);
                if PAGE.RunModal(PAGE::"Tax Coretax Item", KreCoretaxItem) = Action::LookupOK then begin
                    "Coretax Item Code" := KreCoretaxItem.Code;
                    "Coretax Item Description" := KreCoretaxItem.Description;
                end
            end;
        }
        field(60010; "Coretax Item Description"; Text[200])
        {
            DataClassification = ToBeClassified;
        }

        modify("No.")
        {
            trigger OnAfterValidate()
            var
                Item: Record Item;
                KreCoretaxItem: Record "Kre Coretax Item";
            begin
                if Item.Get("No.") then begin
                    "Coretax Item Code" := Item."Coretax Code";
                    if KreCoretaxItem.Get(Item."Coretax Code") then
                        "Coretax Item Description" := KreCoretaxItem.Description;
                end;
            end;
        }

        field(60011; "WHT Source Type"; Enum "Sales Line Type")
        {
            DataClassification = ToBeClassified;
        }
        field(60012; "WHT Source No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(60013; "WHT Applicable"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
}