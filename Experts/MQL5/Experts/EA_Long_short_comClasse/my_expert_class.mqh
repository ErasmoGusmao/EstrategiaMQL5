//+------------------------------------------------------------------+
//|                                              my_expert_class.mqh |
//|                                                           Erasmo |
//|                             https://www.mql5.com/pt/articles/116 |
//+------------------------------------------------------------------+
#property copyright "Erasmo"
#property link      "https://www.mql5.com/pt/articles/116"
//+------------------------------------------------------------------+
//| DECLARA��O DA CLASSE                                             |
//+------------------------------------------------------------------+
class MyExpert
  {
//--- membros privados
private:
   int               Magic_No;       // N�mero m�gico Expert
   int               Chk_Margin;    // Margem checada antes de iniciar um neg�cio? (0 ou 1)
   double            LOTS;          // Lotes ou volume para negocia��o
   double            TradePct;      // Porcentagem de margem livre da conta a ser utilizada para negocia��o
   double            ADX_min;       // Valor m�nimo ADX
   int               ADX_handle;    // Manipulador ADX
   int               MA_handle;     // Manipulador MA
   double            plus_DI[];     // Armazena os valores de cada barra do +DI
   double            minus_DI[];    // Armazena os valores de cada barra do  -DI
   double            MA_val[];      // Valores de cada barra da MA
   double            ADX_val[];     // Valores de cada barra da ADX
   double            Closeprice;    // Armazena o pre�o de fechamento
   MqlTradeRequest   trequest;      // Ser� usada para enviar uma requisi��o de neg�cio
   MqlTradeResult    tresult;       // Ser� usada para pegar uma resposta da neg�cia��o
   string            symbol;        // Nome do papel
   ENUM_TIMEFRAMES   period;        // Vari�vel que armazena o valor do per�do atual
   string            Erromsg;       // Vari�vel para a mensagem de erro
   int               Errocode;      // Vari�vel para o c�digo de erros
   
public:
   void              MyExpert();    // Construtor da Classe
   void              setSymbol(string syb){symbol = syb;}            // Fun��o para pegar o s�mbolo atual (encapsulamento)
   void              setPeriod(ENUM_TIMEFRAMES prd){period = prd;}   // Fun��o para pegar o per�odo atual (encapsulamento)
   void              setCloseprice(double prc){Closeprice = prc;}    // Fun��o para pegar o pre�o de fechamento atual (encapsulamento)
   void              setchkMAG(int mag){Chk_Margin = mag;}           // Fun��o para pegar setar o Marge Cheque
   void              setLOTS(double lot){LOTS = lot;}
   void              setTRpct(double trpct){TradePct=trpct/100;}     // Fun��o que seta a porcentagem de margem livre da conta a ser utilizada para negocia��o
   void              setMagic(int magic){Magic_No = magic;}
   void              setadxmin(double adx){ADX_min=adx;}

//---Fun��es de manipula��o dos valores de entrada              
   void              doInit(int adx_period, int ma_period);          // Fun��o ser� usada para inicializar o EA
   void              doUninit();                                     // Fun��o ser� usada para desinicializar o EA
   bool              checkBuy();                                     // Fun��o que checa a condi��o de compra
   bool              checkSell();                                    // Fun��o que checa a condi��o de venda
   void              openBuy(ENUM_ORDER_TYPE otype,double askprice,
                              double SL,double TP,int dev,string comment="");  // Fun��o para abrir posi��o de compra
   void              openSell(ENUM_ORDER_TYPE otype,double bidprice,
                              double SL,double TP,int dev,string comment="");  // Fun��o para abrir posi��o de venda
                              
protected:
   void              showError(string msg,int ercode);                // Fun��o que mostra no display a mensagem de erro
   void              getBuffers();                                    // Fun��o ser� utilizada para conseguir os buffers indicadores
   bool              MarginOK();                                      // Fun��o que confirma se a margem requerida para lotes est� o.k

//--- Fim da declara��o da classe
  };

//+------------------------------------------------------------------+
//| DEFINI��O DOS MEMBROSDA FUN��O                                   |
//+------------------------------------------------------------------+

