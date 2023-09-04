pageextension 60015 EvtVATProdPostGroup extends "VAT Product Posting Groups"
{
    layout
    {
        addafter(Description)
        {
            field(IS_FORWARDER; Rec.IS_FORWARDER)
            {
                ApplicationArea = All;
                Caption = 'IS FORWARDER';
            }

        }
    }
}