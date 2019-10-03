unit eddicion;

interface

uses
    DVcrt, DVWin, dvDic, sysUtils, classes,
    edVars, edMensag, edLinha, edArq, edAcento, edEmbel, edTela, dvForm,
    edCursor;

procedure ativaDicionario (mudo: boolean);
function verificaDicionario (iniBloco, fimBloco: integer): boolean;
function descobrePalavraAntes (x: integer): string;
procedure verificaPalavraAntes;
procedure trocaPalavraDic;
procedure acharProximaPalavraErrada;

implementation

const caracErro = '#';

var
    listaAlternativa: TStringList;

const
     LETRAS_DE_PALAVRA: set of char =
         ['A'..'Z', 'Á', 'É', 'Í', 'Ó', 'Ú',
          'À', 'Ã', 'Ô', 'Â', 'Ê', 'Ü', 'Ç', 'Ñ', 'Õ', 'È', 'Î', 'Ö',
          'a'..'z', 'á', 'é', 'í', 'ó', 'ú',
          'à', 'ã', 'ô', 'â', 'ê', 'ü', 'ç', 'ñ', 'õ', 'è', 'î', 'ö',
          '-', ''''];

{----------------------------------------------------------------}
{                ativa/desativa dicionário online
{----------------------------------------------------------------}

procedure ativaDicionario (mudo: boolean);
begin
    if not verificaDicionario (1, 0) then
        dicionarioAtivado := false
    else
        dicionarioAtivado := not dicionarioAtivado;
    if not mudo then
        if dicionarioAtivado then
            fala ('EDDICIOA')    {'Dicionário ativado'}
        else
            fala ('EDDICIOD');   {'Dicionário desativado'}
end;

{----------------------------------------------------------------}
{                           processa
{----------------------------------------------------------------}

procedure processaDic (iniBloco, fimBloco: integer);
var
    c: char;
    s, saida, palavra: string;
    lin, i: integer;
    ok, mudo: boolean;
    numErros: integer;
label fim, continuaPalavra;

begin
    numErros := 0;
    mudo := false;
    for lin := iniBloco to fimBloco do
        begin
            s := texto[lin];
            saida := '';
            i := 1;
            if keypressed then
                begin
                    c := readkey;
                    if c = ESC then break
                    else if c = ' ' then mudo := not mudo
                    else informaLinha (lin,  fimBloco, false);
                end;
            while i <= length (s) do
                begin
                    while (i <= length (s)) and not (s[i] in dicAlfabeto) do
                        begin
                            saida := saida + s[i];
                            i := i + 1;
                        end;

                    if i > length (s) then break;

                continuaPalavra:
                    while (i <= length (s)) and (s[i] in dicAlfabeto) do
                        begin
                            palavra := palavra + s[i];
                            i := i + 1;
                        end;

                    if (i < length (s)-1) and (s[i] in ['-', ''''])
                                          and (s[i+1] in dicAlfabeto) then
                        begin
                            palavra := palavra + s[i];
                            i := i + 1;
                            goto continuaPalavra;
                        end;

                     ok := procuraDic (palavra);
                     if ok then
                         saida := saida + palavra
                     else
                         begin
                             if copy (saida, length(saida), 1) = caracErro then
                                 saida := saida + palavra
                             else
                                 saida := saida + caracErro + palavra;
                             if (not mudo) and ((numErros mod 100) = 0) then
                                 sintBip;
                             numErros := numErros + 1;
                         end;
                     palavra := '';
                end;

            if texto[lin] <> saida then
                texto[lin] := saida;

        end;

    if fimBloco >= iniBloco then
        if (numErros = 0)  then Fala ('EDOK')
                           else sintetiza (intToStr (numErros));
    sintClek;
end;

{----------------------------------------------------------------}
{                           verifica bloco
{----------------------------------------------------------------}

function verificaDicionario (iniBloco, fimBloco: integer): boolean;
var
    s: string;
    salvaPosY: integer;
begin
    if not dicCarregado then
        begin
            nomeArqDic := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\diciona.dic';
            s := sintAmbiente ('DICIONARIO', 'ARQDIC');
            if s <> '' then nomeArqDic := s;

            nomeArqSufixos := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\diciona.suf';
            s := sintAmbiente ('DICIONARIO', 'ARQSUFIXOS');
            if s <> '' then nomeArqSufixos := s;

            nomeArqInexist := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\diciona.exc';
            s := sintAmbiente ('DICIONARIO', 'ARQINEXIST');
            if s <> '' then nomeArqInexist := s;

            nomeArqNomes := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\diciona.nom';
            s := sintAmbiente ('DICIONARIO', 'ARQNOMES');
            if s <> '' then nomeArqNomes := s;

            nomeArqSugTroca := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\diciona.sug';
            s := sintAmbiente ('DICIONARIO', 'ARQSUGERE');
            if s <> '' then nomeArqSugTroca := s;

            dicCarregado := carregaDic (nomeArqDic, nomeArqSufixos,
                                        nomeArqInexist, nomeArqNomes, nomeArqSugTroca) = 0;
        end;

    verificaDicionario := dicCarregado;
    if not dicCarregado then exit;

    salvaPosY := posY;
    processaDic (iniBloco, fimBloco);
    posY := salvaPosY;
end;

{----------------------------------------------------------------}
{              extrai uma palavra antes do cursor
{----------------------------------------------------------------}

function descobrePalavraAntes (x: integer): string;
var s, pal: string;
    i: integer;
    c: char;
begin
    descobrePalavraAntes := '';
    if (posy <= 0) or (x <= 1) then exit;
    s := texto[posy];
    s := copy (s, 1, x - 1);
    s := trim (s);
    pal := '';
    for i := length (s) downto 1 do
        begin
            c := s[i];
            if not (c in LETRAS_DE_PALAVRA) then break;
            pal := c + pal;
        end;
    descobrePalavraAntes := pal;
end;

{----------------------------------------------------------------}
{                    verifica uma palavra
{----------------------------------------------------------------}

procedure verificaPalavraAntes;
var pal: string;
begin
    pal := descobrePalavraAntes (posx);
    if pal = '' then exit;
    if not procuraDic(pal) then
        if existeArqSom ('EDERROP') then
            sintSom ('EDERROP')
        else
            begin
                sintBip;
                sintBip;
            end;
end;

{--------------------------------------------------------}
{       Substitui uma palavra por outra em todo o texto
{--------------------------------------------------------}

function trocaPalavraTodoDic (pal, pal2: string): integer;
var
    nl, totalTrocas: integer;

    function trocaTexto (nl: integer): boolean;
    var linha, saida: string;
        tamb: integer;
        x: integer;
    begin
        linha := texto[nl];
        saida := '';
        tamb := length (pal);

        trocaTexto := false;
        while linha <> '' do
            begin
                x := pos (pal, linha);
                if (x <= 0) or (linha[x + length(pal)] in LETRAS_DE_PALAVRA) or
                   ((x  > 1) and (linha[x - 1] in LETRAS_DE_PALAVRA)) then 
                    begin
                        saida := saida + linha;
                        linha := '';
                    end
                else
                    begin
                        totalTrocas := totalTrocas + 1;
                        trocaTexto := true;
                        delete (linha, x, tamb);
                        if x > 1 then
                            saida := saida + copy (linha, 1, x-1);
                        saida := saida + pal2;
                        linha := copy (linha, x, length(linha)-x+1);
                    end;
            end;

        texto[nl] := saida;
    end;


begin
    totalTrocas := 0;
    for nl := 1 to maxLinhas do
        trocaTexto (nl);
    escreveTela;
    trocaPalavraTodoDic := totalTrocas;
end;

{----------------------------------------------------------------}
{         mostra as alternativas à grafia de uma palavra
{----------------------------------------------------------------}

function mostraAlternativasGrafia (s: string): string;
var i, nsel: integer;
begin
    mostraAlternativasGrafia := '';
    if not dicionarioAtivado then ativaDicionario (true);
    if not dicionarioAtivado then
        begin
            fala ('EDDICNAO');   {'dicionário não foi achado'}
        exit;
        end;

    listaAlternativa.clear;
    geraAlternativasDic (s, 1, listaAlternativa);
    for i := 0 to listaAlternativa.Count-1 do
        if s = listaAlternativa[i] then //Para não adicionar palavra repetida ao dicionário
            begin
                fala ('EDPALCOR'); {'Palavra correta'}
                exit;
            end;

    fala ('EDALTERN');    {'Alternativas: use as setas'}

    popupMenuCria(40, 9, 30, listaAlternativa.count + 1, RED);
    for i := 0 to listaAlternativa.Count-1 do
        popupMenuAdiciona('', listaAlternativa[i]);
    popupMenuAdiciona('', 'Ignorar tudo');
    popupMenuAdiciona('', 'Adicionar ao dicionário');
    nsel := popupMenuSeleciona;

    sintclek;
    if nsel = (listaAlternativa.count + 1) then
        mostraAlternativasGrafia := 'Ignorar tudo'
    else
    if nsel = (listaAlternativa.count + 2) then
        mostraAlternativasGrafia := 'Adicionar ao dicionário'
    else
    if nsel > 0 then
        begin
            mostraAlternativasGrafia := listaAlternativa[nsel-1];
            write (' -> ');
            sintWrite (listaAlternativa[nsel-1]);
            clreol;
        end
    else
        fala ('EDDESIST');    {'Desistiu'}
end;

procedure trocaPalavraDic;
var s, pal, pal2: string;
    x, totalPalavrasTrocadas: integer;
begin
    if (posy <= 0) then exit;

    s := texto[posy];
    x := posx;
    while (x > 1) and (s[x-1] = ' ') do
        x := x - 1;
    while (x <= length(s)) and (s[x] in LETRAS_DE_PALAVRA) do
        x := x + 1;

    pal := descobrePalavraAntes (x);
    if pal <> '' then
        begin
            x := x - length (pal);
            pal2 := mostraAlternativasGrafia (pal);

            if (pal2 = 'Ignorar tudo') or
               (pal2 = 'Adicionar ao dicionário') then
                begin
                    if pal2 = 'Adicionar ao dicionário' then
                        if escreveNoFimDoArq (pal, nomeArqNomes) then
                            begin
                            //Linha abaixo para passar a considerar a nova palavra como correta
                                dicCarregado := carregaDic (nomeArqDic, nomeArqSufixos,
                                                            nomeArqInexist, nomeArqNomes, nomeArqSugTroca) = 0;
                                fala ('EDPALADI'); {'Palavra adicionada'}
                            end
                        else
                            fala ('EDDICNAO');  {'Dicionário não foi achado'}

                    if (x > 1) and (s[x-1] = '#') then
                        begin
                            x := x - 1;
                            delete (s, x, 1);
                        end;
                    texto[posy] := s;
                    if corrigirTodoTexto or (pal2 = 'Ignorar tudo') then
                        totalPalavrasTrocadas := trocaPalavraTodoDic ('#' + pal, pal)
                    else
                        totalPalavrasTrocadas := 1;

                    if totalPalavrasTrocadas > 1 then
                        sintetiza (intToStr(totalPalavrasTrocadas));
                    posx := x + length (pal);
                end
            else
            if pal2 <> '' then
                begin
                    delete (s, x, length (pal));
                    if (x > 1) and (s[x-1] = '#') then
                        begin
                            x := x - 1;
                            delete (s, x, 1);
                        end;
                    insert (pal2, s, x);
                    texto[posy] := s;
                    if corrigirTodoTexto then
                        totalPalavrasTrocadas := trocaPalavraTodoDic ('#' + pal, pal2) + 1 + trocaPalavraTodoDic (pal, pal2)
                    else
                        totalPalavrasTrocadas := 1;

                    if totalPalavrasTrocadas > 1 then
                        sintetiza (intToStr(totalPalavrasTrocadas));
                    posx := x + length (pal2);
                end;
        end
    else
        sintBip;
end;

{----------------------------------------------------------------}
{       Posiciona depois da próxima palavra considerada errada
{----------------------------------------------------------------}

procedure acharProximaPalavraErrada;
var s, palavra: string;
    lin, i: integer;
    ok: boolean;
label fim, continuaPalavra;

begin
    if not dicionarioAtivado then ativaDicionario (true);
    i := posx;
    if posy <= 0 then posY := 1;
    s := texto[posY];
    while (i <= length(s)) and (s[i] in LETRAS_DE_PALAVRA) do i := i + 1;

    for lin := posy to maxlinhas do
        begin
            s := texto[lin];
            while i <= length (s) do
                begin
                    while (i <= length (s)) and not (s[i] in dicAlfabeto) do
                        i := i + 1;

                    if i > length (s) then break;

                continuaPalavra:
                    while (i <= length (s)) and (s[i] in dicAlfabeto) do
                        begin
                            palavra := palavra + s[i];
                            i := i + 1;
                        end;

                    if (i < length (s)-1) and (s[i] in ['-', ''''])
                                          and (s[i+1] in dicAlfabeto) then
                        begin
                            palavra := palavra + s[i];
                            i := i + 1;
                            goto continuaPalavra;
                        end;

                    ok := procuraDic (palavra);
                    if not ok then //achou palavra errada sai posicionado depois dela
                        begin
                            posX := i;
                            posY := lin;
                            sintetiza (palavra);
                            exit;
                        end;

                    palavra := '';
                end;
            i := 1;
        end;
    Fala ('EDOK') {'Ok'}
end;


initialization
    dicCarregado := false;
    listaAlternativa := TStringList.Create;
    listaAlternativa.sorted := true;
    listaAlternativa.Duplicates := dupIgnore;
end.
