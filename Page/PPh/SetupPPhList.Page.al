page 60018 SetupPPhList
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Kre_MasterPPh;
    Caption = 'WHT Product Posting Group';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(PPhCode; Rec.PPhCode)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Percentage; Rec.Percentage)
                {
                    ApplicationArea = All;
                }
                field("Percentage Up"; Rec."Percentage Up")
                {
                    ApplicationArea = All;
                    Caption = 'Percentage Non-NPWP';
                }
                field("Sales WHT Account"; Rec."Sales WHT Account")
                {
                    ApplicationArea = All;
                }
                field("Purchase WHT Account"; Rec."Purchase WHT Account")
                {
                    ApplicationArea = All;
                }
                field("Purch. WHT Account (Gross Up)"; Rec."Purch. WHT Account (Gross Up)")
                {
                    ApplicationArea = All;
                    Caption = 'Purchase WHT Account (Gross Up)';
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    // trigger OnInit()
    // var
    //     PPhCode: Codeunit PPhCode;
    // begin
    //     PPhCode.insertdummydescription();
    // end;

}