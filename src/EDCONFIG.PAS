{--------------------------------------------------------}
{
{    Configurações
{
{    Autor: Bernard Condorcet
{
{    Em 06/07/2004
{
{--------------------------------------------------------}

Unit edConfig;

interface

uses
    windows, sysUtils,
    DVcrt, DVWin, dvForm, dvstring,
    dvsapi, dvsapglb,
    edvars, edMensag, edTela, edDicion;

procedure formConfig;
procedure cmdConfig;
procedure acionaFala;
procedure acionaInsert;
procedure acionaSoletragem;
procedure trocaModoFalaNaDigitacao;
procedure acionaQuebraAuto;
procedure trocaVeloc;
procedure selFala (nvoz: char);

implementation

procedure formConfig;
var velGeral: integer;
    confInsLinha, confQuebra, confPontuacao, confSoletrando, confFalandoPalavra, confAutomatica,
    confDicio, confCorrige, confSapi, confFormat: shortString;
    confTipoSapi, confNum, confVeloc, confTonal, confTamanhoTab, erro: integer;
    i: integer;
    s: string;
begin

    //Recuperando informações do DOSVOX.INI

    val (sintAmbiente('EDIVOX', 'VELOCIDADE'), velGeral, erro);
    if erro <> 0 then velGeral := 0;
    confInsLinha   := (sintAmbiente('EDIVOX', 'ENTERINSLINHA'));
    confQuebra     := (sintAmbiente('EDIVOX', 'QUEBRARLINHAS'));
    confPontuacao  := (sintAmbiente('EDIVOX', 'FALARPONTUACAO'));
    confSoletrando := (sintAmbiente('EDIVOX', 'SOLETRANDO'));
    confFalandoPalavra := (sintAmbiente('EDIVOX', 'FALANDOPALAVRA'));
    confAutomatica := (sintAmbiente('EDIVOX', 'FALAAUTOMATICA'));
    confDicio      := (sintAmbiente('EDIVOX', 'DICIONARIOATIVADO'));
    confCorrige    := (sintAmbiente('EDIVOX', 'CORRIGIRTODOTEXTO'));
    confFormat := (sintAmbiente('EDIVOX', 'MODOFALAFORMATACAO'));

    confSapi       := (sintAmbiente('EDIVOX', 'SAPIATIVADO'));

    val (sintAmbiente('EDIVOX', 'TIPOSAPI'), confTipoSapi, erro);
    if erro <> 0 then val (sintAmbiente('SERVFALA', 'TIPOSAPI'), confTipoSapi, erro);
    if erro <> 0 then confTipoSapi := 4;

    val (sintAmbiente('EDIVOX', 'NUMEROSAPI'), confNum, erro);
    if erro <> 0 then confNum:= 1;
    val (sintAmbiente('EDIVOX', 'VELOCIDADESAPI'), confVeloc, erro);
    if erro <> 0 then confVeloc:= 0;
    val (sintAmbiente('EDIVOX', 'TONALIDADESAPI'), confTonal, erro);
    if erro <> 0 then confTonal:= 0;

    val (sintAmbiente('EDIVOX', 'MARGDIR'), margDir, erro);
    if erro <> 0 then margDir := 79;

    val (sintAmbiente('EDIVOX', 'TAMANHOTAB'), confTamanhoTab, erro);
    if erro <> 0 then confTamanhoTab := 4;

    // Apresentando o formulário

    textBackground (BLUE);
    writeln;
    fala ('EDPAICON');
    sintBip; sintBip;
    textBackground (BLACK);
    for i := 10 to 25 do
        begin
             gotoxy (1, i);  clreol;
        end;
    gotoxy (1, 10);

    formCria;
    tamRotulosForm := 34;
    formCampoInt ('EDVELC',   txtmsg('EDVELC')   {'Velocidade: '},         velGeral); {''}
    formCampo    ('EDINSLIN', txtmsg('EDINSLIN') {'ENTER insere linha: '}, confInsLinha, 4); {''}
    formCampo    ('EDQUEAUT', txtmsg('EDQUEAUT') {'Quebrar linhas: '},     confQuebra, 4); {''}
    formCampoInt ('EDMARDIR', txtmsg('EDMARDIR') {'Margem direita: '},     margDir); {''}
    formCampo    ('EDFALPON', txtmsg('EDFALPON') {'Falar pontuação: '},    confPontuacao, 4); {''}
    formCampo    ('EDFALLET', txtmsg('EDFALLET') {'Falar letras: '},    confSoletrando, 4); {''}
    formCampo    ('EDFALPAL', txtmsg('EDFALPAL') {'Falar palavras: '},    confFalandoPalavra, 4); {''}
    formCampo    ('EDFALAUT', txtmsg('EDFALAUT') {'Fala automática: '},    confAutomatica, 4); {''}
    formCampo    ('EDCOMDIC', txtmsg('EDCOMDIC') {'Com dicionário: '},     confDicio, 4); {''}
    formCampo    ('EDCORRTD', txtmsg('EDCORRTD') {'Corrigir tudo: '},     confCorrige, 4); {''}
    formCampo    ('EDMODFOR', txtmsg('EDMODFOR') {'Modo formatação (N, F, B ou M): '}, confFormat, 4); {''}
    formCampo    ('EDCOMSAP', txtmsg('EDCOMSAP') {'Com SAPI: '},           confSapi, 4); {''}
    formCampoInt ('EDTIPSPX', txtmsg('EDTIPSPX') {'Tipo SAPI (3, 4, 5 ou 54): '}, confTipoSapi); {''}
    formCampoInt ('EDNUMSAP', txtmsg('EDNUMSAP') {'Número SAPI: '},        confNum); {''}
    formCampoInt ('EDVEL',    txtmsg('EDVEL')    {'Velocidade SAPI: '},    confVeloc); {''}
    formCampoInt ('EDTOM',    txtmsg('EDTOM')    {'Tonalidade SAPI: '},    confTonal); {''}
    formCampoInt ('EDTATAB',   txtmsg('EDTATAB')   {'tab: '}, confTamanhoTab); {''}
    formEdita (true);

    //Efetuando modificações

    if (velGeral < 0) or (velGeral > 5) then
        velGeral:= 0;

    enterInsLinha := primeiraLetra (confInsLinha) = 'S';
    quebraAuto    := primeiraLetra (confQuebra) = 'S';

    if margDir < 10 then
        margDir := 79;

    falaPontuacao := primeiraLetra (confPontuacao) = 'S';
    soletrando := primeiraLetra (confSoletrando) = 'S';
    falandoPalavra := primeiraLetra (confFalandoPalavra) = 'S';
    autoFala      := primeiraLetra (confAutomatica) = 'S';

    if primeiraLetra (confDicio) <> 'S' then
        dicionarioAtivado:= false
    else
        if not dicionarioAtivado then
            begin
                fala ('EDDICATI');
                dicionarioAtivado:= true;
                verificaDicionario (1, 0);
            end;

    if primeiraLetra (confCorrige) <> 'S' then
        corrigirTodoTexto := false
    else
        corrigirTodoTexto := true;
    if upcase (confFormat[1]) in ['N', 'F', 'B', 'M'] then
        modoFalaFormatacao := upcase (confFormat[1])
    else
        modoFalaFormatacao := 'N';

        if confTamanhoTab < 1 then tamanhoTab := 4
        else tamanhoTab := confTamanhoTab;

    // gravando DOSVOX.INI

    sintGravaAmbiente ('EDIVOX', 'VELOCIDADE', intToStr(velGeral));
    sintGravaAmbiente ('EDIVOX', 'ENTERINSLINHA', maiuscAnsi(confInsLinha));
    sintGravaAmbiente ('EDIVOX', 'QUEBRARLINHAS', maiuscAnsi(confQuebra));
    sintGravaAmbiente ('EDIVOX', 'MARGDIR', intToStr(margDir));
    sintGravaAmbiente ('EDIVOX', 'FALARPONTUACAO', maiuscAnsi(confPontuacao));
    sintGravaAmbiente ('EDIVOX', 'SOLETRANDO', maiuscAnsi(confSoletrando));
    sintGravaAmbiente ('EDIVOX', 'FALANDOPALAVRA', maiuscAnsi(confFalandoPalavra));
    sintGravaAmbiente ('EDIVOX', 'FALAAUTOMATICA', maiuscAnsi(confAutomatica));
    sintGravaAmbiente ('EDIVOX', 'DICIONARIOATIVADO', maiuscAnsi(confDicio));
    sintGravaAmbiente ('EDIVOX', 'CORRIGIRTODOTEXTO', maiuscAnsi(confCorrige));
    sintGravaAmbiente ('EDIVOX', 'MODOFALAFORMATACAO', maiuscAnsi(modoFalaFormatacao));
    sintGravaAmbiente ('EDIVOX', 'SAPIATIVADO', maiuscAnsi(confSapi));
    sintGravaAmbiente ('EDIVOX', 'TIPOSAPI', intToStr(confTipoSapi));
    sintGravaAmbiente ('EDIVOX', 'NUMEROSAPI', intToStr(confNum));
    sintGravaAmbiente ('EDIVOX', 'VELOCIDADESAPI', intToStr(confVeloc));
    sintGravaAmbiente ('EDIVOX', 'TONALIDADESAPI', intToStr(confTonal));
    sintGravaAmbiente ('EDIVOX', 'TAMANHOTAB', intToStr(tamanhoTab));

    fala ('EDAGUARC');
    sintPara;

    s := sintAmbiente ('EDIVOX', 'VELOCIDADE');
    if (s = '') or (s = '0') then
        s := sintAmbiente ('TRADUTOR', 'VELOCIDADE');
    if s = '' then
        velGeral := 0
    else
        val (s, velGeral, erro);

    if confSapi = '' then
        begin
            comSapi := primeiraLetra (sintAmbiente ('TRADUTOR', 'SAPI')) = 'S';
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
            comSapi := primeiraLetra (confSapi) = 'S';
            sintReinic (velGeral, comSapi, confTipoSapi, confNum, confVeloc, confTonal);
        end;

    writeln;
    fala ('EDOK');
    sintBip; sintBip; sintBip;
    escreveTela;
end;

{--------------------------------------------------------}

procedure acionaFala;
begin
    mudo := not mudo;
    if mudo then
        fala ('EDFALDLG')
    else
        fala ('EDFALACI');
end;

{--------------------------------------------------------}

procedure acionaInsert;
begin
    enterInsLinha := not enterInsLinha;
    if enterInsLinha then
        fala ('EDENTINS')
    else
        fala ('EDENTNIN');
end;

{--------------------------------------------------------}

Procedure acionaSoletragem;
begin
    soletrando := not soletrando;
    if soletrando then
        fala ('EDSOLETR')
    else
        fala ('EDNSOLET');
end;

{--------------------------------------------------------}

procedure trocaModoFalaNaDigitacao;
begin
    if soletrando and (not falandoPalavra) then
        begin
            soletrando := false;
            falandoPalavra := true;
            fala ('EDPALAVR'); {'palavras'}
        end
    else
    if (not soletrando) and falandoPalavra then
        begin
            soletrando := true;
            fala ('EDLETPAL'); {'letras e palavras'}
        end
    else
    if soletrando and falandoPalavra then
        begin
            soletrando := false;
            falandoPalavra := false;
            sintClek; sintClek;
        end
    else
    if (not soletrando) and (not falandoPalavra) then
        begin
            soletrando := true;
            fala ('EDLETRAS'); {'letras'}
            falandoPalavra := false;
        end;
end;

{--------------------------------------------------------}

procedure acionaQuebraAuto;
begin
    quebraAuto := not quebraAuto;
    if quebraAuto then
        fala ('EDQAUTO')
    else
        fala ('EDNQAUTO');
end;

{--------------------------------------------------------}

procedure trocaVeloc;
var
    c : char;
begin
    fala ('EDVELOC');  { Qual a velocidade de 1 a 5 }
    c := popupMenuPorLetra ('12345');
    if (c = ESC) or (c=ENTER) then exit;

    sintFim;
    sintInic (ord(c)-ord('0'), DIRsomEdivox);
end;

{--------------------------------------------------------}

procedure cmdConfig;
var
    tecla: char;
label deNovo;
begin
    fala ('EDOPCAO');   { qual opcao ? }
    tecla := leTeclaMaiusc;

deNovo:
    escreveTela;

    case tecla of

        'F': acionaFala;
        'I': acionaInsert;
        'S': acionaSoletragem;
        'Q': acionaQuebraAuto;
        'V': trocaVeloc;

       #$0: begin
                tecla := ajuda (readkey, 'EDAJCF', 7);
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

procedure selFala (nvoz: char);
var
    s: string;
    param: TParamVoz;
    velGeral, erro: integer;

    function extraiParam (var s: string): integer;
    var n: integer;
        negativo: integer;
    begin
        while (s <> '') and (s[1] = ' ') do delete (s, 1, 1);
        n := 0;

        negativo := 1;
        if (s <> '') and (s[1] = '-') then
            begin
                negativo := -1;
                delete (s, 1, 1);
            end;

        while (s <> '') and (s[1] in ['0'..'9']) do
            begin
                n := n * 10 + (ord(s[1]) - ord ('0'));
                delete (s, 1, 1);
            end;
        extraiParam := n * negativo;
    end;

begin
    s := sintAmbiente ('EDIVOX', 'VELOCIDADE');
    if (s = '') or (s = '0') then
        s := sintAmbiente ('TRADUTOR', 'VELOCIDADE');
    if s = '' then
        velGeral := 0
    else
        val (s, velGeral, erro);

    if nvoz = 'N' then
        sintReinic (velGeral, false, 3, 1, 1, 1)
    else
        begin
            s := sintAmbiente ('SAPIUTIL', 'VOZ'+nvoz);
            with param do
                begin
                    voz        := extraiParam (s);
                    velocidade := extraiParam (s);
                    tom        := extraiParam (s);
                    tipoSapi   := extraiParam (s);
                    if tipoSapi = 0 then tipoSapi := 4;

                    sintReinic (velGeral, true, tipoSapi, voz, velocidade, tom);
                end;
        end;
end;

end.
