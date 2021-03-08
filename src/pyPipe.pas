unit pyPipe;

interface
uses Windows, Classes, Sysutils;

var
    InputPipeRead, InputPipeWrite: THandle;
    OutputPipeRead, OutputPipeWrite: Cardinal;
    ErrorPipeRead, ErrorPipeWrite: THandle;
    ProcessInfo : TProcessInformation;

function ReadPipeInput(InputPipe: THandle): String;
procedure WritePipeOut(OutputPipe: THandle; InString: string);
procedure pipeStop;
function pipeExecute (command: string): boolean;

implementation

function ReadPipeInput(InputPipe: THandle): String;
var
    TextBuffer: array[0..32767] of char;
    BytesRead: Cardinal;

begin
    Result := '';

    PeekNamedPipe(InputPipe, nil, Sizeof(TextBuffer)-1, @BytesRead, NIL, NIL);
    if BytesRead > 0 then
        begin
            ReadFile(InputPipe, TextBuffer, Sizeof(TextBuffer)-1, BytesRead, NIL);
            TextBuffer [bytesRead] := #$0;
            Result := strPas(TextBuffer);
        end;
end;

procedure WritePipeOut(OutputPipe: THandle; InString: string);
var
    byteswritten: DWord;
begin
    while inString <> '' do
        begin
        WriteFile (OutputPipe, Instring[1], Length(Instring), byteswritten, nil);
        delete(inString, 1, bytesWritten);
    end;
end;

procedure pipeStop;
begin
    // close pipe handles
    CloseHandle(InputPipeRead);
    CloseHandle(InputPipeWrite);
    CloseHandle(OutputPipeRead);
    CloseHandle(OutputPipeWrite);
    CloseHandle(ErrorPipeRead);
    CloseHandle(ErrorPipeWrite);

    // close process handles
    CloseHandle(ProcessInfo.hProcess);
    TerminateProcess(ProcessInfo.hProcess, 0);
end;

function pipeExecute (command: string): boolean;
var
    Security : TSecurityAttributes;
    start : TStartUpInfo;
begin
    With Security do
        begin
            nLength := SizeOf(TSecurityAttributes) ;
            bInheritHandle := true;
            lpSecurityDescriptor := NIL;
        end;

    CreatePipe(InputPipeRead, InputPipeWrite, @Security, 0);
    CreatePipe(OutputPipeRead, OutputPipeWrite, @Security, 0);
    CreatePipe(ErrorPipeRead, ErrorPipeWrite, @Security, 0);

    FillChar(Start,Sizeof(Start),#0) ;
    start.cb := SizeOf(start) ;
    start.hStdInput := InputPipeRead;
    start.hStdOutput := OutputPipeWrite;
    start.hStdError :=  ErrorPipeWrite;
    start.dwFlags := STARTF_USESTDHANDLES + STARTF_USESHOWWINDOW;
    start.wShowWindow := SW_HIDE;

    pipeExecute := CreateProcess(nil, PChar(command),
           @Security, @Security,
           true,
           CREATE_NEW_CONSOLE or SYNCHRONIZE, nil, nil, start, ProcessInfo);
end;

end.
