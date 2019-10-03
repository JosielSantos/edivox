{--------------------------------------------------------}
{
{    Reformatações Mime
{
{    Autor: José Antonio Borges
{
{    Em 10/12/93
{
{--------------------------------------------------------}

Unit edreform;

interface
uses
    DVcrt, DVWin, edVars, edMensag, edlinha, edTela;

procedure reformata;
function detectaUTF (s: string): boolean;
function utfToAnsi (s: string): string;

{--------------------------------------------------------}

implementation

uses edbloco;

{-------------------------------------------------------------}
{           remove especificacoes quoted printable
{-------------------------------------------------------------}

function convQuotedPrintable (s: string): string;
var i: integer;
    sai: string;

    function conv16 (c: char): integer;
    begin
        if c in ['0'..'9'] then  conv16 := ord (c) - ord ('0')
        else
        if c in ['A'..'F'] then  conv16 := ord (c) - ord ('A') + 10
        else
        if c in ['a'..'f'] then  conv16 := ord (c) - ord ('a') + 10
        else
            conv16 := 0;
    end;

    function eHexa (c: char): boolean;
    begin
        eHexa := c in ['0'..'9', 'a'..'f', 'A'..'F'];
    end;

begin
    sai := '';
    i := 1;
    if (s <> '') and (s[length(s)] = '=') then
        delete (s, length (s), 1);

    while i <= length (s) do
        begin
            if (i <= length(s)-2) and
               (s[i] = '=') and eHexa(s[i+1]) and eHexa(s[i+2]) then
                begin
                    sai := sai + chr ((conv16 (s[i+1]) shl 4) + conv16 (s[i+2]));
                    i := i + 3;
                end
            else
                begin
                    sai := sai + s[i];
                    i := i + 1;
                end;
        end;

    convQuotedPrintable := sai;
end;

{-------------------------------------------------------------}
{            converte de UTF-8 para Ansi
{-------------------------------------------------------------}

function utfToAnsi (s: string): string;
var b, b2: byte;
    s2: string;
    i: integer;
begin
    s2 := '';
    s := s + ' ';
    i := 1;
    while i <= length (s) - 1 do
        begin
            b := ord(s[i]);
            if (b < $80) or ((b and $e0) <> $c0)then
                s2 := s2 + s[i]
            else
                begin
                    b2 := ord (s[i+1]) and $3f;
                    b := (b and $03) shl 6;
                    s2 := s2 + chr(b or b2);
                    i := i + 1;
                end;
            i := i + 1;
        end;
    utfToAnsi := s2;
end;

{-------------------------------------------------------------}
{            converte do formato da Yahoo
{-------------------------------------------------------------}

function convYahoo (s: string): string;
var i: integer;
begin
    for i := length(s)-3 downto 1 do
        if copy (s, i, 2) = '€ ' then
            delete (s, i, 3);
    convYahoo := s;
end;

{--------------------------------------------------------}
{              decodifica um arquivo em MIME64
{--------------------------------------------------------}

function DecodFraseMime64 (aConverter: string): string;

const
    MIME64: array [0..63] of char =
       'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

var
    bloco, grupo: integer;
    tabInvMIME: array [0..255] of byte;
    i: integer;
    caracEnt: char;
    posEnt: integer;
    byteSai: byte;
    saida: string;

begin
   for i := 0 to 255 do
       tabInvMIME [i] := 255;
   for i := 0 to 63 do
       tabInvMIME [ord(MIME64 [i])] := i;
   tabInvMIME [ord('=')] := 0;

   saida := '';

   bloco := 0;
   posEnt := 1;
   caracEnt := ' ';
   byteSai := 0;
   while (posEnt <= length (aConverter)) and (caracEnt <> '=') do
       begin
           caracEnt := aConverter[posEnt];
           posEnt := posEnt + 1;
           if (caracEnt =  ' ') or (caracEnt = '=') then
               continue;

           grupo := tabInvMIME [ord (caracEnt)];
           if grupo = 255 then continue;  {provavel erro}

           case bloco of
               0:    byteSai := grupo shl 2;
               1:    begin
                         byteSai := byteSai or ((grupo shr 4) and $f);
                         saida := saida + chr(byteSai);
                         byteSai := (grupo and $f) shl 4;
                     end;
               2:    begin
                         byteSai := byteSai or ((grupo shr 2) and $3f);
                         saida := saida + chr(byteSai);
                         byteSai := (grupo and 3) shl 6;
                     end;
               3:    begin
                         byteSai := byteSai or (grupo and $3f);
                         saida := saida + chr(byteSai);
                     end;
           end;

           bloco := (bloco + 1) mod 4;
       end;

   DecodFraseMime64 := saida;
end;

{-------------------------------------------------------------}
{       remove especificacoes ISO
{-------------------------------------------------------------}

procedure removeIso (var s: string);
var p, p2: integer;
    saida: string;

    function converteMime (s: string): string;
    begin
        delete (s, 1, 2);
        delete (s, pos('?', s), 99);
        converteMime := DecodFraseMime64 (s);
    end;

    function trocar (s: string): string;
    var i: integer;
    begin
        delete (s, 1, 2);
        while (s <> '') and (s[1] <> '?') do delete (s, 1, 1);
        delete (s, 1, 1);

        if copy (s, 1, 2) = 'B?' then
            begin
                trocar := converteMime (s);
                exit;
            end;

        while (s <> '') and (s[1] <> '?') do delete (s, 1, 1);
        delete (s, 1, 1);

        delete (s, length(s)-1, 2);
        s := convQuotedPrintable (s);
        for i := 1 to length (s) do
            if s[i] = '_' then s[i] := ' ';
        trocar := s;
    end;

begin
    p := pos ('=?', s);
    if p = 0 then exit;

    p2 := 1;
    saida := '';
    while p2 <> 0 do
        begin
            saida := saida + copy (s, 1, p-1);
            delete (s, 1, p-1);
            p2 := pos ('?=', s);
            if p2 <> 0 then
                begin
                    saida := saida + trocar (copy (s, 1, p2+1));
                    delete (s, 1, p2+1);
                end
            else
                saida := saida + s;
        end;

    s := saida;

    while (s <> '') and (s[1] = ' ') do
        delete (s, 1, 1);
end;

{--------------------------------------------------------}

procedure reformata;
var
    tecla: char;
    y: integer;
    s: string;
begin
    if blocoInvalido then
         begin
             fala ('EDBLKINV');   { bloco invalido }
             exit;
         end;

    fala ('EDUTF8');   { 'opção q para quoted-printable, u para utf-8 ou g para yahoogroups'}
    tecla := leTeclaMaiusc;
    if not (tecla in ['Q', 'U', 'G', 'T']) then
        begin
            fala ('EDDESIST');  { Desistiu }
            exit;
        end;

    for y := iniBloco to fimBloco do
        begin
            s := texto[y];
            if tecla = 'Q' then
                begin
                    s := convQuotedPrintable (s);
                    removeIso (s);
                end
            else
            if tecla = 'T' then
                begin
                    s := convQuotedPrintable (s);
                    s := convYahoo (s);
                    removeIso (s);
                end
            else
            if tecla = 'G' then
                s := convYahoo (s)
            else
                s := utfToAnsi (s);
            texto[y] := s;
        end;
end;

{--------------------------------------------------------}

function detectaUTF (s: string): boolean;
begin
    result := (pos('ï»¿', s) = 1) or
              (pos('Ã§' , s) <> 0) or
              (pos('Ã£', s) <> 0) or
              (pos('Ã¡', s) <> 0) or
              (pos('Ã©', s) <> 0) or
              (pos('Ãº', s) <> 0) or
              (pos('Ã³', s) <> 0) or
              (pos('Ã­', s) <> 0);
end;

{--------------------------------------------------------}

begin
end.
