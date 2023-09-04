page 60020 PPhKeluaranList
{
    PageType = List;
    SourceTable = KreWHTTrans;
    SourceTableView = sorting(ID) order(ascending) where("Source Type" = filter(Customer));
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'PPh Keluaran List';
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(PPhKeluaran)
            {
                field(SELECT; Rec.ID)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Caption = 'Posting Date';
                    Editable = false;
                }
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = All;
                    Caption = 'Source Code';
                    Editable = false;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    Caption = 'Document Type';
                    Editable = false;
                }
                field("Document No"; Rec."Document No")
                {
                    ApplicationArea = All;
                    Caption = 'Document No';
                    Editable = false;
                }
                field("Order No"; Rec."Order No")
                {
                    ApplicationArea = All;
                    Caption = 'Order No';
                    Editable = false;
                }
                field(TAXNUMBER; Rec.TAXNUMBER)
                {
                    ApplicationArea = All;
                    Caption = 'Tax No';
                    Editable = false;
                }
                field("Invoice Date"; Rec."Invoice Date")
                {
                    ApplicationArea = All;
                    Caption = 'Invoice Date';
                    Editable = false;
                }
                field("Payment Date"; PaymentDate)
                {
                    ApplicationArea = All;
                    Caption = 'Payment Date';
                    Editable = false;
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;
                    Caption = 'Source Type';
                    Editable = false;
                }
                // field("PPh Code"; Rec. "PPh Code")
                // {
                //     ApplicationArea = All;
                //     Caption = 'PPh Code';
                //     Editable = false;
                // }
                field(WHTProductPostingGroup; Rec.WHTProductPostingGroup)
                {
                    ApplicationArea = All;
                    Caption = 'WHT Product Posting Group';
                    ToolTip = 'WHT Product Posting Group';
                    Editable = false;
                }
                field(WHTProductPostingGroupDesc; WHTProductPostingGroupDesc)
                {
                    ApplicationArea = All;
                    Caption = 'WHT Product Posting Group Name';
                    ToolTip = 'WHT Product Posting Group Name';
                    Editable = false;
                }
                field(WHTPercentage; Rec.WHTPercentage)
                {
                    Caption = 'WHT Percentage (%)';
                    ToolTip = 'WHT Percentage (%)';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(WHTAmount; Rec.WHTAmount)
                {
                    Caption = 'WHT Amount';
                    ToolTip = 'WHT Amount';
                    ApplicationArea = All;
                    //Editable = false;
                }
                field("Remaining Amount"; Rec."Remaining Amount Customer")
                {
                    ApplicationArea = All;
                    Caption = 'Remaining Amount';
                    Editable = false;
                }
                field("Remaining Amount LCY"; Rec."Remaining Amount Customer LCY")
                {
                    ApplicationArea = All;
                    Caption = 'Remaining Amount LCY';
                    Editable = false;
                }
                field("G/L Account No"; Rec."G/L Account No")
                {
                    ApplicationArea = All;
                    Caption = 'G/L Account No';
                    Editable = false;
                }
                field("G/L Account Name"; Rec."G/L Account Name")
                {
                    ApplicationArea = All;
                    Caption = 'G/L Account Name';
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    Editable = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    Caption = 'Quantity';
                    Editable = false;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Amount';
                    //Editable = false;
                }
                field("DPP Amount"; Rec."DPP Amount")
                {
                    ApplicationArea = All;
                    Caption = 'DPP Amount';
                    //Editable = false;
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = All;
                    Caption = 'VAT Amount';
                    //Editable = false;
                }
                field("Bukti Potong Date"; Rec."Bukti Potong Date")
                {
                    ApplicationArea = All;
                    Caption = 'Bukti Potong Date';
                    Editable = true;
                }
                field("Bukti Potong No"; Rec."Bukti Potong No")
                {
                    ApplicationArea = All;
                    Caption = 'Bukti Potong No';
                    Editable = true;
                }
                field("Bukti Potong Status"; Rec."Bukti Potong Status")
                {
                    ApplicationArea = All;
                    Caption = 'Bukti Potong Status';
                    Editable = true;
                }
                field(NPWP; Rec.NPWP)
                {
                    ApplicationArea = All;
                    Caption = 'NPWP';
                    // Editable = false;
                }
                field(NIK; Rec.NIK)
                {
                    ApplicationArea = All;
                    Caption = 'NIK';
                }
                field("Customer No"; Rec."Source No")
                {
                    ApplicationArea = All;
                    Caption = 'Customer No';
                    Editable = false;
                }
                field(Nama; Rec.Nama)
                {
                    ApplicationArea = All;
                    Caption = 'Nama';
                    // Editable = false;
                }
                field("Alamat NPWP"; Rec."Alamat NPWP")
                {
                    ApplicationArea = All;
                    Caption = 'Alamat NPWP';
                    // Editable = false;
                }
                field("External Doc No"; Rec."External Doc No")
                {
                    ApplicationArea = All;
                    Caption = 'External Doc No';
                    Editable = false;
                }
                field("Global Dimension 1"; Rec."Global Dimension 1")
                {
                    ApplicationArea = All;
                    Caption = 'Global Dimension 1';
                    Editable = false;
                }
                field("Global Dimension 2"; Rec."Global Dimension 2")
                {
                    ApplicationArea = All;
                    Caption = 'Global Dimension 2';
                    Editable = false;
                }
                field("Dimension Set ID"; Rec."Dimension Set ID")
                {
                    ApplicationArea = All;
                    Caption = 'Dimension Set ID';
                    Editable = false;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Get NPWP")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = Edit;
                trigger OnAction()
                var
                    PPhCode: Codeunit PPhCode;
                begin
                    PPhCode.GetNPWP(1);
                    CurrPage.Update();
                end;
            }
        }
    }

    VAR
        PaymentDate: Date;
        WHTProductPostingGroupDesc: Text[250];

    trigger OnAfterGetRecord()
    var
        DetailCust: Record "Detailed Cust. Ledg. Entry";
        wht: Record Kre_MasterPPh;
    BEGIN
        DetailCust.Reset();
        DetailCust.SetRange("Cust. Ledger Entry No.", Rec."Entry No Ledger Entry Cust");
        DetailCust.SetRange("Document Type", DetailCust."Document Type"::Payment);
        if DetailCust.FindSet() then
            PaymentDate := DetailCust."Posting Date"
        else
            PaymentDate := 0D;

        wht.Reset();
        if wht.Get(Rec.WHTProductPostingGroup) then
            WHTProductPostingGroupDesc := wht.Description
        else
            WHTProductPostingGroupDesc := '';
    END;
}