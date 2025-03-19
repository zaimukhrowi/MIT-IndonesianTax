pageextension 60037 ExtLocationCard extends "Location Card"
{
    layout
    {
        addlast(General)
        {
            field("Kre ID TKU"; Rec."Kre ID TKU")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the ID TKU field.';
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