//---Construtor da classe
void MyExpert::MyExpert(void)
{
//Inicializando todas as vari�veis necess�rias
ZeroMemory(trequest);
ZeroMemory(tresult);
ZeroMemory(ADX_val);
ZeroMemory(MA_val);
ZeroMemory(plus_DI);
ZeroMemory(minus_DI);
Erromsg="";
Errocode=0;
}

//+------------------------------------------------------------------+
//|  SHOWERROR FUNCTION
//|  *Par�metros de entrada - Error Message, Error Code                                                               
//+------------------------------------------------------------------+
void MyExpert::showError(string msg,int ercode)
{
Alert(msg,"-erro: ",ercode);  //Display erro
}

//+------------------------------------------------------------------+
//|  GETBUFFERS FUNCTION                                                                
//|  *Sem par�metros de entrada
//|  *Usa dados de membros da classe para pegar o buffers dos inciadores
//+------------------------------------------------------------------+
void MyExpert::getBuffers(void)
{
   if(CopyBuffer(ADX_handle,0,0,3,ADX_val)<0 || CopyBuffer(ADX_handle,1,0,3,plus_DI)<0
      || CopyBuffer(ADX_handle,2,0,3,minus_DI)<0 || CopyBuffer(MA_handle,0,0,3,MA_val)<0)
     {
      Erromsg = "Erro ao copiar o indicador no buffer!";
      Errocode = GetLastError();
      showError(Erromsg,Errocode);
     }
}
//+------------------------------------------------------------------+
//|  MARGINOK FUNCTION
//| *Sem par�metros de entrada
//| *Usa dados de membros da classe para verificar se ha margem 
//| requirida para colocar em negocia��o com os lotes est� o.k
//| *Retorna TRUE no sucesso e FALSE caso falhe
//+------------------------------------------------------------------+
bool MyExpert::MarginOK(void)
{
double one_lot_price;                                                       // Margem requerida para um lote
double act_f_mag = AccountInfoDouble(ACCOUNT_MARGIN_FREE);                  // Conta de margem livre
long levrage = AccountInfoInteger(ACCOUNT_LEVERAGE);                         // Alavancagem da conta
double contract_size = SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE); // Tamanho do contrato de neg�cio (Total de unidades para um lote)
string base_currency = SymbolInfoString(symbol,SYMBOL_CURRENCY_BASE);       // Moeda base do ativo
if(base_currency="USD")
  {
   one_lot_price=contract_size/levrage;                                     //Margem necess�ria = Tamanho do contrato por lote / alavancagem
  }
  else
    {
     double bprice = SymbolInfoDouble(symbol,SYMBOL_BID);
     one_lot_price=bprice*contract_size/levrage;                            //Margem necess�ria = pre�o atual do s�mbolo * tamanho do contrato por lote/alavancagem.
    }
