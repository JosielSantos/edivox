{--------------------------------------------------------}

{
{    Tratamento de Blocos de Linhas
{
{    Autor: Marcelo Luis Pinheiro
{
{    Orientador Academico: Jose' Antonio Borges
{
{    Em 10/12/93
{
{--------------------------------------------------------}

Unit edBloco;

interface
uses
    DVcrt, DVWin, DVarq, windows, sysUtils,
    dvForm,
    edVars, edMensag, edLinha, edArq, edAcento, edEmbel, edTela, eddicion,
    edCursor, edReform, edTransf;

function blocoInvalido: Boolean;
procedure informaBloco;
procedure inicBloco;
procedure trataBloco (cmdBloco: boolean);

implementation

{--------------------------------------------------------}

Procedure InicBloco;
begin
    inibloco := 1;
    fimbloco := 0;
    novoini  := 0;
end;

{--------------------------------------------------------}

procedure selecionaTodoTexto;
begin
    inibloco := 1;
    fimbloco := maxlinhas;
    fala ('EDBLKMAR'); {'Bloco marcado'}
end;

{--------------------------------------------------------}

function blocoInvalido: Boolean;
begin
    blocoInvalido := fimbloco < iniBloco;
end;

{--------------------------------------------------------}

procedure informaBloco;
begin
    if blocoInvalido then
        begin
            fala ('EDBLKINV');   { bloco invalido }
            exit;
        end;
    fala('EDINIBLK'); {'Inicio do bloco'}
    sintwrite (intToStr(inibloco));
    fala ('EDFIMBLK'); {'Fim do bloco'}
    sintwrite (intToStr(fimbloco));
end;

{--------------------------------------------------------}

Procedure copiaBloco;
Var
    tam, k : Integer;

Begin
    if blocoInvalido or
        ( (posy >= inibloco) and (posy <= fimbloco) ) then
         begin
             fala ('EDBLKINV');   { bloco invalido }
             exit;
         end;

    tam := fimbloco - inibloco + 1;
    For k := tam-1 downto 0 do
        begin
            if keypressed and (tam > 1000) then
                begin
                    limpabuftec;
                    informaLinha ( tam - k, tam, false);
                end;
                insereLinha (texto [inibloco+k], false);
        end;

    fimbloco := inibloco + tam - 1;
    fala ('EDBLKCPY');
End;

{--------------------------------------------------------}

procedure falaQuantas;
var
    s: string;
    totalLinhasEmBranco, totalPalavras, totalCaracteres, totalEspacos, totalNumeros, totalPontuacao: int64;
    totalLetras, totalLetrasSemAcento, totalLetrasComAcento, totalLetrasMaiusculas, totalLetrasMinusculas: integer;
    y: integer;

    procedure contaPalavras (s: string);
    var
        p: integer;
    begin
        s := trim(s);
        while s <> '' do
            begin
                totalPalavras := totalPalavras + 1;
                p := pos (' ', s);
                if p > 0 then
                    delete (s, 1, p)
                else
                     s := '';
                s := trim(s);
            end;
    end;

    function strToChar (s: string): char;
    begin
        strToChar := s[1];
    end;

    procedure contaCaracteres (s: string);
    var
        i: integer;
    begin
        totalCaracteres := totalCaracteres +  length(s);
        for i := 1 to length(s)do
            if s[i] = ' ' then
                totalEspacos := totalEspacos + 1
            else
            if s[i] in ['0' .. '9'] then
                totalNumeros := totalNumeros + 1
            else
            if s[i] in ['.', ',', '?', '!', ';', ':'] then
                totalPontuacao := totalPontuacao+ 1
            else
            if strToChar(semAcentos(s[i])) in ['A' .. 'Z', 'Ç'] then
                begin
                    totalLetras := totalLetras + 1;
                    if strToChar(maiuscansi(s[i])) in ['A' .. 'Z', 'Ç'] then
                        totalLetrasSemAcento := totalLetrasSemAcento + 1
                    else
                        totalLetrasComAcento := totalLetrasComAcento + 1;
                    if (s[i] = uppercase(s[i])) and (not(s[i] in ['á', 'à', 'â', 'ã', 'ä', 'é', 'è', 'ê', 'ë', 'í', 'ì', 'î', 'ï', 'ó', 'ò', 'ô', 'õ', 'ö', 'ú',
'ù', 'û', 'ü', 'ç'])) then
                        totalLetrasMaiusculas := totalLetrasMaiusculas + 1
                    else
                        totalLetrasMinusculas := totalLetrasMinusculas + 1;
                end;
    end;

begin
    if blocoInvalido then
         begin
             fala ('EDBLKINV');   { bloco invalido }
             exit;
         end;

    totalPalavras := 0;
    totalCaracteres := 0;
    TotalEspacos := 0;
    totalNumeros := 0;
    totalPontuacao := 0;
    totalLetras := 0;
    totalLetrasSemAcento := 0;
    totalLetrasComAcento := 0;
    totalLetrasMaiusculas := 0;
    totalLetrasMinusculas := 0;
        totalLinhasEmBranco := 0;
    for y := iniBloco to fimBloco do
        begin
            s := texto[y];
            if trim(s) = '' then
                totalLinhasEmBranco := totalLinhasEmBranco + 1
            else
                begin
                    contaPalavras (s);
                    contaCaracteres (s);
                end;
        end;

    escreveNumero (totalPalavras);
    fala ('EDPALAVR'); {'palavras'}
    sintClek;
    if not keypressed then     delay (300);
    sintetiza (intToStr (totalCaracteres) + 'Caracteres');
    sintClek;
    if not keypressed then     delay (300);
    sintetiza (intToStr (totalEspacos) + 'Espaços em branco');
    sintClek;
    if not keypressed then     delay (300);
    sintetiza (intToStr (totalLetras) + 'Letras');
    sintClek;
    if not keypressed then     delay (300);
    sintetiza (intToStr (totalLetrasSemAcento) + 'Letras sem acento');
    sintClek;
    if not keypressed then     delay (300);
    sintetiza (intToStr (totalLetrasComAcento) + 'Letras com acento');
    sintClek;
    if not keypressed then     delay (300);
    sintetiza (intToStr (totalLetrasMaiusculas) + 'Letras maiúsculas');
    sintClek;
    if not keypressed then     delay (300);
    sintetiza (intToStr (totalLetrasMinusculas) + 'Letras minúsculas');
    sintClek;
    if not keypressed then     delay (300);
    sintetiza (intToStr (totalNumeros) + 'Números');
    sintClek;
    if not keypressed then     delay (300);
    sintetiza (intToStr (totalPontuacao) + 'Sinais de pontuação');
    sintClek;
    if not keypressed then     delay (300);
    sintetiza (intToStr (totalLinhasEmBranco) + 'Linhas em branco');
    sintClek;
end;

{--------------------------------------------------------}

procedure colocaEmMaiusculoMinusculo (maiusculo, primeiraMaiusculo, paraUTF8: boolean);
var
    y: integer;
    tecla: char;
    s: string;

    function colocaPrimMaiuscula (s: string): string;
    var
        i: integer;
        proximaMaiusc: boolean;
    begin
        s := ansiLowerCase (s);
        proximaMaiusc := true;
        for i := 1 to length (s) do
            begin
                if (s [i] <> ' ') and proximaMaiusc then
                    begin
                        s [i] := (ansiUpperCase (s) [i]);
                        proximaMaiusc := false;
                    end
                else
                if s [i] = ' ' then
                    proximaMaiusc := true;
            end;
        colocaPrimMaiuscula := s;
    end;

begin
    if blocoInvalido then
         begin
             fala ('EDBLKINV');   { bloco invalido }
             exit;
         end;

    if maiusculo then
        fala ('EDMAIUSC')   { 'Deseja converter o bloco para maiúscula?'}
    else
    if primeiraMaiusculo then
        fala ('EDPRIMAI')   { 'Deseja converter primeira letra de todo bloco para maiúscula?'}
    else
    if paraUTF8 then
        fala ('EDPUTF8')   { 'Deseja codificar o bloco para UTF-8'}
    else
        fala ('EDMINUSC');   { 'Deseja converter o bloco para minúscula?'}

    tecla := popupMenuPorLetra ('SN');
    if not (tecla in ['S', ENTER]) then
        begin
            fala ('EDDESIST');  { Desistiu }
            exit;
        end;

    for y := iniBloco to fimBloco do
        begin
            s := texto[y];
            if trim(s) = '' then
                continue
            else
            if maiusculo then
                s := ansiUpperCase (s)
            else
            if primeiraMaiusculo then
                s := colocaPrimMaiuscula (s)
            else
            if paraUTF8 then
                s := AnsiToUtf8(s)
            else
                s := ansiLowerCase (s);

            texto[y] := s;
        end;

    fala ('EDOK');
end;

{--------------------------------------------------------}

procedure tratamentoMaiusculaMinuscula;
var
    c: char;
label deNovo;
begin
    fala ('EDOPCAO');   { qual opcao ? }
    c := leTeclaMaiusc;
deNovo:
    escreveTela;

    case c of
        'A': colocaEmMaiusculoMinusculo (true, false, false);
        'I': colocaEmMaiusculoMinusculo (false, false, false);
        'P': colocaEmMaiusculoMinusculo (false, true, false);
        'U': colocaEmMaiusculoMinusculo (false, false, true);
        'C': falaQuantas;

        #$0: begin
                c:= ajuda (readkey, 'EDAJMM', 6);
                goto deNovo;
            end;
        #$1b:  begin
                fala ('EDDESIST');
                exit;
            end
    else
        sintBip;
    end;
end;

{--------------------------------------------------------}

Procedure Removebloco;
Var
    i: Integer;
Begin
    If blocoInvalido then
        begin
            fala ('EDBLKINV');
            exit;
        end;

    if  (fimbloco - inibloco) > 50000 then
        fala ('EDAGUARD'); {'Aguarde ...'}
    posy  := inibloco;
    For i := inibloco to fimbloco Do
        begin
            if keypressed and ((fimBloco - iniBloco)  > 1000) then
                begin
                    limpaBuftec;
                    informaLinha (i,  fimBloco, false);
                end;
            removeLinha (false);
        end;

    fala ('EDBLKREM');

    inicBloco;
End;

{--------------------------------------------------------}

Procedure moveBloco;
var
    tam, i : Integer;

begin
    if blocoInvalido or
        ( (posy >= inibloco) and (posy <= fimbloco) ) then
         begin
             fala ('EDBLKINV');   { bloco invalido }
             exit;
         end;

    tam := fimbloco - inibloco + 1;
    salvaCury:= posy;

    For i := tam-1 downto 0 do
        begin
            if keypressed and (tam > 1000) then
                begin
                    limpabuftec;
                    informaLinha ( tam - i,  tam, false);
                end;
            insereLinha (texto [fimbloco], false);
            posy := fimBloco;
            removeLinha (false);
            posy := salvaCury;
        end;

    posy := salvaCury;
    iniBloco := posy;
    fimBloco := iniBloco + tam - 1;

    fala ('EDBLKMOV');
end;

{--------------------------------------------------------}

Procedure LeBloco;
var
    salvaNome: string;
    salva: integer;

label fim;

begin
    salvaNome := nomeArq;
    salva := posy;

    if abreArqSemCriar then
        begin
            fimBloco := posy-1;
            iniBloco := salva;
            posy := salva;
            posx := 1;
            fala ('EDBLKCRG');
        end;

    nomeArq := salvaNome;

    if posy <= 0 then
        posy := 1;
end;

{--------------------------------------------------------}

Procedure GravaBloco;
var
    salvaNome: string;
    tecla: char;
    aux: boolean;
begin
    If BlocoInvalido  Then
        begin
            fala ('EDBLKINV');   { bloco Invalido }
            exit;
        end;

    salvanome := nomeArq;
    nomearq := '';

    fala ('EDREFORM');   { Junta linhas para exportar? }
    //tecla := leTeclaMaiusc;
    tecla := popupMenuPorLetra('SN');
    aux := somenteLeitura;
    somenteLeitura := false;
    if tecla <> ESC then
        if upcase (tecla) <> 'S' then
            salvaArquivo (iniBloco, fimBloco)
        else
            salvaJuntaLinhas (iniBloco, fimBloco)
    else
        fala ('EDDESIST');   { Desistiu }
    somenteLeitura := aux;

    nomeArq := salvaNome;
end;

{--------------------------------------------------------}

Procedure AdicionaBloco;
Var
    salvaNome: string;
    adic : Text;
    i : Integer;

Label Inicio, fecha, fim;

Begin
    If blocoInvalido then
        begin
            fala ('EDBLKINV');
            exit;
         end;

Inicio :
    fala ('EDDIGNOM');
    salvaNome := Nomearq;
    nomeArq := obtemNomeArq (10);
    write (nomeArq);
    nomeArq := trim(nomeArq);
    if nomeArq = '' then
        begin
            fala ('EDDESIST');
            goto fim;
        end;

    if not testaExtensao (nomeArq) then
        begin
            assign (adic, nomeArq);
            {$i-} reset (adic); {$i+}
            if ioresult = 0 then
                {$i-} close (adic) {$i+}
            else
                nomeArq := nomeArq + '.txt';
        end;

    assign (adic, nomeArq);
    {$I-} append (adic); {$I+}
    If ioresult <> 0  Then
        begin
            fala('EDARQNAO');
            goto fim;
        end;

    For i := inibloco to fimbloco  Do
        begin
            {$I-} writeln (adic, texto[i]); {$I+}
            If ioResult <> 0  Then
                begin
                    fala ('EDERRESC');
                    goto fecha;
                end;
        end;

fecha:
    {$I-}  close (adic);  {$I+}
    if ioresult = 0 then
        fala ('EDBLKADC'); {  Bloco adicionado. }

fim:
    nomeArq := salvaNome;
End;

{--------------------------------------------------------}

Procedure OrdenaBloco;

        procedure acrescentaZeros (var s: string);
        const zeros = '000000000000000';
        var nnum, i: integer;
        begin
            s := s + '.';
            for i := 1 to length(s) do
                 if not (s[i] in ['0'..'9']) then
                      begin
                          nnum := i-1;
                          break;
                      end;
            delete (s, length(s), 1);
            s := copy (zeros, 1, 15-nnum) + s;
        end;

Var
    i, j : Integer;
    nome1, nome2: string;
    pt : Frase;
Begin
    If blocoInvalido then
        begin
             fala ('EDBLKINV');
             exit;
        end;

    For i := IniBloco to fimBloco-1 do
        For j:= i+1 To fimBloco do
            begin
                nome1 := semAcentos (texto[j]);
                nome2 := semAcentos (texto[i]);
                if (nome1 <> '') and (nome1[1] in ['0'..'9']) then acrescentaZeros(nome1);
                if (nome2 <> '') and (nome2[1] in ['0'..'9']) then acrescentaZeros(nome2);
                if nome1 < nome2 then
                    begin
                        pt       := texto[i];
                        texto[i] := texto[j];
                        texto[j] := pt;
                    end;
            end;
    fala ('EDBLKORD');
end;

{--------------------------------------------------------}

procedure blocoParagrafo;
begin
    inibloco := posy;
    fimBloco := posy;

    while (inibloco > 1) and (trim(texto[inibloco-1]) <> '') do
        inibloco := inibloco - 1;

    while (fimbloco < maxlinhas) and (trim(texto[fimbloco+1]) <> '') do
        fimbloco := fimbloco + 1;

    fala ('EDBLKPAR');
end;

{--------------------------------------------------------}

procedure blocoLinha;
begin
    inibloco := posy;
    fimBloco := posy;
    fala ('EDBLKLIN');
end;

{--------------------------------------------------------}

{--------------------------------------------------------}

procedure justificaParagrafo;
begin
    inibloco := posy;
    fimBloco := posy;

    while (inibloco > 1) and (trim(texto[inibloco-1]) <> '') do
        inibloco := inibloco - 1;

    while (fimbloco < maxlinhas) and (trim(texto[fimbloco+1]) <> '') do
        fimbloco := fimbloco + 1;

    acertaMargens (false);
    inicBloco;
    fala ('EDJUSTIF');
end;

{--------------------------------------------------------}

procedure verificaBloco;
begin
    if blocoInvalido then
         begin
             fala ('EDBLKINV');   { bloco invalido }
             exit;
         end;

    if not verificaDicionario (iniBloco, fimBloco) then
        fala ('EDDICNAO');   {dicionário não foi encontrado}
end;

{--------------------------------------------------------}

procedure removeLinhasEmBranco(removerTodas: boolean);
var
    i: integer;
    passouUma: boolean;
begin
    if blocoInvalido then
         begin
             fala ('EDBLKINV');   { bloco invalido }
             exit;
         end;

    passouUma := false;
    sintClek;
    for i := fimBloco downto iniBloco do
        if trim(texto [i]) = '' then
            begin
                posy := i;
                if (removerTodas or passouUma) then
                    Removelinha(false)
                else
                    passouUma := true;
                if (i mod 100) = 0 then
                    sintClek;
            end
        else
    passouUma := false;

    posy := iniBloco;
    posx := 1;
end;

{--------------------------------------------------------}

Procedure TrataBloco (cmdBloco: boolean);
Var
    c : char;
label deNovo;

Begin
    if cmdBloco then
        fala ('EDOPCAO')   { qual opcao ? }
    else
        fala ('EDCMDBLK');     { bloco: }
    c := sintReadKey;

deNovo:
    case upcase(c) of
         'M' : movebloco;
         'C' : copiabloco;
         'A' : AdicionaBloco;
         'O' : OrdenaBloco;
         'R' : removebloco;

         'I' : begin
                   inibloco := posy;
                   fala ('EDINIBLK');    { inicio do bloco }
               end;

         'F' : begin
                   fimbloco := posy;
                   fala ('EDFIMBLK');    { fim do bloco }
               end;

         'D' : begin
                   inicBloco;
                   fala ('EDBLKDSM');   { bloco desmarcado }
               end;

         'L' : leBloco;
         'G' : gravaBloco;
         'E' : embelezaBloco;
         'P' : blocoParagrafo;
         'S' : blocoLinha;
         'J' : justificaParagrafo;
         'V' : verificaBloco;

         'X' : reformata;
         'U' : tratamentoMaiusculaMinuscula;
         'B' : removeLinhasEmBranco(true);
         ^B : removeLinhasEmBranco(false);

         'W' : areaTransfWord;
         'T' : selecionaTodoTexto;

        #$0: begin
                c := ajuda (readkey, 'EDAJBL', 22);
                goto deNovo;
             end;
        #$1b:  begin
                fala ('EDDESIST');
                exit;
            end
    else
        sintBip;
    end;

    if cmdBloco then
        escreveTela;
end;

{--------------------------------------------------------}

begin
end.
