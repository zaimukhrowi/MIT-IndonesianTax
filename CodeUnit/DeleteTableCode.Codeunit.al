// dotnet
// {
//     assembly(WinSCPnet)
//     {
//         type(WinSCP.SessionOptions; WinSCPnet) { }
//     }
// }
codeunit 60004 DeleteTableCode
{
    Permissions = TableData "Dimension Set Entry" = RIMD, tabledata "G/L Entry" = m;

    procedure DeleteDimensionSetEntry()
    var
        DimSetEntry: Record "Dimension Set Entry";
    begin
        DimSetEntry.DeleteAll();
    end;

    procedure EditGLEntry(EntryNo: Integer; WHTAmount: Decimal; WHTAmountAddCurrency: Decimal)
    var
        GLEntry: Record "G/L Entry";
    begin
        if GLEntry.Get(EntryNo) then begin
            GLEntry.WHTAmount := WHTAmount;
            GLEntry."WHTAmount Additional Currency" := WHTAmountAddCurrency;
            GLEntry.Modify();
        end
    end;

    // VAR
    //     WinSCP_SessionOptions: DotNet "WinSCPnet, Version=1.8.3.12002, Culture=neutral, PublicKeyToken=2271ec4a3c56d0bf.WinSCP.SessionOptions";
    //     WinSCP_Protocol: DotNet "'WinSCPnet, Version=1.6.5.9849, Culture=neutral, PublicKeyToken=2271ec4a3c56d0bf'.WinSCP.Protocol";
    //     WinSCP_Session: DotNet "'WinSCPnet, Version=1.6.5.9849, Culture=neutral, PublicKeyToken=2271ec4a3c56d0bf'.WinSCP.Session";
    //     WinSCP_TransferOptions: DotNet "'WinSCPnet, Version=1.6.5.9849, Culture=neutral, PublicKeyToken=2271ec4a3c56d0bf'.WinSCP.TransferOptions";
    //     WinSCP_TransferResult: DotNet "'WinSCPnet, Version=1.6.5.9849, Culture=neutral, PublicKeyToken=2271ec4a3c56d0bf'.WinSCP.TransferOperationResult";
    //     WinSCP_Transfers: DotNet "'WinSCPnet, Version=1.6.5.9849, Culture=neutral, PublicKeyToken=2271ec4a3c56d0bf'.WinSCP.TransferEventArgsCollection";

}