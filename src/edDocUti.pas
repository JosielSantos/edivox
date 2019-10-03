{--------------------------------------------------------}
{
{           Utilitários para formatação DOC no texto
{
{    Autor: Neno Henrique Albernaz
{
{    Em 23/09/2007
{
{--------------------------------------------------------}

Unit edDocUti;

interface
uses
    DVcrt, DVWin, dvamplia, sysutils,
    edmensag, edvars;

function falaTestaFormatacao (f: string; apenasTesta: boolean): boolean;
procedure falaFormatacaoAtual;
Procedure writeSoTexto (s: string);
procedure sintTextoFormatado (s: string);
function obtemFormatacaoPos (s: string): string;
function obtemFormatacao (s: string): string;

{--------------------------------------------------------}

implementation

{--------------------------------------------------------}
{       Variáveis utilizadas para guardar a formatação
{--------------------------------------------------------}

var
    nomeFonte_guar: string;
    tamanhoFonte_guar: string;
    CorFonte_guar: string;
    negrito_guar: boolean;
    italico_guar: boolean;
    sublinhado_guar: boolean;
    alinhamento_guar: string;

procedure inicializaVariavel_guar;
begin
    nomeFonte_guar := '';
    tamanhoFonte_guar := '';
    CorFonte_guar := '';
    negrito_guar := false;
    italico_guar := false;
    sublinhado_guar := false;
    alinhamento_guar := '';
end;

{--------------------------------------------------------}
{       Fala o tipo de formatação, retornando se ela existe ou não
{--------------------------------------------------------}

function falaTestaFormatacao (f: string; apenasTesta: boolean): boolean;
var
    valor: string;
    p, erro: integer;


    function CorFonte: boolean;
    begin
        if (p < 0) and (p > 16) then
            corFonte := false
        else
            begin
                corFonte := true;
                corFonte_guar := f+ valor+ '>';
            end;
        if apenasTesta then exit;

        if p = 0 then fala ('EDAUTOMA') {'Automática'}
        else
        if p = 1 then fala ('EDPRETO') {'Preto'}
        else
        if p = 2 then fala ('EDAZUL') {'Azul'}
        else
        if p = 3 then fala ('EDTURQUE') {'Turquesa'}
        else
        if p = 4 then fala ('EDVERCLA') {'Verde claro'}
        else
        if p = 5 then fala ('EDROSA') {'Rosa'}
        else
        if p = 6 then fala ('EDVERMEL') {'Vermelho'}
        else
        if p = 7 then fala ('EDAMAREL') {'Amarelo'}
        else
        if p = 8 then fala ('EDBRANCO') {'Branco'}
        else
        if p = 9 then fala ('EDAZUESC') {'Azul escuro'}
        else
        if p = 10 then fala ('EDCERCET') {'Cerceta'}
        else
        if p = 11 then fala ('EDVERDE') {'Verde'}
        else
        if p = 12 then fala ('EDVIOLET') {'Violeta'}
        else
        if p = 13 then fala ('EDVERESC') {'Vermelho escuro'}
        else
        if p = 14 then fala ('EDAMAESC') {'Amarelo escuro'}
        else
        if p = 15 then fala ('EDCINZ50') {'Cinza 50'}
        else
        if p = 16 then fala ('EDCINZ25'); {'Cinza 25'}
    end;

    procedure falaTipo (t: string; toca: boolean);
    begin
        if not apenasTesta then
            begin
                if toca then fala (t)
                else sintetiza (t);
            end;
    end;


begin
    if (f = '') or (f[1] <> '<') or (f[length(f)] <> '>') then
        begin
            falaTestaFormatacao := false;
            exit;
        end;
    falaTestaFormatacao := true;

    P := pos ('=', f);
    if p <> 0 then
        begin
            valor := copy (f, p+1, length (f)-p-1);
            delete (f, p+1, length (f));
            f := maiuscansi (f);
            val (valor, p, erro);
            if erro <> 0 then
                p := 0;

            {Font, tipo de letra parte 1}
            if f = '<TF=' then //Tipo de fonte
                begin
                    falaTipo (valor, false);
                    nomeFonte_guar := f + valor+ '>';
                end
            else
            if f = '<SF=' then //Tamanho da fonte
                begin
                    falaTipo ('EDTAMANH', true);
                    falaTipo (valor, false);
                    tamanhoFonte_guar := f + valor+ '>';
                end
            else
            if f = '<CE=' then //cor da fonte
                CorFonte
            else
                falaTestaFormatacao := false;
        end
    else
        begin
            f := maiuscansi (f);

            //alinhamento e separação de sílabas
            if f = '<AF>' then //Justificar
                begin
                    falaTipo ('EDALIJUS', true); {'Alinhamento justificado'}
                    alinhamento_guar:= f;
                end
            else
            if f = '<C>' then //Centralizar
                begin
                    falaTipo ('EDALICEN', true); {'Alinhamento centralizado'}
                    alinhamento_guar := f;
                end
            else
            if f = '<AL>' then //alinhamento à esquerda
                begin
                    falaTipo ('EDALIESQ', true); {'Alinhamento à esquerda'}
                    alinhamento_guar:= f;
                end
            else
            if f = '<AR>' then //alinhamento à direita
                begin
                    falaTipo ('EDALIDIR', true); {'Alinhamento à direita'}
                    alinhamento_guar:= f;
                end
            else

            //Font, tipo de letra parte 2
            if f = '<IN>' then //Início de texto negritado
                begin
                    falaTipo ('EDININEG', true); {'Início de negrito'}
                    negrito_guar := true;
                end
            else
            if f = '<FN>' then //Fim de texto negritado
                begin
                    falaTipo ('EDFIMNEG', true); {'Fim de negrito'}
                    negrito_guar := false;
                end
            else
            if f = '<II>' then //Inicio de texto em itálico
                begin
                    falaTipo ('EDINIITA', true); {'Início de itálico'}
                    italico_guar := true;
                end
            else
            if f = '<FI>' then //Fim de texto em itálico
                begin
                    falaTipo ('EDFIMITA', true); {'Fim de itálico'}
                    italico_guar := false;
                end
            else
            if f = '<IS>' then //Início de texto sublinhado
                begin
                    falaTipo ('EDINISUB', true); {'Início de sublinhado'}
                    sublinhado_guar := true;
                end
            else
            if f = '<FS>' then //Fim de texto sublinhado
                begin
                    falaTipo ('EDFIMSUB', true); {'Fim de sublinhado'}
                    sublinhado_guar := false;
                end
            else
                falaTestaFormatacao := false;
        end;
end;

{--------------------------------------------------------}
{       Trata a linha do texto, chamando o teste de formatação
{--------------------------------------------------------}

procedure trataLinhaTexto (s: string);
var
    p, p2:integer;
    formatacao: string;
begin
    p := pos ('<', s);
    p2 := pos ('>', s);
    if (p <> 0) and (p2 <> 0) and (p < p2) then
        begin
            formatacao := copy (s, p, (p2 - p + 1));
            delete (s, 1, p2);
            falaTestaFormatacao (formatacao, true);
            if trim (s) <> '' then
                trataLinhaTexto (s);
        end;
end;

{--------------------------------------------------------}
{       Pega a formatação padrão do arquivo normalvox.ini
{--------------------------------------------------------}

procedure pegaFormatacaoPadrao;
var
nomeArq, s, linha: string;
    arq: text;
begin
    nomeArq := sintAmbiente ('TXTWORD', 'ARQNORMALVOX');
    if nomeArq = '' then
        nomeArq := sintDirAmbiente + '\normalvox.ini';
    assign (arq, nomeArq);
    {$i-} reset (arq); {$i+}
    if ioresult <> 0 then exit;

    linha := '';
    while not eof (arq) do
        begin
            {$I-}  readln (arq, s);  {$I+}
            if ioresult <> 0 then break;
            linha := linha + trim (s);
        end;
    {$i-} close (arq); {$i+}
    if ioresult <> 0 then;
    trataLinhaTexto (linha);
end;

{--------------------------------------------------------}
{       Fala a formatação atual da posição do cursor
{--------------------------------------------------------}

procedure falaFormatacaoAtual;
var
    y: integer;
    s: string;
begin
    inicializaVariavel_guar;
    pegaFormatacaoPadrao;

    for y := 1 to posy -1 do
        begin
            s := texto[y];
            if trim (s) <> '' then
                trataLinhaTexto (s);
        end;
    s := texto[posy];
    s := copy (s, 1, posx);
    if trim (s) <> '' then
        trataLinhaTexto (s);

    if negrito_guar then
        fala ('EDNEGRIT'); {'Negrito'}
    if italico_guar then
        fala('EDITALIC'); {'Itálico'}
    if sublinhado_guar then
        fala ('EDSUBLIN'); {'Sublinhado'}
    if (trim(    CorFonte_guar) <> '') and (    CorFonte_guar <> '<CE=0>') then
            falaTestaFormatacao (    CorFonte_guar, false);
    if trim(    tamanhoFonte_guar) <> '' then
            falaTestaFormatacao (    tamanhoFonte_guar, false);
    if trim(nomeFonte_guar) <> '' then
            falaTestaFormatacao (nomeFonte_guar, false);
    if trim(alinhamento_guar) <> '' then
            falaTestaFormatacao (alinhamento_guar, false);

    sintClek;
end;

{--------------------------------------------------------}
{       Retira os tags de formatação da string passada
{--------------------------------------------------------}

function limpaFormatacao (s: string): string;
var
    saida, formatacao: string;
    p, p2: integer;
begin
    p := pos ('<', s);
    p2 := pos ('>', s);
    if (p = 0) or (p2 = 0) or (p > p2) then
        saida := s
    else
        begin
            formatacao := copy (s, p, (p2 - p + 1));
            if falaTestaFormatacao (formatacao, true) then
                saida := copy (s, 1, p-1)
            else
                saida := copy (s, 1, p2);

            delete (s, 1, p2);
            if s <> '' then
                saida := saida + limpaFormatacao (s);
        end;

    limpaFormatacao := saida;
end;

{--------------------------------------------------------}
{       Testa se escreve  formatação ou não
{--------------------------------------------------------}

Procedure writeSoTexto (s: string);
begin
    if escreveApenasTexto then
        write (limpaFormatacao (s))
    else
        write (s);
end;

{--------------------------------------------------------}
{       Sintetiza o texto com o modo de fala escolhido
{--------------------------------------------------------}

procedure sintTextoFormatado (s: string);
var
    formatacao: string;
    p, p2: integer;
    sintFor: boolean;

    procedure sintet (s: string);
    var saida: string;
        i: integer;
    begin
        if comSapi and falaPontuacao then
            begin
                s := trim (s);
                saida := '';
                for i := 1 to length (s) do
                    begin
                         if s[i] in ['.', ',', '!', '?', ':', ';', '<', '(', ')', '/', '\'] then
                             begin
                                 if trim(saida) <> '' then sintetiza (saida);
                                 saida := '';
                                 sintSoletra (s[i]);
                             end
                         else
                             saida := saida + s[i];
                    end;
                if trim(saida) <> '' then sintetiza (saida);
            end
        else
            sintetiza (s);
    end;

begin
    p := pos ('<', s);
    p2 := pos ('>', s);
    if (modoFalaFormatacao = 'N') or (p = 0) or (p2 = 0) or (p > p2) then
        sintet (s)
    else
        begin
            sintet (copy (s, 1, p-1));
            formatacao := copy (s, p, (p2 - p + 1));
            case modoFalaFormatacao of
                'M': sintFor := falaTestaFormatacao (formatacao, true);
                'F': sintFor := falaTestaFormatacao (formatacao, false);
                'B': begin
                        sintFor := falaTestaFormatacao (formatacao, true);
                        if sintFor then sintBip;
                     end;
            else
                sintFor := false;
            end;

            if not sintFor then
                begin
                    amplCampo(formatacao, 1);
                    sintet (formatacao);
                end;

            delete (s, 1, p2);
            if s <> '' then
                sintTextoFormatado (s);
        end;

end;

{--------------------------------------------------------}
{       retorna a formatação da string que começa por <
{--------------------------------------------------------}

function obtemFormatacaoPos (s: string): string;
var
    p: integer;
    formatacao: string;
begin
    formatacao:= '';
    p := pos ('>', s);
    if p > 1 then
        begin
            formatacao := copy (s, 1, p);
            if not falaTestaFormatacao (formatacao, true) then
                formatacao := '';
        end;
    obtemFormatacaoPos := formatacao;
end;

{--------------------------------------------------------}
{       retorna a formatação da string que acaba por >
{--------------------------------------------------------}

function obtemFormatacao (s: string): string;
var
    p, i: integer;
    formatacao: string;
begin
    formatacao:= '';
    P := 0;
    for i := length (s) downto 1 do
        if s [i] = '<' then
            begin
                p := i;
                break;
            end;

    if p > 0 then
        begin
            formatacao := copy (s, p, length (s));
            if not falaTestaFormatacao (formatacao, true) then
                formatacao := '';
        end;

    obtemFormatacao := formatacao;
end;

{--------------------------------------------------------}
begin
end.
