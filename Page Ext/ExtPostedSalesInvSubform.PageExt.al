pageextension 60032 ExtPostedSalesInvSubform extends "Posted Sales Invoice Subform"
{
    Editable = true;
    layout
    {
        addafter(Description)
        {
            field(IsWHTCalc; Rec.IsWHTCalc)
            {
                Editable = true;
                ApplicationArea = All;
            }
        }
        addafter("Job No.")
        {
            field(WHTProductPostingGroup; Rec.WHTProductPostingGroup)
            {
                ApplicationArea = All;
                Caption = 'WHT Product Posting Group';
                ToolTip = 'WHT Product Posting Group';
            }
            field(WHTPercentage; Rec.WHTPercentage)
            {
                Caption = 'WHT Percentage (%)';
                ToolTip = 'WHT Percentage (%)';
                ApplicationArea = All;
            }
            field(WHTAmount; Rec.WHTAmount)
            {
                Caption = 'WHT Amount';
                ToolTip = 'WHT Amount';
                ApplicationArea = All;
            }
            field("WHTAmount Additional Currency"; Rec."WHTAmount Additional Currency")
            {
                Caption = 'WHT Amount Additional Currency';
                ToolTip = 'WHT Amount Additional Currency';
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            action("Send to Tax Jour")
            {
                ToolTip = 'Send to Tax Jour';
                Caption = 'Send to Tax Jour';
                ApplicationArea = All;
                Image = Indent;
                // Promoted = true;
                trigger OnAction()
                var
                    SILine: Record "Sales Invoice Line";
                begin
                    CurrPage.SetSelectionFilter(SILine);
                    if SILine.FindSet() then
                        repeat
                            UpdateFlagisWHT(SILine."Document No.", SILine."Line No.");
                            SalestoJournalLine(SILine."Document No.", SILine."VAT Prod. Posting Group", SILine."Line No.");
                        until SILine.Next() = 0;
                    Message('Success!');
                end;
            }
        }
    }

    local procedure UpdateFlagisWHT(DocNo: Code[20]; LineNo: Integer)
    begin
        if Rec.Get(DocNo, LineNo) then begin
            Rec.IsWHTCalc := false;
        end;
    end;

    local procedure SalestoJournalLine(DocNo: code[20]; VAT_Prod__Posting_Group: Code[20]; LineNo: Integer)
    var
        SalesLineInv: Record "Sales Invoice Line";
        TaxJourLines: Record KRE_TAXJOURLINES;
        PajakCode: Codeunit PajakCode;
        SelisihVAT: Decimal;
        VATGroup: Record "VAT Product Posting Group";
    begin
        SalesLineInv.Reset();
        SalesLineInv.SetRange("Document No.", DocNo);
        SalesLineInv.SetRange("Line No.", LineNo);
        //Validasi VAT Amount Header dgn Line 
        if SalesLineInv.IsEmpty = false then
            SelisihVAT := PajakCode.ValidasiVATAmountSalesLineInv(DocNo, SalesLineInv);
        //Validasi VAT Amount Header dgn Line 
        if SalesLineInv.FindSet() then begin
            TaxJourLines.LockTable();
            repeat
                TaxJourLines.Init();
                TaxJourLines.KRE_TAXJOURID := GetLastID(DocNo);
                TaxJourLines.INVOICELINENO := SalesLineInv."Line No.";
                TaxJourLines.INVOICENo := DocNo;
                TaxJourLines.TYPE := SalesLineInv.Type;
                TaxJourLines.ITEMID := SalesLineInv."No.";
                TaxJourLines.DESCRIPTION := SalesLineInv.Description;
                TaxJourLines.VAT_Bus_Posting_Group := SalesLineInv."VAT Bus. Posting Group";
                TaxJourLines.VAT_Prod_Posting_Group := SalesLineInv."VAT Prod. Posting Group";
                TaxJourLines.VAT_Identifier := SalesLineInv."VAT Identifier";
                TaxJourLines.PRICE := SalesLineInv."Unit Price";
                TaxJourLines.QTY := system.Round(SalesLineInv.Quantity, 1, '>');
                TaxJourLines.TOTAL_AMOUNT := SalesLineInv."Line Amount";
                TaxJourLines.DISCOUNT_AMOUNT := SalesLineInv."Line Discount Amount";
                VATGroup.Reset();
                VATGroup.SetRange("Code", VAT_Prod__Posting_Group);
                VATGroup.FindFirst();
                if (VATGroup.IS_FORWARDER = true) then
                    TaxJourLines.DPP_AMOUNT := SalesLineInv."VAT Base Amount" / 10
                else
                    TaxJourLines.DPP_AMOUNT := SalesLineInv."VAT Base Amount";

                if SelisihVAT > 0 then begin
                    if SalesLineInv."Line No." = 10000 then
                        TaxJourLines.VAT_AMOUNT := ((SalesLineInv."VAT Base Amount" * SalesLineInv."VAT %") / 100) - SelisihVAT
                    else
                        TaxJourLines.VAT_AMOUNT := ((SalesLineInv."VAT Base Amount" * SalesLineInv."VAT %") / 100);
                end
                else
                    TaxJourLines.VAT_AMOUNT := ((SalesLineInv."VAT Base Amount" * SalesLineInv."VAT %") / 100);

                TaxJourLines.Insert();
            until (SalesLineInv.Next() = 0);
        end;
    end;

    local procedure GetLastID(DocNo: Code[20]): Integer
    var
        KRE_TAXJOUR: Record KRE_TAXJOUR;
    begin
        KRE_TAXJOUR.SetRange(INVOICENO, DocNo);
        if KRE_TAXJOUR.FindFirst() then
            exit(KRE_TAXJOUR.ID)
        else
            exit(0);
    end;
}