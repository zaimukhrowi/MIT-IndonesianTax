tableextension 60013 ExtGLAccount extends "G/L Account"
{
    fields
    {
        field(60000; PPhCode; Code[20])
        {
            Caption = 'PPh Code';
            ObsoleteState = Removed;
            ObsoleteReason = 'versi 4.0 sudah tidak digunakan';
        }
        field(60001; IsPPh; Boolean)
        {
            Caption = 'Is PPh';
        }
    }

}