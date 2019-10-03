{----------------------------------------------------------------}
{
{    Levox - leitor de documentos
{    Guarda e recupera posição de arquivos anteriores
{    Autor: Antonio Borges
{    Em 2/6/2002
{    Alterado por: Neno Henrique da Cunha Albernaz em16/09/2017
{
{----------------------------------------------------------------}

unit edretoma;

interface
uses
  dvcrt,
  dvWin,
  dvForm,
  edVars,
  windows,
  sysutils,
  classes;

function recupPosicao: integer;
procedure salvaPosicao;
function obtemNomeAntigo: string;

implementation

const totalRegistros = 30;

{----------------------------------------------------------------}
{                  reposiciona onde parou leitura
{----------------------------------------------------------------}

function recupPosicao: integer;
var nomeCompleto, nomeAntigo: string;
    ref: string;
    i, p, linhaRef, erro: integer;
begin
    result := 0;
    if (not retomarNaLinha) or (somenteLeitura) or
       (nomeArq = '') or
       (ExtractFileName(nomeArq) = '$.$') or
       (ExtractFileName(nomeArq) = '$2.$') or
       (copy(nomeArq, length(nomeArq)-3, 4) = '.tmp') then exit;

    nomeCompleto := expandFilename (nomeArq);

    for i := 0 to (totalRegistros - 1) do
        begin
            ref := sintAmbiente ('EDIVOX', intToStr(i));
            if trim(ref) = '' then continue;
            p := pos(',', ref);
            val (trim(copy (ref, 1, p-1)), linhaRef, erro);
            if erro <> 0 then continue;
            nomeAntigo := trim (copy (ref, p+1, length(ref)));

            if nomeAntigo = nomeCompleto then
                begin
                    result := linhaRef;
                    exit;
                end;
        end;
end;

{----------------------------------------------------------------}
{             guarda referência para continuar leitura
{----------------------------------------------------------------}

procedure salvaPosicao;
var nomeCompleto, nomeAntigo: string;
    ref, s, n: string;
    i, p: integer;
    sl: TStringList;
begin
    if (not retomarNaLinha) or (somenteLeitura) or
       (nomeArq = '') or
       (ExtractFileName(nomeArq) = '$.$') or
       (ExtractFileName(nomeArq) = '$2.$') or
       (copy(nomeArq, length(nomeArq)-3, 4) = '.tmp') then exit;

    nomeCompleto := expandFilename (nomeArq);
    sl := TStringList.Create;

    for i := 0 to (totalRegistros - 1) do
        begin
            ref := sintAmbiente ('EDIVOX', intToStr(i));
            if trim(ref) <> '' then
                sl.Add (ref);
        end;

    for i := 0 to sl.Count-1 do
        begin
            ref := sl[i];
            p := pos(',', ref);
            if p = 0 then continue;
            nomeAntigo := trim (copy (ref, p+1, length(ref)));
            if nomeAntigo = nomeCompleto then
                begin
                    sl.Delete(i);
                    break;
                end;
        end;

    sl.Insert(0, intToStr(posy) + ',' + nomeCompleto);
    if sl.Count > totalRegistros then
        sl.Delete(totalRegistros);

    for i := 0 to (totalRegistros - 1) do
        begin
            n := intToStr(i);
            if i < sl.Count then
                begin
                    s := sl[i];
                    sintGravaAmbiente('EDIVOX', n, s);
                end
            else
                sintRemoveAmbiente('EDIVOX', n);
        end;

    sl.Free;
end;

{----------------------------------------------------------------}
{             guarda referência para continuar leitura
{----------------------------------------------------------------}

function obtemNomeAntigo: string;
var nomeAntigo: string;
    dir, dirA, nomeA: string;
    ref: string;
    i, p, n: integer;
begin
    result := '';
    getDir (0, dir);
    popupMenuCria(wherex, wherey+1, 80, totalRegistros, RED);

    for i := 0 to (totalRegistros - 1) do
        begin
            ref := sintAmbiente ('EDIVOX', intToStr(i));
            if trim(ref) = '' then continue;
            p := pos(',', ref);
            if p = 0 then continue;
            nomeAntigo := trim (copy (ref, p+1, length(ref)));
            if FileExists (nomeAntigo) then
                begin
                    dirA  := ExcludeTrailingBackslash(ExtractFilePath(nomeAntigo));
                    nomeA := ExtractFileName(nomeAntigo);

                    if dir <> dirA then
                        popupMenuAdiciona ('', nomeA + ', em ' + dirA)
                    else
                        popupMenuAdiciona ('', nomeA);
                end;
        end;

    n := popupMenuSeleciona;
    if n <= 0 then exit;
    result := opcoesItemSelecionado;
    p := pos (', em ', result);
    if p <> 0 then
        result := copy (result, p+5, length(result)) + '\'+ copy(result, 1, p-1);
end;

end.
