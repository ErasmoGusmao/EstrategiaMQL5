//+------------------------------------------------------------------+
//|                                                EA_Long_short.mq5 |
//|                                                           Erasmo |
//|                             https://www.mql5.com/pt/articles/100 |
//+------------------------------------------------------------------+
#property copyright "Erasmo"
#property link      "https://www.mql5.com/pt/articles/100"
#property version   "1.00"
//--- input parameters
input int      StopLoss=30;         //Stop Loss(Somente de leitura) - em pontos (se for a��o 1 ponto = R$0,01)
input int      TakeProfit=100;      //Take Profit(Somente de leitura) - em pontos (se for a��o 1 ponto = R$0,01)
input int      ADX_Period=8;        //Per�odo do indicador ADX
input int      MA_Period=8;         //Pr�odo da m�dia
input int      EA_Magic=12345;      //N�mero m�gico ID do EA
input double   ADX_Min=22.0;        //Menor valor do ADX
input double   Lot=100;             //Lotes para opera��es de Trade
//--- outros par�metros
int adxHandle;                      //Manipulador do indicador ADX
int maHandle;                       //Manipulador do indicador de m�dia m�vel
double plsDI[],minDI[],adxVal[];    //Arrays din�micos que guardam os valores de +DI(plsDI), -DI(minDI) e ADX(adxVal) de cada barra
double maVal[];                     //Armazena todos os valores da m�dia m�vel
double p_close;                     //Vari�vel que armazena os valores do pre�o de fechamento de uma barra
int STP,TKP;                        //Manipular os valores do Stop Loss e no Take Profit, pois esses par�metros de entrada s�o somente de leitura
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Pegar o manipulador do indicador ADX
      adxHandle=iADX(NULL,0,ADX_Period);     //Ele toma o s�mbolo do gr�fico (NULL - tamb�m significa o s�mbolo atual no gr�fico atual), o per�odo 0 tamb�m significa o per�odo atual do gr�fico atual
//--- Pegar o manipulador da m�dia m�vel e defino como M�dia m�vel exponencial
      maHandle=iMA(_Symbol,_Period,MA_Period,0,MODE_EMA,PRICE_CLOSE); //Simbolo do gr�fico pode ser obtido como  _symbol, symbol() ou NULL; O per�odo atual do gr�fico pode ser obtido como _period, period(), ou 0
//--- Validar o retorno dos manipuladores dos indicadores
      if(adxHandle<0 || maHandle<0)
        {
         Alert("Erro criado pelos manipuladores dos indicadores - erro: ",GetLastError(),"!!");
        }
