page 60017 Pajak_API
{
    PageType = API;
    Caption = 'taxjourAPI';
    APIPublisher = 'kreatif';
    APIGroup = 'app1';
    APIVersion = 'v2.0';
    EntityName = 'taxjourAPI';
    EntitySetName = 'taxjourAPI';
    SourceTable = KRE_TAXJOUR;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Pajak)
            {
                field(id; Rec.ID)
                {
                    Caption = 'id';
                }
                field(taxnumber; Rec.TAXNUMBER)
                {
                    Caption = 'taxnumber';
                }
                field(taxdate; Rec.TAXDATE)
                {
                    Caption = 'taxdate';
                }


            }
        }

    }

}
