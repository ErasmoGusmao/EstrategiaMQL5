//+------------------------------------------------------------------+
//|                                              my_expert_class.mqh |
//|                                                           Erasmo |
//|                             https://www.mql5.com/pt/articles/116 |
//+------------------------------------------------------------------+
#property copyright "Erasmo"
#property link      "https://www.mql5.com/pt/articles/116"
//+------------------------------------------------------------------+
//| DECLARAÇÃO DA CLASSE                                             |
//+------------------------------------------------------------------+
class MyExpert
  {
//--- membros privados
private:
   int               Magic_No;       // Número mágico Expert
   int               Chk_Margin;    // Margem checada antes de iniciar um negócio? (0 ou 1)
   double            LOTS;          // Lotes ou volume para negociação
   double            TradePct;      // Porcentagem de margem livre da conta a ser utilizada para negociação
   double            ADX_min;       // Valor mínimo ADX
   int               ADX_handle;    // Manipulador ADX
   int               MA_handle;     // Manipulador MA
   double            plus_DI[];     // Armazena os valores de cada barra do +DI
   double            minus_DI[];    // Armazena os valores de cada barra do  -DI
   double            MA_val[];      // Valores de cada barra da MA
   double            ADX_val[];     // Valores de cada barra da ADX
   double            Closeprice;    // Armazena o preço de fechamento
   MqlTradeRequest   trequest;      // Será usada para enviar uma requisição de negócio
   MqlTradeResult    tresult;       // Será usada para pegar uma resposta da negóciação
   string            symbol;        // Nome do papel
   ENUM_TIMEFRAMES   period;        // Variável que armazena o valor do perído atual
   string            Erromsg;       // Variável para a mensagem de erro
   int               Errocode;      // Variável para o código de erros
   
public:
   void              MyExpert();    // Construtor da Classe
   void              setSymbol(string syb){symbol = syb;}            // Função para pegar o símbolo atual (encapsulamento)
   void              setPeriod(ENUM_TIMEFRAMES prd){period = prd;}   // Função para pegar o período atual (encapsulamento)
   void              setCloseprice(double prc){Closeprice = prc;}    // Função para pegar o preço de fechamento atual (encapsulamento)
   void              setchkMAG(int mag){Chk_Margin = mag;}           // Função para pegar setar o Marge Cheque
   void              setLOTS(double lot){LOTS = lot;}
   void              setTRpct(double trpct){TradePct=trpct/100;}     // Função que seta a porcentagem de margem livre da conta a ser utilizada para negociação
   void              setMagic(int magic){Magic_No = magic;}
   void              setadxmin(double adx){ADX_min=adx;}

//---Funções de manipulação dos valores de entrada              
   void              doInit(int adx_period, int ma_period);          // Função será usada para inicializar o EA
   void              doUninit();                                     // Função será usada para desinicializar o EA
   bool              checkBuy();                                     // Função que checa a condição de compra
   bool              checkSell();                                    // Função que checa a condição de venda
   void              openBuy(ENUM_ORDER_TYPE otype,double askprice,
                              double SL,double TP,int dev,string comment="");  // Função para abrir posição de compra
   void              openSell(ENUM_ORDER_TYPE otype,double bidprice,
                              double SL,double TP,int dev,string comment="");  // Função para abrir posição de venda
                              
protected:
   void              showError(string msg,int ercode);                // Função que mostra no display a mensagem de erro
   void              getBuffers();                                    // Função será utilizada para conseguir os buffers indicadores
   bool              MarginOK();                                      // Função que confirma se a margem requerida para lotes está o.k

//--- Fim da declaração da classe
  };

//+------------------------------------------------------------------+
//| DEFINIÇÃO DOS MEMBROSDA FUNÇÃO                                   |
//+------------------------------------------------------------------+

