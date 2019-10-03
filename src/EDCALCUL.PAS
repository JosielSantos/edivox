{--------------------------------------------------------}
{
{    Efetuando cálculos
{
{    Autor: Marcelo Luis Pinheiro e Glauco Férius
{
{    Em 08/04/03, atualizado em 6/02/07
{
{--------------------------------------------------------}

Unit edCalcul;

interface
uses
    Math, DVcrt, DVWin, dvForm, sysUtils, Windows,
    edVars, edLinha, edMensag, edTela;

function converte (tecla: char; nomeConversao: string; numConversoes: integer): char;
procedure Calcula;
procedure conversaoInterativa;

{--------------------------------------------------------}

implementation

const
    CMD_CALCULADORA: set of char =
                ['+','-','*','/','\','%', '|', '@', '#', '$', '&',
                 'a','A','b','B','c','C','d','D','e','E','f','F','g','G',
                 'h','H','i','I','j','J','k','K','l','L','m','M','n','N',
                 'o','O','p','P','q','Q','r','R','s','S','t','T','u','U',
                 'v','V','w','W', 'x', 'X', 'y', 'Y', 'z', 'á', 'Á', 'é', 'É',
                 'í', 'Í', 'ó', 'Ó', 'ú'];

var Operador: char;

    {--------------------------------------------------------}

function converte (tecla: char; nomeConversao: string; numConversoes: integer): char;
var
    arq: file;
    i: integer;
    s: string;

begin
    if tecla = F1 then
        begin
            for i := 1 to numConversoes+1 do
                begin
                    gotoxy (1, 61+i);
                    textBackGround (BLUE); clreol;
                    str (i, s);
                    writeln (textoAjuda (nomeConversao + s));
                end;
            textBackground (BLACK);

            while keypressed do readkey;
            for i := 1 to numConversoes+1 do
                if not keypressed then
                    begin
                        str (i, s);
                        assign (arq, dirSomEdivox + '\' + nomeConversao + s + '.WAV');
                        {$I-}  reset (arq);  {$I+}
                        if ioresult <> 0 then
                            sintetiza (textoAjuda (nomeConversao + s))
                        else
                            begin
                                close (arq);
                                sintSom (nomeConversao + s);
                            end;
                    end;

            converte := upcase (readkey);
        end
    else
        begin
            gotoxy (1, 10);
            popupMenuCria (24, 10, 61, numConversoes-1, RED);

            for i := 2 to numConversoes do
                begin
                    str (i, s);
                    popupMenuAdiciona (nomeConversao + s, textoAjuda (nomeConversao + s));
                end;

            i := popupMenuSeleciona + 1;
            if i = 1 then
                converte := ESC
            else
                begin
                    str (i, s);
                    s := textoAjuda (nomeConversao + s);
                    while (s <> '') and (s[1] = ' ') do delete (s, 1, 1);
                    converte := s[1];
                end;
        end;
end;

{--------------------------------------------------------}

function limpaLinha (s: string): string;
var
    c: char;
    s1: string;

begin
         posx := length( texto [posy])+1;

    repeat
        posx := posx - 1;
        if posx < 1 then c := #0
                    else c := s[posx];
    until c <> ' ';

    repeat
        posx := posx - 1;
        if posx < 1 then c := #0
                    else c := s[posx];
    until not (c in ['0'..'9', '=', '.', ',', '(', ')'] + CMD_CALCULADORA);

    posx := posx - 1;

    if posx <= 0 then
            posx := 1;

    s1 := texto[posy];

    if c <> ' ' then
        delete (s, 1, posx-1)
    else
        delete (s, 1, posx);

    texto[posy] := s;

    limpaLinha := texto[posy];
    texto[posy] := s1;
end;

procedure Calcula;
Var
    c, salva: Char;
    numero, ParteDecimal, ParteDecimalPar, potencia, s, base: String;
    i, i1, k: integer;
    Valor, Valor1, ValorPar: Real;

{--------------------------------------------------------}

function PegaParcela(var Op1:Char):Real;
Var
    erro, i, i1, i3, k, x: Integer;
    numero, numero1, numero2, ParteDecimal, s: String;
    OperadorParcela: char;
    primeiraParcela, retorno, SegundaParcela: Real;

{--------------------------------------------------------}

function trataDivisaoNaParcela: boolean;
begin
    trataDivisaoNaParcela := false;

    if (primeiraParcela <> 0) and (numero2 = '0') then
        begin
            retorno := 1/0;
            exit;
        end;

    if (primeiraParcela = 0) and (numero2 = '0') then
        begin
            retorno := 0/0;
            exit;
        end;

    retorno := primeiraParcela / SegundaParcela;
    trataDivisaoNaParcela := true;
end;

{--------------------------------------------------------}

function trataPotenciaNaParcela: boolean;
var
    i2: Integer;

begin
    trataPotenciaNaParcela := false;

    if (pos (',', (numero2)) <> 0) or
       (pos ('-', (numero2)) <> 0) or
       (pos ('*', (numero2)) <> 0) or (pos ('_', (numero2)) <> 0) then
        begin
            fala ('EDOPRINV'); {'Operação inválida'}
            exit;
        end;

    if (primeiraParcela = 0) and (numero2 = '0') then
        begin
            retorno := 0/0;
            exit;
        end
    else
        retorno := 1;

    val (numero2, retorno, i2);
    retorno := (power (primeiraParcela, retorno));
    trataPotenciaNaParcela := true;
end;

{--------------------------------------------------------}

function trataTangenteNaParcela: boolean;
var
    i2: Integer;

begin
    trataTangenteNaParcela := false;

    if (pos (',', (numero2)) <> 0) or
       (pos ('-', (numero2)) <> 0) or
       (pos ('*', (numero2)) <> 0) or (pos ('_', (numero2)) <> 0) then
        begin
            fala ('EDOPRINV'); {'Operação inválida'}
            exit;
        end;

    val (numero2, retorno, i2);
    if (retorno = 90) or (retorno = 270) or
       (retorno = 450) or (retorno = 630) then
        begin
            retorno := 0/0;
            exit;
        end;

    val (numero2, retorno, i2);
    retorno := (Tan ((retorno) * PI / 180));
    trataTangenteNaParcela := true;
end;

{--------------------------------------------------------}

function trataSecanteNaParcela: boolean;
var
    i2: Integer;

begin
    trataSecanteNaParcela := false;

    if (pos (',', (numero2)) <> 0) or
       (pos ('-', (numero2)) <> 0) or
       (pos ('*', (numero2)) <> 0) or (pos ('_', (numero2)) <> 0) then
        begin
            fala ('EDOPRINV'); {'Operação inválida'}
            exit;
        end;

    val (numero2, retorno, i2);
    if (retorno = 90) or (retorno = 270) or
    (retorno = 450) or (retorno = 630) then
        begin
            retorno := 0/0;
            exit;
        end;

    val (numero2, retorno, i2);
    retorno := (Secant ((retorno) * PI / 180));
    trataSecanteNaParcela := true;
end;

{--------------------------------------------------------}

function trataCotangenteNaParcela: boolean;
var
    i2: Integer;

begin
    trataCotangenteNaParcela := false;

    if (pos (',', (numero2)) <> 0) or
       (pos ('-', (numero2)) <> 0) or
       (pos ('*', (numero2)) <> 0) or (pos ('_', (numero2)) <> 0) then
        begin
            fala ('EDOPRINV'); {'Operação inválida'}
            exit;
        end;

    val (numero2, retorno, i2);
    if (retorno = 0) or (retorno = 180) or
       (retorno = 360) or (retorno = 540) then
        begin
            retorno := 0/0;
            exit;
        end;

    val (numero2, retorno, i2);
    retorno := (Cotan ((retorno) * PI / 180));
    trataCotangenteNaParcela := true;
end;

{--------------------------------------------------------}

function trataCossecanteNaParcela: boolean;
var
    i2: Integer;

begin
    trataCossecanteNaParcela := false;

    if (pos (',', (numero2)) <> 0) or
       (pos ('-', (numero2)) <> 0) or
       (pos ('*', (numero2)) <> 0) or (pos ('_', (numero2)) <> 0) then
        begin
            fala ('EDOPRINV'); {'Operação inválida'}
            exit;
        end;

    val (numero2, retorno, i2);
    if (retorno = 0) or (retorno = 180) or
       (retorno = 360) or (retorno = 540) then
        begin
            retorno := 0/0;
            exit;
        end;

    val (numero2, retorno, i2);
    retorno := (Cosecant ((retorno) * PI / 180));
    trataCossecanteNaParcela := true;
end;

{--------------------------------------------------------}

function logaritmoBaseNnaparcela: boolean;
var
    i2: Integer;

begin
    logaritmoBaseNnaparcela := true;

    if (pos (',', (numero2)) <> 0) or
       (pos ('-', (numero2)) <> 0) or
       (pos ('*', (numero2)) <> 0) or (pos ('_', (numero2)) <> 0) then
        begin
            fala ('EDOPRINV'); {'Operação inválida'}
            exit;
        end;

    if (primeiraParcela = 0) or (numero2 = '0') then
        begin
        retorno := 0/0;
        exit;
        end;

    if (primeiraParcela <> 1) and (numero2 = '1') then
        begin
        retorno := 0/0;
        exit;
        end;

    if (primeiraParcela = 1) and (numero2 <> '0') then
        begin
        retorno := 0;
        exit;
        end;

    if (primeiraParcela = 1) or (numero2 = '0') then
        begin
        retorno := 0/0;
        exit;
        end;

    val (numero2, retorno, i2);
    retorno := (LogN (retorno, primeiraParcela));
    logaritmoBaseNnaparcela := true;
end;

{--------------------------------------------------------}

function logaritmoBaseEnaparcela: boolean;

begin
    logaritmoBaseEnaparcela := false;

    if (pos (',', (numero2)) <> 0) or
       (pos ('-', (numero2)) <> 0) or
       (pos ('*', (numero2)) <> 0) or (pos ('_', (numero2)) <> 0) then
        begin
                fala ('EDOPRINV'); {'Operação inválida'}
        end;

        if numero2 <> '' then
            begin
                fala ('EDOPRINV'); {'Operação inválida'}
            retorno := 0/0;
            exit;
            end;

        if primeiraParcela = 0 then
            begin
            retorno := 0/0;
            exit;
            end;

        if primeiraParcela = 1 then
            begin
            retorno := 0;
            exit;
            end;

    retorno := LnXP1 (primeiraParcela-1);
    logaritmoBaseEnaparcela := true;
end;

{--------------------------------------------------------}

function logaritmoBase10naparcela: boolean;

begin
    logaritmoBase10naparcela := false;

    if (pos (',', (numero2)) <> 0) or
       (pos ('-', (numero2)) <> 0) or
       (pos ('*', (numero2)) <> 0) or (pos ('_', (numero2)) <> 0) then
        begin
            fala ('EDOPRINV'); {'Operação inválida'}
            exit;
        end;

        if numero2 <> '' then
            begin
                fala ('EDOPRINV'); {'Operação inválida'}
                retorno := 0/0;
                exit;
            end;

        if primeiraParcela = 0 then
            begin
            retorno := 0/0;
            exit;
            end;

        if primeiraParcela = 1 then
            begin
            retorno := 0;
            exit;
            end;

    retorno := Log10 (primeiraParcela);
    logaritmoBase10naparcela := true;
end;

{--------------------------------------------------------}

function logaritmoBase2naparcela: boolean;

begin
    logaritmoBase2naparcela := false;
    if (pos (',', (numero2)) <> 0) or
       (pos ('-', (numero2)) <> 0) or
       (pos ('*', (numero2)) <> 0) or (pos ('_', (numero2)) <> 0) then
        begin
            fala ('EDOPRINV'); {'Operação inválida'}
            exit;
        end;

        if numero2 <> '' then
            begin
                fala ('EDOPRINV'); {'Operação inválida'}
                retorno := 0/0;
                exit;
            end;

        if primeiraParcela = 0 then
            begin
            retorno := 0/0;
            exit;
            end;

        if primeiraParcela = 1 then
            begin
            retorno := 0;
            exit;
            end;

    retorno := Log2 (primeiraParcela);
    logaritmoBase2naparcela := true;
end;

{--------------------------------------------------------}

Begin
    PegaParcela := 0;
    numero := LimpaLinha(texto[posy]); { Tira o que vem antes do número }

    if numero = '' then op1 := #0
                   else Op1 := Numero[Length(numero)];

    x := pos ('(', numero);
    If (x > 0) and (numero[x] = '(') Then {verifica se é subconta}
        begin
            numero1 := '';
            i:=x+1;

            while (i< succ(length(numero))) and(numero[i] in ['0'..'9', '.', ',']) do
            begin
                i3 := pos (',', numero1);
                if i3 <> 0 then
                    delete (numero1, i3,1);
                numero1:= numero1 + numero[i];
                inc(i);
            end;

            OperadorParcela := numero[i]; {pega o Operador da segunda conta}

            numero2 := ''; {pega o segundo argumento da subconta}

            if OperadorParcela = 'z' then
                begin
                    inc(i);
                    while (i< succ(length(numero))) and(numero[i] in ['0'..'9', '.', ',', '*', '-', '_']) do
                        begin
                            numero2:= numero2 + numero[i];
                            inc(i);
                        end;
                end
            else
                inc(i);

            while (i< succ(length(numero))) and(numero[i] in ['0'..'9', '.', ',']) do
                begin
                    i3 := pos (',', numero2);
                    if i3 <> 0 then
                        delete (numero2, i3,1);
                    numero2:= numero2 + numero[i];
                    inc(i);
                end;

            val(numero1, primeiraParcela, erro); {faz a conta e retorna à parcela}
            val(numero2, SegundaParcela, erro);

            case OperadorParcela of
                    '+': retorno := primeiraParcela + SegundaParcela;
                    '-': retorno := primeiraParcela - SegundaParcela;
                    '*': retorno := primeiraParcela * SegundaParcela;
                    '/' : if not trataDivisaoNaParcela then exit;
                    '%': retorno := primeiraParcela * SegundaParcela/100;
                    '\': retorno := sqrt (SegundaParcela);
                    '|' : if not trataPotenciaNaParcela then exit;
                    '&': retorno := sqr (SegundaParcela);
                    'a': retorno := (SegundaParcela) * 27225;
                    'A': retorno := (SegundaParcela) * 48400;
                    'b': retorno := (SegundaParcela) * 24200;
                    'B': retorno := (SegundaParcela) * 0.0328;
                    'c': retorno := (SegundaParcela) * 0.3937;
                    'C': retorno := (SegundaParcela) * 0.0011;
                    'd': retorno := (SegundaParcela) * 3785.4;
                    'D': retorno := (SegundaParcela) * 3.7853;
                    'e': retorno := (SegundaParcela) * 0.0022;
                    'E': retorno := (SegundaParcela) * 0.0353;
                    'f': retorno := (SegundaParcela) * 10000;
                    'F': retorno := (SegundaParcela) * 91.44;
                    'g': retorno := (SegundaParcela) * 0.9144;
                    'G': retorno := (SegundaParcela) * 0.8361;
                    'h': retorno := (SegundaParcela) * 453.5924;
                    'H': retorno := (SegundaParcela) * 0.4536;
                    'i': retorno := (SegundaParcela) * 1.0567;
                    'I': retorno := (SegundaParcela) * 1.0936;
                    'j': retorno := (SegundaParcela) * 3.2808;
                    'J': retorno := (SegundaParcela) * 39.37;
                    'k': retorno := (SegundaParcela) * 1.196;
                    'K': retorno := (SegundaParcela) * 10.7639;
                    'l': retorno := (SegundaParcela) * 1.667;
                    'L': retorno := (SegundaParcela) * 0.0547;
                    'm': retorno := (SegundaParcela) * 1.6093;
                    'M': retorno := (SegundaParcela) * 0.8684;
                    'n': retorno := (SegundaParcela) * 2.59;
                    'N': retorno := (SegundaParcela) * 0.447;
                    'o': retorno := (SegundaParcela) * 1.6093;
                    'O': retorno := (SegundaParcela) * 1.8532;
                    'p': retorno := (SegundaParcela) * 28.3495;
                    'P': retorno := (SegundaParcela) * 2.83495 / 100;
                    'q': retorno := (SegundaParcela) * 30.4801;
                    'Q': retorno := (SegundaParcela) * 0.507;
                    'r': retorno := (SegundaParcela) * 2.54;
                    'R': retorno := (SegundaParcela) * 0.833;
                    's': retorno := (SegundaParcela) * 0.946;
                    'S': retorno := (SegundaParcela) * 2.2046;
                    't': retorno := (SegundaParcela) * 0.6214;
                    'T': retorno := (SegundaParcela) * 3280.833;
                    'u': retorno := (SegundaParcela) * 1.19596096;
                    'U': retorno := (SegundaParcela) * 0.3861;
                    'v': retorno := (SegundaParcela) * 0.6214;
                    'V': retorno := (SegundaParcela) * 54.68;
                    'w': retorno := ((SegundaParcela) - 32) * 5 / 9;
                    'W': retorno := (SegundaParcela) * 1.8 + 32;
                    'x' : if not trataPotenciaNaParcela then exit;
                    'X', '@': retorno := (SegundaParcela) * 2 * PI;
                    'y', '#': retorno := (SegundaParcela) * (SegundaParcela) * PI;
                    'Y', '$': retorno := (SegundaParcela) * (SegundaParcela) * (SegundaParcela) * ((4/3) * PI);
                    'z' : if not logaritmoBaseNnaparcela then exit;
                    'á': retorno := (Sin ((SegundaParcela) * PI / 180));
                    'Á': retorno := (Cos ((SegundaParcela) * PI / 180));
                    'é' : if not trataTangenteNaParcela then exit;
                    'É' : if not trataCotangenteNaParcela then exit;
                    'í' : if not trataSecanteNaParcela then exit;
                    'Í' : if not trataCossecanteNaParcela then exit;
                    'ó' : if not logaritmoBaseEnaparcela then exit;
                    'Ó' : if not logaritmoBase10naparcela then exit;
                    'ú' : if not logaritmoBase2naparcela then exit;
            else {do case}
                    retorno := 0;
            end;{ do case}

            s := sintAmbiente ('EDIVOX', 'PARTEDECIMAL');

            if s = '' then
                begin
                    s := '2';
                    sintGravaAmbiente('EDIVOX', 'PARTEDECIMAL', s);
                end;

            val (s, i1, i);

            if i1 > 8 then
                begin
                    i1 := 8;
                    sintGravaAmbiente('EDIVOX', 'PARTEDECIMAL', '8');
                end;

            Str(retorno:0:i1, ParteDecimal);
            k := pos ('.00', ParteDecimal);
            if k <> 0 then
                delete (ParteDecimal, k,i1+1);

        end
    else
        begin
            i := 1;
            while i <= Length(numero) do    // não usar "for" aqui.
                begin
                    If Not (numero[i] in ['0'..'9', '.']) Then
                        Delete(numero, i, 1);
                    i := i + 1;
                end;
            If numero <> '' Then
                Val(numero, Retorno, erro)
            Else
                Retorno := 0;
        end;

    PegaParcela := Retorno;
End;

{--------------------------------------------------------}

function trataDivisao: boolean;

begin
    trataDivisao := false;
    if PegaParcela(Operador) <> 0 then
        Valor := Valor / PegaParcela(Operador)
    else
        begin
            if not (Operador in ['='] + CMD_CALCULADORA) then
                begin
                    fala ('EDERRLEI');
                    exit;
                end
            else
    if Valor = 0 then
    begin
            Valor := 0/0
    end
    else
    if Valor < 0 then
    begin
            Valor := -1/0
    end
    else
    begin
            Valor := 1/0
    end;
            end;

    trataDivisao := true;
end;

{--------------------------------------------------------}

function trataTangente: boolean;

begin
    trataTangente := false;
    if not ((PegaParcela(Operador) = 90) or (PegaParcela(Operador) = 270) or
    (PegaParcela(Operador) = 450) or (PegaParcela(Operador) = 630)) then
        Valor := (Tan ((PegaParcela(Operador)) * PI / 180))
    else
        begin
            if not (Operador in ['='] + CMD_CALCULADORA) then
                begin
                    fala ('EDERRLEI');
                    exit;
                end
            else
            Valor := 0/0;
        end;

    trataTangente := true;
end;

{--------------------------------------------------------}

function trataSecante: boolean;

begin
    trataSecante := false;
    if not ((PegaParcela(Operador) = 90) or (PegaParcela(Operador) = 270) or
    (PegaParcela(Operador) = 450) or (PegaParcela(Operador) = 630)) then
        Valor := (Secant ((PegaParcela(Operador)) * PI / 180))
    else
        begin
            if not (Operador in ['='] + CMD_CALCULADORA) then
                begin
                    fala ('EDERRLEI');
                    exit;
                end
            else
            Valor := 0/0;
        end;

    trataSecante := true;
end;

{--------------------------------------------------------}

function trataCotangente: boolean;

begin
    trataCotangente := false;
    if not ((PegaParcela(Operador) = 0) or (PegaParcela(Operador) = 180) or
    (PegaParcela(Operador) = 360) or (PegaParcela(Operador) = 540)) then
        Valor := (Cotan ((PegaParcela(Operador)) * PI / 180))
    else
        begin
            if not (Operador in ['='] + CMD_CALCULADORA) then
                begin
                    fala ('EDERRLEI');
                    exit;
                end
            else
            Valor := 0/0;
        end;

    trataCotangente := true;
end;

{--------------------------------------------------------}

function trataCossecante: boolean;

begin
    trataCossecante := false;
    if not ((PegaParcela(Operador) = 0) or (PegaParcela(Operador) = 180) or
    (PegaParcela(Operador) = 360) or (PegaParcela(Operador) = 540)) then
        Valor := (Cosecant ((PegaParcela(Operador)) * PI / 180))
    else
        begin
            if not (Operador in ['='] + CMD_CALCULADORA) then
                begin
                    fala ('EDERRLEI');
                    exit;
                end
            else
            Valor := 0/0;
        end;

    trataCossecante := true;
end;

{--------------------------------------------------------}

function trataPotenciaParcelas: boolean;
var
    i: integer;

label fim;
begin
    trataPotenciaParcelas := false;

    Str(PegaParcela(Operador):0: i1, ParteDecimal);
    k := pos ('.00', ParteDecimal);
    if k <> 0 then
        delete (ParteDecimal, k,i1+1);
    val (ParteDecimal, i, i1);

    numero := LimpaLinha(texto[posy]); { Tira o que vem antes do número }
    if (pos (',', (numero)) <> 0) or
       (pos ('-', (numero)) <> 0) or
       (pos ('*', (numero)) <> 0) or (pos ('_', (numero)) <> 0) then
        begin
                fala ('EDOPRINV'); {'Operação inválida'}
            exit;
        end;

    if (i = 0) and ((ParteDecimal) = '0') and (Valor = 0) then
        begin
            Valor := 0/0;
            goto fim;
        end;

    if (i = 0) and ((ParteDecimal) = '0') then
        Valor1 := Valor;
        begin
                      Valor := (power (Valor, PegaParcela(Operador)));
        end;
    fim:
    trataPotenciaParcelas := true;
end;

{--------------------------------------------------------}

function trataPotencia: boolean;

label fim;
     begin
          trataPotencia := false;
          fala ('EDINFPOT'); {'Qual a potência?'}
          c := sintEditaCampo (potencia, 20, wherey, 200, 80, true);
          writeln;

          if (potencia = '') or (c = ESC) then
              begin
                  fala ('EDDESIST');
                  posy := Posy - 1;
                  exit;
              end;

          if (pos (',', (potencia)) <> 0) or
             (pos ('-', (potencia)) <> 0) or (pos ('=', (potencia)) <> 0) or
             (pos ('*', (potencia)) <> 0) or (pos ('_', (potencia)) <> 0) then
              begin
                  fala ('EDDESIST');
                  posy := Posy - 1;
                  exit;
              end;

    if (potencia = '0') and ((PegaParcela(Operador)) = 0) then
    begin
        Valor := 0/0;
        goto fim;
    end;

    if (potencia) = '0' then
        ValorPar := PegaParcela(Operador)
    else
        begin
            val (potencia, Valor, i);
            Valor := (power (PegaParcela(Operador), Valor));
            ValorPar := PegaParcela(Operador);
        end;

fim:
    trataPotencia := true;
end;

{--------------------------------------------------------}

function trataLogaritmo: boolean;

label fim;
begin
    trataLogaritmo := false;
    fala ('EDINFBAS'); {'Qual a base logarítmica?'}
    c := sintEditaCampo (base, 20, wherey, 200, 80, true);
    writeln;

    if (base = '') or (c = ESC) then
        begin
            fala ('EDDESIST');
            posy := Posy - 1;
            exit;
        end;

    if (pos (',', (base)) <> 0) or
       (pos ('-', (base)) <> 0) or (pos ('=', (base)) <> 0) or
       (pos ('*', (base)) <> 0) or (pos ('_', (base)) <> 0) then
        begin
            fala ('EDDESIST');
            posy := Posy - 1;
            exit;
        end;

    if PegaParcela(Operador) = 0 then
    begin
        Valor := 0/0;
        goto fim;
    end;

    if (base = '1') and (PegaParcela(Operador) <> 1) then
    begin
        Valor := 0/0;
        goto fim;
    end;

    if base = '0' then
    begin
        Valor := 0/0;
        goto fim;
    end;

    if (base <> '0') and (PegaParcela(Operador) = 1) then
        goto fim;

    val (base, i1, i);
    if (i1 = 0) and ((base) <> '0') then
        begin
            fala ('EDDESIST');
            posy := Posy - 1;
            exit;
        end;

    val (base, Valor, i);
    Valor := (LogN (Valor, PegaParcela(Operador)));

fim:
    ValorPar := PegaParcela(Operador);
    trataLogaritmo := true;
end;

{--------------------------------------------------------}

function trataLogaritmoNeperiano: boolean;

label fim;
begin
//          trataLogaritmoNeperiano := false;
    if PegaParcela(Operador) = 0 then
    begin
        Valor := 0/0;
        goto fim;
    end;

    if PegaParcela(Operador) = 1 then
    begin
        Valor := 0;
        goto fim;
    end;

    Valor := (LnXP1 ((PegaParcela(Operador))-1)); ValorPar := PegaParcela(Operador);

fim:
    ValorPar := PegaParcela(Operador);
    trataLogaritmoNeperiano := true;
end;

{--------------------------------------------------------}

function trataLogaritmoBase10: boolean;

label fim;
begin
//          trataLogaritmoBase10 := false;
    if PegaParcela(Operador) = 0 then
    begin
        Valor := 0/0;
        goto fim;
    end;

    if PegaParcela(Operador) = 1 then
    begin
        Valor := 0;
        goto fim;
    end;

    Valor := (Log10 ((PegaParcela(Operador)))); ValorPar := PegaParcela(Operador);

fim:
    ValorPar := PegaParcela(Operador);
    trataLogaritmoBase10 := true;
end;

{--------------------------------------------------------}

function trataLogaritmoBase2: boolean;

label fim;
begin
//          trataLogaritmoBase2 := false;
    if PegaParcela(Operador) = 0 then
    begin
        Valor := 0/0;
        goto fim;
    end;

    if PegaParcela(Operador) = 1 then
    begin
        Valor := 0;
        goto fim;
    end;

    Valor := (Log2 ((PegaParcela(Operador)))); ValorPar := PegaParcela(Operador);

fim:
    ValorPar := PegaParcela(Operador);
    trataLogaritmoBase2 := true;
end;

{--------------------------------------------------------}

begin
    ValorPar := 0;
    if (posy > maxLinhas) or (texto[posy] = '') then
        begin
            fala ('EDERRLEI');
            exit;
        end;

    Valor := PegaParcela(Operador);
    salva := ' ';

    While Operador in CMD_CALCULADORA do
        begin
            posy := Posy + 1;

            if (posy > maxLinhas) or (texto[posy] = '') then
                begin
                    fala ('EDERRLEI');
                    exit;
                end;

            salva := Operador;
            case Operador Of
                '+': Valor := Valor + PegaParcela(Operador);
                '-': Valor := Valor - PegaParcela(Operador);
                '*': Valor := Valor * PegaParcela(Operador);
                '/' : if not trataDivisao then exit;
                '%': Valor := (Valor * PegaParcela(Operador))/100;
                '\' : Valor := sqrt (PegaParcela(Operador));
                '|' : if not trataPotenciaParcelas then exit;
                '&': Valor := sqr (PegaParcela(Operador));
                'a': begin Valor := (PegaParcela(Operador)) * 27225; ValorPar := PegaParcela(Operador); end;
                'A': begin Valor := (PegaParcela(Operador)) * 48400; ValorPar := PegaParcela(Operador); end;
                'b': begin Valor := (PegaParcela(Operador)) * 24200; ValorPar := PegaParcela(Operador); end;
                'B': begin Valor := (PegaParcela(Operador)) * 0.0328; ValorPar := PegaParcela(Operador); end;
                'c': begin Valor := (PegaParcela(Operador)) * 0.3937; ValorPar := PegaParcela(Operador); end;
                'C': begin Valor := (PegaParcela(Operador)) * 0.0011; ValorPar := PegaParcela(Operador); end;
                'd': begin Valor := (PegaParcela(Operador)) * 3785.4; ValorPar := PegaParcela(Operador); end;
                'D': begin Valor := (PegaParcela(Operador)) * 3.7853; ValorPar := PegaParcela(Operador); end;
                'e': begin Valor := (PegaParcela(Operador)) * 0.0022; ValorPar := PegaParcela(Operador); end;
                'E': begin Valor := (PegaParcela(Operador)) * 0.0353; ValorPar := PegaParcela(Operador); end;
                'f': begin Valor := (PegaParcela(Operador)) * 10000; ValorPar := PegaParcela(Operador); end;
                'F': begin Valor := (PegaParcela(Operador)) * 91.44; ValorPar := PegaParcela(Operador); end;
                'g': begin Valor := (PegaParcela(Operador)) * 0.9144; ValorPar := PegaParcela(Operador); end;
                'G': begin Valor := (PegaParcela(Operador)) * 0.8361; ValorPar := PegaParcela(Operador); end;
                'h': begin Valor := (PegaParcela(Operador)) * 453.5924; ValorPar := PegaParcela(Operador); end;
                'H': begin Valor := (PegaParcela(Operador)) * 0.4536; ValorPar := PegaParcela(Operador); end;
                'i': begin Valor := (PegaParcela(Operador)) * 1.0567; ValorPar := PegaParcela(Operador); end;
                'I': begin Valor := (PegaParcela(Operador)) * 1.0936; ValorPar := PegaParcela(Operador); end;
                'j': begin Valor := (PegaParcela(Operador)) * 3.2808; ValorPar := PegaParcela(Operador); end;
                'J': begin Valor := (PegaParcela(Operador)) * 39.37; ValorPar := PegaParcela(Operador); end;
                'k': begin Valor := (PegaParcela(Operador)) * 1.196; ValorPar := PegaParcela(Operador); end;
                'K': begin Valor := (PegaParcela(Operador)) * 10.7639; ValorPar := PegaParcela(Operador); end;
                'l': begin Valor := (PegaParcela(Operador)) * 1.667; ValorPar := PegaParcela(Operador); end;
                'L': begin Valor := (PegaParcela(Operador)) * 0.0547; ValorPar := PegaParcela(Operador); end;
                'm': begin Valor := (PegaParcela(Operador)) * 1.6093; ValorPar := PegaParcela(Operador); end;
                'M': begin Valor := (PegaParcela(Operador)) * 0.8684; ValorPar := PegaParcela(Operador); end;
                'n': begin Valor := (PegaParcela(Operador)) * 2.59; ValorPar := PegaParcela(Operador); end;
                'N': begin Valor := (PegaParcela(Operador)) * 0.447; ValorPar := PegaParcela(Operador); end;
                'o': begin Valor := (PegaParcela(Operador)) * 1.6093; ValorPar := PegaParcela(Operador); end;
                'O': begin Valor := (PegaParcela(Operador)) * 1.8532; ValorPar := PegaParcela(Operador); end;
                'p': begin Valor := (PegaParcela(Operador)) * 28.3495; ValorPar := PegaParcela(Operador); end;
                'P': begin Valor := (PegaParcela(Operador)) * 2.83495 / 100; ValorPar := PegaParcela(Operador); end;
                'q': begin Valor := (PegaParcela(Operador)) * 30.4801; ValorPar := PegaParcela(Operador); end;
                'Q': begin Valor := (PegaParcela(Operador)) * 0.507; ValorPar := PegaParcela(Operador); end;
                'r': begin Valor := (PegaParcela(Operador)) * 2.54; ValorPar := PegaParcela(Operador); end;
                'R': begin Valor := (PegaParcela(Operador)) * 0.833; ValorPar := PegaParcela(Operador); end;
                's': begin Valor := (PegaParcela(Operador)) * 0.946; ValorPar := PegaParcela(Operador); end;
                'S': begin Valor := (PegaParcela(Operador)) * 2.2046; ValorPar := PegaParcela(Operador); end;
                't': begin Valor := (PegaParcela(Operador)) * 0.6214; ValorPar := PegaParcela(Operador); end;
                'T': begin Valor := (PegaParcela(Operador)) * 3280.833; ValorPar := PegaParcela(Operador); end;
                'u': begin Valor := (PegaParcela(Operador)) * 1.19596096; ValorPar := PegaParcela(Operador); end;
                'U': begin Valor := (PegaParcela(Operador)) * 0.3861; ValorPar := PegaParcela(Operador); end;
                'v': begin Valor := (PegaParcela(Operador)) * 0.6214; ValorPar := PegaParcela(Operador); end;
                'V': begin Valor := (PegaParcela(Operador)) * 54.68; ValorPar := PegaParcela(Operador); end;
                'w': begin Valor := ((PegaParcela(Operador)) - 32) * 5 / 9; ValorPar := PegaParcela(Operador); end;
                'W': begin Valor := (PegaParcela(Operador)) * 1.8 + 32; ValorPar := PegaParcela(Operador); end;
                'x' : if not trataPotencia then exit;
                'X', '@': begin Valor := (PegaParcela(Operador)) * 2 * PI; ValorPar := PegaParcela(Operador); end;
                'y', '#': begin Valor := (PegaParcela(Operador)) * (PegaParcela(Operador)) * (PI); ValorPar := PegaParcela(Operador); end;
                'Y', '$': begin Valor := (PegaParcela(Operador)) * (PegaParcela(Operador)) * (PegaParcela(Operador)) * (4/3) * PI; ValorPar := PegaParcela(Operador); end;
                'z' : if not trataLogaritmo then exit;
                'á': begin Valor := (Sin ((PegaParcela(Operador)) * PI / 180)); ValorPar := PegaParcela(Operador); end;
                'Á': begin Valor := (Cos ((PegaParcela(Operador)) * PI / 180)); ValorPar := PegaParcela(Operador); end;
                'é' : begin if not trataTangente then exit; ValorPar := PegaParcela(Operador); end;
                'É' : begin if not trataCotangente then exit; ValorPar := PegaParcela(Operador); end;
                'í' : begin if not trataSecante then exit; ValorPar := PegaParcela(Operador); end;
                'Í' : begin if not trataCossecante then exit; ValorPar := PegaParcela(Operador); end;
                'ó' : if not trataLogaritmoNeperiano then exit;
                'Ó' : if not trataLogaritmoBase10 then exit;
                'ú' : if not trataLogaritmoBase2 then exit;
                End;
        end;

    if not (Operador in ['='] + CMD_CALCULADORA) then
        begin
            fala ('EDERRLEI');
            exit;
        end;

    s := sintAmbiente ('EDIVOX', 'PARTEDECIMAL');

    if s = '' then
        begin
            s := '2';
            sintGravaAmbiente('EDIVOX', 'PARTEDECIMAL', s);
        end;

    val (s, i1, i);

    if i1 > 8 then
        begin
            i1 := 8;
            sintGravaAmbiente('EDIVOX', 'PARTEDECIMAL', '8');
        end;

    Str(Valor:0:i1, ParteDecimal);
    k := pos ('.00', ParteDecimal);
    if k <> 0 then
        delete (ParteDecimal, k,i1+1);

    Str(ValorPar:0:i1, ParteDecimalPar);
    k := pos ('.00', ParteDecimalPar);
    if k <> 0 then
        delete (ParteDecimalPar, k,i1+1);

    posy := posy+1;

        if ParteDecimal = 'Nan' then
        ParteDecimal := 'Indeterminado ou inexistente';

        if ParteDecimal = '+Inf' then
        ParteDecimal := 'Infinito positivo';

        if ParteDecimal = '-Inf' then
        ParteDecimal := 'Infinito negativo';

    Operador := salva;
    if Operador in ['@', '#', '$', 'a'..'z', 'A'..'Z', 'á', 'Á', 'é', 'É', 'í', 'Í', 'ó', 'Ó', 'ú'] then
    begin
        case Operador of
           '@':  InsereLinha('A circunferência com ' + ParteDecimalPar + ' unidades de raio tem ' + ParteDecimal + ' unidades de comprimento', False);
           '#':  InsereLinha('O círculo com ' + ParteDecimalPar + ' unidades de raio tem ' + ParteDecimal + ' unidades ao quadrado de área', False);
           '$':  InsereLinha('A esfera com ' + ParteDecimalPar + ' unidades de raio tem ' + ParteDecimal + ' unidades cúbicas de volume', False);
           'a':  InsereLinha(ParteDecimalPar + ' alqueires do norte equivalem a ' + ParteDecimal + ' metros quadrados', False);
           'A':  InsereLinha(ParteDecimalPar + ' alqueires mineiros equivalem a ' + ParteDecimal + ' metros quadrados', False);
           'b':  InsereLinha(ParteDecimalPar + ' alqueires paulistas equivalem a ' + ParteDecimal + ' metros quadrados', False);
           'B':  InsereLinha(ParteDecimalPar + ' centímetros equivalem a ' + ParteDecimal + ' pés', False);
           'c':  InsereLinha(ParteDecimalPar + ' centímetros equivalem a ' + ParteDecimal + '  polegadas', False);
           'C':  InsereLinha(ParteDecimalPar + ' centímetros quadrados equivalem a ' + ParteDecimal + ' pés quadrados', False);
           'd':  InsereLinha(ParteDecimalPar + ' galões equivalem a ' + ParteDecimal + ' centímetros cúbicos', False);
           'D':  InsereLinha(ParteDecimalPar + ' galões equivalem a ' + ParteDecimal + ' litros', False);
           'e':  InsereLinha(ParteDecimalPar + ' gramas equivalem a ' + ParteDecimal + ' libras', False);
           'E':  InsereLinha(ParteDecimalPar + ' gramas equivalem a ' + ParteDecimal + ' onças', False);
           'f':  InsereLinha(ParteDecimalPar + ' hectares equivalem a ' + ParteDecimal + ' metros quadrados', False);
           'F':  InsereLinha(ParteDecimalPar + ' jardas equivalem a ' + ParteDecimal + ' centímetros', False);
           'g':  InsereLinha(ParteDecimalPar + ' jardas equivalem a ' + ParteDecimal + ' metros', False);
           'G':  InsereLinha(ParteDecimalPar + ' jardas quadradas equivalem a ' + ParteDecimal + ' metros quadrados', False);
           'h':  InsereLinha(ParteDecimalPar + ' libras equivalem a ' + ParteDecimal + ' gramas', False);
           'H':  InsereLinha(ParteDecimalPar + ' libras equivalem a ' + ParteDecimal + ' quilogramas', False);
           'i':  InsereLinha(ParteDecimalPar + ' litros equivalem a ' + ParteDecimal + ' quartos', False);
           'I':  InsereLinha(ParteDecimalPar + ' metros equivalem a ' + ParteDecimal + ' jardas', False);
           'j':  InsereLinha(ParteDecimalPar + ' metros equivalem a ' + ParteDecimal + ' pés', False);
           'J':  InsereLinha(ParteDecimalPar + ' metros equivalem a ' + ParteDecimal + ' polegadas', False);
           'k':  InsereLinha(ParteDecimalPar + ' metros quadrados equivalem a ' + ParteDecimal + ' jardas quadradas', False);
           'K':  InsereLinha(ParteDecimalPar + ' metros quadrados equivalem a ' + ParteDecimal + ' pés quadrados', False);
           'l':  InsereLinha(ParteDecimalPar + ' metros por minuto equivalem a ' + ParteDecimal + ' centímetros por segundo', False);
           'L':  InsereLinha(ParteDecimalPar + ' metros por minuto equivalem a ' + ParteDecimal + ' pés por segundo', False);
           'm':  InsereLinha(ParteDecimalPar + ' milhas equivalem a ' + ParteDecimal + ' quilômetros', False);
           'M':  InsereLinha(ParteDecimalPar + ' milhas equivalem a ' + ParteDecimal + ' nós', False);
           'n':  InsereLinha(ParteDecimalPar + ' milhas quadradas equivalem a ' + ParteDecimal + ' quilômetros quadrados', False);
           'N':  InsereLinha(ParteDecimalPar + ' milhas por hora equivalem a ' + ParteDecimal + ' metros por segundo', False);
           'o':  InsereLinha(ParteDecimalPar + ' milhas por hora equivalem a ' + ParteDecimal + ' quilômetros por hora', False);
           'O':  InsereLinha(ParteDecimalPar + ' nós equivalem a ' + ParteDecimal + ' quilômetros por hora', False);
           'p':  InsereLinha(ParteDecimalPar + ' onças equivalem a ' + ParteDecimal + ' gramas', False);
           'P':  InsereLinha(ParteDecimalPar + ' onças equivalem a ' + ParteDecimal + ' quilogramas', False);
           'q':  InsereLinha(ParteDecimalPar + ' pés equivalem a ' + ParteDecimal + ' centímetros', False);
           'Q':  InsereLinha(ParteDecimalPar + ' pés por minuto equivalem a ' + ParteDecimal + ' centímetros por segundo', False);
           'r':  InsereLinha(ParteDecimalPar + ' polegadas equivalem a ' + ParteDecimal + ' centímetros', False);
           'R':  InsereLinha(ParteDecimalPar + ' polegadas equivalem a ' + ParteDecimal + ' pés', False);
           's':  InsereLinha(ParteDecimalPar + ' quartos equivalem a ' + ParteDecimal + ' litros', False);
           'S':  InsereLinha(ParteDecimalPar + ' quilogramas equivalem a ' + ParteDecimal + ' libras', False);
           't':  InsereLinha(ParteDecimalPar + ' quilômetros equivalem a ' + ParteDecimal + ' milhas', False);
           'T':  InsereLinha(ParteDecimalPar + ' quilômetros equivalem a ' + ParteDecimal + ' pés', False);
           'u':  InsereLinha(ParteDecimalPar + ' quilômetros quadrados equivalem a ' + ParteDecimal + ' jardas quadradas', False);
           'U':  InsereLinha(ParteDecimalPar + ' quilômetros quadrados equivalem a ' + ParteDecimal + ' milhas quadradas', False);
           'v':  InsereLinha(ParteDecimalPar + ' quilômetros por hora equivalem a ' + ParteDecimal + ' milhas por hora', False);
           'V':  InsereLinha(ParteDecimalPar + ' quilômetros por hora equivalem a ' + ParteDecimal + ' pés por minuto', False);
           'w':  InsereLinha(ParteDecimalPar + ' graus Fahrenheit equivalem a ' + ParteDecimal + ' graus Celsius', False);
           'W':  InsereLinha(ParteDecimalPar + ' graus Celsius equivalem a ' + ParteDecimal + ' graus Fahrenheit', False);
           'x':  InsereLinha(ParteDecimalPar + ' elevado a ' + (potencia) + ' = ' + ParteDecimal, False);
           'X':  InsereLinha('A circunferência com ' + ParteDecimalPar + ' unidades de raio tem ' + ParteDecimal + ' unidades de comprimento', False);
           'y':  InsereLinha('O círculo com ' + ParteDecimalPar + ' unidades de raio tem ' + ParteDecimal + ' unidades ao quadrado de área', False);
           'Y':  InsereLinha('A esfera com ' + ParteDecimalPar + ' unidades de raio tem ' + ParteDecimal + ' unidades cúbicas de volume', False);
           'z':  InsereLinha('Logaritmo de ' + ParteDecimalPar + ' na base ' + (base) + ' = ' + ParteDecimal, False);
           'á':  InsereLinha('Seno de ' + ParteDecimalPar + '° = ' + ParteDecimal, false);
           'Á':  InsereLinha('Cosseno de ' + ParteDecimalPar + '° = ' + ParteDecimal, false);
           'é':  InsereLinha('Tangente de ' + ParteDecimalPar + '° = ' + ParteDecimal, false);
           'É':  InsereLinha('Cotangente de ' + ParteDecimalPar + '° = ' + ParteDecimal, false);
           'í':  InsereLinha('Secante de ' + ParteDecimalPar + '° = ' + ParteDecimal, false);
           'Í':  InsereLinha('Cossecante de ' + ParteDecimalPar + '° = ' + ParteDecimal, false);
           'ó':  InsereLinha('Logaritmo Neperiano de ' + ParteDecimalPar + ' = ' + ParteDecimal, false);
           'Ó':  InsereLinha('Logaritmo de ' + ParteDecimalPar + ' na base 10 = ' + ParteDecimal, false);
           'ú':  InsereLinha('Logaritmo de ' + ParteDecimalPar + ' na base 2 = ' + ParteDecimal, false);
        end;
    end;


    if not (Operador in ['@', '#', '$', 'a'..'z', 'A'..'Z', 'á', 'Á', 'é', 'É', 'í', 'Í', 'ó', 'Ó', 'ú']) then
        InsereLinha('Total: ' + ParteDecimal, False);
    posx := 1;
    escreveTela;
    sintetiza (texto[posy]);
end;

{--------------------------------------------------------}

procedure conversaoInterativa;
var
    tecla: char;

label deNovo;
begin
    fala ('EDCONVER');   {'Conversão interativa. Use setas ou tecle F1 para ajuda.'}

    tecla := sintReadKey;

deNovo:
    escreveTela;

    case tecla of

        'a':  begin InsereLinha('a', False); calcula; end;
        'A':  begin InsereLinha('A', False); calcula; end;
        'b':  begin InsereLinha('b', False); calcula; end;
        'B':  begin InsereLinha('B', False); calcula; end;
        'c':  begin InsereLinha('c', False); calcula; end;
        'C':  begin InsereLinha('C', False); calcula; end;
        'd':  begin InsereLinha('d', False); calcula; end;
        'D':  begin InsereLinha('D', False); calcula; end;
        'e':  begin InsereLinha('e', False); calcula; end;
        'E':  begin InsereLinha('E', False); calcula; end;
        'f':  begin InsereLinha('f', False); calcula; end;
        'F':  begin InsereLinha('F', False); calcula; end;
        'g':  begin InsereLinha('g', False); calcula; end;
        'G':  begin InsereLinha('G', False); calcula; end;
        'h':  begin InsereLinha('h', False); calcula; end;
        'H':  begin InsereLinha('H', False); calcula; end;
        'i':  begin InsereLinha('i', False); calcula; end;
        'I':  begin InsereLinha('I', False); calcula; end;
        'j':  begin InsereLinha('j', False); calcula; end;
        'J':  begin InsereLinha('J', False); calcula; end;
        'k':  begin InsereLinha('k', False); calcula; end;
        'K':  begin InsereLinha('K', False); calcula; end;
        'l':  begin InsereLinha('l', False); calcula; end;
        'L':  begin InsereLinha('L', False); calcula; end;
        'm':  begin InsereLinha('m', False); calcula; end;
        'M':  begin InsereLinha('M', False); calcula; end;
        'n':  begin InsereLinha('n', False); calcula; end;
        'N':  begin InsereLinha('N', False); calcula; end;
        'o':  begin InsereLinha('o', False); calcula; end;
        'O':  begin InsereLinha('O', False); calcula; end;
        'p':  begin InsereLinha('p', False); calcula; end;
        'P':  begin InsereLinha('P', False); calcula; end;
        'q':  begin InsereLinha('q', False); calcula; end;
        'Q':  begin InsereLinha('Q', False); calcula; end;
        'r':  begin InsereLinha('r', False); calcula; end;
        'R':  begin InsereLinha('R', False); calcula; end;
        's':  begin InsereLinha('s', False); calcula; end;
        'S':  begin InsereLinha('S', False); calcula; end;
        't':  begin InsereLinha('t', False); calcula; end;
        'T':  begin InsereLinha('T', False); calcula; end;
        'u':  begin InsereLinha('u', False); calcula; end;
        'U':  begin InsereLinha('U', False); calcula; end;
        'v':  begin InsereLinha('v', False); calcula; end;
        'V':  begin InsereLinha('V', False); calcula; end;
        'w':  begin InsereLinha('w', False); calcula; end;
        'W':  begin InsereLinha('W', False); calcula; end;
        'x':  begin InsereLinha('x', False); calcula; end;
        'X':  begin InsereLinha('@', False); calcula; end;
        'y':  begin InsereLinha('#', False); calcula; end;
        'Y':  begin InsereLinha('$', False); calcula; end;
        'z':  begin InsereLinha('z', False); calcula; end;
        'á':  begin InsereLinha('á', False); calcula; end;
        'Á':  begin InsereLinha('Á', False); calcula; end;
        'é':  begin InsereLinha('é', False); calcula; end;
        'É':  begin InsereLinha('É', False); calcula; end;
        'í':  begin InsereLinha('í', False); calcula; end;
        'Í':  begin InsereLinha('Í', False); calcula; end;
        'ó':  begin InsereLinha('ó', False); calcula; end;
        'Ó':  begin InsereLinha('Ó', False); calcula; end;
        'ú':  begin InsereLinha('ú', False); calcula; end;

       #$0: begin
                tecla := converte (readkey, 'EDAJCV', 61);
                goto deNovo;
            end;
      #$1b: begin
                fala ('EDDESIST');
                exit;
            end
    else
        sintBip;
        exit;
    end;

    if (texto[posy]) = '' then
        begin
            posy := Posy - 1;
            removeLinha (false);
            escreveTela;
            exit;
        end;

    escreveTela;
end;

end.
