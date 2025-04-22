page 60006 PostedPajakMasukanList
{
    PageType = List;
    SourceTable = KRE_TAXJOUR;
    SourceTableView = sorting(ID) order(ascending)
                    where(TAX_SOURCE = filter(1), TAX_POSTED = filter(1));
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Posted Pajak Masukan List';
    InsertAllowed = false;
    CardPageId = PajakMasukanCard;

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
                    ToolTip = '';
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
                                Xmlport.Run(60000, false, false, TAXJ);
                                PajakCode.SetTaxExported(TAXJ);
                            end
                            else begin
                                Xmlport.Run(60002, false, false, TAXJ);
                                PajakCode.SetTaxExported(TAXJ);
                            end;
                        end;
                    end;
                end;
            }

            action("XMLPortToImportReturn")
            {
                ApplicationArea = All;
                Image = ReturnOrder;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Caption = 'Export XML Return';

                trigger OnAction()
                var
                    KRE_TAXJOUR: Record KRE_TAXJOUR;
                    RecRef: RecordRef;
                    SelectionFilterManagement: Codeunit SelectionFilterManagement;
                begin
                    KRE_TAXJOUR.Reset();
                    CurrPage.SetSelectionFilter(KRE_TAXJOUR);
                    RecRef.GetTable(KRE_TAXJOUR);
                    SelectionFilterManagement.GetSelectionFilter(RecRef, KRE_TAXJOUR.FieldNo(ID));
                    XMLCoretax.CreateXMLPurchaseReturn(KRE_TAXJOUR);
                end;
            }
        }
    }

    var
        XMLCoretax: Codeunit "XML Coretax";
}
