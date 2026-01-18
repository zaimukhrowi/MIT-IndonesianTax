page 60019 SetupPPhCard
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = Kre_MasterPPh;
    Caption = 'WHT Product Posting Group';

    layout
    {
        area(Content)
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
}