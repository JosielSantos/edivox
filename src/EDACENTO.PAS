{--------------------------------------------------------}
{
{    Tratamento dos acentos e letras especiais
{
{    Autor: Marcelo Luis Pinheiro
{
{    Orientador Academico: Jose' Antonio Borges
{
{    Em 10/12/93
{
{--------------------------------------------------------}

Unit edacento;

interface
uses
    DVcrt, DVWin,
    edVars,  edCursor;

function semAcentos (s: string): string;
procedure trataLetrasEspeciais;

implementation

{--------------------------------------------------------}

type
    TABDIGIT = array [1..14] of char;

const
    acentuaveis: set of char = ['A','E','I','O','U','C', 'N',
                                'a','e','i','o','u','c', 'n'];
const
    crases:   TABDIGIT = (#$c0, #$c8, #$cc, #$d2, #$d9, 'C',  'N',
                          #$e0, #$e8, #$ec, #$f2, #$f9, 'C',  'N');

    agudos :  TABDIGIT = (#$c1, #$c9, #$cd, #$d3, #$da, #$c7, 'N',
                          #$e1, #$e9, #$ed, #$f3, #$fa, #$e7, 'N');

    circunfs: TABDIGIT = (#$c2, #$ca, #$ce, #$d4, #$db, 'C',  'N',
                          #$e2, #$ea, #$ee, #$f4, #$fb, 'C',  'N');

    tils:     TABDIGIT = (#$c3, 'E',  'I',  #$d5, 'U',  'C',  #$d1,
                          #$e3, 'E',  'I',  #$f5, 'U',  'C',  #$f1);

    tremas:   TABDIGIT = (#$c4, #$cb, #$cf, #$d6, #$dc, 'C',  'N',
                          #$e4, #$eb, #$ef, #$f6, #$fc, 'C',  'N');

{--------------------------------------------------------}

function semAcentos (s: string): string;
const
    tabMaiuscPC: array [#$80..#$ff] of char = (

    'C','U','E','A','A','A','A','C','E','E','E','I','I','I','A','A',
    'E','ş','ş','O','O','O','U','U','Y','O','U','ş','ş','ş','ş','ş',
    'A','I','O','U','N','N','ş','ş','ş','ş','ş','ş','ş','ş','ş','ş',
    'ş','ş','ş','ş','ş','ş','ş','ş','ş','ş','ş','ş','ş','ş','ş','ş',
    'A','A','A','A','A','A','‘','C','E','E','E','E','I','I','I','I',
    'ş','N','O','O','O','O','O','X','ş','U','U','U','U','Y','ş','ş',
    'A','A','A','A','A','A','‘','C','E','E','E','E','I','I','I','I',
    'ş','N','O','O','O','O','O','X','ş','U','U','U','U','Y','ş','ş');

var
    s2: string;
    i: integer;

begin
    s2 := s;
    for i := 1 to length (s2) do
        if s2[i] in ['a'..'z'] then
            s2[i] := upcase (s2[i])
        else
        if s2[i] >= #$80 then
            s2[i] := tabMaiuscPC [s2[i]];

    semAcentos := s2;
end;

{--------------------------------------------------------}

procedure trocaLetra (var c: char; tabl: TABDIGIT);
begin
    if c in [ '''', '^', '`', '~', '"' ] then exit;
    case c of
        'A': c := tabl[1];
        'E': c := tabl[2];
        'I': c := tabl[3];
        'O': c := tabl[4];
        'U': c := tabl[5];
        'C': c := tabl[6];
        'N': c := tabl[7];
        'a': c := tabl[8];
        'e': c := tabl[9];
        'i': c := tabl[10];
        'o': c := tabl[11];
        'u': c := tabl[12];
        'c': c := tabl[13];
        'n': c := tabl[14];
    end;
end;

{--------------------------------------------------------}

procedure trataLetrasEspeciais;
var tecla : char;
begin
    tecla := readKey;

    case upcase(tecla) of
        'A': insereLetra (#$aa);
        'O': insereLetra (#$ba);
        'P': insereLetra (#$a7);
        'G': insereLetra (#$b0);
        '!': insereLetra (#$a1);
        '?': insereLetra (#$bf);
    else
        sintBip;
    end;
end;

end.
