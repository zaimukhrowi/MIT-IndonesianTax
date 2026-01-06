pageextension 60018 ExtGLAccountCard extends "G/L Account Card"
{
    layout
    {
        addafter("Omit Default Descr. in Jnl.")
        {
            field(IsPPh; Rec.IsPPh)
            {
                ApplicationArea = All;
                Caption = 'Is PPh';
                ToolTip = 'Is PPh';
            }
            field("Coretax Code"; Rec."Coretax Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Coretax Code field.';
            }
            field("Kre Type"; Rec."Kre Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Type field.';
            }
        }
    }


}