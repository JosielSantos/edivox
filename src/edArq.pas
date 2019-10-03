{--------------------------------------------------------}
{
{    Manipulacao de arquivos
{
{    Autor: Marcelo Luis Pinheiro
{
{    Orientador Academico: Jose' Antonio Borges
{
{    Em 10/12/93
{
{--------------------------------------------------------}

Unit edArq;

interface

uses
    DVcrt, DVWin, windows, sysUtils, classes, dvArq, dvexec, dvstring,
    edvars, edMensag, edLinha, edTela,
    edMd5,
    dvForm,
    edDoc, edPdf, edEpub, edBlbTxt, edRetoma;

procedure cmdArquivo;
procedure informaNomeArq (soletra: boolean);
function testaExtensao (nomeArq: string): boolean;
function abreArquivo: boolean;
function abreArqSemCriar: boolean;
procedure salvaArquivo (linha1, linha2: integer);
procedure salvaJuntaLinhas (linha1, linha2: integer);
procedure trocaArquivo;
procedure salvaComo;
procedure gravaETermina;
procedure terminaPrograma (liberaMemoria: boolean);
procedure executaPalavra;
procedure imprime;
function escreveNoFimDoArq (s, nomeArq: string): boolean;
procedure colocaCodificacaoPadrao;

var     md5DoArquivo: string;

implementation

uses edReform;

var arq: file;
    arqSaida: text;
    bufArq: array [0..1023] of char;
    pbufArq, lidosBuf: integer;
    fimDoArq: boolean;

{--------------------------------------------------------}

{----------------------------------------}
{       Retorna o nome do arquivo com o caminho completo
{----------------------------------------}

function pegaCaminhoCompleto (nomeArq: string): string;
var dirAtual: string;
begin
    dirAtual := '';
    if (pos ('\', nomeArq) = 0) and (pos ('/', nomeArq) = 0) then
        begin
            getDir (0, dirAtual);
            if dirAtual[length (dirAtual)] <> '\' then
                dirAtual := dirAtual + '\';
        end;

    pegaCaminhoCompleto := dirAtual + nomeArq;
end;

procedure terminaPrograma (liberaMemoria: boolean);
begin
    if liberaMemoria then texto.Free;
    salvaPosicao;

    if not somenteLeitura then
        fala ('EDFIMPRC')
    else
        sintClek;

    if tamMaxLinha <> 79 then
        trocaTamTela;

    SintFim;
    doneWinCrt;
end;

{--------------------------------------------------------}

procedure informaNomeArq (soletra: boolean);
begin
    fala ('EDNOME');
    write (' ', nomearq);
    if soletra then
        sintSoletra (nomeArq)
    else
        sintetiza (nomeArq);
    delay (500);
end;


{--------------------------------------------------------}

procedure devolveCaracArq (c: char);
begin
   pbufArq := pbufArq - 1;
end;

{--------------------------------------------------------}

function pegaCaracArq: char;
begin
    if pbufArq >= lidosBuf then
         begin
             {$I-} blockread (arq, bufArq, 1024, lidosBuf);  {$i+}
             pbufArq := 0;

             if ioresult <> 0 then
                 begin
                     fala ('EDERRLEI');
                     pegaCaracArq := #$0d;
                     fimDoArq := true;
                     exit;
                 end;
         end;

    if ansiUtfUnicode = C_UNICODE_BIG then
        pbufArq := pbufArq + 1;

    // em unicode, tamanho do arquivo é sempre par, portanto não ocorre problema
    pegaCaracArq := bufArq [pBufArq];

    if ansiUtfUnicode = C_UNICODE then
        pbufArq := pbufArq + 1;

    pbufArq := pbufArq + 1;
    fimDoArq := (pBufArq >= lidosBuf) and eof (arq);
end;

{--------------------------------------------------------}

procedure inicBuffer;
begin
    pbufArq := 9999;
    lidosBuf := 0;
    devolveCaracArq (pegaCaracArq);
    fimDoArq := eof (arq) and (pBufArq >= lidosBuf);
end;

{--------------------------------------------------------}

function carregaUmaLinha (comTabs, comQuebraPag: boolean; var arq: file) : string;
var s: string;
    c: char;
    fimDaLinha: boolean;
begin
    fimDaLinha := false;
    s := '';

    repeat
        c := pegaCaracArq;

        // alterado por Tiago M. C.:
        // se o padrão for usado, o caractere tab horizontal é substituído por oito espaços
        // se o padrão não for usado troca pra '#' caracteres de 0-8, 10 e 13-31,
        //     exceto tab vertical e quebra de página

        if (c = #$0d) or (c = #$0a) then
            fimDaLinha := true
        else
            if (c = #9) and (not comTabs) then
                s := s + '        '
            else
                if (c in [#0..#8, #10, #13..#31]) or ((c = #11) and (not comTabs))
                         or ((c = #12) and (not comQuebraPag)) then
                    s := s + '#'
                else
                    s := s + c;

    until fimDaLinha or fimDoArq;

    if (not fimDoArq) and (c = #$0d) then
        begin
            c := pegaCaracArq;
            if c <> #$0a then
                devolveCaracArq (c);
        end;

    if ansiUtfUnicode = C_UTF8 then
        carregaUmaLinha := utfToAnsi(s)
    else
        carregaUmaLinha := s;
end;

{--------------------------------------------------------}

procedure fazCargaDoArquivo;
var
    s: string;
    comQuebraPag: boolean;
Begin
    // acrescentado por Tiago M. C.: para o processamento dos caracteres tab e quebra de página
    // por padrão "CARACTERESTAB" = "NÃO" e "CARACTEREQUEBRAPAG" = "NÃO"

    comQuebraPag := primeiraLetra (sintAmbiente ('EDIVOX', 'CARACTEREQUEBRAPAG')) = 'S';

    texto.append('');  //Sem essa linha ocorre erro na abertura
    While not fimDoArq do
        begin
            s := carregaUmaLinha (comTabs, comQuebraPag, arq);
            if (s <> '') and (veioDoDos) then
                OemToAnsi(@s[1], @s[1]);
            insereLinha (s, false);
            posy := posy + 1;
        end;

    close (arq);
    veioDoDos := false;
end;

{--------------------------------------------------------}

function tiraCaminhoDir (s: string): string;
begin
    tiraCaminhoDir := s;
    while (s <> '') and ( pos ('\', s) <> 0) do
        delete (s, 1, pos('\', s));
    while (s <> '') and ( pos ('/', s) <> 0) do
        delete (s, 1, pos('/', s));
    if s <> '' then
        tiraCaminhoDir := s;
end;

{--------------------------------------------------------}

function testaExtensao (nomeArq: string): boolean;
begin
    nomeArq := tiraCaminhoDir (nomeArq);
    if pos ('.', nomeArq) <> 0 then
        testaExtensao := true
    else
        testaExtensao := false;
end;

{--------------------------------------------------------}

function geraArqTexto (nomeArq: string): string;
var ext: string;
begin
    ext := ansiUpperCase(extractFileExt(nomeArq));
    delete (ext, 1, 1);
    if ext = 'PDF' then
        nomeArq := convertPdfParaTxt ( nomeArq)
    else
    if ext = 'EPUB' then
        nomeArq := convertEpubParaTxt (nomeArq)
    else
    if (ext = 'DOCX') or
       (ext = 'DOC') or
       (ext = 'RTF') or
       (ext = 'ODT') then
        nomeArq := convertDocParaTxt ( nomeArq)
    else
        nomeArq := converteArquivoParaTxt (nomeArq);
    while sintFalando do waitMessage;
    geraArqTexto := nomeArq;
end;

{--------------------------------------------------------}

function descobreCodifArquivo: TCodif;
var c1, c2, c3: char;
    salvaTipo: TCodif;

label tipoAnsi;
begin
    salvaTipo := ansiUtfUnicode;
    ansiUtfUnicode := C_ANSI;

    c1 := pegaCaracArq;
    if fimDoArq then goto tipoAnsi;
    c2 := pegaCaracArq;
    if fimDoArq then goto tipoAnsi;

    if (c1 = #$FF) and (c2 = #$FE) then
        result := C_UNICODE
    else
    if (c1 = #$FE) and (c2 = #$FF) then
        result := C_UNICODE_BIG
    else
        begin
            c3 := pegaCaracArq;
            if fimDoArq then goto tipoAnsi;
            if (c1 = #$EF) and (c2 = #$BB) and (c3 = #$BF) then
                result := C_UTF8
            else
                goto tipoAnsi;
        end;

    ansiUtfUnicode := salvaTipo;
    exit;

tipoAnsi:
    ansiUtfUnicode := salvaTipo;
    result := C_ANSI;
    pbufArq := 0;
end;

{--------------------------------------------------------}

function abreArquivo: boolean;
var
    i: integer;
    tituloJan: array [0..144] of char;
    s: string;
begin
    abreArquivo := true;

    for i := 9 to 25 do
        begin
             gotoxy (1, i);
             clreol;
        end;

    if nomeArq = '' then
        begin
            fala ('EDDIGNOM');
            nomeArq := trim(obtemNomeArq (15));
            if (nomeArq = '') and (teclaObtemNomeArq = ENTER) then
                begin
                    fala ('EDRECUST');   {'Edições recentes, use as setas.'}
                    nomeArq := trim(obtemNomeAntigo);
                end;
            if (nomeArq = '') or ((nomeArq[length(nomeArq)] in ['\', '/'])) then
                begin
                    abreArquivo := false;
                    exit;
                end;
        end;

    nomeArq := pegaCaminhoCompleto (nomeArq);
    if testaExtensao (nomeArq) and fileExists (nomeArq) then
        nomeArq := geraArqTexto (nomeArq)
    else
    if (not testaExtensao (nomeArq)) and (not fileExists (nomeArq)) then
        nomeArq := nomeArq + '.' + extPadrao;

    if nomeArq = '' then
        begin
            abreArquivo := false;
            fala ('EDDESIST');
            exit;
        end;

    assign (arq, nomeArq);
    {$i-} reset (arq, 1); {$i+}
    if ioresult <> 0 then
        begin
            maxLinhas := 1;
            texto.clear;
            texto.append('');
            texto.append('');
            texto[1] := '';
            colocaCodificacaoPadrao;
            fala ('EDARQNOV');
        end
    else
        begin
            maxLinhas := 0;
            posy := 1;
            inicBuffer;

            ansiUtfUnicode := descobreCodifArquivo;
            fazCargaDoArquivo;
            if maxlinhas = 0 then
                begin
                    maxLinhas := 1;
                    texto.clear;
                    texto.append('');
                    texto.append('');
                    texto[1] := '';
                end;

            if informaCarga then fala ('EDARQCRG');
            informaCarga := true;
        end;

    posx := 1;
    posy := recupPosicao;
    if posy > maxLinhas then posy := 0;
    if posy > 1 then
        begin
            fala ('EDRETOMA');    {'Retomando na linha '}
            textBackground (BLUE);
            sintWriteint (posy);
            textBackground (BLACK);
        end
    else
        posy := 1;

    s := tiraCaminhoDir (nomeArq);
    if length (s) > 124 then
        s := copy (s, 1, 124) + '...';
    strPCopy (tituloJan, s + ' - EDIVOX');
    setWindowText (crtWindow, tituloJan);

    md5DoArquivo := calculaMd5;
end;

{--------------------------------------------------------}

function abreArqSemCriar: boolean;
begin
    abreArqSemCriar := false;

    fala ('EDDIGNOM');
    nomeArq := trim(obtemNomeArq (15));
    if (nomeArq = '') or (nomeArq[length(nomeArq)] in ['\', '/']) then
        begin
            fala ('EDDESIST');
            exit;
        end;

    nomeArq := pegaCaminhoCompleto (nomeArq);
    if testaExtensao (nomeArq) and fileExists (nomeArq) then
        nomeArq := geraArqTexto (nomeArq)
    else
    if (not testaExtensao (nomeArq)) and (not fileExists (nomeArq)) then
        nomeArq := nomeArq + '.' + extPadrao;

    if nomeArq = '' then
        begin
            fala ('EDDESIST');
            exit;
        end;

    assign (arq, nomeArq);
    {$i-} reset (arq, 1); {$i+}
    if ioresult <> 0 then
        begin
            fala ('EDARQNAO');
            exit;
        end;

    inicBuffer;
    fazCargaDoArquivo;
    abreArqSemCriar := true;
end;

{--------------------------------------------------------}

function abreArqSaida: boolean;
var
    resp : char;
label inicio;
begin
    abreArqSaida := true;
inicio:
    limpaBufTec;

    If (nomeArq = '') then
        begin
            fala ('EDNOMGRV');  { Nome do arquivo a gravar: }
            sintReadln (nomearq);
            nomeArq := trim(nomearq);
            if nomearq = '' then
                begin
                    abreArqSaida := false;
                    fala ('EDDESIST');
                    exit;
                end;

            if (not testaExtensao (nomeArq)) and (not fileExists (nomeArq)) then
                nomeArq := nomeArq + '.' + extPadrao;

            if fileExists (nomeArq) then
                begin
                    fala ('EDREESCR');
                    resp := popupMenuPorLetra ('SN');
                    if resp <> 'S' then
                        begin
                            abreArqSaida := false;
                            fala ('EDESCCAN');
                        end;
                end;
        end;
end;

{--------------------------------------------------------}

procedure salvaArquivo (linha1, linha2: integer);
var
    i, j: integer;
    s: string;
label inicio, fechaArq;
begin

inicio:
    if not abreArqSaida then exit;

    assign (arqSaida, nomeArq);
    {$i-} rewrite (arqSaida); {$I+}
    if ioresult <> 0 then
        begin
            fala ('EDERRESC');
            nomeArq := '';
            goto inicio;
        end;

    {$I-}
    case ansiUtfUnicode of
        C_ANSI:         ;
        C_UTF8:         write (arqSaida, #$EF + #$BB + #$BF);
        C_UNICODE:      write (arqSaida, #$FF + #$FE);
        C_UNICODE_BIG:  write (arqSaida, #$FE + #$FF);
    end;
    {$I+}
    ioresult;   // ignora erros

    while (linha2 >= linha1) and (texto[linha2] = '') do
            linha2 := linha2 - 1;

    For i := linha1 to linha2 Do
        begin
            {$I-}
            case ansiUtfUnicode of
                C_ANSI:    writeln (arqSaida, texto[i]); {$I+}
                C_UTF8:    writeln (arqSaida, ansiToUtf8(texto[i]));
                C_UNICODE: begin
                               s := texto[i];
                               s := s + ^m^j;
                               for j := length(s) downto 1 do
                                   insert (#$0, s, j+1);
                               write (arqSaida, s);
                           end;
                C_UNICODE_BIG:
                           begin
                               s := texto[i];
                               s := s + ^m^j;
                               for j := length(s) downto 1 do
                                   insert (#$0, s, j);
                               write (arqSaida, s);
                           end;
            end;
            {$i+}
            if ioresult <> 0 then
                begin
                    fala ('EDERRESC');
                    goto fechaArq;
                end;
        end;

fechaArq:
    {$I-} close (arqSaida); {$I+}
    if ioresult <> 0 then
        begin
            fala ('EDERRESC');
            exit;
        end;

    if somenteLeitura then
        fala ('EDSOMLEI')    {'Este arquivo é somente leitura,}
                             { provavelmente não será gravado'}
    else
        fala ('EDARQGRV');
    md5DoArquivo := calculaMd5;
end;

{--------------------------------------------------------}

procedure salvaJuntaLinhas (linha1, linha2: integer);
var i: integer;
    s, si: string;
label inicio;
begin
inicio:
    if not abreArqSaida then exit;

    assign (arqSaida, nomeArq);
    {$i-} rewrite (arqSaida); {$I+}
    if ioresult <> 0 then
        begin
            fala ('EDERRESC');
            nomeArq := '';
            goto inicio;
        end;

    s := '';
    for i := iniBloco to fimBloco do
        begin
            si := texto[i];

            if trim(si) = '' then
                s := s + #$0d + #$0a
            else

            if copy (si, 1, 4) = '    ' then
                begin
                    s := s + #$0d + #$0a;
                    while copy (si, 1, 4) = '    ' do
                        begin
                            s := s + ^i;
                            delete (si, 1, 4);
                        end;
                    s := s + si;
                end
            else

            if si[1] = ' ' then
                begin
                    delete (si, 1, 1);
                    s := s + #$0d + #$0a + si;
                end
            else
                s := s + ' ' + texto[i];
        end;

    delete (s, 1, 1);
    {$I-} write (arqSaida, s);  {$I-}
    if ioresult <> 0 then
        fala ('EDERRESC');

    {$I-} close (arqSaida); {$I+}
    if ioresult <> 0 then
        fala ('EDERRESC')
    else
        fala ('EDARQGRV');
end;

{--------------------------------------------------------}

procedure trocaArquivo;
var
    resp : char;
begin
    salvaPosicao;

    if md5DoArquivo = calculaMd5 then
    begin
        repeat
            fala ('EDCNFSAI');     {--- confirma saida ---}
            resp := popupMenuPorLetra('SN');
        until resp in ['S','N', ESC];

        if resp in ['N', ESC] then
            begin
                fala ('EDDESIST');
                exit;
            end;
    end
    else
    begin
        repeat
            fala ('EDQUERSV');
            resp := popupMenuPorLetra('SN');
            if resp = #27 then
               begin
                    fala ('EDDESIST');
                    exit;
                end;
        until resp in ['S', 'N'];

        if resp = 'S' then
            salvaArquivo (1, maxLinhas);
    end;

    nomearq := '';
    if not abrearquivo then
        terminaPrograma (true);
end;

{--------------------------------------------------------}

procedure salvaComo;
var
    nomeNovo, s: string;
    c : char;
    tituloJan: array [0..144] of char;
begin
    fala ('EDDIGNOM');
    sintReadln (nomenovo);
    nomeNovo := trim(nomenovo);

    if nomeNovo = '' then
        begin
            fala ('EDDESIST');
            exit;
        end;

    fala ('EDFORTXT');
    c := popupMenuPorLetra ('SN');
    if c = #$1b then
        begin
            fala ('EDDESIST');
            exit;
        end;

    nomeArq := nomeNovo;
    if not testaExtensao (nomeArq) then
        nomeArq := nomeArq + '.' + extPadrao;
    somenteLeitura := false;
    salvaArquivo (1, maxlinhas);

    s := tiraCaminhoDir (nomeArq);
    if length (s) > 124 then
        s := copy (s, 1, 124) + '...';
         strPCopy (tituloJan, s + ' - EDIVOX');
    setWindowText (crtWindow, tituloJan);
    nomeArq := pegaCaminhoCompleto (nomeArq);
end;

{--------------------------------------------------------}

procedure gravaETermina;
begin
    salvaArquivo (1, maxLinhas);
    terminaPrograma (true);
end;

{--------------------------------------------------------}

Procedure cmdArquivo;
var
    tecla: char;
label deNovo;
begin
    fala ('EDOPCAO');   { qual opcao ? }
    tecla := leTeclaMaiusc;

deNovo:
    escreveTela;

    case tecla of

        'I': informaNomeArq (true);
        'S': salvaArquivo (1, maxlinhas);
        'N': trocaArquivo;
        'C': salvaComo;
        'F': gravaETermina;
        'A': terminaPrograma (true);
        'X': salvaArquivo (1, maxlinhas);


       #$0: begin
                tecla := ajuda (readkey, 'EDAJAR', 8);
                goto deNovo;
            end;
      #$1b: begin
                fala ('EDDESIST');
                exit;
            end
    else
        sintBip;
    end;

    escreveTela;
end;

{--------------------------------------------------------}

procedure executaPalavra;
var
    campo, comando: string;
    x1, x2: integer;
const
    espurios: set of char = ['<', '"', '(', '{', '[', '-', '=', '.', '_', 
                             '>', '*', '!', '?', ')', '}', ']'];
begin
    campo := trim(texto[posy]);
    if campo = '' then
        begin
            fala ('EDNEXEC');    {'Não pude executar'}
            exit;
        end;

    x1 := posx;
    while (x1 > 1) and (campo[x1-1] <> ' ') do
       x1 := x1 - 1;
    x2 := posx;
    while (x2 < length(campo)) and (campo[x2] <> ' ') do
        x2 := x2 + 1;
    if (x2 <= length(campo)) and (campo[x2] = ' ') then x2 := x2 - 1;
    comando := copy (campo, x1, x2-x1+1);

    while (comando <> '') and (comando[1] in espurios) do
        delete (comando, 1, 1);
    while (comando <> '') and (comando[length(comando)] in espurios) do
        delete (comando, length(comando), 1);

    if comando = '' then
        fala ('EDNEXEC')    {'Não pude executar'}
    else
        executaArquivo(comando);
end;

{--------------------------------------------------------}

procedure imprime;
var impressor: string;
    nome: string;
    aux: boolean;
begin
    aux := somenteLeitura;
    somenteLeitura := false;
    salvaArquivo (1, maxlinhas);
    somenteLeitura := aux;
    impressor := sintAmbiente ('EDIVOX', 'IMPRESSOR');
    if impressor = '' then
        impressor := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\listavox.exe';

    nome := nomeArq;
    if pos (' ', nome) <> 0 then
        nome := '"' + nome + '"';
    executaProg(impressor, '.', nome);
end;

{--------------------------------------------------------}
{       Escreve string no fim do arquivo passado por parâmetro
{--------------------------------------------------------}

function escreveNoFimDoArq (s, nomeArq: string): boolean;
var arq: text;
begin
    escreveNoFimDoArq := false;
    assign (arq, nomearq);
    {$I-} append (arq);  {$i+}
    if ioresult <> 0 then exit;
    {$i-} writeln (arq, s); {$i+}
    if ioresult = 0 then;
    {$i-} close (arq); {$i+}
    if ioresult = 0 then;
    escreveNoFimDoArq := true;
end;

procedure colocaCodificacaoPadrao;
var s: string;
    begin
    s := maiuscAnsi(sintAmbiente('EDIVOX', 'CODIFICACAO'));
    if s = 'UTF8' then
        ansiUtfUnicode := C_UTF8
    else if s = 'UNICODE' then
        ansiUtfUnicode := C_UNICODE
    else
        ansiUtfUnicode := C_ANSI;
end;

begin
end.
