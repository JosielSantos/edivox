{ rotinas de tratamento de funcoes do editor }
{ Autores: Marcelo Luis Pinheiro }
{ Orientador Academico: Jose' Antonio Borges }
{ Em 10/12/93 }

Unit edcadeia ;

interface
uses
    crt, dos,
    Edivars, Ediarq, edisom, SintVox, edifun;

Procedure operacadeias;
Procedure apagapalavra;
Procedure voltapalavra;
Procedure Pulapalavra;

implementation

VAR  cadeia : String;
    cont : integer;

{-----------------------------}

{----------Funcoes de Avanco na linha----------}

Procedure PulaPalavra;
Begin
    if posx > length (texto[posy]^) then
        exit;
    while texto [posy]^[posx]=' ' Do
          inc ( posx );
    while  ( posx < length ( texto [posy ]^)+1 ) and (texto [ posy ]^ [ posx] <> ' ' )  Do
        inc ( posx );
    sintclek;
end;

{-----------------------------}

Procedure voltaPalavra;
Begin
    while texto[posy]^[posx] =' '  Do
          dec ( posx );
    while  ( posx > 1 ) and (texto [ posy ]^ [ posx] <> ' ' )  Do
          dec ( posx );
    sintclek;
end;

{-----------------------------}

Procedure Apagapalavra;
Var
   i, j : Integer;
Begin
    If (posx > length(texto[posy]^)) or (texto[posy]^[posx] = ' ') then exit;
    While (posx <= length(texto[posy]^))and (texto[posy]^[posx] in letras) Do
        delete ( texto[posy]^, posx, 1);
    dec(posx);
    While (posx >0) and (texto[posy]^[posx]<>' ')  Do
        begin
        delete ( texto[posy]^, posx, 1);
        dec (posx);
        end;
    If posx = 0  then inc(posx)
      else delete ( texto[posy]^, posx, 1);
    sintclek;
end;

{----------}

Procedure procuraCadeia;
Var
   i, j : integer;
Begin
    i:=posy;
    repeat inc ( i);
        j:=pos ( cadeia, maiuscAnsi ( texto [i]^))
    Until (i > maxlinhas) or (j<>0);
    If i > maxlinhas  Then
        sintbip
            {fala nao achei esta cadeia }
    Else begin
                posy := i;
                posx := j;
                {fala achei a cadeia }
                sintbip;
                sintbip;
         end;
end;

{---------------------------------}

Procedure trocaCadeia ;
Label  volta;
Var
   novacadeia : String;
    i, j : integer;
Begin
    {fala digite a cadeia nova }
    sintbip;
    If not peganomes ( novaCadeia)  Then exit;
    i:= posy;
    volta : Repeat
            inc ( i);
            j:= pos ( cadeia, maiuscAnsi( texto [posy]^))
        Until (i>maxlinhas)or (j<>0);
    If i>maxlinhas  Then {fala nao achei cadeia para trocar }
            begin sintbip; exit; end
        Else begin
            If ((j=1) or (texto[i]^[j-1]=' ')) and (texto[i]^[j+1+length(cadeia)]in [';',':',',','.',
    '>','<','''','^','(',')',']','[',' ','+','-','/','*','?','!','='] ) Then
                begin
                apagapalavra;
                For cont :=1 to length(novacadeia)  Do
                    insertchar ( novacadeia [cont]);
                end
            else goto volta;

            end;
    { fala troquei uma cadeia }
    sintbip;
    sintbip;
end;

{-----------------------------------}

Procedure OperaCadeias;
Var
   Opcao : Char;
Begin
    {fala ( 'edcomcad', 0 );}
    If cadeia =''  Then
        Begin
        sintbip;
        {fala (digite a cadeia )}
        If Not peganomes (cadeia) Then begin
                {fala ( cadeia invalida )};
                exit;
                end;
        end
        Else begin
            repeat {fala (deseja trocar cadeia )}
            opcao := readkey
            until opcao in ['n','s', 'N','S'];
            sintbip;
            If upcase (opcao)='S' Then
                    if peganomes (cadeia)=false then exit;
            end;

    For cont := 1 to length ( cadeia)  Do
        cadeia [cont]:= upcase ( cadeia[cont]);
    {fala ( tecle sua opcao )}
    opcao :=readkey;
    Case opcao Of
        'p', 'P' : procuraCadeia;
        't', 'T' : TrocaCadeia;
        #27 : begin
                  fala ('EDDESIST');
                  exit;
              end
        Else sintbip;
    end;
end;

end.
