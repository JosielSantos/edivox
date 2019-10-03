{--------------------------------------------------------}
{
{    Margens e Tabulacoes
{
{    Autor: Marcelo Luis Pinheiro
{
{    Orientador Academico: Jose' Antonio Borges
{
{    Em 10/12/93
{
{--------------------------------------------------------}

Unit edMargem;

interface
uses
    DVcrt, DVWin, dvString, sysutils,
    edvars, edlinha, edMensag, edTela, edcursor;

procedure cmdMargem;
procedure tabula;
procedure tabulaInsere(numEspacos: integer);
procedure removeTabulacoes;
procedure insereTabulacao;
Procedure pedeMargens;

implementation

{--------------------------------------------------------}

procedure tabula;
var i, salva: integer;
    s: string;
label achou;
begin
    for i := 1 to ntabs do
        if tabs[i] > posx then
            begin
                posx := tabs[i];
                goto achou;
            end;

    if posx < margEsq then
        posx := margEsq
    else
        posx := ((posx+3) div 4) * 4 + 1;

achou:
    s := texto[posy];
    if length (s) < (posx-1) then
        begin
            while length (s) < (posx-1) do
                s := s + ' ';
            salva := posx;
            texto[posy] := s;
            posx := salva;
        end;

    sintetiza(intToStr(posx));
    sintClek;
    if posx > length (texto[posy]) then
        sintCarac (' ')
    else
        sintCarac (texto[posy][posx]);
end;

{--------------------------------------------------------}

procedure tabulaInsere(numEspacos: integer);
var posfinal, i: integer;
    comTabs: boolean;
    s: string;
label achou;
begin
    comTabs := primeiraLetra (sintAmbiente ('EDIVOX', 'CARACTERESTAB')) = 'S';
    if comTabs then numEspacos := 1; { Usa apenas um caractere tab por vez }

    posFinal := ((posx+(numEspacos-1)) div numEspacos) * numEspacos + 1;

    s := texto[posy];
    for i := posx+1 to posFinal do
        if comTabs then
            insert (TAB, s, posx)
        else
            insert (' ', s, posx);

    texto[posy] := s;
    posx := posFinal;

    SintSom('EDTECTAB'); {'Tab'}
    if falaEspacos then
        sintetiza(intToStr(posx));
    sintClek;
    sintClek;
end;

{--------------------------------------------------------}

procedure removeTabulacoes;
begin
    ntabs := 0;
    fala ('EDTABCAN');  { tabulacoes canceladas }
end;

{--------------------------------------------------------}

procedure insereTabulacao;
var i, j: integer;
label fim;
begin
    for i := 1 to ntabs do
        begin
            if tabs[i] = posx then exit;
            if tabs[i] > posx then goto fim;
        end;

    i := ntabs+1;

fim:
    for j := ntabs downto i do
        tabs [j+1] := tabs [j];
    tabs[i] := posx;
    ntabs := ntabs + 1;

    fala ('EDTABINS');   { tabulacao inserida }

    sintetiza(intToStr(i));
    sintetiza(intToStr(posx));
    sintclek;
    if posx > length (texto[posy]) then
        sintCarac (' ')
    else
        sintCarac (texto[posy][posx]);
end;

{--------------------------------------------------------}

Procedure pedeMargens;
var
    v: integer;
    salvaMe, salvaMd: integer;
begin
    salvaMe := margEsq;
    salvaMd := margDir;

    repeat
        fala ('EDDIGME');
        v := 0;
        sintReadInt (v);
        if v > 0 then margEsq := v
                 else margEsq := 1;

        fala('EDDIGMD');
        v := 0;
        sintReadInt (v);
        if v > 0 then margDir := v
                                                   else margDir := 79;

        if margDir <= margEsq then
            begin
                fala ('EDMARINV');
                margEsq := salvaMe;
                margDir := salvaMd;
                exit;
            end;

    until margDir > margEsq;

    fala ('EDMARACI');

    if length(texto[posy]) < margEsq-1 then
        begin
            posx := length (texto[posy])+1;
            while length(texto[posy]) < margEsq-1 do
                insereLetra(' ');
        end;
end;

{--------------------------------------------------------}

procedure cmdMargem;
var
     tecla: char;
label deNovo;
begin
    fala ('EDOPCAO');   { qual opcao ? }
    tecla := leTeclaMaiusc;

deNovo:
    escreveTela;

    case tecla of

       'R': removeTabulacoes;
       'T': insereTabulacao;
       'M': pedeMargens;

       #$0: begin
                tecla := ajuda (readkey, 'EDAJMA', 4);
                goto deNovo;
            end;
      #$1b: begin
                fala ('EDDESIST');
                exit;
            end
    end;

    escreveTela;
end;

end.
