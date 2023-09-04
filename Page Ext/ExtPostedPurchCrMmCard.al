pageextension 60036 ExtPostedPurchCrMmCard extends "Posted Purchase Credit Memo"
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
        addlast(Cancel)
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
                    PPhCode.InsertTaxExcemptionWHTPostedCrmMm(Rec);
                    Message('Posting Success')
                end;
            }
        }
    }
}