//---Construtor da classe
void MyExpert::MyExpert(void)
{
//Inicializando todas as variáveis necessárias
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
//|  *Parâmetros de entrada - Error Message, Error Code                                                               
//+------------------------------------------------------------------+
void MyExpert::showError(string msg,int ercode)
{
Alert(msg,"-erro: ",ercode);  //Display erro
}

//+------------------------------------------------------------------+
//|  GETBUFFERS FUNCTION                                                                
//|  *Sem parâmetros de entrada
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
//| *Sem parâmetros de entrada
//| *Usa dados de membros da classe para verificar se ha margem 
//| requirida para colocar em negociação com os lotes está o.k
//| *Retorna TRUE no sucesso e FALSE caso falhe
//+------------------------------------------------------------------+
bool MyExpert::MarginOK(void)
{
double one_lot_price;                                                       // Margem requerida para um lote
double act_f_mag = AccountInfoDouble(ACCOUNT_MARGIN_FREE);                  // Conta de margem livre
long levrage = AccountInfoInteger(ACCOUNT_LEVERAGE);                         // Alavancagem da conta
double contract_size = SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE); // Tamanho do contrato de negócio (Total de unidades para um lote)
string base_currency = SymbolInfoString(symbol,SYMBOL_CURRENCY_BASE);       // Moeda base do ativo
if(base_currency="USD")
  {
   one_lot_price=contract_size/levrage;                                     //Margem necessária = Tamanho do contrato por lote / alavancagem
  }
  else
    {
     double bprice = SymbolInfoDouble(symbol,SYMBOL_BID);
     one_lot_price=bprice*contract_size/levrage;                            //Margem necessária = preço atual do símbolo * tamanho do contrato por lote/alavancagem.
    }
//Checa se a margem requerida está o.k nesse cenário base
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
// FUNÇÕES PÚBLICAS                                                       |
//+-----------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DOINIT FUNCTION
//| *Pega os períodos do indicado ADX e do indicador de média móvel
//| como parâmetros de entrada
//| *Para ser usada na função OnInit() do EA                                                               
//+------------------------------------------------------------------+
void MyExpert::doInit(int adx_period,int ma_period)
{
//--- Pegar o manipuilado do indicador ADX
ADX_handle=iADX(symbol,period,ma_period);
//--- Pegar o manipulador da média móvel
MA_handle=iMA(symbol,period,ma_period,0,MODE_EMA,PRICE_CLOSE);
//--- se retornar um manipulador inválide
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
//|  *Sem parâmetros de entrada
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
//| *Sem parâmetros de entrada
//| *Usa dados de membro da classe para checar o sinal de compra baseado
//|  na definição da estratégia de negócio
//| *Retorna TRUE se a condição de compra for encontrada ou FALSE caso não.
//+------------------------------------------------------------------+
bool MyExpert::checkBuy(void)
{
/*
         Verificar compra o Setup Long/Buy:
      -> MA-8 crescendo sobre o preço de fechamento anterior;
      -> ADX > 22 e +DI > -DI
*/
getBuffers();
//--- Declarando variáveis bool para assegurar nossa condição de compra (sinais de compra)
bool Buy_Condition_1 = (MA_val[0] > MA_val[1]) && (MA_val[1] > MA_val[2]);    //Crecimento da média móvel
bool Buy_Condition_2 = (Closeprice > MA_val[1]);                              //Preço de fechamento anterior maior que a média móvel anterior
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
//| *Sem parâmetros de entrada
//| *Usa dados de membro da classe para checar o sinal de venda baseado
//|  na definição da estratégia de negócio
//| *Retorna TRUE se a condição de venda for encontrada ou FALSE caso não.
//+------------------------------------------------------------------+
bool MyExpert::checkSell(void)
{
/*
         Verificar venda o Setup short/Sell:
      -> MA-8 decrescendo sobre o preço de fechamento anterior;
      -> ADX > 22 e -DI > +DI
*/
getBuffers();
//--- Declarando variáveis bool para assegurar nossa condição de compra (sinais de compra)
bool Sell_Condition_1 = (MA_val[0] < MA_val[1]) && (MA_val[1] < MA_val[2]);    //Decrecimento da média móvel
bool Sell_Condition_2 = (Closeprice < MA_val[1]);                              //Preço de fechamento anterior menor que a média móvel anterior
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
//| *Tem parâmetros de entrada - tipo de ordem, preço atual de venda, Stop Loss,
//|  Take Profit, deviation, comment
//| *Checa a conta margem liver antes de negociar se escolher negociar
//| *Alerta de sucesso se a posição for aberta ou mostra erro
//+------------------------------------------------------------------+
void MyExpert::openBuy(ENUM_ORDER_TYPE otype,double askprice,double SL,double TP,int dev,string comment="")
{
//--- Checar margem
if(Chk_Margin==1)
  {
   if(MarginOK()==false)
     {
      Erromsg = "Você não tem dinheiro suficiente para abrir essa posição!!!";
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
        if(tresult.retcode == 10009 || tresult.retcode == 10008) //Requisição bem sucedida
          {
           Alert("A ordem de compra foi colocada com sucesso com Ticket#: ",tresult.order,"!!");
          }
        else
          {
           Erromsg ="A requisição de ordem de compra não pode ser completada!";
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
        if(tresult.retcode == 10009 || tresult.retcode == 10008) //Requisição bem sucedida
          {
           Alert("A ordem de compra foi colocada com sucesso com Ticket#: ",tresult.order,"!!");
          }
        else
          {
           Erromsg ="A requisição de ordem de compra não pode ser completada!";
           Errocode = GetLastError();
           showError(Erromsg,Errocode);
          }
    }
}
//+------------------------------------------------------------------+
//| OPENSELL FUNCTION
//| *Tem parâmetros de entrada - tipo de ordem, preço atual de compra, Stop Loss,
//|  Take Profit, deviation, comment
//| *Checa a conta margem liver antes de negociar se escolher negociar
//| *Alerta de sucesso se a posição for aberta ou mostra erro
//+------------------------------------------------------------------+
void MyExpert::openSell(ENUM_ORDER_TYPE otype,double bidprice,double SL,double TP,int dev,string comment="")
{
//--- Checar margem
if(Chk_Margin==1)
  {
   if(MarginOK()==false)
     {
      Erromsg = "Você não tem dinheiro suficiente para abrir essa posição!!!";
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
        if(tresult.retcode == 10009 || tresult.retcode == 10008) //Requisição bem sucedida
          {
           Alert("A ordem de venda foi colocada com sucesso com Ticket#: ",tresult.order,"!!");
          }
        else
          {
           Erromsg ="A requisição de ordem de venda não pode ser completada!";
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
        if(tresult.retcode == 10009 || tresult.retcode == 10008) //Requisição bem sucedida
          {
           Alert("A ordem de venda foi colocada com sucesso com Ticket#: ",tresult.order,"!!");
          }
        else
          {
           Erromsg ="A requisição de ordem de venda não pode ser completada!";
           Errocode = GetLastError();
           showError(Erromsg,Errocode);
          }
  }  
}