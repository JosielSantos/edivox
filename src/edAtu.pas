{-------------------------------------------------------------}
{
{ Tratamento das atualizações
{
{       Em 09 de Agosto de 2017
{
{-------------------------------------------------------------}

unit edAtu;
interface
function temAtualizacao: boolean;
implementation
uses dvWin, sysUtils, edVars, fpHttpClient, fpOpenSSL, openSSLSockets, sslSockets, fpJson,
jsonParser;

const
ENDPOINT_ATUALIZACAO = 'https://api.github.com/repos/JosielSantos/edivox/releases/latest';

{ Pega a versão vinda da API do Github }

function pegaVersaoGithub(resposta: string): string;
    var obj: tJsonData;
    p: tJsonParser;
    begin
    result := '';
    try
        p := tJsonParser.create(resposta);
        try
            obj := p.parse;
            result := (obj as tJsonObject).strings['tag_name'];
        finally
            freeAndNil(obj);
        end;
        finally
            freeAndNil(p);
    end;
end;

function temAtualizacao: boolean;
    var resposta, versaoGithub: string;
    begin
    with tFpHttpClient.create(nil) do
    begin
        try
            resposta := simpleGet(ENDPOINT_ATUALIZACAO);
            versaoGithub := pegaVersaoGithub(resposta);
            result := (versaoGithub <> '') and (VERSAO <> versaoGithub);
            free;
        except on e: exception do
            begin
                result := false;
                sintetiza(e.message);
                free;
            end;
        end;
    end;
end;
end.
