pageextension 60029 ExtGLEntries extends "General Ledger Entries"
{
    layout
    {
        addafter("External Document No.")
        {
            field(WHTProductPostingGroup; Rec.WHTProductPostingGroup)
            {
                ApplicationArea = All;
                Caption = 'WHT Product Posting Group';
                ToolTip = 'WHT Product Posting Group';
            }
            field(WHTPercentage; Rec.WHTPercentage)
            {
                ApplicationArea = All;
                Caption = 'WHT Percentage';
                ToolTip = 'WHT Percentage';
            }
            field(WHTAmount; Rec.WHTAmount)
            {
                ApplicationArea = All;
                Caption = 'WHT Amount';
                ToolTip = 'WHT Amount';
                trigger OnValidate()
                var
                    DeleteTableCode: Codeunit DeleteTableCode;
                begin
                    DeleteTableCode.EditGLEntry(Rec."Entry No.", Rec.WHTAmount, Rec."WHTAmount Additional Currency");
                end;
            }
            field("WHTAmount Additional Currency"; Rec."WHTAmount Additional Currency")
            {
                Caption = 'WHT Amount Additional Currency';
                ToolTip = 'WHT Amount Additional Currency';
                ApplicationArea = All;
                trigger OnValidate()
                var
                    DeleteTableCode: Codeunit DeleteTableCode;
                begin
                    DeleteTableCode.EditGLEntry(Rec."Entry No.", Rec.WHTAmount, Rec."WHTAmount Additional Currency");
                end;
            }
            field("WHT Source Type"; Rec."WHT Source Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the WHT Source Type field.';
                Caption = 'WHT Source Type';
            }
            field("WHT Source No."; Rec."WHT Source No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the WHT Source No. field.';
                Caption = 'WHT Source No.';
            }
            field("WHT Source Document No."; Rec."WHT Source Document No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the WHT Source Document No. field.';
                Caption = 'WHT Source Document No.';
            }
        }
    }
}