page 60015 GetEFaktur
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = Kre_EFaktur;

    layout
    {
        area(Content)
        {
            field(URL; Rec.URL)
            {
                ApplicationArea = All;
                QuickEntry = true;

                trigger OnValidate()
                var
                    Config: Record Kre_TaxSetup;

                    GetURL: Codeunit ImportEfaktur;

                    Result: Boolean;

                begin
                    if Config.FindSet() then begin
                        if not Config.Activate_Scan then
                            Error('Scan EFaktur is not Active !')


                    end else
                        Error('Please Setup Tax Config first !');


                    Result := Rec.URL.Contains('http://svc.efaktur.pajak.go.id/validasi/faktur/');
                    if Result = false then
                        Error('Check the Tax service address.')

                    else begin
                        GetURL.GetResponse(rec.URL);
                        Rec.URL := '';
                        CurrPage.Update();
                        CurrPage.Close();

                        // EFaktur.SetRange(URL, Rec.URL);
                        // EFakturCard.SetTableView(EFaktur);
                        // EFakturCard.RunModal();

                    end;
                end;

            }
        }
    }

    // actions
    // {
    //     area(Creation)
    //     {
    //         action("Scan EFaktur")
    //         {
    //             Promoted = true;
    //             PromotedCategory = New;
    //             ApplicationArea = All;
    //             Image = Camera;
    //             PromotedOnly = true;

    //             trigger OnAction()
    //             var
    //                 Camera: page "Camera Interaction";
    //                 pictureStream: InStream;
    //                 url: Text;
    //             begin
    //                 Camera.Quality(100);
    //                 Camera.EncodingType('JPEG');
    //             end;
    //         }
    //     }
    // }
}