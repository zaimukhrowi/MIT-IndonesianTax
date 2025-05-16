pageextension 60039 ExtItem extends "Item Card"
{
    layout
    {
        addlast(Item)
        {
            field("Coretax Code"; Rec."Coretax Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Coretax Code field.';
            }
        }
        addafter("Item Category Code")
        {
            field("Kre Item Type"; Rec."Kre Item Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Item Type field.';
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