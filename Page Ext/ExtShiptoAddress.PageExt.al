pageextension 60028 ExtShiptoAddress extends "Ship-to Address"
{
    layout
    {
        addafter("Address 2")
        {
            field("Alamat NPWP"; Rec.AlamatNPWP)
            {
                ApplicationArea = All;
                Caption = 'Alamat NPWP';
                ToolTip = 'Alamat NPWP';
                MultiLine = true;
            }
        }
    }

}