//Checa se a margem requerida est� o.k nesse cen�rio base
if(MathFloor(LOTS*one_lot_price)>MathFloor(act_f_mag*TradePct))
  {
   return(false);
  }
  else
    {
      return(true);
    }
}
//+-----------------------------------------------------------------------+
// FUN��ES P�BLICAS                                                       |
//+-----------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DOINIT FUNCTION
//| *Pega os per�odos do indicado ADX e do indicador de m�dia m�vel
//| como par�metros de entrada
//| *Para ser usada na fun��o OnInit() do EA                                                               
//+------------------------------------------------------------------+
void MyExpert::doInit(int adx_period,int ma_period)
{
//--- Pegar o manipuilado do indicador ADX
ADX_handle=iADX(symbol,period,ma_period);
//--- Pegar o manipulador da m�dia m�vel
MA_handle=iMA(symbol,period,ma_period,0,MODE_EMA,PRICE_CLOSE);
//--- se retornar um manipulador inv�lide
if(ADX_handle<0 || MA_handle<0)
  {
   Erromsg="Erro ao pegar os manipuladores dos indicadores";
   Errocode=GetLastError();
   showError(Erromsg,Errocode);
  }
//--- Setar os arrays
//--- Array ADX
ArraySetAsSeries(ADX_val,true);
//--- Array +DI
ArraySetAsSeries(plus_DI,true);
//--- Array -DI
ArraySetAsSeries(minus_DI,true);
//--- Array MA
ArraySetAsSeries(MA_val,true);
}
//+------------------------------------------------------------------+
//|  DOUNINIT FUNCTION
//|  *Sem par�metros de entrada
//|  *Usado para perceber os manipuladores dos indicadores ADX e MA
//+------------------------------------------------------------------+
void MyExpert::doUninit(void)
{
//--- Perceber os manipuladores dos indicadores
   IndicatorRelease(MA_handle);
   IndicatorRelease(ADX_handle);
}
//+------------------------------------------------------------------+
//| CHECKBUY FUNCTION
//| *Sem par�metros de entrada
//| *Usa dados de membro da classe para checar o sinal de compra baseado
//|  na defini��o da estrat�gia de neg�cio
//| *Retorna TRUE se a condi��o de compra for encontrada ou FALSE caso n�o.
//+------------------------------------------------------------------+
bool MyExpert::checkBuy(void)
{
/*
         Verificar compra o Setup Long/Buy:
      -> MA-8 crescendo sobre o pre�o de fechamento anterior;
      -> ADX > 22 e +DI > -DI
*/
getBuffers();
//--- Declarando vari�veis bool para assegurar nossa condi��o de compra (sinais de compra)
bool Buy_Condition_1 = (MA_val[0] > MA_val[1]) && (MA_val[1] > MA_val[2]);    //Crecimento da m�dia m�vel
bool Buy_Condition_2 = (Closeprice > MA_val[1]);                              //Pre�o de fechamento anterior maior que a m�dia m�vel anterior
bool Buy_Condition_3 = (ADX_val[0] > ADX_min);                                //Valor atual do indicado ADX > 22 (definido inicialmente)
bool Buy_Condition_4 = (plus_DI[0] > minus_DI[0]);                            // +DI > -DI

//--- Avaliando os sinais de compra
if(Buy_Condition_1 && Buy_Condition_2 && Buy_Condition_3 && Buy_Condition_4)
  {
   return(true);
  }
  else
  {
   return(false);
  }
}
//+------------------------------------------------------------------+
//| CHECKSELL FUNCTION
//| *Sem par�metros de entrada
//| *Usa dados de membro da classe para checar o sinal de venda baseado
//|  na defini��o da estrat�gia de neg�cio
//| *Retorna TRUE se a condi��o de venda for encontrada ou FALSE caso n�o.
//+------------------------------------------------------------------+
bool MyExpert::checkSell(void)
{
/*
         Verificar venda o Setup short/Sell:
      -> MA-8 decrescendo sobre o pre�o de fechamento anterior;
      -> ADX > 22 e -DI > +DI
*/
getBuffers();
//--- Declarando vari�veis bool para assegurar nossa condi��o de compra (sinais de compra)
bool Sell_Condition_1 = (MA_val[0] < MA_val[1]) && (MA_val[1] < MA_val[2]);    //Decrecimento da m�dia m�vel
bool Sell_Condition_2 = (Closeprice < MA_val[1]);                              //Pre�o de fechamento anterior menor que a m�dia m�vel anterior
bool Sell_Condition_3 = (ADX_val[0] > ADX_min);                                //Valor atual do indicado ADX > 22 (definido inicialmente)
bool Sell_Condition_4 = (plus_DI[0] < minus_DI[0]);                            // -DI > +DI

//--- Avaliando os sinais de venda
if(Sell_Condition_1 && Sell_Condition_2 && Sell_Condition_3 && Sell_Condition_4)
  {
   return(true);
  }
  else
  {
   return(false);
  }
}
//+------------------------------------------------------------------+
//| OPENBUY FUNCTION
//| *Tem par�metros de entrada - tipo de ordem, pre�o atual de venda, Stop Loss,
//|  Take Profit, deviation, comment
//| *Checa a conta margem liver antes de negociar se escolher negociar
//| *Alerta de sucesso se a posi��o for aberta ou mostra erro
//+------------------------------------------------------------------+
void MyExpert::openBuy(ENUM_ORDER_TYPE otype,double askprice,double SL,double TP,int dev,string comment="")
{
//--- Checar margem
if(Chk_Margin==1)
  {
   if(MarginOK()==false)
     {
      Erromsg = "Voc� n�o tem dinheiro suficiente para abrir essa posi��o!!!";
      Errocode = GetLastError();
      showError(Erromsg,Errocode);
     }
     else
       {
        trequest.action = TRADE_ACTION_DEAL;
        trequest.type = otype;
        trequest.volume = LOTS;
        trequest.price = askprice;
        trequest.sl = SL;
        trequest.tp = TP;
        trequest.deviation = dev;
        trequest.magic = Magic_No;
        trequest.symbol = symbol;
        trequest.type_filling = ORDER_FILLING_FOK;
        //Envia
        OrderSend(trequest,tresult);
        //Checa o resultado
        if(tresult.retcode == 10009 || tresult.retcode == 10008) //Requisi��o bem sucedida
          {
           Alert("A ordem de compra foi colocada com sucesso com Ticket#: ",tresult.order,"!!");
          }
        else
          {
           Erromsg ="A requisi��o de ordem de compra n�o pode ser completada!";
           Errocode = GetLastError();
           showError(Erromsg,Errocode);
          }
       }
  }
  else
    {
        trequest.action = TRADE_ACTION_DEAL;
        trequest.type = otype;
        trequest.volume = LOTS;
        trequest.price = askprice;
        trequest.sl = SL;
        trequest.tp = TP;
        trequest.deviation = dev;
        trequest.magic = Magic_No;
        trequest.symbol = symbol;
        trequest.type_filling = ORDER_FILLING_FOK;
        //Envia
        OrderSend(trequest,tresult);
        //Checa o resultado
        if(tresult.retcode == 10009 || tresult.retcode == 10008) //Requisi��o bem sucedida
          {
           Alert("A ordem de compra foi colocada com sucesso com Ticket#: ",tresult.order,"!!");
          }
        else
          {
           Erromsg ="A requisi��o de ordem de compra n�o pode ser completada!";
           Errocode = GetLastError();
           showError(Erromsg,Errocode);
          }
    }
}
//+------------------------------------------------------------------+
//| OPENSELL FUNCTION
//| *Tem par�metros de entrada - tipo de ordem, pre�o atual de compra, Stop Loss,
//|  Take Profit, deviation, comment
//| *Checa a conta margem liver antes de negociar se escolher negociar
//| *Alerta de sucesso se a posi��o for aberta ou mostra erro
//+------------------------------------------------------------------+
void MyExpert::openSell(ENUM_ORDER_TYPE otype,double bidprice,double SL,double TP,int dev,string comment="")
{
//--- Checar margem
if(Chk_Margin==1)
  {
   if(MarginOK()==false)
     {
      Erromsg = "Voc� n�o tem dinheiro suficiente para abrir essa posi��o!!!";
      Errocode = GetLastError();
      showError(Erromsg,Errocode);
     }
   else
     {
        trequest.action=TRADE_ACTION_DEAL;
        trequest.type=otype;
        trequest.volume=LOTS;
        trequest.price=bidprice;
        trequest.sl=SL;
        trequest.tp=TP;
        trequest.deviation=dev;
        trequest.magic=Magic_No;
        trequest.symbol=symbol;
        trequest.type_filling=ORDER_FILLING_FOK;
         //Envia
        OrderSend(trequest,tresult);
        //Checa o resultado
        if(tresult.retcode == 10009 || tresult.retcode == 10008) //Requisi��o bem sucedida
          {
           Alert("A ordem de venda foi colocada com sucesso com Ticket#: ",tresult.order,"!!");
          }
        else
          {
           Erromsg ="A requisi��o de ordem de venda n�o pode ser completada!";
           Errocode = GetLastError();
           showError(Erromsg,Errocode);
          }
     }  
  }
else
  {
        trequest.action=TRADE_ACTION_DEAL;
        trequest.type=otype;
        trequest.volume=LOTS;
        trequest.price=bidprice;
        trequest.sl=SL;
        trequest.tp=TP;
        trequest.deviation=dev;
        trequest.magic=Magic_No;
        trequest.symbol=symbol;
        trequest.type_filling=ORDER_FILLING_FOK;
         //Envia
        OrderSend(trequest,tresult);
        //Checa o resultado
        if(tresult.retcode == 10009 || tresult.retcode == 10008) //Requisi��o bem sucedida
          {
           Alert("A ordem de venda foi colocada com sucesso com Ticket#: ",tresult.order,"!!");
          }
        else
          {
           Erromsg ="A requisi��o de ordem de venda n�o pode ser completada!";
           Errocode = GetLastError();
           showError(Erromsg,Errocode);
          }
  }  
}