pageextension 60041 "Kre Currency Exchange Rates" extends "Currency Exchange Rates"
{
    layout
    {
        addlast(Control1)
        {
            field("Kre Tax Rate"; Rec."Kre Tax Rate")
            {
                Caption = 'Tax Rate';
                ToolTip = 'Tax Rate';
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}