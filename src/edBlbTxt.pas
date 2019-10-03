{-------------------------------------------------------------}
{
{           Gerador de vários formatos para  txt
{   São eles: azw, azw3, chm, djvu, doc, docx, ppt, pptx, pps, ppsx, epub, fb2, html, htm, lit, mht, mobi, odt, pdb, pdf, prc, rtf, tcr, wpd, xls, xlsx e ods.
{
{       Autor: Neno Henrique da Cunha Albernaz
{
{       Em 09 de Agosto de 2017
{
{-------------------------------------------------------------}

unit edBlbTxt;

interface

uses
    windows,
    dvcrt,
    sysutils,
    dvwin,
    dvexec,
    dvForm,
    edMensag,
    edVars;

function chamaBlb2txt (nomeArq: string): boolean;
function converteArquivoParaTxt (nomeArq: string): string;

implementation

{--------------------------------------------------------}
{       Extrai o diretório do nome de um arquivo
{--------------------------------------------------------}

function retornaDiretorio (nomeArq: string): string;
var p, i: integer;
begin
    retornaDiretorio := '';
    p := length(nomeArq) - 1;
    for i := p downto 1 do
        if (nomeArq[i] = '\') or (nomeArq[i] = '/') then
            begin
                retornaDiretorio := copy (nomeArq, 1, i);
            break;
            end;
end;

{--------------------------------------------------------}
{       Chama programa blb2txt que converte para txt.
{--------------------------------------------------------}

function chamaBlb2txt (nomeArq: string): boolean;
var
    nomeProg, nomeIni, dirArq, nomeArqTemp: string;
begin
    chamaBlb2txt := false;
    dirArq := retornaDiretorio(nomeArq);
    dirArq := '"' + dirArq + '"';
    nomeArqTemp := ansiUpperCase (nomeArq);
    nomeArq := '"' + nomeArq + '"';

    nomeProg := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\blb2txt.exe';
    if not fileExists (nomeProg) then
        begin
            nomeProg := 'c:\Winvox\blb2txt.exe';
            if not fileExists (nomeProg) then
                begin
                    fala ('EDBLBNAO'); {'Conversor Blb2txt não foi encontrado'}
                    exit;
                end;
        end;

    nomeIni := sintDirAmbiente + '\blb2txt.ini';
    if not fileExists (nomeIni) then
        begin
            nomeIni := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\blb2txt.ini';
            if not fileExists (nomeIni) then
                begin
                    nomeIni := 'c:\Winvox\blb2txt.ini';
                    if not fileExists (nomeIni) then
                        begin
                            fala ('EDINIBLB'); {'Arquivo blb2txt.ini não foi encontrado'}
                            nomeIni := '';
                        end;
                end;
        end;

    nomeProg := '"' + nomeProg   + '" -f';
    nomeArq := nomeArq + ' -v ' + dirArq;
    if (copy(nomeArqTemp, length(nomeArqTemp)-4, 5 ) <> '.XLSX') and
       (copy(nomeArqTemp, length(nomeArqTemp)-3, 4 ) <> '.XLS') and
       (copy(nomeArqTemp, length(nomeArqTemp)-3, 4 ) <> '.ODS') then
        nomeArq := nomeArq + ' -rl -rh'
    else
        nomeArq := nomeArq + ' -rh'; //retirado o -rl Eliminar quebras de linha dentro de um parágrafo
    if nomeIni <> '' then
        nomeArq := nomeArq + ' -d ' + nomeIni;
    if executaProg (nomeProg, dirArq, nomeArq) >= 32 then
        begin
            esperaProgVoltar;
            while sintFalando do waitMessage;
            chamaBlb2txt := true;
        end;
    sintBip; sintbip;
end;

{----------------------------------------}
{   Testa se o arquivo é uma das extensões possíveis,  se for transforma em txt
{   São elas: azw, azw3, chm, djvu, doc, docx, ppt, pptx, pps, ppsx, epub, fb2, html, htm, lit, mht, mobi, odt, pdb, pdf, prc, rtf, tcr, wpd, xls, xlsx e ods.
{----------------------------------------}

function converteArquivoParaTxt (nomeArq: string): string;
var
    nomeArqTemp, ext: string;
    c: char;
begin
    converteArquivoParaTxt := nomeArq;
    ext := ansiUpperCase(extractFileExt(nomeArq));
    delete (ext, 1, 1);
    if (ext <> 'DOCX') and
       (ext <> 'PDF') and
       (ext <> 'PPTX') and
       (ext <> 'PPSX') and
       (ext <> 'DOC') and
       (ext <> 'PPT') and
       (ext <> 'PPS') and
       (ext <> 'EPUB') and
       (ext <> 'HTML') and
       (ext <> 'HTM') and
       (ext <> 'RTF') and
       (ext <> 'XLS') and
       (ext <> 'XLSX') and
       (ext <> 'AZW') and
       (ext <> 'AZW3') and
       (ext <> 'CHM') and
       (ext <> 'DJVU') and
       (ext <> 'FB2') and
       (ext <> 'LIT') and
       (ext <> 'MHT') and
       (ext <> 'MOBI') and
       (ext <> 'ODT') and
       (ext <> 'PDB') and
       (ext <> 'PRC') and
       (ext <> 'TCR') and
       (ext <> 'WPD') and
       (ext <> 'ODS') then exit;

    nomeArqTemp := nomeArq;
    nomeArq := ChangeFileExt(nomeArq, '.txt');
    if fileExists (nomeArq) then
        begin
            repeat
                fala ('EDREESCR'); {'Arquivo já existe, reescreve (s/n) ?'}
                c := popupMenuPorLetra ('SN');
            until c in ['S', 'N', ENTER, ESC];
            if c = 'N' then
                begin
                   converteArquivoParaTxt := nomeArq;
                    exit;
                end;
        end
    else
    repeat
        fala ('EDDESCON'); {'Deseja tentar converter o arquivo para TXT? '}
        c := popupMenuPorLetra ('SN');
    until c in ['S', 'N', ENTER, ESC];

    if c = ESC then
        begin
           converteArquivoParaTxt := '';
            exit;
        end;
    if c = 'N' then
        exit;

    fala ('EDAGUARD'); {'Aguarde ...'}

    if chamaBlb2txt (nomeArqTemp)then
        converteArquivoParaTxt := nomeArq
    else
        converteArquivoParaTxt := '';
    limpaBufTec;
end;

{--------------------------------------------------------}
begin
end.
