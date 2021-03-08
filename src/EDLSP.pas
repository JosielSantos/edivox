{ Cliente simplificado para o LSP (Language Server Protocol) }
{ Autor: Thiago Seus }
{ Em 07/03/2021 }

unit edlsp;
interface
function abreLsp(comando: string): boolean;
implementation
uses dvWin, strUtils, sysUtils, windows, superObject, pyPipe;
const CRLF = #13 + #10;
var id: longWord;
    buffer: string;

procedure debug(s: string);
    begin
    sintWriteln(s);
    while sintFalando do waitMessage;
end;

function patcheiaMensagem(mensagem: iSuperObject): iSuperObject;
    begin
    patcheiaMensagem := mensagem;
    mensagem.I['id'] := id;
    inc(id);
    mensagem.S['jsonrpc'] := '2.0';
end;

procedure enviaJsonRPC(mensagem: iSuperObject);
    var cabecalho: string;
    mensagemEmJson: string;
    begin
    mensagemEmJson := patcheiaMensagem(mensagem).asJson + CRLF;
    cabecalho := 'Content-Length: ' + intToStr(length(mensagemEmJson)) + CRLF + CRLF;
    writePipeOut(inputPipeWrite, cabecalho + mensagemEmJson);
end;

procedure leParaOBuffer;
    begin
    buffer := buffer + readPipeInput(outputPipeRead); { Dói na memória ma vamo que vamo }
end;

function extraiLinhaDoBuffer: string;
    var s: string;
    novaLinha: integer;
    begin
    extraiLinhaDoBuffer := '';
    novalinha := pos(#10, buffer);
    if novaLinha > 0 then
        begin
        s := copy(buffer, 1, novaLinha);
        delete(buffer, 1, novaLinha);
        delete(s, length(s), 1);
        if s[length(s)] = #13 then delete(s, length(s), 1);
        extraiLinhaDoBuffer := s;
    end;
end;

function leRespostaJsonRpc: iSuperObject;
    var linha: string;
    tamanho: integer;
    begin
    repeat
        //debug(readPipeInput(errorPipeRead)); para ler o stderr do processo
        leParaOBuffer;
        linha := extraiLinhaDoBuffer;
    until ansiStartsStr('CONTENT-LENGTH', maiuscAnsi(linha));

    tamanho := strToInt(copy(linha, pos(':', linha) + 2, length(linha)));

    linha := extraiLinhaDoBuffer; // Linha em branco do cabeçalho

    while length(buffer) < tamanho do
        begin
        leParaOBuffer;
    end;
    leRespostaJsonRpc := so(copy(buffer, 1, tamanho));

    if length(buffer) > tamanho then
        begin
        buffer := copy(buffer, tamanho + 1, length(buffer) - tamanho);
    end;
end;

function fazHandShake: boolean;
    var obj: iSuperObject;
    resposta: iSuperObject;
    begin
    fazHandShake := false;

    obj := tSuperObject.parsefile('modelo-handshake.json', true);
    obj.I['processId'] := getCurrentProcessId;

    enviaJsonRpc(obj);
    resposta := leRespostaJsonRpc;

    fazHandShake := (resposta <> nil) and (resposta.O['result'] <> nil);
end;

function abreLsp(comando: string): boolean;
    begin
    abreLsp := false;

    if not pipeExecute(comando) then exit;

    id := 0;
    abreLsp := fazHandShake;
end;
end.
