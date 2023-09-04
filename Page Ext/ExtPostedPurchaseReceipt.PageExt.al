pageextension 60034 ExtPostedPurchReceipt extends "Posted Purchase Receipt"
{
    actions
    {
        addafter("&Receipt")
        {

            action("Fixing Line No")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = Apply;
                ToolTip = 'Fixing Line No';
                Caption = 'Fixing Line No';
                trigger OnAction()
                var
                    Testcode: Codeunit PPhCode;
                    S: page "Posted Purchase Rcpt. Subform";
                begin
                    Testcode.UpdateLineNo(Rec."No.");
                    S.Update();
                    CurrPage.Update();
                    Message('fixing success!');
                end;
            }
        }
    }
}