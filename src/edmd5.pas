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
    classes,
    sysutils,
    edVars;

function calculaMd5: string;

implementation
uses md5;

function calculaMd5: string;
begin
    calculaMd5 := md5Print(md5String(texto.Text));
end;

begin
end.
