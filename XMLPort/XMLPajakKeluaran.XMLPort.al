// xmlport 60005 "XML Pajak Keluaran"
// {
//     Format = Xml;
//     Encoding = UTF8;
//     Direction = Export;
//     UseRequestPage = false;
//     PreserveWhiteSpace = true;

//     schema
//     {
//         tableelement("Company Information"; "Company Information")
//         {
//             XmlName = 'TaxInvoiceBulk';
//             textattribute("xmlns:xsi") { }
//             textattribute("xsi:noNamespaceSchemaLocation") { }
//             fieldelement(TIN; "Company Information"."VAT Registration No.") { }
//             tableelement(KRE_TAXJOUR; KRE_TAXJOUR)
//             {
//                 XmlName = 'ListOfTaxInvoice';

//                 textelement(TaxInvoice)
//                 {
//                     fieldelement(TaxInvoiceDate; "Company Information"."Custom System Indicator Text")
//                     {
//                         trigger OnBeforePassField()
//                         begin
//                             "Company Information"."Custom System Indicator Text" := Format(KRE_TAXJOUR.TAXDATE, 10, '<Year4>-<Month,2>-<Day,2>');
//                         end;
//                     }
//                     fieldelement(TaxInvoiceOpt; "Company Information"."Custom System Indicator Text")
//                     {
//                         trigger OnBeforePassField()
//                         begin
//                             "Company Information"."Custom System Indicator Text" := 'Normal';
//                         end;
//                     }
//                     fieldelement(TrxCode; KRE_TAXJOUR."Kode Transaksi") { }
//                     fieldelement(AddInfo; "Company Information"."Custom System Indicator Text")
//                     {
//                         trigger OnBeforePassField()
//                         begin
//                             "Company Information".Reset();
//                             "Company Information"."Custom System Indicator Text" := '';
//                         end;
//                     }
//                     fieldelement(CustomDoc; "Company Information"."Custom System Indicator Text") { }
//                     fieldelement(CustomDocMonthYear; "Company Information"."Custom System Indicator Text") { }
//                     fieldelement(RefDesc; KRE_TAXJOUR.INVOICENO) { }
//                     textelement(FacilityStamp) { }
//                     fieldelement(SellerIDTKU; "Company Information"."Custom System Indicator Text")
//                     {
//                         trigger OnBeforePassField()
//                         var
//                             Location: Record Location;
//                         begin
//                             if Location.Get(KRE_TAXJOUR."Location Code") then
//                                 "Company Information"."Custom System Indicator Text" := Location."Kre ID TKU";
//                         end;
//                     }
//                     fieldelement(BuyerTin; "Company Information"."Custom System Indicator Text")
//                     {
//                         trigger OnBeforePassField()
//                         begin
//                             if KRE_TAXJOUR."Jenis ID Pembeli" <> KRE_TAXJOUR."Jenis ID Pembeli"::TIN then
//                                 "Company Information"."Custom System Indicator Text" := '0000000000000000'
//                             else begin
//                                 if StrLen(KRE_TAXJOUR.NPWP) = 15 then
//                                     "Company Information"."Custom System Indicator Text" := '0' + KRE_TAXJOUR.NPWP
//                                 else
//                                     "Company Information"."Custom System Indicator Text" := KRE_TAXJOUR.NPWP
//                             end;

//                         end;
//                     }
//                     fieldelement(BuyerDocument; KRE_TAXJOUR."Jenis ID Pembeli") { }
//                     fieldelement(BuyerCountry; "Company Information"."Custom System Indicator Text")
//                     {
//                         trigger OnBeforePassField()
//                         begin
//                             "Company Information"."Custom System Indicator Text" := 'IDN';
//                         end;
//                     }
//                     fieldelement(BuyerDocumentNumber; KRE_TAXJOUR.NPWP)
//                     {
//                         trigger OnBeforePassField()
//                         begin
//                             if KRE_TAXJOUR."Jenis ID Pembeli" = KRE_TAXJOUR."Jenis ID Pembeli"::TIN then
//                                 KRE_TAXJOUR.NPWP := '-';
//                         end;
//                     }
//                     fieldelement(BuyerName; KRE_TAXJOUR.NAMA) { }
//                     fieldelement(BuyerAdress; KRE_TAXJOUR.ALAMATNPWP) { }
//                     fieldelement(BuyerEmail; "Company Information"."Custom System Indicator Text")
//                     {
//                         trigger OnBeforePassField()
//                         begin
//                             "Company Information"."Custom System Indicator Text" := '';
//                         end;
//                     }
//                     fieldelement(BuyerIDTKU; KRE_TAXJOUR."ID TKU Pembeli") { }
//                     textelement(ListOfGoodService)
//                     {
//                         tableelement(KRE_TAXJOURLINES; KRE_TAXJOURLINES)
//                         {
//                             XmlName = 'GoodService';

//                             fieldelement(Opt; KRE_TAXJOURLINES.TYPE) { }
//                             fieldelement(Code; KRE_TAXJOURLINES.TYPE) { }
//                             fieldelement(Name; KRE_TAXJOURLINES.TYPE) { }
//                             fieldelement(Unit; KRE_TAXJOURLINES.TYPE) { }
//                             fieldelement(Price; KRE_TAXJOURLINES.TYPE) { }
//                             fieldelement(Qty; KRE_TAXJOURLINES.TYPE) { }
//                             fieldelement(TotalDiscount; KRE_TAXJOURLINES.TYPE) { }
//                             fieldelement(TaxBase; KRE_TAXJOURLINES.TYPE) { }
//                             fieldelement(OtherTaxBase; KRE_TAXJOURLINES.TYPE) { }
//                             fieldelement(VATRate; KRE_TAXJOURLINES.TYPE) { }
//                             fieldelement(VAT; KRE_TAXJOURLINES.TYPE) { }
//                             fieldelement(STLGRate; KRE_TAXJOURLINES.TYPE) { }
//                             fieldelement(STLG; KRE_TAXJOURLINES.TYPE) { }
//                         }
//                     }
//                 }

//                 trigger OnPreXmlItem()
//                 begin
//                     KRE_TAXJOUR.SetRange(TAX_POSTED, KRE_TAXJOUR.TAX_POSTED::YES);
//                 end;
//             }

//             trigger OnAfterGetRecord()
//             begin
//                 "xmlns:xsi" := 'http://www.w3.org/2001/XMLSchema-instance';
//                 "xsi:noNamespaceSchemaLocation" := 'TaxInvoice.xsd';
//             end;
//         }

//     }


//     var
//         PostingDate: Text;
// }