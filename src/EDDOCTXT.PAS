{--------------------------------------------------------}
{
{    Transforma doc ou rtf em txt
{
{    Autores: Neno Henrique Albernaz e Geraldo Junior
{
{    Em 30/07/2003
{
{--------------------------------------------------------}

Unit edDocTxt;

interface
uses
    DVcrt, DVWin, windows, sysUtils,
    edMensag,
    Activex, comobj;

function  testaArqDoc ( nomeArq: string): string;

implementation

{----------------------------------------}
{   Testa se o arquivo é .doc ou .rtf, se for transforma em .txt
{----------------------------------------}

function  testaArqDoc ( nomeArq: string): string;
var
    nomeArqTemp, dirAtual: string;
    word: Variant;
    opc: char;
begin
    testaArqDoc := nomeArq;
    nomeArqTemp := upperCase (nomeArq);
    if (pos ('.DOC', nomeArqTemp) = 0) and (pos ('.RTF', nomeArqTemp) = 0) then exit;
    if (pos ('.DOC',nomeArqTemp) = length (nomeArqTemp) - 3) or (pos ('.RTF',nomeArqTemp) = length (nomeArqTemp) - 3) then
        begin
            fala ('EDDESCON'); {'Deseja tentar converter o arquivo para TXT? '}
            opc := popupMenuPorLetra ('SN');
            if (opc <> 'S') and (opc <> ENTER) then exit;  

            fala ('EDAGUARD'); {'Aguarde ...'}
            if (pos ('\', nomeArq) = 0) and (pos ('/', nomeArq) = 0) then
                begin
                    getDir (0, dirAtual);
                    if dirAtual[length (dirAtual)] <> '\' then
                        dirAtual := dirAtual + '\';
                    nomeArq := dirAtual + nomeArq;
                end;
            nomeArqTemp := nomeArq;
            nomeArq [length (nomeArq) - 2] := 't';
            nomeArq [length (nomeArq) - 1] := 'x';
            nomeArq [length (nomeArq)]     := 't';

            coinitialize (NIL);
            sintClek;
            try
                Word := CreateOleObject('Word.Basic');
                sintClek;
            except
                exit;
            end;
            try
                Word.FileOpen (nomeArqTemp);
                sintClek;
            except
                exit;
            end;
            try
                Word.FileSaveAs(nomeArq, 3);
                sintClek;
            finally
                Word.FileQuit;
                sintClek;
            end;
        end;

    testaArqDoc := nomeArq;
end;
{----------------------------------------}
end.
