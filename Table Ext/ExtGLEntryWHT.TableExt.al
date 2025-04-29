tableextension 60017 ExtGLEntryWHT extends "G/L Entry"
{
    fields
    {
        field(60000; WHTProductPostingGroup; Code[25])
        {
            TableRelation = Kre_MasterPPh.PPhCode;
            DataClassification = ToBeClassified;
            // AccessByPermission = TableData "G/L Entry" = m;
        }
        field(60001; WHTPercentage; Decimal)
        {
            DataClassification = ToBeClassified;
            //AccessByPermission = TableData "G/L Entry" = m;
        }
        field(60002; WHTAmount; Decimal)
        {
            DataClassification = ToBeClassified;
            //AccessByPermission = TableData "G/L Entry" = m;
        }
        field(60003; "WHTAmount Additional Currency"; Decimal)
        {
            DataClassification = ToBeClassified;
            //AccessByPermission = TableData "G/L Entry" = m;
        }
    }

    // trigger OnModify()
    // var
    //     PPhCode: Codeunit PPhCode;
    // begin
    //     PPhCode.Run();
    // end;

    trigger OnAfterInsert()
    var
        //     SalesInv: Record "Sales Invoice Line";
        //     SalesCrMm: Record "Sales Cr.Memo Line";
        //     PurchInv: Record "Purch. Inv. Line";
        //     PurchCrMm: Record "Purch. Cr. Memo Line";
        //     GJLine: Record "Gen. Journal Line";
        PPhCode: Codeunit PPhCode;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOnAfterInsert(IsHandled, Rec);
        if IsHandled then
            exit;

        PPhCode.UpdateGLEntryWHT(Rec."Entry No.");

        // case "Gen. Posting Type" of
        //     "Gen. Posting Type"::Sale:
        //         begin
        //             case "Document Type" of
        //                 "Document Type"::Invoice:
        //                     begin
        //                         SalesInv.SetRange("Document No.", "Document No.");
        //                         SalesInv.SetRange("No.", "G/L Account No.");
        //                         SalesInv.SetRange(Amount, Amount * -1);
        //                         if SalesInv.FindFirst() then begin
        //                             Rec.WHTProductPostingGroup := SalesInv.WHTProductPostingGroup;
        //                             Rec.WHTPercentage := SalesInv.WHTPercentage;
        //                             Rec.WHTAmount := SalesInv.WHTAmount;
        //                             Rec.Modify();
        //                         end;
        //                     end;
        //                 "Document Type"::"Credit Memo":
        //                     begin
        //                         SalesCrMm.SetRange("Document No.", "Document No.");
        //                         SalesCrMm.SetRange("No.", "G/L Account No.");
        //                         SalesCrMm.SetRange(Amount, Amount * -1);
        //                         if SalesCrMm.FindFirst() then begin
        //                             Rec.WHTProductPostingGroup := SalesCrMm.WHTProductPostingGroup;
        //                             Rec.WHTPercentage := SalesCrMm.WHTPercentage;
        //                             Rec.WHTAmount := SalesCrMm.WHTAmount;
        //                             Rec.Modify();
        //                         end;
        //                     end;
        //                 else
        //             end;
        //         end;
        //     "Gen. Posting Type"::Purchase:
        //         begin
        //             case "Document Type" of
        //                 "Document Type"::Invoice:
        //                     begin
        //                         PurchInv.SetRange("Document No.", "Document No.");
        //                         PurchInv.SetRange("No.", "G/L Account No.");
        //                         PurchInv.SetRange(Amount, Amount * -1);
        //                         if PurchInv.FindFirst() then begin
        //                             Rec.WHTProductPostingGroup := PurchInv.WHTProductPostingGroup;
        //                             Rec.WHTPercentage := PurchInv.WHTPercentage;
        //                             Rec.WHTAmount := PurchInv.WHTAmount;
        //                             Rec.Modify();
        //                         end;
        //                     end;
        //                 "Document Type"::"Credit Memo":
        //                     begin
        //                         PurchCrMm.SetRange("Document No.", "Document No.");
        //                         PurchCrMm.SetRange("No.", "G/L Account No.");
        //                         PurchCrMm.SetRange(Amount, Amount * -1);
        //                         if PurchCrMm.FindFirst() then begin
        //                             Rec.WHTProductPostingGroup := PurchCrMm.WHTProductPostingGroup;
        //                             Rec.WHTPercentage := PurchCrMm.WHTPercentage;
        //                             Rec.WHTAmount := PurchCrMm.WHTAmount;
        //                             Rec.Modify();
        //                         end;
        //                     end;
        //                 else
        //             end;
        //         end;
        //     "Gen. Posting Type"::" ":
        //         begin
        //             case "Document Type" of
        //                 "Document Type"::Payment:
        //                     begin
        //                         GJLine.SetRange("Document No.", "Document No.");
        //                         GJLine.SetRange("Account No.", "G/L Account No.");
        //                         GJLine.SetRange(Amount, Amount * -1);
        //                         if GJLine.FindFirst() then begin
        //                             Rec.WHTProductPostingGroup := GJLine.WHTProductPostingGroup;
        //                             Rec.WHTPercentage := GJLine.WHTPercentage;
        //                             Rec.WHTAmount := GJLine.WHTAmount;
        //                             Rec.Modify();
        //                         end;
        //                     end;
        //                 else
        //             end;
        //         end;
        //     else
        // end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnAfterInsert(var IsHandled: Boolean; GLEntry: Record "G/L Entry")
    begin
    end;
}