//--- Trabalhar com pares de pre�os como 5 ou 3 d�gitos  em vez de 4
      STP = StopLoss;
      TKP = TakeProfit;
      if(_Digits==5||_Digits==3)
        {
         STP*=10; //ou STP=STP*10
         TKP*=10; //ou TKP=TKP*10
        }
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Perceber os manipuladores dos indicadores
   IndicatorRelease(adxHandle);
   IndicatorRelease(maHandle);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {   
//--- Esperar que tenhamos barras sufucientes para trabalhar
   if(Bars(Symbol(),Period())<60)   //Se o total de barras � menor que 60
     {
      Alert("N�s temos menos de 60 barras, o EA ir� sair!!");
      return;
     }

   // Usar a vari�vel static Old_Time para trabalhar com a barra de tempo.
   // Para cada execu��o do OnTick iremos comparar a barra de tempo atual com a salva.
   // Se a barra de tempo n�o for igual a de tempo salva, isso indeica que temos um novo tick.
   static datetime Old_Time;
   datetime New_Time[1];
   bool IsNewBar=false;
//--- Copiando a ultima barra de tempo para New_Time[0]
   int copied=CopyTime(Symbol(),Period(),0,1,New_Time);
   if(copied>0)   //O.k! Dado foi copiado com sucesso!
     {
      if(Old_Time!=New_Time[0])
        {
         IsNewBar=true;    //Se isso n�o for a primeira chamada, a nova barra apareceu
         //if(MQL5InfoInteger(MQL5_DEBUGGING))
           {
            Print("We have new bar here ",New_Time[0]," old time was ",Old_Time);
           }
           Old_Time=New_Time[0]; //Salva a barra de tempo
        }
     }
     else
        {
         Alert("Erro ao copiar o hist�rico das datas dos dados, erro =",GetLastError());
         ResetLastError();
         return;
        }

//--- EA dever� checar o novo trade se n�s tivermos uma nova barra
   if(IsNewBar==false)
     {
      return;
     }

//--- Temos barra suficientes para trabalhar
   int Mybars=Bars(Symbol(),Period());
   if(Mybars<60)
     {
      Alert("N�s temos menos de 60 barras, o EA ir� sair!!");
      return;
     }

//--- Define algumas estruturas que ser�o usadas nos trades
   MqlTick last_price;        //Para pegar o ultimo(mais recente) pre�o das cota��es
   MqlTradeRequest mrequest;  //Para enviar nosso pedido de trade
   MqlTradeResult mresult;    //Para pegar o resultado do nosso trade
   MqlRates mrate[];          //Para armazenar os pre�os, os volumes e spreads de cada barra
   ZeroMemory(mrequest);      //Para inicar a minha estrutura mrequest

//--- Certificar que os valores de Rates, ADX, MA estam armazenados de forma similar em timesires array
//--- Array Rates
   ArraySetAsSeries(mrate,true);
//--- Array ADX +DI
   ArraySetAsSeries(plsDI,true);
//--- Array ADX -DI
   ArraySetAsSeries(minDI,true);
//--- Array ADX
   ArraySetAsSeries(adxVal,true);
//--- Array MA
   ArraySetAsSeries(maVal,true);
   
//--- Pegar a ultima cota��o dos pre�os usando a estrutura do MQL5 MqlTick
   if(!SymbolInfoTick(Symbol(),last_price))
     {
      Alert("Erro ao pegar a cota��o do ultimo pre�o - erro: ", GetLastError(),"!!");
      return;
     }
//--- Pegar os detalhes das ultimas 3 barras
   if(CopyRates(Symbol(),Period(),0,3,mrate)<0)
     {
      Alert("Erro ao copiar ratas/hist�rico dos dados - erro: ", GetLastError(),"!!");
      return;
     }
//--- Copiando os novos valores dos indicadores para os buffers (arrays) usando os manipuladores (handle)
   if(CopyBuffer(adxHandle,0,0,3,adxVal) < 0 || CopyBuffer(adxHandle,1,0,3,plsDI) < 0 || CopyBuffer(adxHandle,2,0,3,minDI) < 0)
     {
      Alert("Erro ao copiar o indicado ADX para o buffer - erro: ", GetLastError(),"!!");
      return;
     }
   if(CopyBuffer(maHandle,0,0,3,maVal)<0)
     {
      Alert("Erro ao copiar o indicado MA(m�dia m�vel) para o buffer - erro: ", GetLastError(),"!!");
      return;
     }
   //N�s n�o tempos erro, ent�o continue.
   //Nesse momento, queremos verificar se n�s j� possu�mos uma posi��o de compra ou venda aberta.
   //Em outras palavras, n�s queremos nos certificar de que n�s possu�mos UMA negocia��o de compra ou venda aberta de cada vez.
   //N�s n�o queremos abrir uma nova compra se n�s j� possu�mos uma, e n�s n�o queremos abrir uma nova venda se n�s j� abrimos uma.
//--- N�s temos uma posi��o aberta?
   bool Buy_opened=false;     //Vari�vel assegura a posi��o de compra aberta
   bool Sell_opened=false;    //Vari�vel assegura a posi��o de venda aberta
   
   if(PositionSelect(Symbol())==true)  //Se tempos uma posi��o aberta, verifique qual
     {
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         Buy_opened=true;  //� uma compra
        }
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         Sell_opened=true; //� uma venda
        }
     }
     
//--- Armazenar o pre�o de fechamento da barra anterior para configurar nossa compra/venda
   p_close=mrate[1].close; //Pre�o de fechamento anterior
   
   //===============================================================
   //=                  Checar sinal do ADX e MA                   =
   //===============================================================
   /*
      1. Verificar compra o Setup Long/Buy:
      -> MA-8 crescendo sobre o pre�o de fechamento anterior;
      -> ADX > 22 e +DI > -DI
   */
//--- Declarando vari�veis bool para assegurar nossa condi��o de compra (sinais de compra)  
   bool Buy_Condition_1 = (maVal[0]>maVal[1]) && (maVal[1]>maVal[2]);   //Crecimento da m�dia m�vel
   bool Buy_Condition_2 = (p_close > maVal[1]);                         //Pre�o de fechamento anterior maior que a m�dia m�vel anterior
   bool Buy_Condition_3 = (adxVal[0] > ADX_Min);                        //Valor atual do indicado ADX > 22 (definido inicialmente)
   bool Buy_Condition_4 = (plsDI[0] > minDI[0]);                        //+DI > -DI
   
