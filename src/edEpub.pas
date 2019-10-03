unit edEpub;

interface
uses
    windows,
    dvcrt,
    sysutils,
    dvwin,
    dvexec,
    dvForm,
    classes,
    comobj,
    edLinha,
    edMensag,
    edTela,
    edBlbTxt,
    edVars;

function convertEpubParaTxt (nomeArq: string): string;

implementation

{--------------------------------------------------------}
{           Chama programa externo que gera txt
{--------------------------------------------------------}

function chamaConversorEpub (nomeArq: string): boolean;
var
    nomeProg, nomeArqConvert: string;
begin
    chamaConversorEpub := false;
    nomeArqConvert := ChangeFileExt(nomeArq, '.txt');
    if (pos (' ', nomeArq) <> 0) and (nomeArq[1] <> '"') then
        begin
            nomeArq := '"' + nomeArq + '"';
            nomeArqConvert := '"' + nomeArqConvert + '"';
        end;

    nomeProg := sintAmbiente ('EDIVOX', 'EPUBVOX');
    if nomeProg = '' then nomeProg := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\epubvox.exe';
    if executaProg (nomeProg, '', nomeArq + ' ' + nomeArqConvert) >= 32 then
        begin
            esperaProgVoltar;
            while sintFalando do waitMessage;
            chamaConversorEpub := true;
        end;
//    else
//comentado esta fala pois neste caso abre o blb2txt.        fala ('EDEPUNAO'); {'Conversor de formato EPUB não pode ser ativado'}
end;

{--------------------------------------------------------}

function convertEpubParaTxt (nomeArq: string): string;
var
    c: char;
    nomeArqTemp: string;
begin
    convertEpubParaTxt := nomeArq;
    if copy(ansiUpperCase(nomeArq), length(nomeArq)-4, 5 ) <> '.EPUB' then exit;

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
                   convertEpubParaTxt := nomeArq;
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
           convertEpubParaTxt := '';
            exit;
        end;
    if c = 'N' then
        exit;

    fala ('EDAGUARD'); {'Aguarde ...'}

    if chamaConversorEpub(nomeArqTemp) then
        convertEpubParaTxt := nomeArq
    else
    if chamaBlb2txt (nomeArqTemp) then
        convertEpubParaTxt := nomeArq
    else
        convertEpubParaTxt := '';
    limpaBufTec;
end;

{--------------------------------------------------------}

begin
end.
