pageextension 60040 "Ext Purchase Ret. Order Sub." extends "Purchase Return Order Subform"
{
    layout
    {
        addafter(Description)
        {
            field("Coretax Item Code"; Rec."Coretax Item Code")
            {
                ApplicationArea = All;
                Caption = 'Coretax Item Code';
                ToolTip = 'Specifies the value of the Coretax Item Code field.';
            }
            field("Coretax Item Description"; Rec."Coretax Item Description")
            {
                ApplicationArea = All;
                Caption = 'Coretax Item Description';
                ToolTip = 'Specifies the value of the Coretax Item Description field.';
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