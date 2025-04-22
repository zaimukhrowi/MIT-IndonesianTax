page 60010 PajakMasukanCard
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = KRE_TAXJOUR;
    Caption = 'Pajak Masukan Card';
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
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
                field("INVOICE DATE"; Rec.INVOICEDATE)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("FG Pengganti"; Rec.FG_Pengganti)
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
                field("ACCOUNT ID"; Rec.ACCOUNTID)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(NPWP; Rec.NPWP)
                {
                    ApplicationArea = All;
                }
                field(NAMA; Rec.NAMA)
                {
                    ApplicationArea = All;
                }
                field(ALAMATNPWP; Rec.ALAMATNPWP)
                {
                    ApplicationArea = All;
                }
                field(Kode_Dokumen_Pendukung; Rec.Kode_Dokumen_Pendukung)
                {
                    ApplicationArea = All;
                    ToolTip = '';
                }
                field("Pre-Assigned No."; Rec."Pre-Assigned No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            group(Invoice)
            {
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
            }
            group(Other)
            {
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
                field("IS RETURNITEM"; Rec.IS_RETURNITEM)
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
                    ToolTip = '';
                }
                field(Notes; Rec.Notes)
                {
                    ApplicationArea = All;
                    ToolTip = '';
                }
            }
            part("Pajak Masukan Lines"; PajakMasukanLines)
            {
                SubPageLink = KRE_TAXJOURID = field(ID);
                UpdatePropagation = SubPart;
                Visible = true;
                ApplicationArea = All;

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
                Visible = btn_posting;
                Image = PostingEntries;
                trigger OnAction()
                var
                    PajakCode: Codeunit PajakCode;
                begin
                    PajakCode.SetPostingPajakTrueLine(Rec.ID);
                end;
            }
            action("Export Efaktur")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Visible = btn_export;
                Image = ExportFile;
                trigger OnAction()
                var
                    TAXJ: Record KRE_TAXJOUR;
                    PajakCode: Codeunit PajakCode;
                begin
                    TAXJ.Reset();
                    TAXJ.SetRange(ID, Rec.ID);
                    if (TAXJ.IS_RETURNITEM = TAXJ.IS_RETURNITEM::NO) then begin
                        Xmlport.Run(60000, false, false, TAXJ);
                        PajakCode.SetTaxExported(TAXJ);
                    end
                    else begin
                        Xmlport.Run(60002, false, false, TAXJ);
                        PajakCode.SetTaxExported(TAXJ);
                    end;
                end;
            }
            action("XMLPortToImport")
            {
                ApplicationArea = All;
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Caption = 'Export XML';

                trigger OnAction()
                var
                    KRE_TAXJOUR: Record KRE_TAXJOUR;
                    RecRef: RecordRef;
                    SelectionFilterManagement: Codeunit SelectionFilterManagement;
                    XMLCoretax: Codeunit "XML Coretax";
                begin
                    KRE_TAXJOUR.Reset();
                    CurrPage.SetSelectionFilter(KRE_TAXJOUR);
                    RecRef.GetTable(KRE_TAXJOUR);
                    SelectionFilterManagement.GetSelectionFilter(RecRef, KRE_TAXJOUR.FieldNo(ID));
                    if Rec.IS_RETURNITEM = Rec.IS_RETURNITEM::YES then
                        XMLCoretax.CreateXMLPurchaseReturn(KRE_TAXJOUR)
                    // else
                    // XMLCoretax.CreateXMLSalesOrder(KRE_TAXJOUR);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if (Rec.TAX_POSTED = Rec.TAX_POSTED::NO) then begin
            btn_export := false;
            btn_posting := true;
        end
        else begin
            btn_export := true;
            btn_posting := false;
        end;
    end;

    var
        btn_export: Boolean;
        btn_posting: Boolean;
}