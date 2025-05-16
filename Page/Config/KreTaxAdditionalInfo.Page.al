page 60023 "Kre Tax Additional Info"
{
    ApplicationArea = All;
    Caption = 'Kre Tax Additional Info';
    PageType = List;
    SourceTable = "Kre Tax Additional Info";
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
                field("Additional Info"; Rec."Additional Info")
                {
                    ToolTip = 'Specifies the value of the Additional Info field.', Comment = '%';
                }
            }
        }
    }
}
