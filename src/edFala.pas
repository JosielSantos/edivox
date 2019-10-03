{--------------------------------------------------------}
{
{    Controle da Fala
{
{    Autor: Marcelo Luis Pinheiro
{
{    Orientador Academico: Jose' Antonio Borges
{
{    Em 10/12/93
{
{--------------------------------------------------------}

Unit edFala;

interface
uses
    Dvcrt, DvWin, dvWav, windows, sysutils,
    edVars, edTela, edMensag, edDocUti, edDicion;

Procedure cmdFala;
Procedure falaPalavra;
Procedure falaPalavraAntes;
Procedure falaRestoLinha;
Procedure falaRestoTexto;
procedure falaAtePonto;

implementation

{--------------------------------------------------------}

function isolaPalavra: string;
Var
    j  : integer;
    f, palavra : String;

const
    alfa: set of char = ['a'..'z','A'..'Z', #128..#255];
    numeros: set of char = ['0'..'9'];
Begin
    f := texto[posy];

    palavra :='';
    isolaPalavra := '';
    If (posx > length(f)) or (length(f)=0)
        Then exit;

    j := posx;
    while (j < length(f)) and (f[j] = ' ')  Do
        inc (j);

    if f[j] = '<' then
        palavra := obtemFormatacaoPos (copy(f, j, length(f)-j+1));

    if palavra <> '' then
        j := j + length (palavra)
    else
    if not (f[j] in alfa) then
        begin
           If f[j] in numeros then
               Begin
                   while (j<=length(f)) and (f[j] in numeros) do
                       begin
                           palavra := palavra + f[j];
                           inc(j);
                       end;
               End
           Else
               begin
                   palavra := f[j];
                   inc(j);
               end;
        end
    else
        begin
            while  (j<=length(f)) and (f[j] in alfa) do
                begin
                    palavra:=palavra+ f[j];
                    inc (j);
                end;
        end;

    isolaPalavra := palavra;
    posx := j;
end;

{--------------------------------------------------------}

procedure soletraPalavra;
var palavra: string;
begin
    if mudo then exit;

    palavra := isolaPalavra;
    sintsoletra (palavra);
end;

{--------------------------------------------------------}

procedure falaPalavra;
var palavra: string;
begin
    if mudo then exit;

    if posx <= 80 then
        gotoxy (posx, 15)
    else
        gotoxy (80, 15);

    palavra := isolaPalavra;
    if palavra = ' ' then
        sintclek
    else
        if length (palavra) > 0 then
            sintTextoFormatado (palavra)
        else
            sintBip;
end;

{--------------------------------------------------------}

Procedure falaPalavraAntes;
begin
    sintetiza (descobrePalavraAntes (posx));
end;

{--------------------------------------------------------}

procedure falaRestoLinha;
begin
    if mudo then exit;

    queueingWaves := true;
    if length (texto[posy]) = 0 then
        sintBip
    else
//        if sapiPresente then
//            begin
//                sintTextoFormatado (copy (texto[posy]^, posx, length (texto[posy]^)));
//                posx := length (texto[posy]^) + 1;
//            end
 //       else
            while (posx <= length (texto[posy])) and (not keypressed) do
                falaPalavra;

    queueingWaves := false;
    while sintFalando do waitMessage;
    if keypressed then sintPara;
end;

{--------------------------------------------------------}

procedure falaInicioLinha;
var salva: integer;
begin
    if mudo then exit;

    queueingWaves := true;
    if length (texto[posy]) = 0 then
        sintBip
    else
        begin
            salva := posx;
            posx := 1;
            while (posx+1 < salva) and (not keypressed) do
                    falaPalavra;
            posx := salva;
        end;
    queueingWaves := false;
    while sintFalando do waitMessage;
end;

{--------------------------------------------------------}

procedure falaAtePontuacao (var chegouAoFim: boolean);
var
    s, s2: string;
    p: integer;
label fimTexto;

label fimFala;

begin
    chegouAoFim := false;

    if mudo then
        begin
            chegouAoFim := true;
            exit;
        end;

    if posy > maxLinhas then goto fimTexto;

    if posx > length(texto[posy]) then   { ignora fim de linha e linhas em branco }
        begin
            posx := 1;
            posy := posy + 1;
        end;

    while (posy <= maxLinhas) and (texto[posy] = '') do
        posy := posy + 1;

    if posy > maxLinhas then goto fimTexto;

    s := '';
    repeat
        s2 := texto[posy] + ' ';    // faz com que tenha sempre um espaço no final

        for p := posx to length (s2) do
            begin
                s := s + s2[p];

                if s2[p] in ['.', '!', '?', ':', ';', '<'] then
                    begin
                        if s2[p+1] = ' ' then   // tem que ter espaço depois para encerrar
                            begin
                                posx := p+1;
                                goto fimFala;
                            end;
                    end;
            end;

        posy := posy + 1;
        posx := 1;

    until (posy > maxLinhas) or (texto[posy] = '') or (texto[posy][1] = ' ');

fimFala:
    queueingWaves := true;
    sintTextoFormatado (s);

    while sintFalando do waitMessage;
    queueingWaves := false;

fimTexto:
    if (posy > maxLinhas) or (posx > length (texto[posy])) then
        begin
            posx := 1;
            posy := posy + 1;
        end;

    if posy > maxLinhas then
        begin
            posy := maxLinhas;
            posx := length (texto[posy])+1;
            while sintFalando do waitMessage;
            fala ('EDFIMTEX');
            chegouAoFim := true;
        end;
end;

{--------------------------------------------------------}

procedure falaAtePonto;
var dummy: boolean;
begin
    falaAtePontuacao (dummy);
end;

{--------------------------------------------------------}

Procedure falaRestoTexto;
var chegouAoFim: boolean;
label fim;
begin
    if mudo then exit;

    queueingWaves := true;
    sintFalaPont := falaPontuacao;

    repeat
        if posx <= 80 then
            gotoxy (posx, 15)
        else
            gotoxy (80, 15);

        falaAtePontuacao (chegouAoFim);
        escreveTela;
        if posy > maxLinhas then
            break
        else
            delay (200);

    until chegouAoFim or keypressed;

fim:
    sintFalaPont := true;

    if posy > maxLinhas then
        begin
            posy := maxLinhas;
            posx := length (texto[posy])+1;
        end;

    queueingWaves := false;
    while sintFalando do waitMessage;

    if not somenteLeitura then
        while keypressed do readkey;
end;

{--------------------------------------------------------}

Procedure cmdFala;
var
    tecla: char;
label deNovo;
begin

    fala ('EDOPCAO');   { qual opcao ? }
    tecla := leTeclaMaiusc;

deNovo:
    escreveTela;

    case tecla of

       #$0d, 'F',
             'L': falaRestoLinha;
             'T': falaRestoTexto;
             'I': falaInicioLinha;
             'P': falaAtePonto;

       #$0: begin
                tecla := ajuda (readkey, 'EDAJFA', 4);
                goto deNovo;
            end;
      #$1b: begin
                fala ('EDDESIST');
                exit;
            end
    end;

    escreveTela;
end;

{--------------------------------------------------------}
begin
end.
