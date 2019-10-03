{--------------------------------------------------------}
{
{    Calcula MD5 do arquivo
{
{    Autores: Neno Henrique Albernaz E José Antonio Borges
{
{    Em 23/09/2012
{
{--------------------------------------------------------}

Unit edMd5;

interface

uses
    umd5,
    classes,
    sysutils,
    edVars;

function calculaMd5: string;

implementation


function calculaMd5: string;
var
    criptog, binaryResult: string;
    i: integer;
    MD5: TMD5Stream;

const
    cr = ^m^j;

begin
    criptog := '';

{$r-}
    MD5 := TMD5Stream.Create;
    for i := 1 to maxlinhas do
    begin
        MD5.WriteBuffer(texto [i][1], Length(texto [i]));
        MD5.WriteBuffer(cr[1], 2);
    end;
    binaryResult := MD5.DigestString;

    for i := 1 to Length(binaryResult) do
        criptog := criptog + Format('%.2x', [Ord(BinaryResult[I])]);

    MD5.Free;

    calculaMd5 := criptog;
end;

begin
end.
