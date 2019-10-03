{-------------------------------------------------------------}
{
{       Tratamento de arquivos DOC, conversões e impressão
{
{       Autores: José Antônio Borges / Neno Henrique da Cunha Albernaz
{
{       Em 03de julho de 2006
{
{-------------------------------------------------------------}

unit eddoc;

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
    activex,
    edLinha,
    edMensag,
    edTela,
    edBlbTxt,
    edVars;

function convertDocParaTxt (nomeArq: string): string;
procedure chamaTratamentoWord;
procedure insereFormatacao;
procedure cmdmodoFalaFormatacao;
procedure ocultarFormatacaoTela;

implementation

{--------------------------------------------------------}
{       Chama bibliotecas do Microsoft Office para converter arquivo
{--------------------------------------------------------}

function chamaBlibliotecasOffice (nomeArqConvert, nomeArq: string): boolean;
var
    word: Variant;
begin
    coinitialize (NIL);
    sintClek;
    try
        Word := CreateOleObject('Word.Basic');
        sintClek;
    except
        exit;
    end;
    try
        Word.FileOpen (nomeArqConvert);
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

    chamaBlibliotecasOffice := true;
end;

{----------------------------------------}
{   Testa se o arquivo é .doc, .docx, .rtf ou .odt, se for transforma em .txt
{----------------------------------------}

function convertDocParaTxt (nomeArq: string): string;
var
    nomeArqTemp: string;
    c: char;
begin
   convertDocParaTxt := nomeArq;
    nomeArqTemp := ansiUpperCase (nomeArq);
    if (copy(nomeArqTemp, length(nomeArqTemp)-4, 5 ) <> '.DOCX') and (copy(nomeArqTemp, length(nomeArqTemp)-3, 4 ) <> '.DOC') and
       (copy(nomeArqTemp, length(nomeArqTemp)-3, 4 ) <> '.RTF') and (copy(nomeArqTemp, length(nomeArqTemp)-3, 4 ) <> '.ODT') then exit;

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
                   convertDocParaTxt := nomeArq;
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
           convertDocParaTxt := '';
            exit;
        end;
    if c = 'N' then
        exit;

    fala ('EDAGUARD'); {'Aguarde ...'}

    if chamaBlibliotecasOffice (nomeArqTemp, nomeArq) then
        convertDocParaTxt := nomeArq
    else
    if chamaBlb2txt (nomeArqTemp)then
        convertDocParaTxt := nomeArq
    else
        convertDocParaTxt := '';
end;

{--------------------------------------------------------}
{       Chama programa externo que gera doc ou imprimi
{--------------------------------------------------------}

procedure chamaTratamentoWord;
var
    nomeProg, nomeArqConvert: string;
begin
    nomeArqConvert := nomeArq;
    if pos (' ', nomeArq) <> 0 then
        if nomeArq [1] <> '"' then
            nomeArqConvert := '"' + nomeArq + '"';

    nomeProg := sintAmbiente ('EDIVOX', 'TXTWORD');
    if nomeProg = '' then nomeProg := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\txtword.exe';
    if executaProg (nomeProg, '', nomeArqConvert) >= 32 then
        begin
            esperaProgVoltar;
            while sintFalando do waitMessage;
            fala ('EDOK'); {'Ok'}
        end
    else
        fala ('EDTXTNEX'); {'Falta o arquivo txtword.exe'}
    sintClek;
end;

{--------------------------------------------------------}
{       Procedimentos para  inserir caracteres de formatação no texto
{--------------------------------------------------------}

procedure insereTagComValor (tag: string);
var
    v: string;
begin
        fala ('EDINFVAL'); {'Informe o valor '}
    sintReadln (v);
    if v = '' then
        fala ('EDDESIST')
    else
        begin
            tag := tag + trim (v) + '>';
            insereNaLinha (tag);
            escreveTela;
            fala ('EDOK'); {'Ok'}
        end;
end;

procedure MenuAdiciona (msg: string);
begin
     popupMenuAdiciona (msg, textoAjuda (msg));
end;

{       Insere o nome da fonte   }

function geraArqFontes: boolean;
var
        n, i: integer;
    aplicWord: variant;
    nomeArqFont: string;
    arq: text;
begin
    nomeArqFont := sintAmbiente ('EDIVOX', 'ARQFONTES');
    if trim (nomeArqFont) = '' then
        nomeArqFont := sintDirAmbiente + '\arqfonte.ini';
    assign (arq, nomeArqFont);
    {$i-} rewrite (arq); {$I+}
    if ioresult <> 0 then
        begin
            fala ('EDERRESC'); {'Erro de escrita no arquivo'}
            geraArqFontes := false;
            exit;
        end;
    geraArqFontes := true;

    aplicWord := createoleobject ('Word.Application');
    aplicWord.visible := 1;
    n := aplicWord.fontNames.count;
    for i := 1 to n do
        begin
            {$i-} writeln (arq, aplicWord.FontNames.item(i)); {$I+}
            if ioresult <> 0 then
                begin
                    fala ('EDERRESC'); {'Erro de escrita no arquivo'}
                    geraArqFontes := false;
                    break;
                end;
        end;

    aplicWord.Quit (false);
    {$i-} close (arq); {$I+}
    if ioresult <> 0 then;
end;

procedure inseriNomeFonte;
var
        i, n: integer;
    nomeArqFont, nomeFonte: string;
    linhasArquivo: TStringList;

    function carregaLinhasArquivo (nomeArq: string): boolean;
    begin
        linhasArquivo := TStringList.create;
        carregaLinhasArquivo := true;
        try
            linhasArquivo.loadFromFile (nomeArq);
        except
             carregaLinhasArquivo := false;
        end;
    end;

    procedure destroiLinhasArquivo;
    begin
        linhasArquivo.free;
    end;

begin
    nomeArqFont := sintAmbiente ('EDIVOX', 'ARQFONTES');
    if trim (nomeArqFont) = '' then
        nomeArqFont := sintDirAmbiente + '\arqfonte.ini';
    if not carregaLinhasArquivo (nomeArqFont) then
        if not geraArqFontes then exit
        else
        if not carregaLinhasArquivo (nomeArqFont) then exit;

    n := linhasArquivo.count;
    sintetiza (intToStr(n));
    fala ('EDFONTES'); {'Fontes'}
    fala ('EDCFVEL'); {'Use as setas para selecionar.'}
    delay (100);
    popupMenuCria(wherex, wherey, 40, n, 0);
    for i := 1 to n do
         popupMenuAdiciona ('', linhasArquivo[i-1]);
    i := popupMenuSeleciona;

    if (i >= 1) and (i <= n) then
        begin
            nomeFonte := linhasArquivo[i-1];
            nomeFonte := '<TF=' + trim (nomeFonte) + '>';
            insereNaLinha (nomeFonte);
            escreveTela;
            fala ('EDOK'); {'Ok'}
        end
    else
        begin
            fala ('EDDESIST');
        end;
end;

{       Tamanho da fonte    }

procedure insereTamanhoFonte;
var
    c: char;
    tamanho: string;

    function selsetasFolheia: boolean;
    var i: integer;
    begin
        popupMenuCria(wherex, wherey, 40, 16, 0);
        for i := 1 to 5 do
            popupMenuAdiciona ('', intToStr (i+7));
        for i := 6 to 13 do
            popupMenuAdiciona ('', intToStr ((2*i)+2));
        popupMenuAdiciona ('', '36');
        popupMenuAdiciona ('', '48');
        popupMenuAdiciona ('', '72');
        i := popupMenuSeleciona;

        if (i >= 1) and (i <= 16) then
            begin
                if (i >0) and (i <= 5) then tamanho := intToStr (i + 7)
                else if (i >5) and (i <= 13) then tamanho := intToStr ((2*i)+2)
                else if i = 14 then tamanho := '36'
                else if i = 15 then tamanho := '48'
                else if i = 16 then tamanho := '72';
                selsetasFolheia := true;
            end
        else
            selsetasFolheia := false;
    end;

label inicio;
begin
inicio:
    fala ('EDDIGTAM'); {'Digite o tamanho da fonte'}
    tamanho := '12';
    c := sintEditaCampo (tamanho, 1, wherey, 3, 80, true);
    writeln;
    if (c = BAIX) or (c = CIMA) then
        if not selsetasFolheia then tamanho := '';
    if c in [F1, F9] then
        begin
            fala ('EDALTERN'); {'Use as setas para alternativas'}
            goto inicio;
        end;

    if (c <> ESC) and (tamanho <> '') then
        begin
            insereNaLinha ('<SF='+ tamanho+ '>');
            escreveTela;
            fala ('EDOK'); {'Ok'}
        end
    else
        fala ('EDDESIST');
end;

{       Cor da fonte }

procedure insereCorFonte;
var
        i: integer;
begin
    fala ('EDCFVEL'); {'Use as setas para selecionar.'}
    delay (100);
    popupMenuCria(wherex, wherey, 40, 17, 0);
    MenuAdiciona ('EDAUTOMA'); {'Automática'}
    MenuAdiciona ('EDPRETO'); {'Preto'}
    MenuAdiciona ('EDAZUL'); {'Azul'}
    MenuAdiciona ('EDTURQUE'); {'Turquesa'}
    MenuAdiciona ('EDVERCLA'); {'Verde claro'}
    MenuAdiciona ('EDROSA'); {'Rosa'}
    MenuAdiciona ('EDVERMEL'); {'Vermelho'}
    MenuAdiciona ('EDAMAREL'); {'Amarelo'}
    MenuAdiciona ('EDBRANCO'); {'Branco'}
    MenuAdiciona ('EDAZUESC'); {'Azul escuro'}
    MenuAdiciona ('EDCERCET'); {'Cerceta'}
    MenuAdiciona ('EDVERDE'); {'Verde'}
    MenuAdiciona ('EDVIOLET'); {'Violeta'}
    MenuAdiciona ('EDVERESC'); {'Vermelho escuro'}
    MenuAdiciona ('EDAMAESC'); {'Amarelo escuro'}
    MenuAdiciona ('EDCINZ50'); {'Cinza 50'}
    MenuAdiciona ('EDCINZ25'); {'Cinza 25'}
    i := popupMenuSeleciona;

    if (i > 0) and (i <= 17) then
        begin
            insereNaLinha ('<CE='+ intToStr (i-1)+ '>');
            escreveTela;
            fala ('EDOK'); {'Ok'}
        end
    else
        fala ('EDDESIST');
end;

{--------------------------------------------------------}
{       Menus de formatação
{--------------------------------------------------------}

{       Menu de alinhamento e separação de sílabas }

procedure menu_alinhamento;
var
    c, c2: char;
const
    tabLetrasOpcoes: string[4] = 'JCDE';

    function selSetas: char;
    var n: integer;
    begin
        popupMenuCria (wherex, wherey, 50, 4, MAGENTA);
        MenuAdiciona ('EDAJDA1'); {'  J - justificar'}
        MenuAdiciona ('EDAJDA2'); {'  C - centralizar'}
        MenuAdiciona ('EDAJDA3'); {'  D - alinhar a direita'}
        MenuAdiciona ('EDAJDA4'); {'  E - alinhar a esquerda'}

        n := popupMenuSeleciona;

        if (n > 0) and (n <= 4) then
            selSetas := tabLetrasOpcoes[n]
        else
            selSetas := ESC;
    end;

label inicio;
begin
inicio:
    fala ('EDOPCAO');  {'Qual opcao? '}
    sintLetecla (c, c2);
    if (c2 = BAIX) or (c2 = CIMA) then
        c := selSetas
    else
    if c2 in [F1, F9] then
        begin
            fala ('EDALTERN'); {'Use as setas para alternativas'}
            goto inicio;
        end;

    c := upcase (c);
    case c of
        'J': insereNaLinha ('<AF>');
        'C': insereNaLinha ('<C>');
        'D': insereNaLinha ('<AR>');
        'E': insereNaLinha ('<AL>');

        ESC: fala ('EDDESIST')
    else
        fala ('EDOPCINV');
    end;

    if pos(c, tabLetrasOpcoes) <> 0 then fala ('EDOK'); {'Ok'}
end;

{       Menu formatação de fonte    }

procedure menu_Fonte;
var
    c, c2: char;
const
    tabLetrasOpcoes: string[9] = 'FTCN'+ ^N+ 'I'+ ^I+ 'S'+ ^S;

    function selSetas: char;
    var n: integer;
    begin
        popupMenuCria (wherex, wherey, 50, 9, MAGENTA);
        MenuAdiciona ('EDAJF01');{'  F - nome da fonte'}
        MenuAdiciona ('EDAJF02');{'  T - tamanho da fonte'}
        MenuAdiciona ('EDAJF03');{'  C - cor da fonte'}
        MenuAdiciona ('EDAJF04');{'  N - início de negrito'}
        MenuAdiciona ('EDAJF05');{'  CONTROL + N - fim de negrito'}
        MenuAdiciona ('EDAJF06');{'  I - início de itálico'}
        MenuAdiciona ('EDAJF07');{'  CONTROL + I - fim de itálico'}
        MenuAdiciona ('EDAJF08');{'  S - início de sublinhado'}
        MenuAdiciona ('EDAJF09');{'  CONTROL + S - fim de sublinhado'}

        n := popupMenuSeleciona;
        if (n > 0) and (n <= 9) then
            selSetas := tabLetrasOpcoes[n]
        else
            selSetas := ESC;
    end;

label inicio;
begin
inicio:
    fala ('EDOPCAO');  {'Qual opcao? '}
    sintLetecla (c, c2);
    if (c2 = BAIX) or (c2 = CIMA) then
        c := selSetas
    else
    if c2 in [F1, F9] then
        begin
            fala ('EDALTERN'); {'Use as setas para alternativas'}
            goto inicio;
        end;

    c := upcase (c);
    case c of
        'F': inseriNomeFonte;
        'T': insereTamanhoFonte;
        'C': insereCorFonte;
        'N': insereNaLinha ('<IN>');
        ^N: insereNaLinha ('<FN>');
        'I': insereNaLinha ('<II>');
        ^I: insereNaLinha ('<FI>');
        'S': insereNaLinha ('<IS>');
        ^S: insereNaLinha ('<FS>');

        ESC: fala ('EDDESIST') {'Desistiu'}
    else
        fala ('EDOPCINV');
    end;

    if not (c in ['F', 'T', 'C']) then
        if pos(c, tabLetrasOpcoes) <> 0 then fala ('EDOK'); {'Ok'}
end;

{       Menu principal para inserir tags de formatação no texto}

procedure insereFormatacao;
var
    c, c2: char;

    function selSetas: char;
    var
        n: integer;
    const
        tabLetrasOpcoes: string[2] = 'FA';
    begin
        popupMenuCria (wherex, wherey, 50, 2, MAGENTA);
        MenuAdiciona ('EDAJMF1');{'  F - fonte'}
        MenuAdiciona ('EDAJMF2');{'  A - alinhamento'}

        n := popupMenuSeleciona;
        if (n > 0) and (n <= 2) then
            selSetas := tabLetrasOpcoes[n]
        else
            selSetas := ESC;
    end;

label inicio;
begin
    fala ('EDINSFOR'); {'Inserir marcas de formatação'}
inicio:
    fala ('EDCOMAND'); {'Qual comando? '}
    sintLetecla (c, c2);
    if (c2 = BAIX) or (c2 = CIMA) then
        c := selSetas;

    c := upcase (c);
    if c2 in [F1, F9] then
        begin
            fala ('EDALTERN'); {'Use as setas para alternativas'}
            goto inicio;
        end
    else
    case c of
        'F': menu_Fonte;
        'A': menu_alinhamento;

        ESC: fala ('EDDESIST') {'Desistiu'}
    else
        fala ('EDOPCINV');
    end
end;

{--------------------------------------------------------}
{       Modos de falar a formatação do texto
{--------------------------------------------------------}

procedure cmdmodoFalaFormatacao;
var
    tecla: char;
label deNovo;
begin
    fala ('EDMOFAFO'); {'Modos de falar formatação'}
    fala ('EDOPCAO'); {'Qual opcao? '}
    tecla := leTeclaMaiusc;

deNovo:
    escreveTela;

    case tecla of
        'N', 'F', 'B', 'M': modoFalaFormatacao := tecla;

        #$0: begin
                tecla := ajuda (readkey, 'EDAJFF', 5);
                goto deNovo;
            end;
      #$1b: begin
                fala ('EDDESIST');
                exit;
            end
    else
        sintBip;
    end;
    fala ('EDOK');
end;

{--------------------------------------------------------}
{       Liga ou desliga o modo ocultar formatação na tela
{--------------------------------------------------------}

procedure ocultarFormatacaoTela;
begin
    escreveApenasTexto := not escreveApenasTexto;
    escreveTela;
    if escreveApenasTexto then
        fala ('EDFOROCU') {'Formatação oculta na tela'}
    else
        fala ('EDFORAPA'); {'Formatação aparente na tela'}
end;

{--------------------------------------------------------}
begin
end.
