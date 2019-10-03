{-------------------------------------------------------------}
{
{       Tratamento de arquivos PDF, conversão para TXT
{
{       Autor: Neno Henrique da Cunha Albernaz
{
{       Em 12de Fevereiro de 2012
{
{-------------------------------------------------------------}

unit edPdf;

interface

uses
    windows,
    dvcrt,
    sysutils,
    dvForm,
    dvwin,
    dvexec,
    edMensag,
    edBlbTxt,
    edVars;

function convertPdfParaTxt (nomeArq: string): string;

implementation

{--------------------------------------------------------}
{       Chama programa PdfToText que converte pdf para txt.
{--------------------------------------------------------}

function chamaPdfToText (nomeArqConvert: string): boolean;
var
    nomeProg: string;
begin
    chamaPdfToText := false;
    if pos (' ', nomeArqConvert) <> 0 then
        if nomeArqConvert[1] <> '"' then
            nomeArqConvert := '"' + nomeArqConvert + '"';

    nomeProg := sintAmbiente ('EDIVOX', 'CONVERSORPDF');
    if nomeProg = '' then nomeProg := '"pdftotext" -nopgbrk -layout';

    if executaProg (nomeProg, '', nomeArqConvert) >= 32 then
        begin
            esperaProgVoltar;
            while sintFalando do waitMessage;
            chamaPdfToText := true;
        end;
//    else
//comentado esta fala pois neste caso abre o blb2txt.        fala ('EDPDFNEX'); {'Falta o conversor de PDF para TXT, arquivo pdftotext'}
end;

{----------------------------------------}
{   Testa se o arquivo é .pdf, se for transforma em .txt
{----------------------------------------}

function convertPdfParaTxt (nomeArq: string): string;
var
    nomeArqTemp: string;
    c: char;
begin
    convertPdfParaTxt := nomeArq;
    if copy(ansiUpperCase(nomeArq), length(nomeArq)-3, 4 ) <> '.PDF' then exit;

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
                   convertPdfParaTxt := nomeArq;
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
           convertPdfParaTxt := '';
            exit;
        end;
    if c = 'N' then
        exit;

    fala ('EDAGUARD'); {'Aguarde ...'}

    if chamaPdfToText (nomeArqTemp)then
        convertPdfParaTxt := nomeArq
    else
    if chamaBlb2txt (nomeArqTemp)then
        convertPdfParaTxt := nomeArq
    else
        convertPdfParaTxt := '';
    limpaBufTec;
end;

{--------------------------------------------------------}

begin
end.
