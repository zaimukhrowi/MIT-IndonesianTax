table 60009 KreWHTTrans
{
    fields
    {
        field(1; ID; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(3; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
        }
        field(4; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionMembers = ,Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund;
        }
        field(5; "Document No"; Code[20])
        {
            Caption = 'Document No';
        }
        field(6; "Source Type"; Option)
        {
            Caption = 'Source Type';
            OptionMembers = ,Customer,Vendor,"Bank Account","Fixed Asset",Employee;
        }
        field(7; "PPh Code"; Code[25])
        {
            Caption = 'PPh Code';
            ObsoleteState = Removed;
            ObsoleteReason = 'Sudah tidak digunakan di Pajak Indonesia 4.0';
        }
        field(8; "G/L Account No"; Code[20])
        {
            Caption = 'G/L Account No';
        }
        field(9; "G/L Account Name"; Text[100])
        {
            Caption = 'G/L Account Name';
        }
        field(10; Description; Text[250])
        {
            Caption = 'Description';
        }
        field(11; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(12; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(13; "DPP Amount"; Decimal)
        {
            Caption = 'DPP Amount';
        }
        field(14; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
        }
        field(15; "Bukti Potong Date"; Date)
        {
            Caption = 'Bukti Potong Date';
        }
        field(16; "Bukti Potong No"; Text[100])
        {
            Caption = '"Bukti Potong No';
        }
        field(17; "Bukti Potong Status"; Option)
        {
            Caption = 'Bukti Potong Status';
            OptionMembers = ,"In Process","Posted","Closed";
        }
        field(18; NPWP; Text[25])
        {
            Caption = 'NPWP';
        }
        field(19; Nama; Text[250])
        {
            Caption = 'Nama';
        }
        field(20; "Alamat NPWP"; Text[500])
        {
            Caption = 'Alamat NPWP';
        }
        field(21; "Entry No"; Integer)
        {
            Caption = 'Entry No';
        }
        field(22; "External Doc No"; Code[35])
        {
            Caption = 'External Doc No';
        }
        field(23; "Global Dimension 1"; Code[20])
        {
            Caption = 'Global Dimension 1';
        }
        field(24; "Global Dimension 2"; Code[20])
        {
            Caption = 'Global Dimension 2';
        }
        field(25; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
        }
        field(26; "Gen. Posting Type"; Option)
        {
            Caption = 'Gen. Posting Type';
            OptionMembers = ,Purchase,Sale,Settlement;
        }
        field(27; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
        }
        field(28; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
        }
        field(29; "VAT Type"; Option)
        {
            Caption = 'VAT Type';
            OptionMembers = ,Purchase,Sale,Settlement;
        }
        field(30; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
        }
        field(31; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
        }
        field(32; "Source No"; Code[20])
        {
            Caption = 'Source No';
        }
        field(33; WHTProductPostingGroup; Code[25])
        {
            DataClassification = ToBeClassified;
        }
        field(34; WHTPercentage; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(35; WHTAmount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(36; "Remaining Amount Vendor"; Decimal)
        {
            //AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum("Detailed Vendor Ledg. Entry"."Amount" WHERE("Vendor Ledger Entry No." = FIELD("Entry No Ledger Entry Vend")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(37; "Remaining Amount Customer"; Decimal)
        {
            //AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum("Detailed Cust. Ledg. Entry"."Amount" WHERE("Cust. Ledger Entry No." = FIELD("Entry No Ledger Entry Cust")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(38; "Invoice Date"; Date)
        {

        }
        field(39; "Order No"; Code[20])
        {

        }
        field(40; "Entry No Ledger Entry Cust"; Integer)
        {

        }
        field(41; "Entry No Ledger Entry Vend"; Integer)
        {

        }
        field(42; TAXNUMBER; Code[19])
        {
            Caption = 'TAX NUMBER';
        }
        field(43; NIK; Code[16])
        {
            Caption = 'NIK';
        }
        field(44; "Pre-Assigned No."; Code[20])
        {
            Caption = 'Pre-Assigned No.';
        }
        field(45; "Remaining Amount Vendor LCY"; Decimal)
        {
            //AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum("Detailed Vendor Ledg. Entry"."Amount (LCY)" WHERE("Vendor Ledger Entry No." = FIELD("Entry No Ledger Entry Vend")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(46; "Remaining Amount Customer LCY"; Decimal)
        {
            //AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum("Detailed Cust. Ledg. Entry"."Amount (LCY)" WHERE("Cust. Ledger Entry No." = FIELD("Entry No Ledger Entry Cust")));
            Editable = false;
            FieldClass = FlowField;
        }

        field(47; NITKU; Text[22])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PrimaryKey; ID)
        {
            Clustered = true;
        }
    }

}
