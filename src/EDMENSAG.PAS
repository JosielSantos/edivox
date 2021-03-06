{--------------------------------------------------------}
{
{    Controle da Fala
{
{    Autor: Marcelo Luis Pinheiro
{
{    Orientador Academico: Jose' Antonio Borges
{
{    Em 10/12/93
{
{--------------------------------------------------------}

Unit edMensag;

interface
uses
    DVcrt, DVWin,
    edvars;

function textoAjuda (f: string): string;
function txtmsg (f: string): string;
Procedure FalaSeguinte (f: String);
Procedure Fala (f: String);
function leTeclaMaiusc: char;

{--------------------------------------------------------}

implementation

function textoAjuda (f: string): string;
begin
    if f = 'EDAJIN1' then textoAjuda := 'Sao os seguintes:'
    else
    if f = 'EDAJIN2' then textoAjuda := '  C - comandos de cursor'
    else
    if f = 'EDAJIN3' then textoAjuda := '  L - linha'
    else
    if f = 'EDAJIN4' then textoAjuda := '  P - procura de textos'
    else
    if f = 'EDAJIN5' then textoAjuda := '  M - margem'
    else
    if f = 'EDAJIN6' then textoAjuda := '  A - arquivos'
    else
    if f = 'EDAJIN7' then textoAjuda := '  B - blocos de linhas'
    else
    if f = 'EDAJIN8' then textoAjuda := '  F - acionamento da fala'
    else
    if f = 'EDAJIN9' then textoAjuda := '  I - instalacao'
    else
    if f = 'EDAJIN10' then textoAjuda := '  E - letras especiais'
    else
    if f = 'EDAJIN11' then textoAjuda := '  W - tratamento Word'
    else

    if f = 'EDAJFW1' then textoAjuda := 'Os comandos de tratamento Word s�o'
    else
    if f = 'EDAJFW2' then textoAjuda := '  F - insere marcas de formata��o'
    else
    if f = 'EDAJFW3' then textoAjuda := '  I - informa formata��o no cursor'
    else
    if f = 'EDAJFW4' then textoAjuda := '  G - gera arquivo DOC'
    else
    if f = 'EDAJFW5' then textoAjuda := '  O - Ocultar formata��o na tela'
    else
    if f = 'EDAJFW6' then textoAjuda := '  M - modos de falar formata��o'
    else

    if f = 'EDAJLI1' then textoAjuda := 'Os comandos de linha sao:'
    else
    if f = 'EDAJLI2' then textoAjuda := '  I - insere uma linha acima'
    else
    if f = 'EDAJLI3' then textoAjuda := '  A - insere uma linha abaixo'
    else
    if f = 'EDAJLI4' then textoAjuda := '  R - remove linha'
    else
    if f = 'EDAJLI5' then textoAjuda := '  V - volta linha removida'
    else
    if f = 'EDAJLI6' then textoAjuda := '  Q - quebra linha em duas'
    else
    if f = 'EDAJLI7' then textoAjuda := '  J - junta duas linhas'
    else
    if f = 'EDAJLI8' then textoAjuda := '  E - exclui linhas com o texto'
    else
    if f = 'EDAJLI9' then textoAjuda := '  S - insere no in�cio da linha'
    else
    if f = 'EDAJLI10' then textoAjuda := '  D - insere no fim da linha'

    else

    if f = 'EDAJCU1' then textoAjuda := 'Os comandos de cursor sao:'
    else
    if f = 'EDAJCU2' then textoAjuda := '  - - inicio do texto'
    else
    if f = 'EDAJCU3' then textoAjuda := '  + - fim do texto'
    else
    if f = 'EDAJCU4' then textoAjuda := '  A - avan�a paragrafo'
    else
    if f = 'EDAJCU5' then textoAjuda := '  R - recua paragrafo'
    else
    if f = 'EDAJCU6' then textoAjuda := '  P - posiciona em certa linha'
    else
    if f = 'EDAJCU7' then textoAjuda := '  I - apaga inicio da linha'
    else
    if f = 'EDAJCU8' then textoAjuda := '  F - apaga fim da linha'
    else
    if f = 'EDAJCU9' then textoAjuda := '  L - informa linha'
    else
    if f = 'EDAJCU10' then textoAjuda := '  C - informa coluna'
    else
    if f = 'EDAJCU11' then textoAjuda := '  M - memoriza posi��o do cursor'
    else
    if f = 'EDAJCU12' then textoAjuda := '  V - volta cursor � posi��o memorizada'
    else
    if f = 'EDAJCU13' then textoAjuda := '  N - avan�a para linha em branco'
    else
    if f = 'EDAJCU14' then textoAjuda := '  E - recua para linha em branco'
    else

    if f = 'EDAJBL1' then textoAjuda := 'Os comandos de bloco sao:'
    else
    if f = 'EDAJBL2' then textoAjuda := '  I - inicio do bloco'
    else
    if f = 'EDAJBL3' then textoAjuda := '  F - fim do bloco'
    else
    if f = 'EDAJBL4' then textoAjuda := '  M - move o bloco'
    else
    if f = 'EDAJBL5' then textoAjuda := '  C - copia o bloco'
    else
    if f = 'EDAJBL6' then textoAjuda := '  A - adiciona bloco a um arquivo'
    else
    if f = 'EDAJBL7' then textoAjuda := '  O - ordena o bloco'
    else
    if f = 'EDAJBL8' then textoAjuda := '  R - remove o bloco'
    else
    if f = 'EDAJBL9' then textoAjuda := '  D - desmarca o bloco'
    else
    if f = 'EDAJBL10' then textoAjuda := '  L - le arquivo gerando bloco'
    else
    if f = 'EDAJBL11' then textoAjuda := '  G - grava o bloco em arquivo'
    else
    if f = 'EDAJBL12' then textoAjuda := '  E - embeleza o bloco'
    else
    if f = 'EDAJBL13' then textoAjuda := '  P - paragrafo vira bloco'
    else
    if f = 'EDAJBL14' then textoAjuda := '  J - justifica paragrafo do cursor'
    else
////    if f = 'EDAJBL15' then textoAjuda := '  S - envia para servidor de fala'
    if f = 'EDAJBL15' then textoAjuda := '  S - linha vira bloco'
    else
    if f = 'EDAJBL16' then textoAjuda := '  V - verifica��o ortogr�fica'
    else
    if f = 'EDAJBL17' then textoAjuda := '  X - decodifica��o'
    else
    if f = 'EDAJBL18' then textoAjuda := '  U - converter bloco'
    else
    if f = 'EDAJBL19' then textoAjuda := '  B - remover linhas em branco'
    else
    if f = 'EDAJBL20' then textoAjuda := '  W - transfer�ncia no formato do Word'
    else
    if f = 'EDAJBL21' then textoAjuda := '  T - seleciona Todo o texto'
    else
    if f = 'EDAJBL22' then textoAjuda := '  Ctrl + B - remover linhas em branco deixando uma'
    else

    if f = 'EDAJMA1' then textoAjuda := 'Os comandos de margem sao:'
    else
    if f = 'EDAJMA2' then textoAjuda := '  M - informa margens'
    else
    if f = 'EDAJMA3' then textoAjuda := '  T - nova coluna de tabulacao'
    else
    if f = 'EDAJMA4' then textoAjuda := '  R - remove todas tabulacoes'
    else

    if f = 'EDAJAR1' then textoAjuda := 'Os comandos de arquivos sao:'
    else
    if f = 'EDAJAR2' then textoAjuda := '  I - informa nome do arquivo'
    else
    if f = 'EDAJAR3' then textoAjuda := '  S - salva arquivo e continua'
    else
    if f = 'EDAJAR4' then textoAjuda := '  N - edita um novo arquivo'
    else
    if f = 'EDAJAR5' then textoAjuda := '  C - salva como outro arquivo'
    else
    if f = 'EDAJAR6' then textoAjuda := '  F - salva e fim'
    else
    if f = 'EDAJAR7' then textoAjuda := '  A - abandona sem gravar'
    else
    if f = 'EDAJAR8' then textoAjuda := '  X - exporta formato IBM'
    else

    if f = 'EDAJBU1' then textoAjuda := 'Os comandos de busca sao:'
    else
    if f = 'EDAJBU2' then textoAjuda := '  P - procura texto'
    else
    if f = 'EDAJBU3' then textoAjuda := '  N - busca de novo'
    else
    if f = 'EDAJBU4' then textoAjuda := '  T - troca palavras por outras'
    else

    if f = 'EDAJFA1' then textoAjuda := 'Os comandos de fala sao:'
    else
    if f = 'EDAJFA2' then textoAjuda := '  I - fala inicio da linha'
    else
    if f = 'EDAJFA3' then textoAjuda := '  L - fala resto da linha'
    else
    if f = 'EDAJFA4' then textoAjuda := '  T - fala resto do texto'
    else

    if f = 'EDAJCF1' then textoAjuda := 'Os comandos de configuracao sao:'
    else
    if f = 'EDAJCF2' then textoAjuda := '  F - fala'
    else
    if f = 'EDAJCF3' then textoAjuda := '  I - insercao com Enter'
    else
    if f = 'EDAJCF4' then textoAjuda := '  A - acentuacao'
    else
    if f = 'EDAJCF5' then textoAjuda := '  S - soletragem'
    else
    if f = 'EDAJCF6' then textoAjuda := '  Q - quebra de linha automatica'
    else
    if f = 'EDAJCF7' then textoAjuda := '  V - velocidade'
    else

    if f = 'EDAJEM1' then textoAjuda := 'Os comandos de embelezamento sao:'
    else
    if f = 'EDAJEM2' then textoAjuda := '  C - centra bloco'
    else
    if f = 'EDAJEM3' then textoAjuda := '  M - acerta margens'
    else
    if f = 'EDAJEM4' then textoAjuda := '  A - alinha com as margens'
    else
    if f = 'EDAJEM5' then textoAjuda := '  T - tabula pela esquerda o bloco'
    else
    if f = 'EDAJEM6' then textoAjuda := '  I - indenta o bloco'
    else

    if f = 'EDAJCV1' then textoAjuda := 'As 50 convers�es s�o:'
    else
    if f = 'EDAJCV2' then textoAjuda := '  a min�sculo - alqueire do norte para metros quadrados'
    else
    if f = 'EDAJCV3' then textoAjuda := '  A mai�sculo - alqueire mineiro para metros quadrados'
    else
    if f = 'EDAJCV4' then textoAjuda := '  b min�sculo - alqueire paulista para metros quadrados'
    else
    if f = 'EDAJCV5' then textoAjuda := '  B mai�sculo - cent�metros para p�s'
    else
    if f = 'EDAJCV6' then textoAjuda := '  c min�sculo - cent�metros para  polegadas'
    else
    if f = 'EDAJCV7' then textoAjuda := '  C mai�sculo - cent�metros quadrados para p�s quadrados'
    else
    if f = 'EDAJCV8' then textoAjuda := '  d min�sculo - gal�es para cent�metros c�bicos'
    else
    if f = 'EDAJCV9' then textoAjuda := '  D mai�sculo - gal�es para litros'
    else
    if f = 'EDAJCV10' then textoAjuda := '  e min�sculo - gramas para libras'
    else
    if f = 'EDAJCV11' then textoAjuda := '  E mai�sculo - gramas para on�as'
    else
    if f = 'EDAJCV12' then textoAjuda := '  f min�sculo - hectare para metros quadrados'
    else
    if f = 'EDAJCV13' then textoAjuda := '  F mai�sculo - jardas para cent�metros'
    else
    if f = 'EDAJCV14' then textoAjuda := '  g min�sculo - jardas para metros'
    else
    if f = 'EDAJCV15' then textoAjuda := '  G mai�sculo - jardas quadradas para metros quadrados'
    else
    if f = 'EDAJCV16' then textoAjuda := '  h min�sculo - libras para gramas'
    else
    if f = 'EDAJCV17' then textoAjuda := '  H mai�sculo - libras para quilogramas'
    else
    if f = 'EDAJCV18' then textoAjuda := '  i min�sculo - litros para quartos'
    else
    if f = 'EDAJCV19' then textoAjuda := '  I mai�sculo - metros para jardas'
    else
    if f = 'EDAJCV20' then textoAjuda := '  j min�sculo - metros para p�s'
    else
    if f = 'EDAJCV21' then textoAjuda := '  J mai�sculo - metros para polegadas'
    else
    if f = 'EDAJCV22' then textoAjuda := '  k min�sculo - metros quadrados para jardas quadradas'
    else
    if f = 'EDAJCV23' then textoAjuda := '  K mai�sculo - metros quadrados para p�s quadrados'
    else
    if f = 'EDAJCV24' then textoAjuda := '  l min�sculo - metros por minuto para cent�metros por segundo'
    else
    if f = 'EDAJCV25' then textoAjuda := '  L mai�sculo - metros por minuto para p�s por segundo'
    else
    if f = 'EDAJCV26' then textoAjuda := '  m min�sculo - milhas para quil�metros'
    else
    if f = 'EDAJCV27' then textoAjuda := '  M mai�sculo - milhas para n�s'
    else
    if f = 'EDAJCV28' then textoAjuda := '  n min�sculo - milhas quadradas para quil�metros quadrados'
    else
    if f = 'EDAJCV29' then textoAjuda := '  N mai�sculo - milhas por hora para metros por segundo'
    else
    if f = 'EDAJCV30' then textoAjuda := '  o min�sculo - milhas por hora para quil�metros por hora'
    else
    if f = 'EDAJCV31' then textoAjuda := '  O mai�sculo - n�s para quil�metros por hora'
    else
    if f = 'EDAJCV32' then textoAjuda := '  p min�sculo - on�as para gramas'
    else
    if f = 'EDAJCV33' then textoAjuda := '  P mai�sculo - on�as para quilogramas'
    else
    if f = 'EDAJCV34' then textoAjuda := '  q min�sculo - p�s para cent�metros'
    else
    if f = 'EDAJCV35' then textoAjuda := '  Q mai�sculo - p�s por minuto para cent�metros por segundo'
    else
    if f = 'EDAJCV36' then textoAjuda := '  r min�sculo - polegadas para cent�metros'
    else
    if f = 'EDAJCV37' then textoAjuda := '  R mai�sculo - polegadas para p�s'
    else
    if f = 'EDAJCV38' then textoAjuda := '  s min�sculo - quartos para litros'
    else
    if f = 'EDAJCV39' then textoAjuda := '  S mai�sculo - quilogramas para libras'
    else
    if f = 'EDAJCV40' then textoAjuda := '  t min�sculo - quil�metros para milhas'
    else
    if f = 'EDAJCV41' then textoAjuda := '  T mai�sculo - quil�metros para p�s'
    else
    if f = 'EDAJCV42' then textoAjuda := '  u min�sculo - quil�metros quadrados para jardas quadradas'
    else
    if f = 'EDAJCV43' then textoAjuda := '  U mai�sculo - quil�metros quadrados para milhas quadradas'
    else
    if f = 'EDAJCV44' then textoAjuda := '  v min�sculo - quil�metros por hora para milhas por hora'
    else
    if f = 'EDAJCV45' then textoAjuda := '  V mai�sculo - quil�metros por hora para p�s por minuto'
    else
    if f = 'EDAJCV46' then textoAjuda := '  w min�sculo - Fahrenheit para Celsius'
    else
    if f = 'EDAJCV47' then textoAjuda := '  W mai�sculo - Celsius para Fahrenheit'
    else
    if f = 'EDAJCV48' then textoAjuda := '  x min�sculo - Potencia��o'
    else
    if f = 'EDAJCV49' then textoAjuda := '  X mai�sculo - Comprimento da circunfer�ncia'
    else
    if f = 'EDAJCV50' then textoAjuda := '  y min�sculo - �rea do c�rculo'
    else
    if f = 'EDAJCV51' then textoAjuda := '  Y mai�sculo - Volume da esfera'
    else
    if f = 'EDAJCV52' then textoAjuda := '  z min�sculo - Logar�tmo em qualquer base'
    else
    if f = 'EDAJCV53' then textoAjuda := '  � min�sculo agudo - Seno'
    else
    if f = 'EDAJCV54' then textoAjuda := '  � mai�sculo agudo - Cosseno'
    else
    if f = 'EDAJCV55' then textoAjuda := '  � min�sculo agudo - Tangente'
    else
    if f = 'EDAJCV56' then textoAjuda := '  � mai�sculo agudo - Cotangente'
    else
    if f = 'EDAJCV57' then textoAjuda := '  � min�sculo agudo - Secante'
    else
    if f = 'EDAJCV58' then textoAjuda := '  � mai�sculo agudo - Cossecante'
    else
    if f = 'EDAJCV59' then textoAjuda := '  � min�sculo agudo - Logar�tmo Neperiano'
    else
    if f = 'EDAJCV60' then textoAjuda := '  � mai�sculo agudo - Logar�tmo na base 10'
    else
    if f = 'EDAJCV61' then textoAjuda := '  � min�sculo agudo - Logar�tmo na base 2'
    else
    if f = 'EDAJCV62' then textoAjuda := '  Use as setas para selecionar.'
    else

    if f = 'EDAJDA1' then textoAjuda := '  J - justificar'
    else
    if f ='EDAJDA2' then textoAjuda := '  C - centralizar'
    else
    if f ='EDAJDA3' then textoAjuda := '  D - alinhar a direita'
    else
    if f ='EDAJDA4' then textoAjuda := '  E - alinhar a esquerda'
    else

    if f ='EDAJF01' then textoAjuda := '  F - nome da fonte'
    else
    if f ='EDAJF02' then textoAjuda := '  T - tamanho da fonte'
    else
    if f ='EDAJF03' then textoAjuda := '  C - cor da fonte'
    else
    if f ='EDAJF04' then textoAjuda := '  N - in�cio de negrito'
    else
    if f ='EDAJF05' then textoAjuda := '  CONTROL + N - fim de negrito'
    else
    if f ='EDAJF06' then textoAjuda := '  I - in�cio de it�lico'
    else
    if f ='EDAJF07' then textoAjuda := '  CONTROL + I - fim de it�lico'
    else
    if f ='EDAJF08' then textoAjuda := '  S - in�cio de sublinhado'
    else
    if f ='EDAJF09' then textoAjuda := '  CONTROL + S - fim de sublinhado'
    else

    if f ='EDAJMF1' then textoAjuda := '  F - fonte'
    else
    if f ='EDAJMF2' then textoAjuda := '  A - alinhamento'
    else

    if f ='EDAJMM1' then textoAjuda := 'Os comandos de mai�sculas e minusculas s�o:'
    else
    if f ='EDAJMM2' then textoAjuda := '  A - mai�scula'
    else
    if f ='EDAJMM3' then textoAjuda := '  I - min�scula'
    else
    if f ='EDAJMM4' then textoAjuda := '  P - Primeira letra mai�scula'
    else
    if f ='EDAJMM5' then textoAjuda := '  U - converter para UTF-8'
    else
    if f ='EDAJMM6' then textoAjuda := '  C - contar palavras'
    else

    if f ='EDAUTOMA' then textoAjuda := 'Autom�tica'
    else
    if f ='EDPRETO' then textoAjuda := 'Preto'
    else
    if f ='EDAZUL' then textoAjuda := 'Azul'
    else
    if f ='EDTURQUE' then textoAjuda := 'Turquesa'
    else
    if f ='EDVERCLA' then textoAjuda := 'Verde claro'
    else
    if f ='EDROSA' then textoAjuda := 'Rosa'
    else
    if f ='EDVERMEL' then textoAjuda := 'Vermelho'
    else
    if f ='EDAMAREL' then textoAjuda := 'Amarelo'
    else
    if f ='EDBRANCO' then textoAjuda := 'Branco'
    else
    if f ='EDAZUESC' then textoAjuda := 'Azul escuro'
    else
    if f ='EDCERCET' then textoAjuda := 'Cerceta'
    else
    if f ='EDVERDE' then textoAjuda := 'Verde'
    else
    if f ='EDVIOLET' then textoAjuda := 'Violeta'
    else
    if f ='EDVERESC' then textoAjuda := 'Vermelho escuro'
    else
    if f ='EDAMAESC' then textoAjuda := 'Amarelo escuro'
    else
    if f ='EDCINZ50' then textoAjuda := 'Cinza 50'
    else
    if f ='EDCINZ25' then textoAjuda := 'Cinza 25'
    else

    if f = 'EDAJFF1' then textoAjuda := 'Os modos de falar a formata��o s�o:'
    else
    if f = 'EDAJFF2' then textoAjuda := '  N - natural'
    else
    if f = 'EDAJFF3' then textoAjuda := '  F - formata��o'
    else
    if f = 'EDAJFF4' then textoAjuda := '  B - bips'
    else
    if f = 'EDAJFF5' then textoAjuda := '  M - mudo'
    else

;
end;

{--------------------------------------------------------}

function txtmsg (f: string): string;
begin
    if f = 'EDMSGINI' then txtmsg := 'EDIVOX - v.' + VERSAO + ' ' + ALFABETA + ^m+^j+
                                'Autor: Marcelo Pimentel'
    else
    if f = 'EDSEMTRD' then txtmsg := 'Erro no diretorio do tradutor'
    else
    if f = 'EDQUERSV' then txtmsg := 'Quer salvar o arquivo (s/n) ? '
    else
    if f = 'EDFIMPRC' then txtmsg := 'Fim do EDIVOX - Autor: Marcelo Pimentel'
    else
    if f = 'EDDIGNOM' then txtmsg := 'Qual o nome do Arquivo? '
    else
    if f = 'EDREESCR' then txtmsg := 'Arquivo j� existe, reescreve (s/n) ?'
    else
    if f = 'EDARQGRV' then txtmsg := 'Arquivo gravado'
    else
    if f = 'EDARTRUN' then txtmsg := 'Arquivo enorme foi truncado'
    else
    if f = 'EDARQNOV' then txtmsg := 'Arquivo novo'
    else
    if f = 'EDARQCRG' then txtmsg := 'Arquivo carregado'
    else
    if f = 'EDQUERSN' then txtmsg := 'Quer salvar este texto (s/n)'
    else
    if f = 'EDERRESC' then txtmsg := 'Erro de escrita no arquivo'
    else
    if f = 'EDERRLEI' then txtmsg := 'Erro de leitura no arquivo'
    else
    if f = 'EDOPRINV' then txtmsg := 'Opera��o inv�lida'
    else
    if f = 'EDLINHA'  then txtmsg := 'Linha: '
    else
    if f = 'EDCOLUNA' then txtmsg := 'Coluna: '
    else
    if f = 'EDDEL'    then txtmsg := 'DEL'
    else
    if f = 'EDFALDLG' then txtmsg := 'Fala desligada'
    else
    if f = 'EDFALACI' then txtmsg := 'Fala acionada'
    else
    if f = 'EDLINREM' then txtmsg := 'Linha removida'
    else
    if f = 'EDCNFSAI' then txtmsg := 'Confirma saida (s/n) ? '
    else
    if f = 'EDDIGMD'  then txtmsg := 'Informe a margem direita: '
    else
    if f = 'EDDIGME'  then txtmsg := 'Informe a margem esquerda: '
    else
    if f = 'EDMARINV' then txtmsg := 'Margem invalida'
    else
    if f = 'EDMARACI' then txtmsg := 'Margem acionada'
    else
    if f = 'EDACENT'  then txtmsg := 'Acentuacao acionada'
    else
    if f = 'EDNACENT' then txtmsg := 'Acentuacao desligada'
    else
    if f = 'EDINITEX' then txtmsg := 'Inicio do texto'
    else
    if f = 'EDFIMTEX' then txtmsg := 'Fim do texto'
    else
    if f = 'EDBLKMOV' then txtmsg := 'Bloco movido'
    else
    if f = 'EDBLKCPY' then txtmsg := 'Bloco copiado'
    else
    if f = 'EDBLKCRG' then txtmsg := 'Bloco carregado'
    else
    if f = 'EDBLKADC' then txtmsg := 'Bloco adicionado'
    else
    if f = 'EDBLKORD' then txtmsg := 'Bloco ordenado'
    else
    if f = 'EDBLKCNT' then txtmsg := 'Bloco centrado'
    else
    if f = 'EDBLKTAB' then txtmsg := 'Bloco tabulado'
    else
    if f = 'EDBLKMRG' then txtmsg := 'Bloco margeado'
    else
    if f = 'EDBLKALI' then txtmsg := 'Bloco alinhado'
    else
    if f = 'EDBLKPAR' then txtmsg := 'Bloco par�grafo'
    else
    if f = 'EDBLKLIN' then txtmsg := 'Bloco linha'
    else
    if f = 'EDBLKINV' then txtmsg := 'Bloco invalido'
    else

    if f = 'EDBLKREM' then txtmsg := 'Bloco removido'
    else
    if f = 'EDCMDBLK' then txtmsg := 'Comando de bloco: '
    else
    if f = 'EDBLKMAR' then txtmsg := 'Bloco marcado'
    else
    if f = 'EDINCOMP' then txtmsg := 'Bloco incompleto'
    else
    if f = 'EDINIBLK' then txtmsg := 'Inicio do bloco'
    else
    if f = 'EDFIMBLK' then txtmsg := 'Fim do bloco'
    else
    if f = 'EDJUSTIF' then txtmsg := 'Trecho justificado'
    else
    if f = 'EDPOSINV' then txtmsg := 'Posicao de bloco invalida'
    else
    if f = 'EDBLKDSM' then txtmsg := 'Bloco desmarcado'
    else
    if f = 'EDLINQUE' then txtmsg := 'Linha quebrada'
    else
    if f = 'EDAPAINI' then txtmsg := 'Apagado a esquerda'
    else
    if f = 'EDAPAFIM' then txtmsg := 'Apagado a direita'
    else
    if f = 'EDLINSER' then txtmsg := 'Linha nova'
    else
    if f = 'EDLGRAND' then txtmsg := 'Linha excederia 250 letras, n�o juntei'
    else
    if f = 'EDLINJUN' then txtmsg := 'Linhas juntadas'
    else
    if f = 'EDTXTPRC' then txtmsg := 'Qual o texto ? '
    else
    if f = 'EDTXTENC' then txtmsg := 'Texto encontrado'
    else
    if f = 'EDTXNENC' then txtmsg := 'Texto n�o encontrado'
    else
    if f = 'EDTXTTRC' then txtmsg := 'Texto trocado'
    else
    if f = 'EDQUATRE' then txtmsg := 'Qual o texto nas linhas a excluir?'

    else
    if f = 'EDARQNAO' then txtmsg := 'Arquivo n�o existe'
    else
    if f = 'EDNOME'   then txtmsg := 'Nome deste arquivo: '
    else
    if f = 'EDFORTXT' then txtmsg := 'Usa acentuacao internacional (s/n) '

    else
    if f = 'EDLINGRA' then txtmsg := 'Linhas grandes foram divididas'
    else
    if f = 'EDNOMGRV' then txtmsg := 'Nome do arquivo a gravar: '
    else
    if f = 'EDESCCAN' then txtmsg := 'Gravacao de arquivo cancelada'
    else
    if f = 'EDDGNLIN' then txtmsg := 'Digite o numero da linha: '
    else
    if f = 'EDLINAO'  then txtmsg := 'Linha n�o existe'
    else
    if f = 'EDVELOC'  then txtmsg := 'Qual a velocidade, de 1 a 5? '
    else
    if f = 'EDCOLMAR' then txtmsg := 'Informe a coluna da esquerda: '
    else
    if f = 'EDNCLIND' then txtmsg := 'Numero de colunas a indentar: '
    else
    if f = 'EDDESIST' then txtmsg := 'Desistiu... '
    else
    if f = 'EDTABINS' then txtmsg := 'Tabulacao inserida'
    else
    if f = 'EDTABCAN' then txtmsg := 'Tabulacoes canceladas'
    else
    if f = 'EDENTINS' then txtmsg := 'Enter vai inserir linha'
    else
    if f = 'EDENTNIN' then txtmsg := 'Enter n�o vai inserir linha'
    else
    if f = 'EDSOLETR' then txtmsg := 'Soletragem acionada'
    else
    if f = 'EDNSOLET' then txtmsg := 'Soletragem desligada'
    else
    if f = 'EDMEMPEQ' then txtmsg := 'Memoria muito reduzida.  Tecle ENTER.'
    else
    if f = 'EDINFTXT' then txtmsg := 'Informe o novo texto: '
    else
    if f = 'EDTODBLK' then txtmsg := 'Todo texto (T) ou bloco (B): '
    else
    if f = 'EDCOMAND' then txtmsg := 'Qual comando? '
    else
    if f = 'EDOPCAO'  then txtmsg := 'Qual opcao? '
    else
    if f = 'EDQAUTO'  then txtmsg := 'Quebra automatica ligada'
    else
    if f = 'EDNQAUTO' then txtmsg := 'Quebra automatica desligada'

    else
    if f = 'EDNUM'    then txtmsg := 'Num Lock ligado'
    else
    if f = 'EDNONUM'  then txtmsg := 'Num Lock desligado'
    else
    if f = 'EDCAPS'   then txtmsg := 'Caps Lock ligado'
    else
    if f = 'EDNOCAPS' then txtmsg := 'Caps Lock desligado'
    else
    if f = 'EDERRSRV' then txtmsg := 'Erro no servidor'
    else
    if f = 'EDGRANDE' then txtmsg := 'Bloco muito grande'

    else
    if f = 'EDCOPTRU' then txtmsg := 'Bloco n�o pode ser transcrito por tem mais de 65000 letras'
    else
    if f = 'EDBLKTRN' then txtmsg := 'Bloco trazido foi truncado por ser muito grande'
    else
    if f = 'EDDICNAO' then txtmsg := 'Dicion�rio n�o foi achado'
    else
    if f = 'EDUTF8'   then txtmsg := 'Escolha q para quoted-printable, u para utf-8 ou g para yahoogroups'
    else
    if f = 'EDAGUARD' then txtmsg := 'Aguarde ...'
    else
    if f = 'EDDESCON' then txtmsg := 'Deseja tentar converter o arquivo para TXT? '
    else
    if f = 'EDMAIUSC' then txtmsg := 'Deseja converter o bloco para mai�scula? '
    else
    if f = 'EDPUTF8' then txtmsg := 'Deseja codificar o bloco para UTF-8'
    else
    if f = 'EDDECODI' then txtmsg := 'Deseja decodificar o texto?'
    else
    if f = 'EDDICIOA' then txtmsg := 'Dicion�rio ativado'
    else
    if f = 'EDDICIOD' then txtmsg := 'Dicion�rio desativado'
    else
    if f = 'EDPALCOR' then txtmsg := 'Palavra correta'
    else
    if f = 'EDPALADI' then txtmsg := 'Palavra adicionada'

    else
    if f = 'EDCONVER' then txtmsg := 'Convers�es. Tecle F1 para ajuda.'
    else
    if f = 'EDINFPOT' then txtmsg := 'Qual a pot�ncia?'

    else
    if f = 'EDSEMSUG' then txtmsg := 'Sem sugest�es'
    else
    if f = 'EDALTERN' then txtmsg := 'Use as setas para alternativas'
    else
    if f = 'EDOK'     then txtmsg := 'OK'
    else
    if f = 'EDPAICON' then txtmsg := 'Painel de configura��o'
    else
    if f = 'EDMARDIR' then txtmsg := 'Margem direita: '
    else
    if f = 'EDDICATI' then txtmsg := 'O dicion�rio ser� ativado'
    else
    if f = 'EDAGUARC' then txtmsg := 'Aguarde, configurando'
    else
    if f = 'EDCARDIC' then txtmsg := 'Carregando dicion�rio'
    else
    if f = 'EDREFORM' then txtmsg := 'Junta linhas para exportar? '

    else
    if f = 'EDNEXEC' then txtmsg := 'N�o pude executar'

    else
    if f = 'EDINFVAL' then txtmsg := 'Informe o valor '
    else
    if f = 'EDFONTES' then txtmsg := 'Fontes'
    else
    if f = 'EDDE' then txtmsg := ' de '
    else
    if f = 'EDLIDO' then txtmsg := ' lido '
    else
    if f = 'EDTXTNEX' then txtmsg := 'Falta o arquivo txtword.exe'
    else
    if f = 'EDDIGTAM' then txtmsg := 'Digite o tamanho da fonte'
    else
    if f = 'EDOPCINV' then txtmsg := 'Op��o inv�lida'
    else
    if f = 'EDINSFOR' then txtmsg := 'Inserir marcas de formata��o'

    else
    if f ='EDAUTOMA' then txtmsg := 'Autom�tica'
    else
    if f ='EDPRETO' then txtmsg := 'Preto'
    else
    if f ='EDAZUL' then txtmsg := 'Azul'
    else
    if f ='EDTURQUE' then txtmsg := 'Turquesa'
    else
    if f ='EDVERCLA' then txtmsg := 'Verde claro'
    else
    if f ='EDROSA' then txtmsg := 'Rosa'
    else
    if f ='EDVERMEL' then txtmsg := 'Vermelho'
    else
    if f ='EDAMAREL' then txtmsg := 'Amarelo'
    else
    if f ='EDBRANCO' then txtmsg := 'Branco'
    else
    if f ='EDAZUESC' then txtmsg := 'Azul escuro'
    else
    if f ='EDCERCET' then txtmsg := 'Cerceta'
    else
    if f ='EDVERDE' then txtmsg := 'Verde'
    else
    if f ='EDVIOLET' then txtmsg := 'Violeta'
    else
    if f ='EDVERESC' then txtmsg := 'Vermelho escuro'
    else
    if f ='EDAMAESC' then txtmsg := 'Amarelo escuro'
    else
    if f ='EDCINZ50' then txtmsg := 'Cinza 50'
    else
    if f ='EDCINZ25' then txtmsg := 'Cinza 25'

    else
    if f = 'EDFONTE' then txtmsg := 'Fonte'
    else
    if f = 'EDTAMANH' then txtmsg := 'Tamanho'
    else
    if f = 'EDALIJUS' then txtmsg := 'Alinhamento justificado'
    else
    if f = 'EDALICEN' then txtmsg := 'Alinhamento centralizado'
    else
    if f = 'EDALIESQ' then txtmsg := 'Alinhamento � esquerda'
    else
    if f = 'EDALIDIR' then txtmsg := 'Alinhamento � direita'
    else
    if f = 'EDININEG' then txtmsg := 'In�cio de negrito'
    else
    if f = 'EDFIMNEG' then txtmsg := 'Fim de negrito'
    else
    if f = 'EDINIITA' then txtmsg := 'In�cio de it�lico'
    else
    if f = 'EDFIMITA' then txtmsg := 'Fim de it�lico'
    else
    if f = 'EDINISUB' then txtmsg :=  'In�cio de sublinhado'
    else
    if f = 'EDFIMSUB' then txtmsg :=  'Fim de sublinhado'
    else
    if f = 'EDNEGRIT' then txtmsg := 'Negrito'
    else
    if f = 'EDITALIC' then txtmsg := 'It�lico'
    else
    if f = 'EDSUBLIN' then txtmsg := 'Sublinhado'
    else
    if f = 'EDMINUSC' then txtmsg := 'Deseja converter o bloco para min�scula?'
    else
    if f = 'EDPRIMAI' then txtmsg := 'Deseja converter primeira letra de todo bloco para mai�scula?'
    else
    if f = 'EDPALAVR' then txtmsg := 'palavras'
    else
    if f = 'EDLETPAL' then txtmsg := 'letras e palavras'
    else
    if f = 'EDLETRAS' then txtmsg := 'letras'
    else
    if f = 'EDSOMLEI' then txtmsg := 'Este arquivo � somente leitura, provavelmente n�o ser� gravado'
    else
    if f = 'EDFOROCU' then txtmsg := 'Formata��o oculta na tela'
    else
    if f = 'EDFORAPA' then txtmsg := 'Formata��o aparente na tela'
    else
    if f = 'EDMOFAFO' then txtmsg := 'Modos de falar formata��o'
    else
    if f = 'EDORIUTF' then txtmsg := 'Original cont�m texto em UTF-8 na linha '
    else
    if f = 'EDRETOMA' then txtmsg := 'Retomando na linha '
    else
    if f = 'EDRECUST' then txtmsg := 'Edi��es recentes, use as setas.'
    else
    if f = 'EDPDFNEX' then txtmsg := 'Falta instalar o conversor de PDF para TXT, pdftotext'
    else
    if f = 'EDEPUNAO' then txtmsg := 'Conversor de formato EPUB n�o pode ser ativado'
    else
    if f = 'EDBLBNAO' then txtmsg := 'Conversor Blb2txt n�o foi encontrado'
    else
    if f = 'EDINIBLB' then txtmsg := 'Arquivo blb2txt.ini n�o foi encontrado'

    else
    if f = 'EDCFVEL'  then txtmsg := 'Use as setas para selecionar.'
    else
    if f = 'EDVELC'   then txtmsg := 'Velocidade: '
    else
    if f = 'EDINSLIN' then txtmsg := 'ENTER insere linha: '
    else
    if f = 'EDQUEAUT' then txtmsg := 'Quebrar linhas: '
    else
    if f = 'EDFALPON' then txtmsg := 'Falar pontua��o: '
    else
    if f = 'EDFALLET' then txtmsg := 'Falar letras: '
    else
    if f = 'EDFALPAL' then txtmsg := 'Falar palavras: '
    else
    if f = 'EDFALAUT' then txtmsg := 'Fala autom�tica: '
    else
    if f = 'EDCOMDIC' then txtmsg := 'Com dicion�rio: '
    else
    if f = 'EDCORRTD' then txtmsg := '  Corrigir tudo: '
    else
    if f = 'EDMODFOR' then txtmsg := 'Modo formata��o (N, F, B ou M): '
    else
    if f = 'EDCOMSAP' then txtmsg := 'Com SAPI: '
    else
    if f = 'EDNUMSAP' then txtmsg := 'N�mero SAPI: '
    else
    if f = 'EDVEL'    then txtmsg := 'Velocidade SAPI: '
    else
    if f = 'EDTOM'    then txtmsg := 'Tonalidade SAPI: '
    else
    if f = 'EDTIPSAP' then txtmsg := 'Tipo SAPI (3, 4 ou 5): '
    else
    if f = 'EDTIPSPX' then txtmsg := 'Tipo SAPI (3, 4, 5 ou 54): '
    else
    if f = 'EDDGNUPA' then txtmsg := 'Digite o numero da p�gina: '
    else
    if f = 'EDPAGNAO' then txtmsg := 'P�gina n�o existe.'

    else if f = 'EDPROANT' then txtmsg := 'Procurar anterior'
    else if f = 'EDPROPRO' then txtmsg := 'Procurar pr�xima'
    else if f = 'EDMEMORI' then txtmsg := 'memorizada'
    else if f = 'EDPTPBR' then txtmsg := 'Limpando e traduzindo de Pt para Br ...'
    else if f = 'EDLIMTXT' then txtmsg := 'Limpando o texto ...'
    else if f = 'EDPAGINA' then txtmsg := 'P�gina '
    else if f = 'EDTATAB' then txtmsg := 'N�mero de espa�os ao apertar tab'
    else if f = 'EDUSATAB' then txtmsg := 'Usa o caractere tab'
    else if f = 'EDCODIF' then txtmsg := 'Salva em qual codifica��o'
    else if f = 'EDPRESERVULTLB' then txtmsg := 'Preserva �ltimas linhas em branco?'
    else if f = 'EDUSAEOLUNIX' then txtmsg := 'Usa fim de linha Unix?'

    else
        txtmsg := '----- erro de mensagem ???? ----';
end;

{--------------------------------------------------------}

Procedure FalaSeguinte (f: String);
var s: string;
begin
    s := txtmsg (f);
    write (s);
    textBackground (BLACK);
    clreol;

    if existeArqSom ('EF_' + f) then
        sintSom ('EF_' + f);

    if existeArqSom (f) then
        sintSom (f)
    else
        sintetiza (s);
end;

{--------------------------------------------------------}

Procedure Fala (f: String);
begin
    gotoxy (1, 9);
    textBackground (BLUE);
    falaSeguinte (f);
end;

{--------------------------------------------------------}

function leTeclaMaiusc: char;
var tecla : char;
begin
    tecla := sintReadKey;
    leTeclaMaiusc := upcase (tecla);
end;

end.
