{--------------------------------------------------------}
{
{    Rotinas de tratamento de linhas do EDIVOX
{
{    Autor: Marcelo Luis Pinheiro
{
{    Orientador Academico: Jose' Antonio Borges
{
{    Em 10/12/93
{
{--------------------------------------------------------}

Unit edLinha;

interface
uses
    DVcrt, DVWin, sysutils,
    dvForm, 
    edvars,  edMensag, edTela;

procedure memorizaLinha;
procedure posicionaNaLinhaMemorizada;
procedure cmdLinha;
Procedure insereLinha (conteudo : String; falando: boolean) ;
Procedure insereProxLinha (conteudo : String; falando: boolean) ;
Procedure Removelinha (falando: boolean);
procedure voltaRemovida;
procedure quebraLinha;
procedure insereNaLinha (conteudo: string);

implementation

{--------------------------------------------------------}

const maxMemoria = 30;
type tLinhaMemo = array [1..maxMemoria] of integer;
var memoriaLinha: tLinhaMemo;

{--------------------------------------------------------}

procedure memorizaLinha;
var
    i: integer;
    gravou: boolean;
begin
    gravou := false;
    for i := 1 to maxMemoria do
        if memoriaLinha [i] = posy then
            begin
                gravou := true;
                break;
            end;

    if not gravou then
        for i := 1 to maxMemoria do
            if memoriaLinha [i] = 0 then
                begin
                    gravou := true;
                    memoriaLinha [i] := posy;
                    break;
                end;

    if not gravou then
        begin
            for i := 1 to (maxMemoria - 1) do
                memoriaLinha [i] := memoriaLinha [i + 1];
            memoriaLinha [maxMemoria] := posy;
        end;
    fala ('EDLINHA');
    escreveNumero (posy);
    fala ('EDMEMORI'); {'memorizada'}
end;

{--------------------------------------------------------}

procedure posicionaNaLinhaMemorizada;
var
    i, n, qtdMemo: integer;
begin
    qtdMemo := 0;
    i := 1;
    while i <= maxMemoria do
        if (memoriaLinha [i] > 0) and (memoriaLinha [i] <= maxlinhas)  then
            begin
                qtdMemo := qtdMemo + 1;
                i := i + 1;
            end
        else
        if memoriaLinha [i] > maxlinhas  then
            for n := i to (maxMemoria - 1) do memoriaLinha [n] := memoriaLinha [n + 1]
        else
            i := i + 1;

    if qtdMemo = 0 then
        begin
            sintBip;
            exit;
        end;
    if qtdMemo = 1 then
        posy := memoriaLinha [1]
    else
        begin
            fala ('EDCFVEL'); {'Use as setas para selecionar.'}
            popupMenuCria (35, wherey, 44, qtdMemo, RED);
            for i := 1 to qtdMemo do
                popupMenuAdiciona('', intToStr(memoriaLinha [i]) + ' ' + texto[memoriaLinha [i]]);

            n := popupMenuSeleciona;
            if (n > 0) and (n <= qtdMemo) then
                posy := memoriaLinha [n]
            else
                begin
                    sintclek;
                    exit;
                end;
        end;

    escreveNumero (posy);
end;

{--------------------------------------------------------}

Procedure insereLinha (conteudo : String; falando: boolean) ;
Begin
    texto.Insert(posy, conteudo);
    inc (maxlinhas);
    while posy >= texto.count do texto.append('');

    posx := length (conteudo)+1;

    if falando then
        fala ('EDLINSER');

    if posy < inibloco then
        inibloco := inibloco + 1;
    if posy <= fimbloco then
        fimbloco := fimbloco + 1;
    if posy < salvaCury then
        salvaCury := salvaCury + 1;
end;

{--------------------------------------------------------}

Procedure insereProxLinha (conteudo : String; falando: boolean) ;
Begin
    posy := posy + 1;
    insereLinha (conteudo, false);

    if falando and (posy < maxlinhas) then
        fala ('EDLINSER');
end;

{-----------------------------}

Procedure Removelinha (falando: boolean);
Begin
    linhaRemovida := intToStr(posy) + '|' + texto[posy];

    If posy< maxlinhas then
        begin
            dec (maxlinhas);
            texto.delete(posy);
        end
    else
        If posy = maxlinhas Then
            begin
                texto [posy] := '';
                if falando then sintBip;
            end;

    posx := 1;
    if falando then
        fala ( 'EDLINREM' );

    if posy < iniBloco then
        iniBloco := iniBloco - 1;
    if posy <= fimBloco then
        fimBloco := fimBloco - 1;

    if posy = salvaCury then
        begin
            salvaCurx := 1;
            salvaCury := 1;
        end;

    if posy < salvaCury then
        salvaCury := salvaCury - 1;
end;

{--------------------------------------------------------}

procedure voltaRemovida;
var p: integer;
begin
    if linhaRemovida = '' then
        sintBip
    else
        begin
            p := pos ('|', linhaRemovida);
            posy := strToInt(copy(linhaRemovida, 1, p-1));
            delete (linhaRemovida, 1, p);
            if posy > maxLinhas then posy := maxLinhas + 1;
            insereLinha (linhaRemovida, true);
            linhaRemovida := '';
        end;
end;

{--------------------------------------------------------}

procedure juntaLinhas;
var linha: string;
    salvax, salvay: integer;
begin
    if posy < maxlinhas then
        begin
            linha := texto [posy] + ' ' + texto [posy+1];
            salvax := posx;  salvay := posy;
            removeLinha (false);
            texto[posy] := linha;
            posx := salvax;  posy := salvay;
            fala ('EDLINJUN');
        end;
end;

{-----------------------------}

Procedure quebraLinha;
Var
    linha1, linha2: String;
Begin
    If posx = 1 Then
        Begin
            insereLinha ('', false);
            posy := posy + 1;
            fala ('EDLINQUE');
        end
    Else
    If posx > length ( texto[posy]) then
        juntaLinhas
    Else
        begin
            linha1 := copy (texto [posy], 1, posx-1);
            linha2 := copy (texto [posy], posx, length (texto[posy])-posx+1);
            texto[posy] := linha2;
            insereLinha (linha1, false);
            posy := posy + 1;
            posx := 1;
            fala ('EDLINQUE');
        end;
end;

{--------------------------------------------------------}

procedure editaOuApagaLinha (noInicio: boolean; apagaLinha: boolean);
var
    y, yIni, yFim, salvaY, p, salvaIniBloco, salvaFimBloco: integer;
    textoBusc, s: string;
    c: CHAR;
begin
    repeat
        textoBusc := '';
        if apagaLinha then
            fala ('EDQUATRE') {'Qual o texto das linhas a excluir?'}
        else
            fala ('EDTXTPRC'); {'Qual o texto ? '}
        c := sintEditaCampo (textoBusc, 1, wherey, 255, 80, true);
        writeln;
    until upcase(c) in [ENTER, ESC];
    if (c = ESC) or (trim(textoBusc) = '') then
        begin
                    fala ('EDDESIST');
            exit;
        end;

    repeat
        fala ('EDTODBLK'); {'Todo texto (T) ou bloco (B): '}
        c := popupMenuPorLetra ('TB');
    until c in ['T', 'B', ESC];
    if c = ESC then
        begin
                    fala ('EDDESIST');
            exit;
        end;

    if c = 'T' then
        begin
            yIni := 1;
            yFim := maxLinhas;
        end
    else
    if (c = 'B') and (fimbloco < iniBloco) then
         begin
             fala ('EDBLKINV');   { bloco invalido }
             exit;
         end
    else //Bloco válido
        begin
            yIni := iniBloco;
            yFim := fimBloco;
        end;

    if apagaLinha then
        if textoBusc[length(textoBusc)] = '*' then
            begin
                delete (textobusc, length(textoBusc), 1);
                noInicio := true;
            end
        else noInicio := false;

    salvaIniBloco := iniBloco;
    salvaFimBloco := fimBloco;
    salvaY := posY;
    for y := yFim downto yIni do
        begin
            s := texto[y];
            if trim (s) = '' then continue;
            if not apagaLinha then
                begin
                    if noInicio then
                        s := textoBusc + s
                    else
                        s := s + textoBusc;
                    texto[y] := s;
                    continue;
                end;

            if noInicio then
                p := pos (textoBusc, copy (s, 1, length (textoBusc)))
            else
                p := pos (textoBusc, s);
            if p > 0 then
                begin
                    posY := y;
                    Removelinha (false);
                    if y <= salvaY then
                        salvaY := salvaY - 1;
                end;

        end;

    if not apagaLinha then
        begin
            iniBloco := salvaIniBloco;
            fimBloco := salvaFimBloco;
        end;

    posY := salvaY;
    if posY > maxLinhas then posY := maxLinhas
    else
    if posY < 1 then posY := 1;
    fala ('EDOK');
end;

{--------------------------------------------------------}

procedure excluiLinhasComTexto;
begin
    editaOuApagaLinha (false, true);
    end;

{--------------------------------------------------------}

procedure cmdLinha;
var
     tecla: char;
label deNovo;

begin

    fala ('EDOPCAO');   { qual opcao ? }
    tecla := leTeclaMaiusc;

deNovo:
    escreveTela;

    case tecla of

       'I': insereLinha ('', true);
  'A', 'N': insereProxLinha ('', true);
       'R': Removelinha (true);
       'V': voltaRemovida;
       'Q': quebraLinha;
       'J': juntaLinhas;
       'E': excluiLinhasComTexto;
       'S': editaOuApagaLinha (true , false);
       'D': editaOuApagaLinha (false , false);

       #$0: begin
                tecla := ajuda (readkey, 'EDAJLI', 10);
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
{       Insere uma string na linha
{--------------------------------------------------------}

procedure insereNaLinha (conteudo: string);
var
    linha, saida: string;
    salvax: integer;
begin
    linha := texto[posy];
    saida := copy (linha, 1, posx-1) + conteudo + copy (linha, posx, length(linha)-posx+1);
    salvax := posx;
    texto[posy] := saida;
    posx := salvax + length (conteudo);
end;

end.

{--------------------------------------------------------}

begin
end.
