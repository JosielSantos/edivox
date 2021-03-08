{ Cliente simplificado para o LSP (Language Server Protocol) }
{ Autor: Thiago Seus }
{ Em 07/03/2021 }

unit edlsp;
interface
function abreLsp(comando: string): boolean;
procedure fechaLsp;

procedure abriuDocumentoLsp(uri, linguagem: string; versao: integer; texto: string);
procedure mudouDocumentoLsp(uri: string; texto: string);
implementation
uses dvWin, strUtils, sysUtils, windows, superObject, pyPipe;
const CRLF = #13 + #10;
var id: longWord;
    versao: longWord;
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

procedure debugaStdErr;
    var s: string;
    begin
    repeat
        s := readPipeInput(errorPipeRead); {para ler o stderr do processo }
        debug(s);
    until s = '';
end;

function leRespostaJsonRpc: iSuperObject;
    var linha: string;
    tamanho: integer;
    begin
    repeat
        debugaStdErr;
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
    delete(buffer, 1, tamanho);
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

procedure fechaLsp;
    begin
    pipeStop;
end;

procedure enviaChamada(metodo: string; params: iSuperObject);
    var chamada: iSuperObject;
    begin
    chamada := so;
    chamada.S['method'] := metodo;
    chamada.O['params'] := params;
enviaJsonRpc(chamada);
end;

procedure abriuDocumentoLsp(uri, linguagem: string; versao: integer; texto: string);
    var documento: iSuperObject;
resposta: iSuperObject;
    begin
    versao := 0;
    documento := so;
    documento.S['uri'] := uri;
    documento.S['languageId'] := linguagem;
    documento.I['version'] := versao;
    documento.S['text'] := texto;

    enviaChamada('textDocument/didOpen', documento);

    resposta := leRespostaJsonRpc;
    debug(resposta.asJson);
end;

// TODO implementar mudanças com documentChangeEvent completo
procedure mudouDocumentoLsp(uri: string; texto: string);
    var idDocumento, mudancas, params, resposta: iSuperObject;
    begin
    idDocumento := so;
    idDocumento.S['uri'] := uri;
    idDocumento.I['version'] := versao;

    inc(versao);

    mudancas := so;
    mudancas.S['text'] := texto;

    params := so;
    params.O['textDocument'] := idDocumento;
    params.O['contentChanges'] := mudancas;

    enviaChamada('textDocument/didChange', params);
    resposta := leRespostaJsonRpc;
    debug(resposta.asJson);
end;
end.
