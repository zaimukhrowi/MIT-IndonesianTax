page 60026 "Tax Coretax Item"
{
    ApplicationArea = All;
    Caption = 'Coretax Item';
    PageType = List;
    SourceTable = "Kre Coretax Item";
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
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
            }
        }
    }
}