//--- Avaliando os sinais de compra
   if(Buy_Condition_1 && Buy_Condition_2)
     {
      if(Buy_Condition_3 && Buy_Condition_4)
        {
         // Alguma posi��o de compra aberta?
         if(Buy_opened)
           {
            Alert("J� temos uma posi��o de compra!");
            return; //N�o abra uma nova posi��o
           }
           mrequest.action = TRADE_ACTION_DEAL;                                       //Executa a ordem a pre�o de mercado imediatamente
           mrequest.price = NormalizeDouble(last_price.ask,Digits());                 //Ultimo pre�o de venda
           mrequest.sl = NormalizeDouble(last_price.ask - STP*Point(),Digits());      //Stop Loss
           mrequest.tp = NormalizeDouble(last_price.ask + TKP*Point(),Digits());      //Tack Profit
           mrequest.symbol = Symbol();                                                //Papel atual
           mrequest.volume = Lot;                                                     //N�mero de Lotes para Trade
           mrequest.magic = EA_Magic;                                                 //ID EA
           mrequest.type = ORDER_TYPE_BUY;                                            //Ordem de compra
           mrequest.type_filling = ORDER_FILLING_FOK;
           mrequest.deviation = 100;                                                  //O m�ximo desvio de pre�o, especificado em pontos       
           //---Envia a ordem
           OrderSend(mrequest,mresult);
        }
        //Pegando o c�digo do resultado
        if(mresult.retcode == 10009 || mresult.retcode == 10008)                       //Requisi��o completa ou ordem colocada
          {
           Alert("A ordem de compra foi colocada com sucesso com Ticket#: ",mresult.order,"!!");
          }
          else
            {
            Alert("A ordem de compra n�o pode ser completada -erro: ", GetLastError(),"!!");
            ResetLastError();
            return;
            }
     }
   /*
      2. Verificar venda o Setup short/Sell:
      -> MA-8 decrescendo sobre o pre�o de fechamento anterior;
      -> ADX > 22 e -DI > +DI
   */
   //--- Declarando vari�veis bool para assegurar nossa condi��o de venda (sinais de venda)  
   bool Sell_Condition_1 = (maVal[0]<maVal[1]) && (maVal[1]<maVal[2]);  //Decrecimento da m�dia m�vel
   bool Sell_Condition_2 = (p_close < maVal[1]);                        //Pre�o de fechamento anterior menor que a m�dia m�vel anterior
   bool Sell_Condition_3 = (adxVal[0] > ADX_Min);                        //Valor atual do indicado ADX > 22 (definido inicialmente)
   bool Sell_Condition_4 = (plsDI[0] < minDI[0]);                        //-DI > +DI

//--- Avaliando os sinais de venda
   if(Sell_Condition_1 && Sell_Condition_2)
     {
      if(Sell_Condition_3 && Sell_Condition_4)
        {
         // Alguma posi��o de venda aberta?
         if(Sell_opened)
           {
           Alert("J� temos uma posi��o de venda!");
            return; //N�o abra uma nova posi��o
           }
           mrequest.action = TRADE_ACTION_DEAL;
           mrequest.price = NormalizeDouble(last_price.bid,Digits());            //Ultimo pre�o de compra
           mrequest.sl = NormalizeDouble(last_price.bid - STP*Point(),Digits()); //Stop Loss
           mrequest.tp = NormalizeDouble(last_price.bid + TKP*Point(),Digits()); //Tack Profit
           mrequest.symbol = Symbol();
           mrequest.volume = Lot;
           mrequest.magic = EA_Magic;
           mrequest.order = ORDER_TYPE_SELL;                                     //Oredem de venda
           mrequest.type_filling = ORDER_FILLING_FOK;
           mrequest.deviation = 100;                                             //O m�ximo desvio de pre�o, especificado em pontos
           //---Envia a ordem
           OrderSend(mrequest,mresult);           
        }
        //Pegando o c�digo do resultado
        if(mresult.retcode == 10009 || mresult.retcode == 10008)                       //Requisi��o completa ou ordem colocada
          {
           Alert("A ordem de venda foi colocada com sucesso com Ticket#: ",mresult.order,"!!");
          }
          else
            {
            Alert("A ordem de venda n�o pode ser completada -erro: ", GetLastError(),"!!");
            ResetLastError();
            return;
            }
     }   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
