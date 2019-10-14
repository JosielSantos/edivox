{--------------------------------------------------------}
{
{    Funcoes de manipulacao do cursor
{
{    Autor: Marcelo Luis Pinheiro
{
{    Orientador Academico: Jose' Antonio Borges
{
{    Em 10/12/93
{
{--------------------------------------------------------}

Unit edCursor;

interface
uses
    DVcrt, DVWin, Windows,
    edvars, edMensag, edTela, edEmbel, sysUtils, edDocUti;

function eEspaco(c: char): boolean;
Procedure compactaLinha (posy: integer);
procedure cmdCursor;
procedure insereLetra (letra: char);
Procedure removeLetra (falaDel, falaLetra: boolean);
Procedure removeProxLetra (falaDel, falaLetra: boolean);
procedure removeAreaMarcada;

Procedure SetaEsq;
Procedure SetaDir;
Procedure SetaBaixo;
Procedure SetaCima;
Procedure SetaVertBaixo;
Procedure SetaVertCima;

Procedure inicioTexto;
Procedure fimTexto;
procedure coluna1;
procedure ultimaColuna;
Procedure pulaPag;
Procedure voltaPag;
Procedure avancaParag (paragrafo: boolean);
Procedure recuaParag (paragrafo: boolean);
Procedure posicEmLinha;

Procedure palavraDir (falando: boolean);
Procedure palavraEsq (falando: boolean);

Procedure apagaPalavra;
Procedure apagaFimlinha;
Procedure apagaIniciolinha;

Procedure informaLinha (posAtual, totalLinhas: integer; falarLido: boolean);
Procedure informaColuna;

implementation

{--------------------------------------------------------}

function eEspaco(c: char): boolean;
    begin
    eEspaco := c in [' ', TAB];
end;

{--------------------------------------------------------}

Procedure compactaLinha (posy: integer);
var
    t, tamOrig: integer;
    s: string;
begin
    tamOrig := length (texto[posy]);
    if (tamOrig = 0) or not (eEspaco (texto[posy][tamOrig])) then
        exit;

    s := texto [posy];
    t := tamOrig;
    if t > 0 then
        begin
            while (t > 0) and (eEspaco (s[t])) do  t := t - 1;
            s := copy (s, 1, t);
        end;

    texto [posy] := s;
end;

{--------------------------------------------------------}

procedure insereLetra (letra: char);
var s: string;
begin
    s := texto[posy];
    if posx <= length (s) then
        insert (letra, s,  posx)
    else
        s := s + letra;

    texto [posy] := s;

    posx := posx + 1;

    escreveLinha;

    if (length(texto[posy]) > margDir) then
        if (quebraAuto and (letra <> ' ') and (posx > margDir)) then
            ajusteAutomatico
        else
            sintBip;

    if soletrando then
        sintCarac (letra);
end;

{--------------------------------------------------------}

Procedure removeLetra (falaDel, falaLetra: boolean);
var c: char;
    s, s2: string;
begin
    If posx > 1 Then
        begin
            s := texto[posy];
            s2 := obtemFormatacao (copy (s, 1, posx-1));
            if falaDel then fala ('EDDEL');
            if s2 <> '' then
                begin
                    posx := posx - length (s2);
                    delete (s, posx  , length(s2));
                    sintTextoFormatado (s2);
                end
            else
                begin
                    c := s[posx-1];
                    delete (s, posx-1, 1);
                    dec(posx);
                    if falaLetra then sintCarac (c);
                end;

            texto[posy] := s;

            escreveLinha;
        end
    else
        sintBip;
end;

{--------------------------------------------------------}

Procedure removeProxLetra (falaDel, falaLetra: boolean);
begin
    If posx <= length(texto[posy]) Then
        begin
            posx := posx + 1;
            removeLetra (falaDel, falaLetra);
        end
    else
        sintBip;
end;

{--------------------------------------------------------}

procedure removeAreaMarcada;
var i, n: integer;
begin
    posx := iniMarca;
    n := fimMarca-iniMarca;
    iniMarca := 0;
    fimMarca := 0;
    for i := 1 to n do
       begin
           if (i = 4) and (n > 5) then
               begin
                   sintClek; sintclek;
               end;

           removeProxLetra (i=1, I<4);
       end;
end;

{--------------------------------------------------------}

Procedure SetaEsq;
Begin
    if posx > 1 then
        begin
            posx := posx - 1;
            gotoxy (posx-deslocEsqTela, 15);
            sintCarac(texto[posy][posx]);
        end
    else
        sintBip;
end;

{--------------------------------------------------------}

Procedure SetaDir;
var c: char;
Begin
    if posx <= length(texto [posy]) then
        begin
            posx := posx + 1;
            gotoxy (posx-deslocEsqTela, 15);
            c := texto[posy][posx-1];
            if (not (c in ['A'..'Z', 'a'..'z'])) or
               (getKeyState (vk_Menu) >= 0) then
                sintCarac(c)
            else
                sintSom('_FON' + intToStr(ord(c)));
        end
    else
        sintBip;
end;

{--------------------------------------------------------}

procedure falaEspacosNaFrente;
var
    i: integer;
    s: string;
begin
    if not falaEspacos then exit;
    s := texto[posy];
    if (trim (s) = '') or not (eEspaco (s[1])) then exit;
    i := 1;
    while eEspaco (s[i]) and (i < length(s)) do
        i := i + 1;
    i := i -1;
    sintetiza (intToStr(i));
    sintClek;
end;

{--------------------------------------------------------}

Procedure SetaBaixo;
begin
    if posy < maxlinhas then
        begin
            compactaLinha (posy);
            posy := posy + 1;
            falaEspacosNaFrente;
        end
    else
        begin
            limpaBufTec;
            falaEspacosNaFrente;
            fala ('EDFIMTEX');
        end;

    posx := 1;
end;

{--------------------------------------------------------}

Procedure SetaCima;
begin
    If posy > 1 then
        begin
            compactaLinha (posy);
            posy := posy - 1;
            posx := 1;
            falaEspacosNaFrente;
        end
    else
        begin
            limpaBufTec;
            falaEspacosNaFrente;
            fala ('EDINITEX');
        end;

    posx := 1;
end;

{--------------------------------------------------------}

Procedure SetaVertBaixo;
var
    s: string;

begin
    if posy < maxlinhas then
        begin
            compactaLinha (posy);
            posy := posy + 1;
            sintetiza (intToStr(posx));
            sintclek;

            s := texto[posy];
            while (posx-1) > length(s) do
                s := s + ' ';
            texto[posy] := s;
            if posx > length (texto[posy]) then
                sintCarac (' ')
            else
                sintCarac (texto[posy][posx]);
        end
    else
        begin
            limpaBufTec;
            fala ('EDFIMTEX');
        end;
end;

{--------------------------------------------------------}

Procedure SetaVertCima;
var
    s: string;

begin
    sintetiza (intToStr(posx));
    sintclek;

    If posy > 1 then
        begin
            compactaLinha (posy);
            posy := posy - 1;

            s := texto[posy];
            while (posx-1) > length(s) do
                s := s + ' ';
            texto[posy] := s;
            if posx > length (texto[posy]) then
                sintCarac (' ')
            else
                sintCarac (texto[posy][posx]);
        end
    else
        begin
            limpaBufTec;
            fala ('EDINITEX');
        end;
end;

{--------------------------------------------------------}

procedure coluna1;
begin
    posx := 1;
    sintClek;
end;

{--------------------------------------------------------}

procedure ultimaColuna;
begin
    posx := length( texto [posy])+1;
    sintClek;
end;

{--------------------------------------------------------}

Procedure inicioTexto;
begin
    posy := 1;
    posx := 1;
    fala ('EDINITEX');
    delay (100);
end;

{--------------------------------------------------------}

Procedure fimTexto;
begin
    posy :=maxlinhas;
    posx := 1;
    fala ('EDFIMTEX');
    delay (100);
end;

{--------------------------------------------------------}

Procedure pulaPag;
begin
    posx := 1;
    posy:=posy + 15;
    If posy > maxlinhas Then
        begin
            posy:=maxlinhas;
            limpaBufTec;
            fala ('EDFIMTEX');
        end
    else
        begin
            sintClek;  sintClek;
        end;
end;

{--------------------------------------------------------}

Procedure voltaPag;
var  aux : integer;
begin
    posx := 1;
    aux  := posy - 15;
    If aux < 1 Then
        begin
            posy := 1;
            limpaBufTec;
            fala ('EDINITEX');
        end
     Else
        begin
            posy :=  aux ;
            sintClek;  sintClek;
        end;
end;

{--------------------------------------------------------}

Procedure avancaParag (paragrafo: boolean);
begin
    sintClek;
    if texto [posy] <> '' then
        while (posy <= maxlinhas) and (trim(texto[posy]) <> '') and
            ((texto[posy][1] <> ' ') or (not paragrafo))  do
            begin
                posy := posy + 1;
            if (posy mod 100) = 0 then
                sintClek;
            end
    else
        posy := posy + 1;

    while (posy <= maxlinhas) and (trim(texto[posy]) = '') do
        begin
            posy := posy + 1;
            if (posy mod 20) = 0 then
                sintClek;
        end;

    posx := 1;
    If posy > maxlinhas Then
        begin
            posy := maxlinhas;
            limpaBufTec;
            fala ('EDFIMTEX');
        end
    else
        begin
            sintClek;  sintClek;
        end;
end;

{--------------------------------------------------------}

Procedure recuaParag (paragrafo: boolean);
begin
    posy := posy - 1;
    sintClek;

    while (posy > 0) and (trim(texto[posy]) = '') do
        begin
            posy := posy - 1;
            if (posy mod 100) = 0 then
                sintClek;
        end;

    while (posy > 0) and (trim(texto[posy]) <> '') and
            ((texto[posy][1] <> ' ') or (not paragrafo))  do
        begin
            posy := posy - 1;
            if (posy mod 20) = 0 then
                sintClek;
        end;

    if posy < 1 then
        begin
            posy := 1;
            limpaBufTec;
            fala ('EDINITEX');
        end
    else
        begin
            posy := posy + 1;
            sintClek;  sintClek;
        end;
end;

{--------------------------------------------------------}

Procedure palavraDir (falando: boolean);
var
    linha: string;
    tam: integer;
    c: char;
begin
    tam := length (texto [posy]);
    linha := texto [posy] + ' x';

    c := linha[posx];
    if not eEspaco(c)  then
        repeat
            posx := posx + 1;
            c := linha[posx];
        until not (c in ['a'..'z', 'A'..'Z', '0'..'9', #128..#255]);

    if eEspaco (c) then
        repeat
            posx := posx + 1;
            c := linha[posx];
        until not eEspaco (c);

    if posx > tam+1 then
        begin
            posx := tam+1;
            if falando then sintBip;
        end
    else
        if falando then {sintClek};
end;

{--------------------------------------------------------}

Procedure palavraEsq (falando: boolean);
var
    linha: string;
    c: char;
begin
    linha := ' x' + texto [posy];
    posx := posx + 2;

    repeat
        posx := posx - 1;
        if posx <= length (linha) then
            c := linha[posx]
        else
            c := ' ';
    until c <> ' ';

    repeat
        posx := posx - 1;
        c := linha[posx];
    until not (c in ['a'..'z', 'A'..'Z', '0'..'9', #128..#255]);

    posx := posx - 1;

    if posx <= 0 then
        begin
            posx := 1;
            if falando then sintBip;
        end
    else
        if falando then {sintClek};
end;

{--------------------------------------------------------}

Procedure posicEmLinha;
var num : Integer;
Begin
    num := 0;
    fala ('EDDGNLIN'); { Digite o numero da linha }
    sintReadInt (num);

    if (num > maxLinhas) or (num < 1) then
        fala ('EDLINAO')    { Linha nao existe! }
    else
        begin
            posy := Num;
            posx := 1;
            sintClek;
        end;
end;

{--------------------------------------------------------}

Procedure apagaPalavra;
var
    x, x1, x2: integer;
    s, s2: string;
begin
    posx := posx + 1;
    palavraEsq (false);
    x1 := posx;
    palavraDir (false);
    x2 := posx;

    if x1 <> x2 then
        begin
            s := texto[posy];
            s2 := s;   {para falar depois}

            delete (s, x1, x2-x1);
            texto[posy] := s;
            posx := x1;

            escreveTela;

            sintSom ('EDDEL');
            for x := x1 to x2-1 do
                sintCarac (s2[x]);
        end
    else
        sintBip;
end;

{--------------------------------------------------------}

Procedure apagaFimlinha;
var
    s: string;
begin
    s := texto [posy];
    if posx = 1 then
        s := ''
    else
        s := copy (s, 1, posx-1);

    texto[posy] := s;

    fala ('EDAPAFIM');
end;

{--------------------------------------------------------}

Procedure apagaIniciolinha;
var
    s: string;
begin
    s := texto [posy];

    delete (s, 1, posx-1);
    texto[posy] := s;

    posx := 1;
    fala ('EDAPAINI');
end;

{--------------------------------------------------------}

Procedure informaLinha (posAtual, totalLinhas: integer; falarLido: boolean);
begin
    fala ('EDLINHA');
    escreveNumero (posAtual);
    if not keypressed then delay (50);
    falaSeguinte ('EDDE'); {'de'}
    if not keypressed then delay (50);
    escreveNumero (totalLinhas);
    if not keypressed then delay (100);
////    if falarLido then falaSeguinte ('EDLIDO'); {'lido'}
    escreveNumero ((posAtual*100)div totalLinhas);
    sintWrite ('%');
    delay (100);
end;

{--------------------------------------------------------}

Procedure informaColuna;
begin
    fala ('EDCOLUNA');
    escreveNumero (posx);
    if not keypressed then     delay (100);
end;

{--------------------------------------------------------}

procedure memorizaPoscur;
begin
    salvaCurx := posx;
    salvaCury := posy;
end;

{--------------------------------------------------------}

procedure voltaPoscur;
begin
    posx := salvaCurx;
    posy := salvaCury;
    if posy > maxLinhas then posy := maxlinhas;
    if posx > length (texto[posy])+1 then
        posx := 1;

    escreveTela;
end;

{--------------------------------------------------------}

Procedure cmdCursor;
var
    tecla: char;
label deNovo;
begin
    fala ('EDOPCAO');   { qual opcao ? }
    tecla := leTeclaMaiusc;

deNovo:
    escreveTela;

    case tecla of
        '-': inicioTexto;
        '+': fimTexto;
        'A': avancaParag (true);
        'R': recuaParag (true);
        'P': posicEmLinha;
        'I': apagaIniciolinha;
        'F': apagaFimlinha;
        'L': informaLinha (posy, maxLinhas, true);
        'C': informaColuna;
        'M': memorizaPoscur;
        'V': voltaPoscur;
        'N': avancaParag (false);
        'E': recuaParag (false);

       #$0: begin
                tecla := ajuda (readkey, 'EDAJCU', 14);
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
