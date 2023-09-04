pageextension 60030 ExtPostedPurchInvCard extends "Posted Purchase Invoice"
{
    layout
    {
        addafter(Corrective)
        {
            field(TAXNUMBER; Rec.TAXNUMBER)
            {
                ApplicationArea = All;
                Caption = 'Tax Number';
            }
            field(TAXDATE; Rec.TAXDATE)
            {
                ApplicationArea = All;
                Caption = 'Tax Date';
            }
        }
    }
    actions
    {
        addlast(Correct)
        {
            action("Posting WHT")
            {
                ToolTip = 'Posting WHT';
                Caption = 'Posting WHT';
                ApplicationArea = All;
                Image = Post;
                Promoted = true;
                PromotedCategory = Category6;
                trigger OnAction()
                var
                    PPhCode: Codeunit PPhCode;
                begin
                    PPhCode.InsertTaxExcemptionWHTPostedPI(Rec);
                    Message('Posting Success')
                end;
            }
        }
    }
}