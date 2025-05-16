page 60025 "Kre Tax Unit of Measure"
{
    ApplicationArea = All;
    Caption = 'Kre Tax Unit of Measure';
    PageType = List;
    SourceTable = "Kre Tax Unit of Measure";
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
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ToolTip = 'Specifies the value of the Unit of Measure field.', Comment = '%';
                }
            }
        }
    }
}
