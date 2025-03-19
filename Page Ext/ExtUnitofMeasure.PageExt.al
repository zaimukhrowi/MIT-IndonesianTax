pageextension 60038 MyExtension extends "Units of Measure"
{
    layout
    {
        addlast(Control1)
        {
            field("Kre Coretax Code"; Rec."Kre Coretax Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Coretax Code field.';
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