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
        }
    }


}