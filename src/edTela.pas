{--------------------------------------------------------}
{
{    Controle da escrita na tela
{
{    Autor: Marcelo Luis Pinheiro
{
{    Orientador Academico: Jose' Antonio Borges
{
{    Em 10/12/93
{
{--------------------------------------------------------}

Unit edtela;

interface
uses
    DVcrt, DVWin, Windows, dvform, dvAmplia,
    edVars, edMensag, edDocUti, sysutils;

function tabOuEspaco: char;
function eEspaco(c: char): boolean;
procedure desenhaTelaInicial;
procedure escreveTela;
procedure escreveLinha;
procedure trataStatusTec (var status: word);
procedure escreveNumero (n: longint);
function ajuda (tecla: char; nomeAjuda: string; numAjudas: integer): char;
procedure limpaBufTec;
procedure trocaTamTela;

{--------------------------------------------------------}

implementation

{--------------------------------------------------------}

function tabOuEspaco: char;
    begin
    if comTabs then
        tabOuEspaco := TAB
    else
        tabOuEspaco := ' ';
end;

{--------------------------------------------------------}

function eEspaco(c: char): boolean;
    begin
    eEspaco := c in [' ', TAB];
end;

{--------------------------------------------------------}

procedure desenhaTelaInicial;
begin
    clrscr;

    textColor (WHITE);    textBackground (BLUE);
    writeln (' ****** *******   ******  **     **   ******   **   ** ');
    writeln (' **      **   **    **    **     **  **    **   ** **  ');
    writeln (' **      **   **    **    **     **  **    **    ***   ');
    writeln (' *****   **   **    **     **   **   **    **     *    ');
    writeln (' **      **   **    **      ** **    **    **    ***   ');
    writeln (' **      **   **    **       ***     **    **   ** **  ');
    writeln (' ****** *******   ******      *       ******   **   ** ');

    textBackground (BLACK);   textColor (WHITE);
end;

{--------------------------------------------------------}

function blocoValido: Boolean;
begin
    blocoValido := (iniBloco > 0) and (fimbloco >= iniBloco);
end;

{--------------------------------------------------------}

Procedure escreveTela;
Var
    desloc, i: integer;
Begin
    while sintFalando do waitMessage;
    gotoxy (1, 9);
    clreol;

    desloc := posx-(tamMaxLinha+1);
    if desloc < 0 then
        desloc := 0
    else
        desloc := (desloc+7) and $f8;

    if deslocEsqTela <> desloc then
        deslocEsqTela := desloc;

    For i := posy-5 To posy+10  Do
        begin
            if i = posy then
                 begin
                     escreveLinha;
                     continue;
                 end;

            corLetra := WHITE;
            if blocoValido and (i >= iniBloco) and (i <= fimBloco) then
                corLetra := GREEN;

            gotoxy ( 1, 15 + (i-posy));
            textColor (corLetra);
            textBackground (corFundo);
            clreol;

            if i = 0 then
                begin
                    textBackground (MAGENTA);
                    write ('---- Inicio do texto ----');
                    textBackground (BLACK);
                end;

            if (i > 0) and (i <= maxlinhas) then
                writeSoTexto (copy (texto[i], deslocEsqTela+1, tamMaxLinha));
        end;

    textColor (WHITE);
    textBackground (BLACK);
end;

{--------------------------------------------------------}

Procedure escreveLinha;
Var
    desloc: integer;
    campoPC: string;
    x1, x2: integer;
    atr: word;

     procedure troca (var x1, x2: integer);
     var temp: integer;
     begin
         temp := x1;  x1 := x2;  x2 := temp;
     end;

begin
    if not keypressed then
        while sintFalando do waitMessage;

    gotoxy (1, 9);
    clreol;

    desloc := posx-(tamMaxLinha+1);
    if desloc < 0 then
        desloc := 0
    else
        desloc := (desloc+7) and $f8;

    if deslocEsqTela <> desloc then
        begin
            deslocEsqTela := desloc;
            escreveTela;
        end;

    gotoxy (1, 15);

    corLetra := YELLOW;
    if blocoValido and (posy >= iniBloco) and (posy <= fimBloco) then
        corLetra := LIGHTGREEN;

    textColor (corLetra);
    textBackground (corFundo);

    campoPC := copy (texto[posy], deslocEsqTela+1, tamMaxLinha);
    If (posy > 0) and (posy <= maxlinhas) then
        begin
        x1 := iniMarca - deslocEsqTela - 1;
        x2 := fimMarca - deslocEsqTela - 1;
        if iniMarca > fimMarca then troca (x1, x2);

        if (fimMarca = 0) or (x1 >= 80) or (x2 < 0) then
            writeSoTexto (campoPC)
        else
            begin
                atr := textAttr;
                if x1 > 0 then
                    writeSoTexto (copy (campoPC, 1, x1));
                TextBackGround (DARKGRAY);
                writeSoTexto (copy (campoPC, x1+1, x2-x1));
                textAttr := atr;
                writeSoTexto (copy (campoPC, x2+1, length(campoPC)));
             end;
        end;

    if length (campoPC) < 80 then clreol;

    gotoxy (posx-deslocEsqTela, 15);
    textColor (WHITE);
    textBackground (BLACK);

    if tamMaxLinha > 70 then
        begin
            gotoxy (66, fatorAmpl+1);
            clreol;
            write ('L:', posy:2, ' C:', posx:2);
        end;
end;

{--------------------------------------------------------}

Procedure trataStatusTec (var status: word);

    function KbStatus: byte;
        var retorno: byte;
    begin
        retorno := 0;
        If (getKeyState (vk_numlock) and 1) <> 0  then
            retorno := retorno + $20;
        If (getkeystate (vk_capital) and 1) <> 0  then
            retorno := retorno + $40;
        kbStatus := retorno;
    end;

var
    dif, novostatus: word;

begin
    novostatus := kbStatus;

    dif := status xor novostatus;
    status := novostatus;
    if dif = 0 then exit;

    if (dif and $20) <> 0 then
        if (status and $20) <> 0 then
            fala ('EDNUM')
        else
            fala ('EDNONUM');

    if (dif and $40) <> 0 then
        if (status and $40) <> 0 then
            fala ('EDCAPS')
        else
            fala ('EDNOCAPS');
end;

{--------------------------------------------------------}

Procedure escreveNumero (n: longint);
begin
  SintWriteInt (n );
end;

{--------------------------------------------------------}

function ajuda (tecla: char; nomeAjuda: string; numAjudas: integer): char;
var
    i: integer;
    s: string;
    arq: file;
begin
    if tecla = F1 then
        begin
            for i := 1 to numAjudas do
                begin
                    gotoxy (1, 9+i);
                    textBackGround (BLUE); clreol;
                    str (i, s);
                    writeln (textoAjuda (nomeAjuda + s));
                end;
            textBackground (BLACK);

            while keypressed do readkey;
            for i := 1 to numAjudas do
                if not keypressed then
                    begin
                        str (i, s);
                        assign (arq, dirSomEdivox + '\' + nomeAjuda + s + '.WAV');
                        {$I-}  reset (arq);  {$I+}
                        if ioresult <> 0 then
                            sintetiza (textoAjuda (nomeAjuda + s))
                        else
                            begin
                                close (arq);
                                sintSom (nomeAjuda + s);
                            end;
                    end;

            ajuda := upcase (readkey);
        end
    else
        begin
            gotoxy (1, 10);
            popupMenuCria (30, 10, 50, numAjudas-1, RED);

            for i := 2 to numAjudas do
                begin
                    str (i, s);
                    popupMenuAdiciona (nomeAjuda + s, textoAjuda (nomeAjuda + s));
                end;

            i := popupMenuSeleciona + 1;
            if i = 1 then
                ajuda := ESC
            else
                begin
                    str (i, s);
                    s := trim(textoAjuda (nomeAjuda + s));
                    if copy(s, 1, 8) = 'Ctrl + B' then
                        ajuda := ^b
                    else
                        ajuda := s[1];
                end;
        end;
end;

{--------------------------------------------------------}

procedure limpaBufTec;
begin
    while keypressed do readkey;
end;

{--------------------------------------------------------}

procedure trocaTamTela;
begin
    if tamMaxLinha = 79 then
        tamMaxLinha := 39
    else
        tamMaxLinha := 79;

    desenhaTelaInicial;
end;

end.
