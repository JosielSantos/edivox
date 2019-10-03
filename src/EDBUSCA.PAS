{--------------------------------------------------------}
{
{    Busca e Substituicao de Cadeias
{
{    Autor: Marcelo Luis Pinheiro
{
{    Orientador Academico: Jose' Antonio Borges
{
{    Em 10/12/93
{
{    Atualizado por: Neno Henrique da Cunha Albernaz
{    Em 23/09/2018
{    Em 20/10/2018
{
{--------------------------------------------------------}

Unit edBusca;

interface
uses
    DVcrt, DVWin, dvForm, sysutils, classes,
    edBloco, edvars, edmensag, edAcento, edTela, edLinha, edCursor;

procedure cmdBusca;
procedure buscaDeNovo (paraTraz: boolean);
procedure formatarBuscado;
procedure buscaPalavra (paraTraz: boolean);
procedure trocaPalavra;
procedure limpaTexto (limparTexto: boolean);

implementation

{--------------------------------------------------------}

var buscarIdentica: boolean;

{--------------------------------------------------------}

procedure buscaParaFrente;
var i, x: integer;
    linha: string;
begin
    for i := posy to maxlinhas do
        begin
            if not buscarIdentica then
                linha := semAcentos(texto [i]) + ^a
            else
                linha := texto [i] + ^a;
            if i = posy then
                for x := 1 to posx do
                    linha[x] := ^a;

            x := pos (buscado, linha);
            if x > 0 then
                begin
                    fala ('EDTXTENC');
                    posy := i;
                    posx := x;
                    exit;
                end;
        end;

    fala ('EDTXNENC');
end;

{--------------------------------------------------------}

procedure buscaParaTraz;
var i, x: integer;
    linha: string;
begin
    for i := posy downto 1 do
        begin
            if not buscarIdentica then
                linha := semAcentos (texto [i]) + ^a
            else
                linha := texto [i] + ^a;
            if i = posy then
                for x :=  posx to length(linha) do
                    linha[x] := ^a;

            x := pos (buscado, linha);
            if x > 0 then
                begin
                    fala ('EDTXTENC');
                    posy := i;
                    posx := x;
                    exit;
                end;
        end;

    fala ('EDTXNENC');
end;

{--------------------------------------------------------}

Procedure buscaDeNovo (paraTraz: boolean);
begin
    if buscado = '' then
        buscaPalavra (paraTraz)
    else
    if paraTraz then
        buscaParaTraz
    else
        buscaParaFrente;
end;

{--------------------------------------------------------}

procedure formatarBuscado;
begin
    buscarIdentica := false;
    if (length(buscado) > 1) and ((pos ('&', buscado) = 1) or (buscado[length(buscado)] = '&')) then
        begin
            buscarIdentica := true;
            if buscado[1] = '&' then delete (buscado, 1, 1);
            if (length(buscado) > 1) and (buscado[length(buscado)] = '&') then delete (buscado, length(buscado), 1);
        end
    else
        buscado := semAcentos (buscado);
end;

{--------------------------------------------------------}

Procedure buscaPalavra (paraTraz: boolean);
var c: char;
begin
    buscado := sintAmbiente ('EDIVOX', 'BUSCADO');
    fala ('EDTXTPRC');
    c := sintEditaCampo (buscado, 1, wherey, 255, 80, true);
    sintGravaAmbiente('EDIVOX', 'BUSCADO', buscado);
    formatarBuscado;

    if (c = ESC) or (buscado = '') then
        begin
            fala ('EDDESIST');
            exit;
        end;

    buscaDeNovo (paraTraz);
end;

{--------------------------------------------------------}

procedure trocaPalavra;
var
    c: char;
    buscado, aTrocar: string;
    nl: integer;
    achou: boolean;
    totalPalavras: int64;

    function trocaTexto (nl: integer): boolean;
    var linha, saida: string;
        tamb, x: integer;
    begin
        linha := texto[nl];
        saida := '';
        tamb := length (buscado);

        trocaTexto := false;
        while linha <> '' do
            begin
                x := pos (buscado, linha);
                if x <= 0 then
                    begin
                        saida := saida + linha;
                        linha := '';
                    end
                else
                    begin
                        trocaTexto := true;
                        totalPalavras := totalPalavras + 1;
                        delete (linha, x, tamb);
                        if x > 1 then
                            saida := saida + copy (linha, 1, x-1);
                        saida := saida + atrocar;
                        linha := copy (linha, x, length(linha)-x+1);
                    end;
            end;

        texto[nl] := saida;
    end;

begin
    fala ('EDTXTPRC');

    sintReadln (buscado);
    if buscado = '' then
        begin
            fala ('EDDESIST');
            exit;
        end;

    fala ('EDINFTXT');
    sintReadln (aTrocar);

    repeat
        fala ('EDTODBLK');
        c := popupMenuPorLetra ('TB');
        if c = #$1b then
            begin
                fala ('EDDESIST');
                exit;
            end;
    until c in ['T', 'B'];

    totalPalavras := 0;
    achou := false;
    if c = 'T' then
        begin
            for nl := 1 to maxLinhas do
                if trocaTexto (nl) then achou := true;
        end
    else
        begin
            if iniBloco > 0 then
                for nl := iniBloco to fimBloco do
                    if trocaTexto (nl) then achou := true;
        end;

    escreveTela;

    if achou then
        begin
            fala ('EDTXTTRC');
            sintetiza (intToStr(totalPalavras));
            sintclek;
        end
    else
        fala ('EDTXNENC');
end;

{--------------------------------------------------------}

procedure cmdBusca;
var
    tecla: char;
label deNovo;
begin
    fala ('EDOPCAO');   { qual opcao ? }
    tecla := leTeclaMaiusc;

deNovo:
    escreveTela;

    case tecla of

       'P': buscaPalavra (false);
       'A': buscaPalavra (true);
       'N': buscaDeNovo (false);
       'T': trocaPalavra;

       #$0: begin
                tecla := ajuda (readkey, 'EDAJBU', 4);
                goto deNovo;
            end;
      #$1b: begin
                fala ('EDDESIST');
                exit;
            end
    else
        sintBip;
    end;

    escreveTela;
end;

{--------------------------------------------------------}
{       Limpa um texto retirando caracteres estranhos
{       O arquivo de caracteres com nome arqTroca.ini deve estar na pasta de arquivos de configuração do Dosvox.
{       Outro arquivo de troca é o arqTroca_PT_BR.ini para limpar e traduzir textos de Portugal
{--------------------------------------------------------}

procedure limpaTexto  (limparTexto: boolean);
var
    i, k, yIni, yFim: integer;
    nomeArqLimpa, nomeArqTroca, saida, textoATrocar, novoTextoATrocar: string;
////    arqLimpa: text;
    linhasArqLimpa: TStringList;
    c: char;
label fim;

    procedure trocaTexto (nl: integer);
    var
        linha, saida: string;
        tamb, x: integer;
    begin
        linha := texto[nl];
        saida := '';
        tamb := length (textoATrocar);
        while linha <> '' do
            begin
                x := pos (textoATrocar, linha);
                if x <= 0 then
                    begin
                        saida := saida + linha;
                        linha := '';
                    end
                else
                    begin
                        delete (linha, x, tamb);
                        if x > 1 then
                            saida := saida + copy (linha, 1, x-1);
                        saida := saida + novoTextoATrocar;
                        linha := copy (linha, x, length(linha)-x+1);
                    end;
            end;
        texto[nl] := saida;
    end;

begin
    if limparTexto then
        begin
            fala ('EDLIMTXT'); {'Limpando o texto ...'}
            nomeArqTroca := '\arqTroca.ini';
        end
    else
        begin
            fala ('EDPTPBR'); {'Limpando e traduzindo de Pt para Br ...'}
            nomeArqTroca := '\arqTroca_Pt_Br.ini';
        end;

    nomeArqLimpa := sintDirAmbiente + nomeArqTroca;
    if not fileExists (nomeArqLimpa) then
        begin
            nomeArqLimpa := sintAmbiente('DOSVOX', 'PGMDOSVOX') + nomeArqTroca;
            if not fileExists (nomeArqLimpa) then
                begin
                    nomeArqLimpa := 'c:\Winvox' + nomeArqTroca;
                    if not fileExists (nomeArqLimpa) then
                        begin
                            fala ('EDARQNAO'); {'Arquivo não existe'}
                            sintetiza (nomeArqLimpa);
                            exit;
                        end;
                end;
        end;

    repeat
        fala ('EDTODBLK'); {'Todo texto (T) ou bloco (B): '}
        c := popupMenuPorLetra ('TB');
    until c in ['T', 'B', ESC];
    if c = ESC then
        begin
                    fala ('EDDESIST');
            exit;
        end;

    if c = 'T' then
        begin
            yIni := 1;
            yFim := maxLinhas;
        end
    else
    if  fimbloco < iniBloco then
        begin
            fala ('EDBLKINV');   { bloco invalido }
            exit;
        end
    else //Bloco válido
        begin
            yIni := iniBloco;
            yFim := fimBloco;
        end;

////    assign (arqLimpa, nomeArqLimpa);
////    {$I-}  reset (arqLimpa);  {$I+}
////    if ioresult <> 0 then;

    linhasArqLimpa := TStringList.create;
    try
        linhasArqLimpa.loadFromFile (nomeArqLimpa);
    except
        fala ('EDARQNAO'); {'Arquivo não existe'}
        sintetiza (nomeArqLimpa);
        exit;
    end;

////    while not eof(arqLimpa) do
    for k := 0 to (linhasArqLimpa.count -1) do
        begin
////            readln (arqLimpa, saida);
            saida := linhasArqLimpa[k];
            i := pos ('|', saida);
            if i < 2 then continue;
            textoATrocar := copy (saida, 1, i-1);
            if trim(textoATrocar) = '' then continue;
            delete (saida, 1, i);
            novoTextoATrocar := saida;
            for i := yIni to yFim do
                begin
                    if keypressed and ((yfim - yIni) > 1000) then
                        begin
                            c := readkey;
                            if c = ESC then
                                begin
                                            fala ('EDDESIST');
                                    goto fim;
                                end
                            else
                                begin
////                                informaLinha ((k+1),  (linhasArqLimpa.count-1), false);
                                    escreveNumero (((k+1)*100)div (linhasArqLimpa.count-1));
                                    sintWrite ('%');
                                end;
                        end;
                    trocaTexto (i);
                end;
        end;

fim:
////{$i-}  close (arqLimpa); {$i+}
////    if ioresult = 0 then;
    linhasArqLimpa.free;
    inicBloco;
    escreveTela;
    fala ('EDOK'); {'OK'}
    posx := 1;
end;

{--------------------------------------------------------}

begin
end.
