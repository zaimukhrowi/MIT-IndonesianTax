codeunit 60002 Notifikasi
{
    trigger OnRun()
    begin

    end;

    procedure ValidasiBeforePosting(NotifValidasi: Notification)
    var
        TaxJour: Record KRE_TAXJOUR;
        InvNo: Text;
    begin
        InvNo := NotifValidasi.GetData('InvNo');
        TaxJour.Reset();
        TaxJour.SetRange(INVOICENO, InvNo);
        if TaxJour.FindFirst() then
            if TaxJour.TAX_SOURCE = TaxJour.TAX_SOURCE::Purchase then begin
                if TaxJour.IS_RETURNITEM = TaxJour.IS_RETURNITEM::YES then begin
                    if (TaxJour.RETURN_DATE = 0D) OR (TaxJour.RETURN_DOC_NUMBER = '') OR (TaxJour.RETURN_TAX_NUMBER = '') then
                        Error('Please fill Return Tax Number, Return Tax Date and Return Doc Number on Invoice No: %1', InvNo);
                end
                else
                    if (TaxJour.TAXDATE = 0D) OR (TaxJour.TAXNUMBER = '') then
                        Error('Please fill Tax Number and Tax Date on Invoice No: %1', InvNo);

            end else
                if TaxJour.IS_RETURNITEM = TaxJour.IS_RETURNITEM::YES then begin
                    if (TaxJour.RETURN_DATE = 0D) OR (TaxJour.RETURN_DOC_NUMBER = '') then
                        Error('Please fill Return Tax Date on Invoice No: %1', InvNo)
                end
                else
                    if TaxJour.TAXDATE = 0D then
                        Error('Please fill Tax Date on Invoice No: %1', InvNo);
    end;

}