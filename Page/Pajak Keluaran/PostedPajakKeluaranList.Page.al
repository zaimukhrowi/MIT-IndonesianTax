page 60004 PostedPajakKeluaranList
{
    PageType = List;
    SourceTable = KRE_TAXJOUR;
    SourceTableView = sorting(ID) order(ascending)
                    where(TAX_SOURCE = filter(2), TAX_POSTED = filter(1));
    UsageCategory = Lists;
    Caption = 'Posted Pajak Keluaran List';
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
                    NotBlank = true;
                }
                field("TAX DATE"; Rec.TAXDATE)
                {
                    ApplicationArea = All;
                    NotBlank = true;
                }
                field("IS RETURNITEM"; Rec.IS_RETURNITEM)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("RETURN TAX NUMBER"; Rec.RETURN_TAX_NUMBER)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("RETURN DOC NUMBER"; Rec.RETURN_DOC_NUMBER)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("RETURN DATE"; Rec.RETURN_DATE)
                {
                    ApplicationArea = All;
                    Editable = false;
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
                field(Notes; Rec.Notes)
                {
                    ApplicationArea = All;
                    ToolTip = '';
                }
                field("Keterangan Tambahan"; Rec."Keterangan Tambahan")
                {
                    ApplicationArea = All;
                    ToolTip = '';
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
            action("Export Efaktur")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = ExportFile;
                trigger OnAction()
                var
                    TAXJ: Record KRE_TAXJOUR;
                    PajakCode: Codeunit PajakCode;
                    isretur: Integer;
                    totaltrans: Integer;
                    trans: Integer;
                begin
                    if TAXJ.Count() = 0 then
                        Message('No Data')

                    else begin
                        TAXJ.Reset();
                        CurrPage.SetSelectionFilter(TAXJ);
                        totaltrans := TAXJ.Count();
                        isretur := PajakCode.CheckTransBeforeExport(TAXJ);
                        trans := PajakCode.TotalTransFilter(TAXJ, isretur);

                        TAXJ.Reset();

                        CurrPage.SetSelectionFilter(TAXJ); //Filter ulang transaksi setelah di reset
                        if trans <> totaltrans then begin
                            PajakCode.CheckTransType(TAXJ);
                            Error('Please check your selected journal');
                        end else begin
                            TAXJ.SetFilter(TAX_Cancelled, '<>%1', Rec.TAX_Cancelled::YES);

                            if isretur = 0 then begin
                                Xmlport.Run(60001, false, false, TAXJ);
                                PajakCode.SetTaxExported(TAXJ);
                            end
                            else begin
                                Xmlport.Run(60003, false, false, TAXJ);
                                PajakCode.SetTaxExported(TAXJ);
                            end;
                        end;
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
                    XMLPajakKeluaran: XmlPort "XML Pajak Keluaran";
                    Content: Text;
                    TxtBuilder: TextBuilder;
                begin
                    KRE_TAXJOUR.Reset();
                    CurrPage.SetSelectionFilter(KRE_TAXJOUR);
                    XMLCoretax.CreateXML(KRE_TAXJOUR);
                end;
            }
            action("Synchronize Customer")
            {
                ApplicationArea = All;
                Image = RefreshRegister;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Caption = 'Synchronize Customer';

                trigger OnAction()
                begin
                    XMLCoretax.SynchronizeCustomer();
                end;
            }
        }
    }
    var
        XMLCoretax: Codeunit "XML Coretax";
}
