pageextension 60033 ExtPostedPurchInvSubform extends "Posted Purch. Invoice Subform"
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

            field("WHT Source Type"; Rec."WHT Source Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the WHT Source Type field.';
                Caption = 'WHT Source Type';
            }
            field("WHT Source No."; Rec."WHT Source No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the WHT Source No. field.';
                Caption = 'WHT Source No.';
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
                    PILine: Record "Purch. Inv. Line";
                begin
                    CurrPage.SetSelectionFilter(PILine);
                    if PILine.FindSet() then
                        repeat
                            UpdateFlagisWHT(PILine."Document No.", PILine."Line No.");
                            PurchasetoJournalLine(PILine."Document No.", PILine."VAT Prod. Posting Group", PILine."Line No.");
                        until PILine.Next() = 0;
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

    local procedure PurchasetoJournalLine(DocNo: code[20]; VAT_Prod__Posting_Group: Code[20]; LineNo: Integer)
    var
        PurchLineInv: Record "Purch. Inv. Line";
        TaxJourLines: Record KRE_TAXJOURLINES;
        PajakCode: Codeunit PajakCode;
        SelisihVAT: Decimal;
        VATGroup: Record "VAT Product Posting Group";
    begin
        PurchLineInv.Reset();
        PurchLineInv.SetRange("Document No.", DocNo);
        PurchLineInv.SetRange("Line No.", LineNo);
        //Validasi VAT Amount Header dgn Line 
        if PurchLineInv.IsEmpty = false then
            SelisihVAT := PajakCode.ValidasiVATAmountPurchaseLineInv(DocNo, PurchLineInv);
        //Validasi VAT Amount Header dgn Line 
        if PurchLineInv.FindSet() then begin
            TaxJourLines.LockTable();
            repeat
                TaxJourLines.Init();
                TaxJourLines.KRE_TAXJOURID := GetLastID(DocNo);
                TaxJourLines.INVOICELINENO := PurchLineInv."Line No.";
                TaxJourLines.INVOICENo := DocNo;
                TaxJourLines.TYPE := PurchLineInv.Type;
                TaxJourLines.ITEMID := PurchLineInv."No.";
                TaxJourLines.DESCRIPTION := PurchLineInv.Description;
                TaxJourLines.VAT_Bus_Posting_Group := PurchLineInv."VAT Bus. Posting Group";
                TaxJourLines.VAT_Prod_Posting_Group := PurchLineInv."VAT Prod. Posting Group";
                TaxJourLines.VAT_Identifier := PurchLineInv."VAT Identifier";
                TaxJourLines.PRICE := PurchLineInv."Direct Unit Cost";
                TaxJourLines.QTY := system.Round(PurchLineInv.Quantity, 1, '>');
                TaxJourLines.TOTAL_AMOUNT := PurchLineInv."Line Amount";
                TaxJourLines.DISCOUNT_AMOUNT := PurchLineInv."Line Discount Amount";
                TaxJourLines.DPP_AMOUNT := PurchLineInv."VAT Base Amount";

                if SelisihVAT > 0 then begin
                    if PurchLineInv."Line No." = 10000 then
                        TaxJourLines.VAT_AMOUNT := ((PurchLineInv."VAT Base Amount" * PurchLineInv."VAT %") / 100) - SelisihVAT
                    else
                        TaxJourLines.VAT_AMOUNT := ((PurchLineInv."VAT Base Amount" * PurchLineInv."VAT %") / 100);
                end
                else
                    TaxJourLines.VAT_AMOUNT := ((PurchLineInv."VAT Base Amount" * PurchLineInv."VAT %") / 100);

                TaxJourLines.Insert();
            until (PurchLineInv.Next() = 0);
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