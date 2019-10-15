{--------------------------------------------------------}
{
{    Rotinas de embelezamento de bloco
{
{    Autor: Marcelo Luis Pinheiro
{
{    Orientador Academico: Jose' Antonio Borges
{
{    Em 10/12/93
{
{--------------------------------------------------------}

Unit edembel;

interface

uses
    DVcrt, DVWin, sysutils,
    edvars, edMensag, edLinha, edTela;

Procedure EmbelezaBloco;
Procedure AjusteAutomatico;
procedure acertaMargens (falando: boolean);

implementation

{--------------------------------------------------------}

function blocoInvalido: Boolean;
begin
    blocoInvalido := (iniBloco <= 0) or (fimbloco < iniBloco);
end;

{--------------------------------------------------------}

procedure CentraBloco;
var i, x, posic, inicio, centro: integer;
    b, l: string;

begin
    If (inibloco = 0) or (fimbloco = 0) then
        begin
            fala ('EDBLKINV' );
            exit;
        end;

    for posic := inibloco to fimbloco do
        begin
            l := texto[posic] + 'x';
            x := 1;
            while l[x] = ' ' do
                x := x + 1;
            l := copy (l, x, length (l)-x);

            l := 'x' + l;
            x := length (l);
            while l[x] = ' ' do
                x := x - 1;
            l := copy (l, 2, x-1);

            centro := (margesq+margdir) div 2;
            inicio := centro - length(l) div 2;
            if inicio < 0 then inicio := 1;

            b := '';
            for i := 2 to inicio do
                b := b + ' ';

            texto[posic] := b + l;
        end;

    posx := 1;
    posy := iniBloco;
    fala ('EDBLKCNT');
end;

{--------------------------------------------------------}

Procedure tabulaBloco;
Var
    y, nbr: integer;
    brancos, s: string;

Begin
    If blocoInvalido Then
        begin
            fala ('EDBLKINV');
            exit;
        end;

    fala ('EDCOLMAR');    { informe a coluna da esquerda }
    nbr := 0;
    SintReadInt (nbr);
    if nbr < 1 then
        begin
            fala ('EDDESIST');
            exit;
        end;

    brancos := '';
    while nbr > 1 do
        begin
           brancos := brancos + ' ';
           nbr := nbr - 1;
        end;

    For y := inibloco to fimbloco do
        begin
            s := texto[y];
            s := s + '*';
            while eEspaco (s[1])  do
                delete (s, 1, 1);
            delete (s, length(s), 1);

            s := brancos + s;
            texto[y] := s;
        end;

    posx := 1;
    posy := inibloco;
    fala ('EDBLKTAB');
end;

{--------------------------------------------------------}

Procedure IndentaBloco;
Var
    y, i, ncol: integer;
    s: string;

Begin
    If blocoInvalido  Then
        begin
            fala ('EDBLKINV');
            exit;
        end;

    fala ('EDNCLIND');  { Numero de colunas a indentar: }
    ncol := 0;
    sintReadInt (ncol);
    if ncol = 0 then
        begin
            fala ('EDDESIST');
            exit;
        end;

    For y := inibloco to fimbloco  Do
        begin
            s := texto[y];
            if ncol > 0 then
                for i := 1 to ncol do
                    s := ' ' + s
            else
                for i := 1 to abs(ncol) do
                    if (s <> '') and (eEspaco (s[1])) then
                        delete (s, 1, 1);

            texto[y] := s;
        end;

    posx := 1;
    posy := inibloco;
    fala ('EDBLKALI');
end;

{--------------------------------------------------------}

procedure acertaMargens (falando: boolean);
var
    linhaIns: integer;
    bcoMargem, linha, sobra: string;
    margAntiga: integer;

const MARCAFIM = ^f;

    {--------------------------------------------------------}

    procedure daSaida (var txt: string);
    var
        posBranco, limiteDir: integer;
        s: string;
    label parteLinha;

    begin
        limiteDir := margDir-MargEsq+1;

        if length (txt) <= limiteDir then
            begin
                posy := linhaIns;
                insereLinha (bcoMargem + txt, false);
                txt := '';
                linhaIns := linhaIns + 1;
                exit;
            end;

        for posBranco := limiteDir+1 downto 2 do
            if eEspaco (txt[posBranco]) then
                goto parteLinha;

        posBranco := limiteDir;

parteLinha:
        s := copy (txt, 1, posBranco);
        while (s <> '') and (s[length(s)] = ' ') do
            delete (s, length(s), 1);
        txt := copy (txt, posBranco+1, length(txt)-posBranco);

        posy := linhaIns;
        insereLinha (bcoMargem + s, false);
        linhaIns := linhaIns + 1;
    end;

    {--------------------------------------------------------}

    procedure descarrega (txt: string);
    begin
        while txt <> '' do
            daSaida (txt);
    end;

    {--------------------------------------------------------}

    function inicioParagrafo (linha: string): boolean;
    begin
        if (trim(linha) <> '') and not eEspaco (linha [1]) then
            inicioParagrafo := false
        else
            inicioParagrafo := true;
    end;

    {--------------------------------------------------------}

    procedure achaMargemAntiga;
    var l, c: integer;
    label proxLinha;

    begin
        margAntiga := 255;
        for l := iniBloco to fimBloco do
            begin
                for c := 1 to length (texto[l]) do
                    begin
                        if c >= margAntiga then
                            goto proxLinha;

                        if not eEspaco(texto[l][c]) then
                            margAntiga := c;
                    end;
    proxLinha:
            end;

        if margAntiga = 255 then
            margAntiga := 1;
    end;

    {--------------------------------------------------------}

    procedure compactaBrancos;
    var i: integer;
    label bcoEsqRemov;
    begin
                     {--- remove margem antiga ---}

        for i := 1 to margAntiga-1 do
            if (length (linha) = 0) or not eEspaco (linha[1]) then
                goto bcoEsqRemov
            else
                delete (linha, 1, 1);

bcoEsqRemov:
                     {--- acha primeiro nao branco ---}
        i := 1;
        while (i < length(linha)) and eEspaco (linha [i]) do
           i := i + 1;

                     {--- compacta brancos seguidos ---}

        while i < length(linha) do
            if eEspaco (linha[i]) and eEspaco (linha[i+1]) then
                delete (linha, i, 1)
            else
                i := i + 1;
    end;

    {--------------------------------------------------------}

var
    i: integer;

begin
////    achaMargemAntiga;
    margAntiga := 1;

    bcoMargem := '';
    for i := 2 to margEsq do
        bcoMargem := bcoMargem + ' ';

    linhaIns  := iniBloco;
    fimBloco := fimBloco+1;
    posy := fimBloco;
    insereLinha (MARCAFIM, false);
    sobra := '';

    repeat
        posy := linhaIns;
        linha := texto[posy];
        compactaBrancos;

        removeLinha (false);

        if linha = MARCAFIM then
            descarrega (sobra)

        else if linha = '' then
            begin
                descarrega (sobra);
                sobra := '';
                daSaida (sobra);
            end

        else if inicioParagrafo (linha) then
            begin
                descarrega (sobra);
                sobra := linha;
            end

        else
            begin
                if sobra <> '' then
                    linha := sobra + ' ' + linha;
                while (length(linha) + margEsq - 1) > margDir do
                    daSaida (linha);
                sobra := linha;
            end;

        until linha = MARCAFIM;

    posx := 1;
    posy := iniBloco;
    fimBloco := fimBloco-1;
    if falando then
        fala ('EDBLKMRG');
end;

{--------------------------------------------------------}

procedure alinhaBloco;

var
    s: string;

    {--------------------------------------------------------}

    function EInicioParagrafo (linha: string): boolean;
    var lim, i: integer;
    begin
        EInicioParagrafo := true;
        lim := margEsq+1;
        if length (linha) < lim then
            lim := length (linha);
        for i := 1 to lim do
            if not eEspaco(linha [i]) then
                begin
                    EInicioParagrafo := false;
                    exit;
                end;
    end;

    {--------------------------------------------------------}

    procedure ajustaLinha;
    var pbr, primCarac, i: integer;
    label limpouFim, achouNaoBranco;

    begin
        for i := length (s) downto 1 do
            if eEspaco (s [i])  then
                delete (s, i, 1)
            else
                goto limpouFim;

        if length(s) = 0 then exit;

    limpouFim:
        for primCarac := margEsq to length(s) do
            if not eEspaco (s [primCarac]) then
                goto achouNaoBranco;
        primCarac := length(s) + 1;

    achouNaoBranco:
        if (length (s) <> margDir) and
           (pos (' ', copy (s, primcarac, length(s))) > 0) then
            begin
                pbr := length(s)-1;
                while length (s) <> margDir do
                    begin
                        while (pbr > primCarac) and not eEspaco(s [pbr]) do
                            pbr := pbr - 1;
                        if pbr <= primCarac then
                            pbr := length(s)-1
                        else
                            begin
                                s := copy (s, 1, pbr) + ' ' +
                                    copy (s, pbr+1, length(s)-pbr);
                                pbr := pbr - 1;
                            end;
                    end;
            end;
    end;

var y: integer;
begin
    acertaMargens (false);

    for y := iniBloco to fimBloco do
        begin
            posy := y;
            if (length (texto[posy]) < margDir) and
               (posy < maxlinhas) and (texto[posy+1] <> '') and
               (not EInicioParagrafo (texto[posy+1])) then
                begin
                    s := texto[posy];
                    ajustaLinha;
                    texto[posy] := s;
                end;
        end;

    posx := 1;
    posy := iniBloco;
    fala ('EDBLKALI');
end;

{--------------------------------------------------------}

Procedure ajusteAutomatico;
var
    posBranco, i, salvax, salvay: integer;
    s1, s2, bco: string;

label brancoEsq, brancoDir, buscaEsq;

begin
    salvax := posx;
    salvay := posy;

    if posx < margEsq + length (texto[posy]) div 2 then
                   { cursor na 1a. metade da linha ? }
        begin

            {--- busca primeiro branco a direita ---}
            for i := posx to margDir-1 do
                if eEspaco (texto[posy][i]) then
                    begin
                        posBranco := i;
                        goto brancoDir;
                    end;

            goto buscaEsq;

            {--- parte linha neste branco ---}

brancoDir:
            s1 := copy (texto [posy], 1, posBranco-1);
            s2 := copy (texto [posy], posBranco,
                        length (texto[posy])-posBranco+1);

            {--- acerta margem da linha quebrada ---}

            while not (eEspaco (s2[1]) and (length(s2) = 1)) and eEspaco (s2 [1]) do
                delete (s2, 1, 1);
            bco := '';
            for i := 2 to margEsq do
                bco := bco + ' ';
            s2 := bco + s2;

            {--- recria as duas linhas }

            removeLinha (false);
            insereLinha (s2, false);
            insereLinha (s1, false);
        end

    else      { cursor na 2a. metade da linha ? }

        begin
            {--- busca primeiro branco a esquerda ---}
buscaEsq:
            for i := posx-1 downto margEsq+1 do
                if eEspaco (texto[posy][i]) then
                    begin
                        posBranco := i;
                        goto brancoEsq;
                    end;

            posBranco := posx-2;

            {--- parte linha depois deste branco ---}
brancoEsq:
            s1 := copy (texto [posy], 1, posBranco);
            s2 := copy (texto [posy], posBranco+1,
                       length (texto[posy])-posBranco);

            salvax := posx - length (s1);

            {--- acerta margem da linha quebrada ---}

            while not (eEspaco (s2[1]) and (length(s2) = 1)) and eEspaco (s2 [1]) do
                begin
                     delete (s2, 1, 1);
                     salvax := salvax - 1;
                end;

            bco := '';
            for i := 2 to margEsq do
                bco := bco + ' ';
            s2 := bco + s2;
            salvax := salvax + length (bco);

            {--- remove brancos da direita da primeira linha ---}

            while (s1 <> '') and eEspaco (s1 [length(s1)]) do
                delete (s1, length(s1), 1);

            {--- recria as duas linhas }

            removeLinha (false);
            insereLinha (s2, false);
            insereLinha (s1, false);

            {--- cursor vai para posicao conveniente da proxima linha ---}

            salvay := salvay + 1;
        end;

    {--- posiciona cursor ---}

    posx := salvax;
    posy := salvay;

    if posx < 1 then posx := 1;             { programacao defensiva }
    if posx > length (texto[posy])+1 then
        posx := length (texto[posy])+1;

    escreveTela;
end;

{--------------------------------------------------------}

Procedure EmbelezaBloco;
var c: char;
label deNovo;
begin
    If blocoInvalido then
        begin
             fala ( 'EDBLKINV' );
             exit;
        end;

    fala ('EDOPCAO');   { qual opcao ? }
    c := leTeclaMaiusc;
    escreveTela;
    
deNovo:
    case c of
        'C':  centraBloco;
        'M':  acertaMargens (true);
        'A':  alinhaBloco;
        'T':  tabulaBloco;
        'I':  indentaBloco;
       #$0: begin
                c := ajuda (readkey, 'EDAJEM', 6);
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

end.
