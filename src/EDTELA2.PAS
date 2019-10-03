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

Unit EDTELA2;

interface
uses
    DVcrt, DVWin, Windows, dvform,
    edVars, edMensag;

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

procedure desenhaTelaInicial;
var
    i: integer;
    video: string;
begin
    if tamMaxLinha = 79 then
        textmode (co80)
    else
        textmode (co40);

    video := sintAmbiente ('GLOBAIS', 'VIDEO');
    for i := 1 to length (video) do
        video[i] := upcase (video[i]);
    videoVGA := (video = 'VGA') or (video = 'SVGA');

    if videoVGA then
        clrscr;

    textBackground (CYAN);   textColor (BLACK);
    writeln (' ****** ******    ******  **     **   ******   **   ** ');
    writeln (' **      **   **    **    **     **  **    **   ** **  ');
    writeln (' **      **   **    **    **     **  **    **    ***   ');
    writeln (' *****   **   **    **     **   **   **    **     *    ');
    writeln (' **      **   **    **      ** **    **    **    ***   ');
    writeln (' **      **   **    **       ***     **    **   ** **  ');
    writeln (' ****** ******    ******      *       ******   **   ** ');
    writeln;
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
    gotoxy (1, 8);
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
                if videoVGA then
                    write (copy (texto^[i]^, deslocEsqTela+1, tamMaxLinha))
                else
                    write (copy (texto^[i]^, deslocEsqTela+1,
                           tamMaxLinha));
        end;

    textColor (WHITE);
    textBackground (BLACK);

    if tamMaxLinha > 66 then
        begin
            gotoxy (66, 1);
            clreol;
            write ('L:', posy:2, ' C:', posx:2);
        end;
end;

{--------------------------------------------------------}

Procedure escreveLinha;
Var
    desloc: integer;
Begin
    gotoxy (1, 8);
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

    corLetra := LIGHTGRAY;
    if blocoValido and (posy >= iniBloco) and (posy <= fimBloco) then
        corLetra := GREEN;

    textColor (corLetra);
    textBackground (corFundo);

    If (posy > 0) and (posy <= maxlinhas) then
        if videoVGA then
            write (copy (texto^[posy]^, deslocEsqTela+1, tamMaxLinha))
        else
            write (copy (texto^[posy]^, deslocEsqTela+1,
                   tamMaxLinha));
    clreol;

    gotoxy (posx-deslocEsqTela, 15);
    textColor (lightGray);
    textBackground (BLACK);

    if tamMaxLinha > 70 then
        begin
            gotoxy (66, 1);
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
                    s := textoAjuda (nomeAjuda + s);
                    while (s <> '') and (s[1] = ' ') do delete (s, 1, 1);
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
