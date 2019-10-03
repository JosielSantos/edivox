{--------------------------------------------------------}
{
{    Tratamento de páginas
{
{    Autor: Neno Henrique da Cunha Albernaz
{
{    Otimização do código original de: Glauco Ferius Constantino
{
{    Em 20/11/2018
{
{--------------------------------------------------------}

Unit edPagina;

interface

uses
    DVcrt, DVWin, Windows, sysUtils,
    edvars, edMensag, edTela;

procedure inicializaPaginas;
function falaNumeroPagina (falarTotal, mudo: boolean): integer;
Procedure vaiParaPagina (pagina: integer);

implementation

{--------------------------------------------------------}

var
    primLinha, ultimLinha, primColuna, ultimColuna, limPorPag, colPorLin, nPaginaAtual: integer;

{--------------------------------------------------------}

procedure inicializaPaginas;
var
    impressor, s: string;
    erro: integer;
begin
    impressor := sintAmbiente ('EDIVOX', 'IMPRESSOR');
    if impressor = '' then impressor := 'c:\winvox\listavox.exe';
    if  pos ('LISTAVOX.EXE', uppercase (impressor)) > 0 then impressor := 'LISTAVOX'
    else impressor := 'IMPRIVOX';

    s := sintAmbiente (impressor, 'PrimeiraLinha');
    val (s, primLinha, erro);
    if erro <> 0 then
        begin
                if impressor = 'LISTAVOX' then primLinha := 3
                else primLinha := 2;
        end;
    s := sintAmbiente (impressor, 'UltimaLinha');
    val (s, ultimLinha, erro);
    if erro <> 0 then
        begin
            if impressor = 'LISTAVOX' then ultimLinha := 62
            else ultimLinha := 58;
        end;
    s := sintAmbiente (impressor, 'PrimeiraColuna');
    val (s, primColuna, erro);
    if erro <> 0 then
        begin
            if impressor = 'LISTAVOX' then primColuna := 8
            else primColuna := 9;
        end;
    s := sintAmbiente (impressor, 'UltimaColuna');
    val (s, ultimColuna, erro);
    if erro <> 0 then
        begin
            if impressor = 'LISTAVOX' then ultimColuna := 79
            else ultimColuna := 77;
        end;

    colPorLin := ultimColuna  - primColuna; //número de colunas por linha
    limPorPag := ultimLinha - primLinha; //número de linhas por página
end;

{--------------------------------------------------------}

function falaNumeroPagina (falarTotal, mudo: boolean): integer;
var
    q, r, nPaginas, NLinhasImprime, tamLinha: integer;
begin
    nLinhasImprime := 0;
    for r := 1 to maxLinhas do
        begin
            tamLinha := length( texto [r]);
            q := (tamLinha div     colPorLin)+1;
            if q = 0 then q := 1;
            nLinhasImprime := nLinhasImprime + q;
            if r = posy then nPaginaAtual := ((nLinhasImprime-1) div limPorPag) + 1;
        end;

    if not mudo then
        begin
            nPaginas := ((nLinhasImprime-1) div limPorPag) + 1;
            fala ('EDPAGINA'); {'Página '}
            escreveNumero (nPaginaAtual);
            if falarTotal then
                begin
                    fala ('EDDE'); {' de '}
                    escreveNumero (nPaginas);
                    if nPaginaAtual = 1 then
                        escreveNumero (0)
                    else
                        escreveNumero ((nPaginaAtual*100)div nPaginas);
                    sintWrite ('%');
                    if not keypressed then delay (100);
                end;
        end;
    falaNumeroPagina := nLinhasImprime;
end;

{--------------------------------------------------------}

Procedure vaiParaPagina (pagina: integer);
var
    c: char;
    q, r, nPaginas, nPaginasy, nPaginaDestino, NLinhasImprime, tamLinha, erro: integer;
    s: string;
begin
    nLinhasImprime := falaNumeroPagina (true, pagina <> 0);

    if pagina = 0 then
        begin
            fala ('EDDGNUPA'); {'Digite o numero da página: '}
            c := sintEditaCampo (s, 1, wherey, 200, 80, true);
            writeln;
            val (s, nPaginaDestino, erro);
            if (c = ESC) or (s = '') or (erro <> 0) then
                begin
                    fala ('EDDESIST');
                    falaNumeroPagina (true, false);
                    exit;
                end;
        end
    else
        nPaginaDestino := nPaginaAtual + pagina;

    nPaginas := ((nLinhasImprime-1) div limPorPag) + 1;
    if (nPaginaDestino < 1) or (nPaginaDestino > nPaginas) then
        begin
            posy := 1;
            if nPaginaDestino < 1 then fala ('EDINITEX') {'Inicio do texto'}
            else
                begin
                    posy := maxlinhas;
                    fala ('EDFIMTEX'); {'Fim do texto'}
                end;
            posx := 1;
            exit;
        end;

    nLinhasImprime := 0;
    posy := 0;
    for r := 1 to maxLinhas do
        begin
            posy := posy + 1;
            tamLinha := length( texto [posy]);
            q := (tamLinha div     colPorLin)+1;
            if q = 0 then q := 1;
            nLinhasImprime := nLinhasImprime + q;
            nPaginasy := (nLinhasImprime-1) div limPorPag;
            if nPaginasy = (nPaginaDestino - 1) then break;
        end;
    posx := 1;
    falaNumeroPagina (pagina = 0, false);
    sintClek;
end;

{--------------------------------------------------------}

begin
end.
