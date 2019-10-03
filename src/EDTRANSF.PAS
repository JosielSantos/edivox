{--------------------------------------------------------}
{
{    Manipulacao da area de transferencia
{
{    Autor: Antonio Borges
{
{    Em 27/01/98
{
{--------------------------------------------------------}

Unit edTransf;

interface
uses
    DVcrt, DVWin, sysUtils, windows,
    edVars, edMensag, edLinha;

procedure jogaAreaTransf (falando: boolean);
procedure pegaAreaTransf (falando: boolean);
procedure areaTransfWord;
procedure falaAreaTransf;

implementation

{--------------------------------------------------------}

procedure troca (var x1, x2: integer);
var temp: integer;
begin
    temp := x1;  x1 := x2;  x2 := temp;
end;

{--------------------------------------------------------}

procedure jogaAreaTransf (falando: boolean);
var i: integer;
    p: PChar;
    pos, tam: integer;
    tamAloc: integer;

begin
    if (iniMarca > 0) and (fimMarca > 0) then   // trechinho marcado
        begin
            tamAloc := length (texto[posy]) + 2;
            getmem (p, tamAloc);
            if iniMarca > fimMarca then troca(iniMarca, fimMarca);
            for i := 1 to (fimMarca-iniMarca) do
                p[i-1] := texto[posy][i+iniMarca-1];
            p [fimMarca-iniMarca] := #$0;
            putClipboard (p);
            freemem (p, tamAloc);
            sintClek; sintClek;
            exit;
        end;

    if (fimbloco = 0) or (iniBloco = 0) then
        begin
            inibloco := posy;
            fimBloco := posy;
        end;

    if fimbloco < inibloco then
        fala ('EDBLKINV')
    else
        begin
            tamAloc := 0;
            for i := iniBloco to fimBloco do
                tamAloc := tamAloc + length (texto[i]) + 2;
            tamAloc := tamAloc + 2;   // para o NIL

            getmem (p, tamAloc);
            pos := 0;
            for i := iniBloco to fimBloco do
                begin
                    tam := length (texto[i]);
                    if (longint (pos) + tam + 2) > tamAloc then   // nunca deve acontecer isso
                        begin
                            fala ('EDCOPTRU');   {cópia truncada}
                            break;
                        end;
                    if tam > 0 then
                        move (texto[i][1], p[pos], tam);
                    pos := pos + tam;
                    p[pos]   := #$0d;
                    p[pos+1] := #$0a;
                    pos := pos + 2;
                end;
            p[pos] := #$0;

            putClipboard (p);
            freemem (p, tamAloc);

            if falando then
                fala ('EDBLKCRG')   {'Bloco carregado'}
            else
                sintClek;
        end;
end;

{--------------------------------------------------------}

procedure areaTransfWord;
var i: integer;
    s, si: string;

begin
    if fimbloco = 0 then
        begin
            inibloco := posy;
            fimBloco := posy;
        end;

    if fimbloco < inibloco then
        fala ('EDBLKINV')
    else
        begin
            s := '';
            for i := iniBloco to fimBloco do
                begin
                    si := texto[i];

                    if trim(si) = '' then
                        s := s + #$0d + #$0a
                    else

                    if copy (si, 1, 4) = '    ' then
                        begin
                            s := s + #$0d + #$0a;
                            while copy (si, 1, 4) = '    ' do
                                begin
                                    s := s + ^i;
                                    delete (si, 1, 4);
                                end;
                            s := s + si;
                        end
                    else

                    if si[1] = ' ' then
                        begin
                            delete (si, 1, 1);
                            s := s + #$0d + #$0a + si;
                        end
                    else
                        s := s + ' ' + texto[i];
                end;

            s := s + #$0d + #$0a;
            putClipboard (@s[2]);

            fala ('EDBLKCRG')   {'Bloco carregado'}
        end;
end;

{--------------------------------------------------------}

procedure insereTransfNaLinha (buf: pchar);
var s: string;
    salva: cardinal;
begin
    s := texto[posy];
    if (iniMarca > 0) and (fimMarca > 0) then   // trechinho marcado
        begin
            if iniMarca > fimMarca then troca (iniMarca, fimMarca);
            posx := iniMarca;
            delete (s, iniMarca, fimMarca-iniMarca);
            insert (strPas(buf), s, iniMarca);
        end
    else
        s := copy (s, 1, posx-1) + strPas (buf) + copy (s, posx, length(s));

    iniMarca := 0;
    fimMarca := 0;

    salva := posx;
    texto[posy] := s;
    posx := salva + strLen (buf);
    if posx > length (s) then posx := length (s)+1;

    sintClek; sintClek;
end;

{--------------------------------------------------------}

procedure pegaAreaTransf (falando: boolean);
var
    i: integer;
    s: string;
    buf: PChar;
    hmem: THandle;

label fim;
Begin
    if not openClipboard (crtWindow) then exit;
    hmem := getClipboardData (CF_TEXT);
    if hmem = 0 then
        begin
            closeClipboard;
            exit;
        end;

    iniBloco := posy;
    fimBloco := posy;

    buf := globalLock (hmem);

    for i := 0 to 65000-1 do
        begin
            if buf[i] = #0 then
                begin
                    insereTransfNaLinha (buf);
                    goto fim;
                end
            else
            if (buf[i] = #$0d) or (buf[i] = #$0a) then break;
        end;

    i := 0;
    while buf[i] <> #$0 do
        begin
            s := '';
            while (buf[i] <> #$0a) and (buf[i] <> #$0) do
                begin
                    if buf[i] <> #$0d then
                        s := s + buf[i];
                    i := i + 1;
                end;

            if buf[i] <> #$0 then
                i := i + 1;

            insereLinha (s, false);
            posy := posy + 1;
        end;

    posx := 1;
    fimbloco := posy-1;

    if falando then
        fala ('EDBLKADC')  {'Bloco adicionado'}
    else
        sintClek;

fim:
    globalUnlock (hmem);
    closeClipboard;
end;

{--------------------------------------------------------}

procedure falaAreaTransf;
var
    i: integer;
    s: string;
    buf: PChar;
    hmem: THandle;

label fim;
Begin
    if not openClipboard (crtWindow) then exit;
    hmem := getClipboardData (CF_TEXT);
    if hmem = 0 then
        begin
            closeClipboard;
            exit;
        end;

    limpaBufTec;
    sintclek;
    buf := globalLock (hmem);
    for i := 0 to 65000-1 do
        begin
            if buf[i] = #0 then
                begin
                    sintetiza (strPas(buf));
                    goto fim;
                end
            else
            if (buf[i] = #$0d) or (buf[i] = #$0a) then break;
            if keypressed then goto fim;
        end;

    i := 0;
    while buf[i] <> #$0 do
        begin
            s := '';
            while (buf[i] <> #$0a) and (buf[i] <> #$0) do
                begin
                    if buf[i] <> #$0d then
                        s := s + buf[i];
                    i := i + 1;
                    if (buf[i] = #$0d) or (buf[i] = #$0a) then break;
                end;

            if buf[i] <> #$0 then
                i := i + 1;

            sintetiza (strPas(buf));
            if keypressed then break;
            if (buf[i] = #$0d) or (buf[i] = #$0a) then break;
        end;

fim:
    globalUnlock (hmem);
    closeClipboard;
    limpaBufTec;
    sintclek;
end;

{--------------------------------------------------------}

begin
end.
