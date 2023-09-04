tableextension 60008 ExtVATEntry extends "VAT Entry"
{
    fields
    {
        field(60000; TAX_SYNCH; Enum YESNO)
        {
            Caption = 'TAX SYNCH';
            ObsoleteState = Removed;
            ObsoleteReason = 'tidak terpakai';
        }
        field(60001; Is_Synch; Boolean)
        {
            Caption = 'IS SYNCH';
        }
    }
}