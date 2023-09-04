page 60022 PajakKeluaranDigunggungList
{
    PageType = List;
    SourceTable = KRE_TAXJOUR;
    SourceTableView = sorting(ID) order(ascending)
                    where(TAX_SOURCE = filter(2), TAX_POSTED = filter(0));
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Pajak Keluaran Digunggung List';
    InsertAllowed = false;
    CardPageId = PajakKeluaranCard;

    layout
    {
        area(Content)
        {
            repeater(PajakKeluaran)
            {
                field(SELECT; Rec.ID)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("TAX NUMBER"; Rec.TAXNUMBER)
                {
                    ApplicationArea = All;
                }
                field("TAX DATE"; Rec.TAXDATE)
                {
                    ApplicationArea = All;
                }
                field("IS RETURNITEM"; Rec.IS_RETURNITEM)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("RETURN TAX NUMBER"; Rec.RETURN_TAX_NUMBER)
                {
                    ApplicationArea = All;
                }
                field("RETURN DOC NUMBER"; Rec.RETURN_DOC_NUMBER)
                {
                    ApplicationArea = All;
                }
                field("RETURN DATE"; Rec.RETURN_DATE)
                {
                    ApplicationArea = All;
                }
                field("INVOICE NO"; Rec.INVOICENO)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(DOCUMENTNO; Rec.DOCUMENTNO)
                {
                    ApplicationArea = All;
                    ToolTip = '';
                    Editable = false;
                }
                field("Pre-Assigned No."; Rec."Pre-Assigned No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("INVOICE DATE"; Rec.INVOICEDATE)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("ACCOUNT ID"; Rec.ACCOUNTID)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(NPWP; Rec.NPWP)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(NAMA; Rec.NAMA)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(ALAMATNPWP; Rec.ALAMATNPWP)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(CURRENCY; Rec.CURRENCY)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("INVOICE AMOUNT"; Rec.INVOICEAMOUNT)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("DPP AMOUNT"; Rec.DPPAMOUNT)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("VAT AMOUNT"; Rec.VATAMOUNT)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("VAT Calculation Type"; Rec."VAT Calculation Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("IS CREDITABLE"; Rec.IS_CREDITABLE)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("TAX SOURCE"; Rec.TAX_SOURCE)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("TAX POSTED"; Rec.TAX_POSTED)
                {
                    ApplicationArea = All;
                    //Editable = false;
                }
                field("TAX EXPORTED"; Rec.TAX_EXPORTED)
                {
                    ApplicationArea = All;
                    //Editable = false;
                }
                field("TAX CANCELLED"; Rec.TAX_Cancelled)
                {
                    ApplicationArea = All;
                }
            }
        }

    }
    actions
    {
        area(Processing)
        {
            action("Posting")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = PostingEntries;
                trigger OnAction()
                var
                    TAXJ: Record KRE_TAXJOUR;
                    PajakCode: Codeunit PajakCode;
                begin
                    if TAXJ.Count() = 0 then
                        Message('No Data')

                    else begin
                        CurrPage.SetSelectionFilter(TAXJ);
                        PajakCode.SetPostingPajakTrue(TAXJ);
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        Setup: Record Kre_TaxSetup;
    begin
        if Setup.FindFirst() then
            Rec.SetRange("VAT Bus. Posting Group", Setup."VAT Retail");
    end;
}