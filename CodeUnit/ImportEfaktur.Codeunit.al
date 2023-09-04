codeunit 60003 ImportEfaktur
{
    procedure GetResponse(Url: Text[250])
    var
        Kre_EFaktur: Record Kre_EFaktur;

        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        XMLResponse: Text;
        XMLDoc: XmlDocument;
        i: Integer;
        j: Integer;
        // k: Integer;

        NodeList_resValidateFakturPm: XmlNodeList;
        Node_kdJenisTransaksi: XmlNode;
        Node_fgPengganti: XmlNode;
        Node_nomorFaktur: XmlNode;
        Node_tanggalFaktur: XmlNode;
        Node_npwpPenjual: XmlNode;
        Node_namaPenjual: XmlNode;
        Node_alamatPenjual: XmlNode;
        Node_npwpLawanTransaksi: XmlNode;
        Node_namaLawanTransaksi: XmlNode;
        Node_alamatLawanTransaksi: XmlNode;
        Node_jumlahDpp: XmlNode;
        Node_jumlahPpn: XmlNode;
        Node_jumlahPpnBm: XmlNode;
        Node_statusApproval: XmlNode;
        Node_statusFaktur: XmlNode;
        Node_referensi: XmlNode;

        NodeList_detailTransaksi: XmlNodeList;
        Node_nama: XmlNode;
        Node_hargaSatuan: XmlNode;
        Node_jumlahBarang: XmlNode;
        Node_hargaTotal: XmlNode;
        Node_diskon: XmlNode;
        Node_dpp: XmlNode;
        Node_ppn: XmlNode;
        Node_tarifPpnbm: XmlNode;
        Node_ppnbm: XmlNode;

        _kdJenisTransaksi: Text;
        _fgPengganti: Text;
        _nomorFaktur: Text;
        _tanggalFaktur: Text;
        _npwpPenjual: Text;
        _namaPenjual: Text;
        _alamatPenjual: Text;
        _npwpLawanTransaksi: Text;
        _namaLawanTransaksi: Text;
        _alamatLawanTransaksi: Text;
        _jumlahDpp: Text;
        _jumlahPpn: Text;
        _jumlahPpnBm: Text;
        _statusApproval: Text;
        _statusFaktur: Text;
        _referensi: Text;

        _nama: Text;
        _hargaSatuan: Text;
        _jumlahBarang: Text;
        _hargaTotal: Text;
        _diskon: Text;
        _dpp: Text;
        _ppn: Text;
        _tarifPpnbm: Text;
        _ppnbm: Text;

    begin
        Client.DefaultRequestHeaders().Add('User-Agent', 'Dynamics 365');

        Client.Get(Url, ResponseMessage);

        if InvoiceAlreadyExists(Url) then
            Error('Invoice already scan !');

        if not ResponseMessage.IsSuccessStatusCode() then
            error('The web service returned an error message:\\' +
                  'Status code: %1\' +
                  'Description: %2',
                  ResponseMessage.HttpStatusCode(),
                  ResponseMessage.ReasonPhrase());

        ResponseMessage.Content().ReadAs(XMLResponse);
        XmlDocument.ReadFrom(XMLResponse, XMLDoc);

        XMLDoc.SelectNodes('resValidateFakturPm', NodeList_resValidateFakturPm);

        for i := 1 TO NodeList_resValidateFakturPm.Count() do begin
            XMLDoc.SelectSingleNode('//resValidateFakturPm/kdJenisTransaksi', Node_kdJenisTransaksi);
            _kdJenisTransaksi := Node_kdJenisTransaksi.AsXmlElement().InnerText();
            XMLDoc.SelectSingleNode('//resValidateFakturPm/fgPengganti', Node_fgPengganti);
            _fgPengganti := Node_fgPengganti.AsXmlElement().InnerText();
            XMLDoc.SelectSingleNode('//resValidateFakturPm/nomorFaktur', Node_nomorFaktur);
            _nomorFaktur := Node_nomorFaktur.AsXmlElement().InnerText();
            XMLDoc.SelectSingleNode('//resValidateFakturPm/tanggalFaktur', Node_tanggalFaktur);
            _tanggalFaktur := Node_tanggalFaktur.AsXmlElement().InnerText();
            XMLDoc.SelectSingleNode('//resValidateFakturPm/npwpPenjual', Node_npwpPenjual);
            _npwpPenjual := Node_npwpPenjual.AsXmlElement().InnerText();
            XMLDoc.SelectSingleNode('//resValidateFakturPm/namaPenjual', Node_namaPenjual);
            _namaPenjual := Node_namaPenjual.AsXmlElement().InnerText();
            XMLDoc.SelectSingleNode('//resValidateFakturPm/alamatPenjual', Node_alamatPenjual);
            _alamatPenjual := Node_alamatPenjual.AsXmlElement().InnerText();
            XMLDoc.SelectSingleNode('//resValidateFakturPm/npwpLawanTransaksi', Node_npwpLawanTransaksi);
            _npwpLawanTransaksi := Node_npwpLawanTransaksi.AsXmlElement().InnerText();
            XMLDoc.SelectSingleNode('//resValidateFakturPm/namaLawanTransaksi', Node_namaLawanTransaksi);
            _namaLawanTransaksi := Node_namaLawanTransaksi.AsXmlElement().InnerText();
            XMLDoc.SelectSingleNode('//resValidateFakturPm/alamatLawanTransaksi', Node_alamatLawanTransaksi);
            _alamatLawanTransaksi := Node_alamatLawanTransaksi.AsXmlElement().InnerText();
            XMLDoc.SelectSingleNode('//resValidateFakturPm/jumlahDpp', Node_jumlahDpp);
            _jumlahDpp := Node_jumlahDpp.AsXmlElement().InnerText();
            XMLDoc.SelectSingleNode('//resValidateFakturPm/jumlahPpn', Node_jumlahPpn);
            _jumlahPpn := Node_jumlahPpn.AsXmlElement().InnerText();
            XMLDoc.SelectSingleNode('//resValidateFakturPm/jumlahPpnBm', Node_jumlahPpnBm);
            _jumlahPpnBm := Node_jumlahPpnBm.AsXmlElement().InnerText();
            XMLDoc.SelectSingleNode('//resValidateFakturPm/statusApproval', Node_statusApproval);
            _statusApproval := Node_statusApproval.AsXmlElement().InnerText();
            XMLDoc.SelectSingleNode('//resValidateFakturPm/statusFaktur', Node_statusFaktur);
            _statusFaktur := Node_statusFaktur.AsXmlElement().InnerText();

            IF XMLDoc.SelectSingleNode('//resValidateFakturPm/referensi', Node_referensi) = true then
                _referensi := Node_referensi.AsXmlElement().InnerText()
            else
                _referensi := '';

            Kre_EFaktur.Init();
            Kre_EFaktur.KD_Jenis_Transaksi := _kdJenisTransaksi;
            Kre_EFaktur.FG_Pengganti := _fgPengganti;
            Kre_EFaktur.No_Faktur := _nomorFaktur;
            Evaluate(Kre_EFaktur.Tanggal_Faktur, CopyStr(_tanggalFaktur, 4, 2) + CopyStr(_tanggalFaktur, 1, 2) + CopyStr(_tanggalFaktur, 7, 4));
            Kre_EFaktur.NPWP_Penjual := _npwpPenjual;
            Kre_EFaktur.Nama_Penjual := _namaPenjual;
            Kre_EFaktur.Alamat_Penjual := _alamatPenjual;
            Kre_EFaktur.NPWP_Lawan_Transaksi := _npwpLawanTransaksi;
            Kre_EFaktur.Nama_Lawan_Transaksi := _namaLawanTransaksi;
            Kre_EFaktur.Alamat_Lawan_Transaksi := _alamatLawanTransaksi;
            Evaluate(Kre_EFaktur.Jumlah_DPP, _jumlahDpp);
            Evaluate(Kre_EFaktur.Jumlah_PPN, _jumlahPpn);
            Evaluate(Kre_EFaktur.Jumlah_PPNBM, _jumlahPpnBm);
            Kre_EFaktur.Status_Approval := _statusApproval;
            Kre_EFaktur.Status_Faktur := _statusFaktur;
            Kre_EFaktur.Referensi := _referensi;
            Kre_EFaktur.URL := Url;
            Kre_EFaktur.Insert();

            XMLDoc.SelectNodes('//resValidateFakturPm/detailTransaksi', NodeList_detailTransaksi);
            for j := 1 TO NodeList_detailTransaksi.Count() do begin

                XMLDoc.SelectSingleNode('//detailTransaksi/nama', Node_nama);
                _nama := Node_nama.AsXmlElement().InnerText();
                Node_nama.Remove();
                XMLDoc.SelectSingleNode('//detailTransaksi/hargaSatuan', Node_hargaSatuan);
                _hargaSatuan := Node_hargaSatuan.AsXmlElement().InnerText();
                Node_hargaSatuan.Remove();
                XMLDoc.SelectSingleNode('//detailTransaksi/jumlahBarang', Node_jumlahBarang);
                _jumlahBarang := Node_jumlahBarang.AsXmlElement().InnerText();
                Node_jumlahBarang.Remove();
                XMLDoc.SelectSingleNode('//detailTransaksi/hargaTotal', Node_hargaTotal);
                _hargaTotal := Node_hargaTotal.AsXmlElement().InnerText();
                Node_hargaTotal.Remove();
                XMLDoc.SelectSingleNode('//detailTransaksi/diskon', Node_diskon);
                _diskon := Node_diskon.AsXmlElement().InnerText();
                Node_diskon.Remove();
                XMLDoc.SelectSingleNode('//detailTransaksi/dpp', Node_dpp);
                _dpp := Node_dpp.AsXmlElement().InnerText();
                Node_dpp.Remove();
                XMLDoc.SelectSingleNode('//detailTransaksi/ppn', Node_ppn);
                _ppn := Node_ppn.AsXmlElement().InnerText();
                Node_ppn.Remove();
                XMLDoc.SelectSingleNode('//detailTransaksi/tarifPpnbm', Node_tarifPpnbm);
                _tarifPpnbm := Node_tarifPpnbm.AsXmlElement().InnerText();
                Node_tarifPpnbm.Remove();
                XMLDoc.SelectSingleNode('//detailTransaksi/ppnbm', Node_ppnbm);
                _ppnbm := Node_ppnbm.AsXmlElement().InnerText();
                Node_ppnbm.Remove();
                InsertEFakturLines(_nama, _hargaSatuan, _jumlahBarang, _hargaTotal, _diskon, _dpp, _ppn, _tarifPpnbm, _ppnbm);
            end;
        end;

        MESSAGE('Get EFaktur Success.');
        exit;
    END;

    local procedure InsertEFakturLines(_nama: Text;
        _hargaSatuan: Text;
        _jumlahBarang: Text;
        _hargaTotal: Text;
        _diskon: Text;
        _dpp: Text;
        _ppn: Text;
        _tarifPpnbm: Text;
        _ppnbm: Text)
    var
        Kre_EFakturLines: record Kre_EFakturLines;
    begin
        Kre_EFakturLines.Init();
        Kre_EFakturLines.ID_Kre_EFaktur := GetLastID_Kre_EFaktur();
        Kre_EFakturLines.Nama := _nama;
        Evaluate(Kre_EFakturLines.Harga_Satuan, _hargaSatuan);
        Evaluate(Kre_EFakturLines.Jumlah_Barang, _jumlahBarang);
        Evaluate(Kre_EFakturLines.Harga_Total, _hargaTotal);
        Evaluate(Kre_EFakturLines.Diskon, _diskon);
        Evaluate(Kre_EFakturLines.DPP, _dpp);
        Evaluate(Kre_EFakturLines.PPN, _ppn);
        Evaluate(Kre_EFakturLines.Tarif_PPNBM, _tarifPpnbm);
        Evaluate(Kre_EFakturLines.PPN, _ppnbm);
        Kre_EFakturLines.Insert()
    end;

    local procedure InvoiceAlreadyExists(paramUrl: Text[250]): Boolean
    var
        Kre_EFaktur: Record Kre_EFaktur;
    begin
        Kre_Efaktur.SetCurrentKey(URL);
        Kre_Efaktur.SetRange(URL, paramUrl);
        exit(Kre_Efaktur.FindFirst())
    end;



    local procedure GetLastID_Kre_EFaktur(): Integer
    var
        Kre_EFaktur: Record Kre_EFaktur;
        ID_free: Integer;
    begin
        Kre_EFaktur.SetCurrentKey(ID);
        Kre_EFaktur.Ascending();
        Kre_EFaktur.FindLast();
        ID_free := Kre_EFaktur.ID;
        exit(ID_free);
    end;

    procedure SetTaxExported(var Trans: Record Kre_EFaktur)
    var
        i: Integer;
    begin
        i := 0;
        if Trans.Find('-') then
            repeat
                SetTaxExportedLine(Trans.ID);
                i := i + 1;
            until Trans.Next <= 0;
    end;

    local procedure SetTaxExportedLine(ID: Integer)
    var
        Kre_EFaktur: Record Kre_EFaktur;
    begin
        Kre_EFaktur.Get(ID);
        Kre_EFaktur.TAX_EXPORTED := Kre_EFaktur.TAX_EXPORTED::YES;
        Kre_EFaktur.Modify();
    end;
}