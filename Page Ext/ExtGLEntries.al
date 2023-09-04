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
        }
    }
}