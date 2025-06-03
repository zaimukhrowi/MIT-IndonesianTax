page 60023 "Tax Additional Info"
{
    ApplicationArea = All;
    Caption = 'Tax Additional Info';
    PageType = List;
    SourceTable = "Kre Tax Additional Info";
    UsageCategory = Administration;

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
