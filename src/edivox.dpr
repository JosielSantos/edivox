{--------------------------------------------------------}
{
{    Programa Editor Vocal
{
{    Autor: Marcelo Luis Pinheiro
{
{    Orientador Academico: Jose' Antonio Borges
{
{    Em 10/12/93
{
{    Versao 3.0 de 25/4/96
{    Versao 6.0 em 06/11/2007
{    Versao 6.1 em 02/03/2008
{    Versao 7.0 em 25/05/2018. Por: Neno Henrique da Cunha Albernaz

{
{--------------------------------------------------------}

program Edivox;
{$apptype gui}
uses
  Windows,
  SysUtils,
  Classes,
  dvCrt,
  dvForm,
  dvWin,
  dvWav,
  dvHora,
  dvexec,
  dvAmplia,
  dvstring,
  edVars,
  edMensag,
  edFala,
  edTela,
  edCursor,
  edAcento,
  edLinha,
  edArq,
  edBloco,
  edBusca,
  edMargem,
  edConfig,
  edTransf,
  edCalcul,
  edDoc,
  edDocUti,
  edMd5,
  edDicion,
  edPagina,
  edEpub ;

{ dicionário }

var
    progAcabou: boolean;
    perguntaAoSair: boolean;

function confirmasaida(perguntaSeSai: boolean): boolean; forward;

{-----------------------------}

procedure inicializa;
var
     s: string;
     erro: integer;
     velGeral, confTipoSapi, confNum, confVeloc, confTonal: integer;
     par: string;
     c: char;

begin
    clrscr;
    texto := TStringList.create;
    texto.append('');

    tamMaxLinha := 79;
    desenhaTelaInicial;
    setWindowText (crtWindow, 'EDIVOX');

    dirSomEdivox := sintAmbiente ('EDIVOX', 'DIREDIVOX');

    s := sintAmbiente ('EDIVOX', 'VELOCIDADE');
    if (s = '') or (s = '0') then
        s := sintAmbiente ('TRADUTOR', 'VELOCIDADE');
    if s = '' then
        velGeral := 3
    else
        val (s, velGeral, erro);
    sintInic (velGeral, DirSomEdivox);

    c := primeiraLetra (sintAmbiente('EDIVOX', 'SAPIATIVADO'));

    if trim(c) = '' then
        begin
            comSapi := copy (sintAmbiente ('TRADUTOR', 'SAPI'), 1, 1) <> 'N';
            if comSapi then
                begin
                    val (sintAmbiente('SERVFALA', 'VOZ'), confNum, erro);
                    if erro <> 0 then val (sintAmbiente('EDIVOX', 'NUMEROSAPI'), confNum, erro);
                    if erro <> 0 then confNum := 1;

                    val (sintAmbiente('SERVFALA', 'TIPOSAPI'), confTipoSapi, erro);
                    if erro <> 0 then val (sintAmbiente('EDIVOX', 'TIPOSAPI'), confTipoSapi, erro);
                    if erro <> 0 then confTipoSapi := 3;

                    val (sintAmbiente('SERVFALA', 'VELOCIDADE'), confVeloc, erro);
                    if erro <> 0 then val (sintAmbiente('EDIVOX', 'VELOCIDADESAPI'), confVeloc, erro);
                    if erro <> 0 then confVeloc:= 0;

                    val (sintAmbiente('SERVFALA', 'TOM'), confTonal, erro);
                    if erro <> 0 then val (sintAmbiente('EDIVOX', 'TONALIDADESAPI'), confTonal, erro);
                    if erro <> 0 then confTonal:= 0;

                    sintReinic (velGeral, comSapi, confTipoSapi, confNum, confVeloc, confTonal);
                end;
        end
    else
        begin
            comSapi := upcase(c) = 'S';
            val (sintAmbiente('EDIVOX', 'NUMEROSAPI'), confNum, erro);
            if erro <> 0 then val (sintAmbiente('SERVFALA', 'VOZ'), confNum, erro);
            if erro <> 0 then confNum := 1;

            val (sintAmbiente('EDIVOX', 'TIPOSAPI'), confTipoSapi, erro);
            if erro <> 0 then val (sintAmbiente('SERVFALA', 'TIPOSAPI'), confTipoSapi, erro);
            if erro <> 0 then confTipoSapi := 3;

            val (sintAmbiente('EDIVOX', 'VELOCIDADESAPI'), confVeloc, erro);
            if erro <> 0 then confVeloc:= 0;
            val (sintAmbiente('EDIVOX', 'TONALIDADESAPI'), confTonal, erro);
            if erro <> 0 then confTonal:= 0;

            sintReinic (velGeral, comSapi, confTipoSapi, confNum, confVeloc, confTonal);
        end;

            val (sintAmbiente('EDIVOX', 'FREQBASEINDENTACAO'), frequenciaBaseIndentacao, erro);
            if erro <> 0 then frequenciaBaseIndentacao := IDENT_BASE_FREQ;

            val (sintAmbiente('EDIVOX', 'DURACAOINDENTACAO'), duracaoIndentacao, erro);
            if erro <> 0 then duracaoIndentacao := IDENT_DURACAO_BEEP;

            val (sintAmbiente('EDIVOX', 'MAXESPACOSINDENTACAO'), maxEspacosIndentacao, erro);
            if erro <> 0 then maxEspacosIndentacao := IDENT_MAX_ESPACOS;

    checkbreak := false;
    checkFocus := true;
    while keypressed do readkey;

    nomeArq := '';
    somenteLeitura := false;
    if paramCount >= 1 then
        begin
            nomeArq := trim (paramStr(paramCount));
            par := maiuscAnsi (paramStr(1));
            if (par = '/D') or (par = '/L') then
                begin
                    somenteLeitura := true;
                    if par = '/D' then veioDoDos := true;
                    if paramCount = 1 then nomeArq := '';
                end;
        end;
    informaCarga := not somenteLeitura;

    window (57,3, 80,7);
    TextColor (yellow);
    if not somenteLeitura then
         fala ('EDMSGINI');
    TextColor (WHITE);
    window (1,1,80,25);

    texto.clear;
    val (sintAmbiente('EDIVOX', 'MARGDIR'), margDir, erro);
    if (erro <> 0) or (margDir < 10)   then margDir := 79;
    margEsq := 1;
    ntabs := 0;
    mudo := false;
    s := sintAmbiente ('EDIVOX', 'SOLETRANDO');
    if s = '' then sintGravaAmbiente('EDIVOX', 'SOLETRANDO', 'SIM');
    soletrando := upcase((s+'S')[1]) = 'S';
    s := sintAmbiente ('EDIVOX', 'FALANDOPALAVRA');
    if s = '' then sintGravaAmbiente('EDIVOX', 'FALANDOPALAVRA', 'NAO');
    falandoPalavra := upcase((s+'N')[1]) = 'S';
    rapidinho := false;

    enterInsLinha := copy (sintAmbiente ('EDIVOX', 'ENTERINSLINHA'), 1, 1) = 'S';
    quebraAuto := copy (sintAmbiente ('EDIVOX', 'QUEBRARLINHAS'), 1, 1) <> 'N';
    falaPontuacao := copy (sintAmbiente ('EDIVOX', 'FALARPONTUACAO'), 1, 1) <> 'N';
    falaEspacos := copy (sintAmbiente ('EDIVOX', 'FALAESPACOS'), 1, 1) = 'S';
    autofala := copy (sintAmbiente ('EDIVOX', 'FALAAUTOMATICA'), 1, 1) = 'S';
    escreveApenasTexto := copy (sintAmbiente ('EDIVOX', 'ESCREVEAPENASTEXTO'), 1, 1) = 'S';
    perguntaAoSair := copy (sintAmbiente ('EDIVOX', 'PERGUNTAAOSAIR'), 1, 1) <> 'N';

    s := sintAmbiente ('EDIVOX', 'MODOFALAFORMATACAO');
    if trim (s) = '' then s := 'N';
    modoFalaFormatacao := upcase(s[1]);

    statusTecControle := 0;
    maxlinhas := 0;
    buscado := sintAmbiente ('EDIVOX', 'BUSCADO');
    formatarBuscado;
    linhaRemovida := '';

    salvaCurx := 1;
    salvaCury := 1;

    deslocEsqTela := 0;
    corLetra := WHITE;
    corFundo := BLACK;
    extPadrao := sintAmbiente ('EDIVOX', 'EXTENSAOPADRAO');
    if extPadrao = '' then
        begin
            extPadrao := 'txt';
            sintGravaAmbiente('EDIVOX', 'EXTENSAOPADRAO', extPadrao);
        end;

    inicBloco;

    if somenteLeitura then
        dicionarioAtivado := false //Para não deixar lenta a leitura do texto no Cartavox
    else
        begin
            s := sintAmbiente ('EDIVOX', 'DICIONARIOATIVADO');
            dicionarioAtivado := maiuscAnsi (copy (s, 1, 1)) <> 'N';
            if dicionarioAtivado then
                begin
                    verificaDicionario (1, 0);
                end;
        end;

    s := sintAmbiente ('EDIVOX', 'CORRIGIRTODOTEXTO');
    corrigirTodoTexto := maiuscAnsi (copy (s, 1, 1)) = 'S';

    s := sintAmbiente ('EDIVOX', 'TAMANHOTAB');
    val (s, tamanhoTab, erro);
    if erro <> 0 then tamanhoTab := 4;

    comTabs := primeiraLetra (sintAmbiente ('EDIVOX', 'CARACTERESTAB')) = 'S';

    retomarNaLinha := copy (sintAmbiente ('EDIVOX', 'RETOMARNALINHA'), 1, 1) <> 'N';

    iniMarca := 0;
    fimMarca := 0;

    inicializaPaginas;
end;

{--------------------------------------------------------}

procedure abreOutroEditor;
var
    nomeProg: string;
begin
    nomeProg := sintAmbiente ('DOSVOX', 'EDITOR');
    if nomeProg = '' then
        nomeProg := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\edivox.exe';
    if executaProg (nomeProg, '', '') < 32 then
        fala ('EDNEXEC'); {'Não pude executar'}
end;

{--------------------------------------------------------}

procedure tratamentoWord;
var
    tecla: char;
    aux: boolean;

label deNovo;

begin
    fala ('EDOPCAO'); {'Qual opcao? '}
    tecla := leTeclaMaiusc;

deNovo:
    escreveTela;

    case tecla of
        'F': insereFormatacao;
        'I': falaFormatacaoAtual;
        'G': begin
                 aux := somenteLeitura;
                 somenteLeitura := false;
                 salvaArquivo (1, maxlinhas);
                 somenteLeitura := aux;
                 chamaTratamentoWord;
             end;
        'O': ocultarFormatacaoTela;
        'M': cmdmodoFalaFormatacao;
        #$0: begin
                tecla := ajuda (readkey, 'EDAJFW', 6);
                goto deNovo;
            end;
      #$1b: begin
                fala ('EDDESIST');
                exit;
            end
    else
        sintBip;
    end;
end;

{--------------------------------------------------------}

procedure comandoInterativo;
var tecla: char;

label deNovo;

begin
    fala ('EDCOMAND');   { comando ? }
    tecla := leTeclaMaiusc;

deNovo:
    escreveTela;

    case tecla of
       'C': cmdCursor;
       'L': cmdLinha;
       'P': cmdBusca;
       'M': cmdMargem;
       'A': cmdArquivo;
       'B': trataBloco (true); 
       'F': cmdFala;
       'I': cmdConfig;
       'E': trataLetrasEspeciais;
        'W': tratamentoWord;
       #$0: begin
                tecla := ajuda (readkey, 'EDAJIN', 11);
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

procedure trataPFeALT (tecla: char);
var
    salva: integer;
    aux: boolean;
    mantemMarca, saiuDaLinha, apertouShift: boolean;
    sf: string;
    n: integer;
label reprocTecla;
begin
reprocTecla:

    apertouShift := GetKeyState(VK_SHIFT) < 0;
    mantemMarca := apertouShift or
           (tecla = DEL) or (tecla = SHIFTINS) or (tecla = CTLINS);
    saiuDaLinha := (tecla in [ALTF1, F3, F5, CTLF5, F6, CTLF6,
                    F7, CTLF7, F9, F10,
                    CTLPGUP, CTLPGDN, CIMA, BAIX, PGUP, PGDN]);

    if saiuDaLinha then
        amplEsconde;

    if (not mantemMarca) or saiuDaLinha then
        begin
            iniMarca := 0;
            fimMarca := 0;
        end
    else
        begin
            if iniMarca <= 0 then
                iniMarca := posx;
        end;

    Case tecla of
        F1 :  begin
                  if getKeyState (vk_Menu) >= 0 then
                      falaPalavra
                  else
                      begin
                          tecla := ALTF1;
                          goto reprocTecla;
                      end;
              end;

        #33: insereFormatacao; //ALT+F
        #34: begin //ALT+G
                 aux := somenteLeitura;
                 somenteLeitura := false;
                 salvaArquivo (1, maxlinhas);
                 somenteLeitura := aux;
                 chamaTratamentoWord;

            end;
        #23: falaFormatacaoAtual;   //ALT + I
        #24: ocultarFormatacaoTela; //ALT + O
        #50: cmdmodoFalaFormatacao; //ALT + M

        CTLF1 :  falaRestoLinha;
        ALTF1 :  begin
                     falaRestoTexto;
                     iniMarca := 0;
                     fimMarca := 0;
                  end;

        F2 : if getKeyState (vk_Menu) >= 0 then
                    salvaArquivo (1, maxlinhas)
                else // ALTF2
                    memorizaLinha;
        CTLF2:   salvaComo;

        F3 : if getKeyState (vk_Menu) >= 0 then
                begin
                    trocaarquivo;
                    inicBloco;
                    escreveTela;
                end
             else // ALTF3
                    posicionaNaLinhaMemorizada;
        CTLF3:   abreOutroEditor;

        F4 :    if getKeyState (vk_Menu) >= 0 then
                    acionaSoletragem
                else
                    progAcabou := somenteLeitura or confirmasaida(false);
        CTLF4 : if apertouShift then
                    trocaModoFalaNaDigitacao
                else
                    formConfig;

        F5 : if apertouShift then
                    buscaPalavra (true)
                else
                    buscaPalavra (false);
        CTLF5 : if apertouShift then
                    buscaDeNovo (true)
                else
                    buscaDeNovo (false);
        F6:      trocaPalavra;
        CTLF6:   begin
                     if (pos ('=', texto[posy]) <> 0) and
                        (texto[posy][length(texto[posy])] = '=') then
                         conversaoInterativa
                     else
                         calcula;
                     exit;
                 end;
        F7:      removelinha (true);
        CTLF7:   trocaTamTela;

        F8:      falaHora;
        CTLF8:   falaDia;

        F9:      comandoInterativo;
        CTLF9:
            begin
                if apertouShift then
                    limpaTexto (false)
                else
                    limpaTexto (true);
////                falaRestoTexto;
            end;

        F10:     pedeMargens;
        F11:     ativaDicionario (false);
        F12:     executaPalavra;
        CTLF12:   begin
                     sintSom ('EDMSGINI');  sintSoletra (trim (VERSAO)); sintetiza (ALFABETA);
                 end;

        CTLHOME: inicioTexto;
        CTLEND:  fimTexto;
        CTLPGUP: vaiParaPagina (-1);
        CTLPGDN:  vaiParaPagina (1);

        CTLDIR:  begin
                     salva := posx;
                     palavraDir (true);
                     n := posx-salva;
                     sf := copy (texto[posy], salva, n);
                     if trim (sf) = '' then
                         sintclek
                     else
                         sintetiza (sf);
                     if dicionarioAtivado then verificaPalavraAntes;
                     if falandoPalavra then falaPalavraAntes;
                 end;
        CTLESQ:  begin
                     salva := posx;
                     palavraEsq (true);
                     n := salva-posx;
                     sf := copy (texto[posy], posx, n);
                     if trim (sf) = '' then
                         sintclek
                     else
                         sintetiza (sf);
                 end;

        CTLUP:   setaVertCima;
        CTLDOWN: setaVertBaixo;

        INS:     acionaInsert;
        DEL:     if GetKeyState(VK_CONTROL) < 0 then
                     removelinha (true)
                 else
                 if (iniMarca > 0) and (fimMarca > 0) then
                     removeAreaMarcada
                 else
                     removeProxLetra (true, true);

        DIR:     setaDir;
        ESQ:     setaEsq;

        CIMA:    if (statusTecControle and CONTROL) <> 0 then
                     SetaVertCima
                 else if  apertouShift then
                     recuaParaMesmoNivelDeIndentacao
                 else
                     SetaCima;

        BAIX:    if (statusTecControle and CONTROL) <> 0 then
                     SetaVertBaixo
                 else if  apertouShift then
                     avancaParaMesmoNivelDeIndentacao
                 else
                     Setabaixo;

        HOME: coluna1;
        TEND: ultimaColuna;
        PGUP: voltaPag;
        PGDN: pulaPag;

        CTLINS:       jogaAreaTransf (false);
        SHIFTINS:     pegaAreaTransf (false);

       #129:  selFala('N');   // ALT 0
        'x':  selFala('1');   // ALT 1
        'y':  selFala('2');   // ALT 2
        'z':  selFala('3');   // ALT 3

        else  { of case }

            sintBip;
            sintBip;
    end;

    if apertouShift then
         fimMarca := posx;

    if tecla in [CTLF1, ALTF1, F3, F5, CTLF5, F6, F7, F9, F10, F12,
             CTLPGUP, CTLPGDN, CTLDIR, CTLESQ, CTLHOME, CTLEND,
             CIMA, BAIX, PGUP, PGDN, DEL, CTLDOWN, CTLUP,
             SHIFTINS] then
        escreveTela
    else
        escreveLinha;

    if autoFala then
        begin
            salva := posx;
            if tecla in [CIMA,BAIX, PGUP, PGDN, CTLPGUP, CTLPGDN,
                         CTLHOME, CTLEND, F3] then
                begin
                    if length (trim(texto[posy])) = 0 then
                        begin
                            if not keypressed then
                                sintBip;
                        end
                    else
                        sintTextoFormatado (texto[posy]);
                end
            else
                if tecla in [F5, CTLF5, F6] then
                    falaRestoLinha;

            posx := salva;
        end;
end;

{--------------------------------------------------------}

function criaLinhaNaMargem: string;
var s: string;
    i: integer;
begin
    s := '';
    for i := 1 to margEsq-1 do
        s := s + ' ';

    sintClek;
    if margEsq > 1 then
        sintClek;

    criaLinhaNaMargem := s;
end;

{--------------------------------------------------------}

procedure proxLinhaNaMargem;
var salva: string;

begin
    setaBaixo;
    salva := texto[posy];
    while length (salva) < margEsq do
        salva := salva + ' ';
    texto[posy] := salva;
    posx := margEsq;
end;

{--------------------------------------------------------}

procedure trataControls (tecla: char);
var apertouShift: boolean;
begin
    if (tecla <> ^c) and (tecla <> ^v) then
        begin
            iniMarca := 0;
            fimMarca := 0;
        end;

    apertouShift := GetKeyState(VK_SHIFT) < 0;

    case tecla of
        ^A: avancaParag (false);
        ^R: recuaParag (false);
        ^n : informaNomeArq (false);
        ^y : removelinha (true);
        ^d : apagaFimlinha;
        ^s : apagaInicioLinha;

        ^q : quebralinha;

        ^j:  { control enter }
             insereLinha (criaLinhaNaMargem, true);

        ^m : {tratamento de enter}
             begin
                 if dicionarioAtivado then verificaPalavraAntes;
                 if falandoPalavra then falaPalavraAntes;
                 if enterInsLinha or (posy = maxLinhas) then
                     insereProxLinha (criaLinhaNaMargem, true)
                 else
                     proxLinhaNaMargem;
             end;

        ^I : tabulaInsere(tamanhoTab);
        ^t : tabula;
        ^h : removeLetra (true, true);
        ^b : if apertouShift then informaBloco
             else trataBloco (false);

        ^l : if apertouShift then falaNumeroPagina (true, false)
             else informaLinha (posy, maxLinhas, true);
        ^k : informaColuna;

        ^u : acharProximaPalavraErrada;
        ^e : trataLetrasEspeciais;
        ^x : gravaETermina;
        ^g : if apertouShift then vaiParaPagina (0)
             else posicEmLinha;

        ^f:  falaAtePonto;

        ^c:  if apertouShift then falaAreaTransf
             else jogaAreaTransf (true);
        ^v:  pegaAreaTransf (true);
        ^\:  sintTelefona (texto[posy]);
        ^O: begin
                falaEspacos := not falaEspacos;
                sintbip;
            end;
        ^p: imprime;
        ^w:  trocaPalavraDic;
        ^Z: voltaRemovida;

        CTLBS:   apagaPalavra;

    else { case }

        sintBip;   { teclas invalidas dao dois bips }
        sintBip;
    end;

    escreveTela;
    if tecla in [^A, ^R] then
    sintTextoFormatado (texto[posy]);
end;

{--------------------------------------------------------}

function confirmasaida(perguntaSeSai: boolean): boolean;
var
    resp: char;
begin
    confirmaSaida := true;

    if perguntaSeSai and perguntaAoSair then
    begin
        repeat
            fala ('EDCNFSAI');     {--- confirma saida ---}
            resp := popupMenuPorLetra('SN');
        until resp in ['S','N', ESC];

        if resp in ['N', ESC] then
            begin
                confirmaSaida := false;
                fala ('EDDESIST');
                exit;
            end;
    end;

    if md5DoArquivo = calculaMd5 then
        exit;

    repeat                     {--- ve se quer salvar o arquivo ---}
        fala ('EDQUERSV');
        resp := popupMenuPorLetra ('SN');
    until resp in ['S', 'N', ESC];

    if resp = ESC then
        begin
            confirmaSaida := false;
            fala ('EDDESIST');
            exit;
        end;

    if resp = 'S' then
        salvaArquivo (1, maxLinhas);
end;

{--------------------------------------------------------}

var tecla, tecla2: char;
    ultimoTitulo: array [0..80] of char;
    dummy: integer;

begin
    inicializa;
    amplPegaConfig(fatorAmpl, dummy, dummy, dummy);

    if not abreArquivo then
        terminaPrograma (false);

    escreveTela;
    getWindowText (getFocus, ultimoTitulo, 80);

    EnableMenuItem(GetSystemMenu(CrtWindow, False), sc_Close, mf_Disabled);
    checkBreak := false;

    posx := 1;
    progAcabou := false;

    if (not somenteLeitura) and autoFala then
        begin
            sintTextoFormatado (texto[posy]);
            posx := 1;
        end
    else
        falaRestoTexto;

    repeat
        gotoxy (posx-deslocEsqTela, 15);
        forceCursor;
        amplCampo(texto[posy], posx);

        while not keypressed do
            begin
                waitMessage;
                if not keypressed then
                    if getForegroundWindow = crtWindow then
                        begin
                            trataStatusTec (statusTecControle);
                            gotoxy (posx-deslocEsqTela, 15);
                        end;
            end;

        tecla := readkey;
        sintPara;
        unforceCursor;

        tecla2 := #0;
        if tecla = #0 then
            begin
                tecla2 := readkey;
                if tecla2 in [#16..#18] then
                    tecla := readkey; {ALT-GR q,w,e}
            end;

        case tecla of
             GOTFOCUS, NOFOCUS: ;
             #0:          trataPFeALT (tecla2);
             #27:         begin
                              amplEsconde;
                              progAcabou := somenteLeitura or confirmasaida(true);
                          end;
             #1..#26,
             #28..#31,
             #127:        trataControls (tecla);
        else
            if tecla in [' ', '.', ',', ';', '?', '!', ':'] then
                begin
                    if dicionarioAtivado then verificaPalavraAntes;
                    if falandoPalavra then falaPalavraAntes;
                end;

            iniMarca := 0;
            fimMarca := 0;
            insereLetra (tecla);
        End;

    Until progAcabou;
    terminaPrograma (true);
end.
