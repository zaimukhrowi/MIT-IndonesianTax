page 60024 "Kre Tax Facility Stamp"
{
    ApplicationArea = All;
    Caption = 'Kre Tax Facility Stamp';
    PageType = List;
    SourceTable = "Kre Tax Facility Stamp";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field.', Comment = '%';
                }
                field("Facility Stamp"; Rec."Facility Stamp")
                {
                    ToolTip = 'Specifies the value of the Facility Stamp field.', Comment = '%';
                }
            }
        }
    }
}
