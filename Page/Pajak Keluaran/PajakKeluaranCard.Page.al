page 60008 PajakKeluaranCard
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = KRE_TAXJOUR;
    Caption = 'Pajak Keluaran Card';
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
                    ToolTip = '';
                    Editable = false;
                }
                field(DOCUMENTNO; Rec.DOCUMENTNO)
                {
                    ApplicationArea = All;
                    ToolTip = '';
                    Editable = false;
                }
                field("Keterangan Tambahan"; Rec."Keterangan Tambahan")
                {
                    ApplicationArea = All;
                    TableRelation = "Kre Tax Additional Info".Code;
                    ToolTip = '';
                }
                field("Cap Fasilitas"; Rec."Cap Fasilitas")
                {
                    ApplicationArea = All;
                    TableRelation = "Kre Tax Facility Stamp".Code;
                    ToolTip = '';
                }
                field("INVOICE DATE"; Rec.INVOICEDATE)
                {
                    ApplicationArea = All;
                    ToolTip = '';
                    Editable = false;
                }
                field("FG Pengganti"; Rec.FG_Pengganti)
                {
                    ApplicationArea = All;
                    ToolTip = '';
                    Editable = false;
                }
                field("TAX NUMBER"; Rec.TAXNUMBER)
                {
                    ApplicationArea = All;
                    ToolTip = '';
                }
                field("TAX DATE"; Rec.TAXDATE)
                {
                    ApplicationArea = All;
                    ToolTip = '';
                }
                field("RETURN TAX NUMBER"; Rec.RETURN_TAX_NUMBER)
                {
                    ApplicationArea = All;
                    ToolTip = '';
                }
                field("RETURN DOC NUMBER"; Rec.RETURN_DOC_NUMBER)
                {
                    ApplicationArea = All;
                    ToolTip = '';
                }
                field("RETURN DATE"; Rec.RETURN_DATE)
                {
                    ApplicationArea = All;
                    ToolTip = '';
                }
                field("ACCOUNT ID"; Rec.ACCOUNTID)
                {
                    ApplicationArea = All;
                    ToolTip = '';
                    Editable = false;
                }
                field(NPWP; Rec.NPWP)
                {
                    ApplicationArea = All;
                    ToolTip = '';
                }
                field("Customer ID"; Rec."Customer ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer ID field.';
                }
                field(NAMA; Rec.NAMA)
                {
                    ApplicationArea = All;
                    ToolTip = '';
                }
                field(ALAMATNPWP; Rec.ALAMATNPWP)
                {
                    ApplicationArea = All;
                    ToolTip = '';
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
                    ToolTip = 'Specifies the value of the Pre-Assigned No. field.';
                }
            }
            group(Invoice)
            {
                field(CURRENCY; Rec.CURRENCY)
                {
                    ApplicationArea = All;
                    ToolTip = '';
                    Editable = false;
                }
                field("INVOICE AMOUNT"; Rec.INVOICEAMOUNT)
                {
                    ApplicationArea = All;
                    ToolTip = '';
                    Editable = false;
                }
                field("DPP AMOUNT"; Rec.DPPAMOUNT)
                {
                    ApplicationArea = All;
                    ToolTip = '';
                    Editable = false;
                }
                field("VAT AMOUNT"; Rec.VATAMOUNT)
                {
                    ApplicationArea = All;
                    ToolTip = '';
                    Editable = false;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = '';
                    Editable = false;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = '';
                    Editable = false;
                }
                field("VAT Calculation Type"; Rec."VAT Calculation Type")
                {
                    ApplicationArea = All;
                    ToolTip = '';
                    Editable = false;
                }
            }
            group(Other)
            {
                field("IS CREDITABLE"; Rec.IS_CREDITABLE)
                {
                    ApplicationArea = All;
                    ToolTip = '';
                    Editable = false;
                }
                field("TAX SOURCE"; Rec.TAX_SOURCE)
                {
                    ApplicationArea = All;
                    ToolTip = '';
                    Editable = false;
                }
                field("IS RETURNITEM"; Rec.IS_RETURNITEM)
                {
                    ApplicationArea = All;
                    ToolTip = '';
                    Editable = false;
                }
                field("TAX POSTED"; Rec.TAX_POSTED)
                {
                    ApplicationArea = All;
                    ToolTip = '';
                    //Editable = false;
                }
                field("TAX EXPORTED"; Rec.TAX_EXPORTED)
                {
                    ApplicationArea = All;
                    ToolTip = '';
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
                field("Jenis ID Pembeli"; Rec."Jenis ID Pembeli")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Jenis ID Pembeli field.';
                    Editable = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the LOCATION CODE field.';
                    Editable = false;
                }
                field("ID TKU Pembeli"; Rec."ID TKU Pembeli")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ID TKU Pembeli field.';
                    Editable = false;
                }
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Code field.';
                    Editable = false;
                }
            }

            part("Pajak Keluaran Lines"; PajakKeluaranLines)
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
                PromotedOnly = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                ToolTip = 'Posting';
                Visible = btn_posting;
                Image = PostingEntries;
                trigger OnAction()
                var
                    PajakCode: Codeunit PajakCode;
                begin
                    PajakCode.SetPostingPajakTrueLine(Rec.ID);
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
                ToolTip = 'Executes the Export XML action.';

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
                        XMLCoretax.CreateXMLSalesReturn(KRE_TAXJOUR)
                    else
                        XMLCoretax.CreateXMLSalesOrder(KRE_TAXJOUR);
                end;
            }
            action("Export Efaktur")
            {
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                ToolTip = 'Export Efaktur';
                Visible = btn_export;
                Image = ExportFile;
                trigger OnAction()
                var
                    TAXJ: Record KRE_TAXJOUR;
                    PajakCode: Codeunit PajakCode;
                    YN: Enum YESNO;
                begin
                    TAXJ.Reset();
                    TAXJ.SetRange(ID, Rec.ID);
                    if (TAXJ.IS_RETURNITEM = YN::NO) then begin
                        Xmlport.Run(60001, false, false, TAXJ);
                        PajakCode.SetTaxExported(TAXJ);
                    end
                    else begin
                        Xmlport.Run(60003, false, false, TAXJ);
                        PajakCode.SetTaxExported(TAXJ);
                    end;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if (Rec.TAX_POSTED = YesNo::NO) then begin
            btn_export := false;
            btn_posting := true;
        end
        else begin
            btn_export := true;
            btn_posting := false;
        end;
    end;

    var
        YesNo: Enum YESNO;
        btn_export: Boolean;
        btn_posting: Boolean;
}