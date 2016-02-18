//+------------------------------------------------------------------+
//|                               EA_Long_short_Orientado_Objeto.mq5 |
//|                                                           Erasmo |
//|                             https://www.mql5.com/pt/articles/116 |
//+------------------------------------------------------------------+
#property copyright "Erasmo"
#property link      "https://www.mql5.com/pt/articles/116"
#property version   "1.00"
//--- Incluir classe
//#include "my_expert_class.mqh" //Se estiver no mesmo diret�rio do EA
#include <my_expert_class.mqh>
//--- input parameters
input int      StopLoss=30;         //Stop Loss(Somente de leitura) - em pontos (se for a��o 1 ponto = R$0,01)
input int      TackProfit=100;      //Take Profit(Somente de leitura) - em pontos (se for a��o 1 ponto = R$0,01)
input int      ADX_Period=14;       //Per�odo do indicador ADX
input int      MA_Period=10;        //Pr�odo da m�dia
input int      EA_Magic=54321;      //N�mero m�gico ID do EA
input double   ADX_Min=22.0;        //Menor valor do ADX
input double   Lot=100.0;           //Lotes para opera��es de Trade
input int      Margin_Chk=0;        //Checar Margem antes de negociar (0=N�o, 1=SIM)
input double   Trd_percent=15.0;    // Porcentage de margem l�ivre para negociar
//--- Outros par�metro
int STP,TKP;                        //Manipular os valores do Stop Loss e no Take Profit, pois esses par�metros de entrada s�o somente de leitura
//--- Criando o objeto na nossa classe my_expert_class.mqh
MyExpert Cexpert;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Inicializando fun��o
   Cexpert.doInit(ADX_Period,MA_Period);
//--- setando todas as outras vari�veis necess�rias para nossa classe objeto
   Cexpert.setPeriod(Period());     //Seta o per�do do gr�fico
   Cexpert.setSymbol(Symbol());     //Seta o simbolo atual do papel do gr�fico
   Cexpert.setMagic(EA_Magic);
   Cexpert.setadxmin(ADX_Min);      //Seta o menor valor para ADX
   Cexpert.setLOTS(Lot);
   Cexpert.setchkMAG(Margin_Chk);   //Seta checagem de margem
   Cexpert.setTRpct(Trd_percent);   //Seta o percentual de margem livre
//--- Trabalhar com pares de pre�os como 5 ou 3 d�gitos  em vez de 4
      STP = StopLoss;
      TKP = TackProfit;
      if(_Digits==5||_Digits==3)
        {
         STP*=10; //ou STP=STP*10
         TKP*=10; //ou TKP=TKP*10
        }
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Desinicializa��o do EA
   Cexpert.doUninit();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Esperar que tenhamos barras sufucientes para trabalhar
   int Mybars=Bars(Symbol(),Period());
   if(Mybars<60)           //Se o total de barras � menor que 60
     {
      Alert("N�s temos menos de 60 barras, o EA ir� sair!!");
      return;
     }
//--- Define algumas MQL5 estruturas para negociar
   MqlTick last_price;   //Ser� usado para pegar a cota��o mais recente de pre�o
   MqlRates mrate[];      //Ser� usado para armazenar pre�o, volume, sprede de cada barra
//--- Organizando dados
   ArraySetAsSeries(mrate,true);
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
//--- O EA deve apenas checar para o novo neg�cio se temos uma nova barra
   static datetime Prev_time;
//--- Pegar o tempo inicial da barra atual
   datetime Bar_time[1];
//--- copia o tempo
   Bar_time[0]=mrate[0].time;
//--- N�o teremos uma nova barra se o tempo for o mesmo
   if(Prev_time == Bar_time[0])
     {
      return;
     }
//--- Copia Prev_time para valor est�tico
   Prev_time = Bar_time[0];
//--- N�o temo erro, ent�o continue
//--- Verificar se temos posi��o aberta
   bool Buy_opened = false, Sell_opened = false;      //Vari�veis para asegura a abertura da posi��o
   if(PositionSelect(Symbol())==true) //Estamos posicionados
     {
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         Buy_opened = true; // Est� comprado
        }
      else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         Sell_opened = true; //Est� vendido
        }
     }
//--- Copiar o pre�o da barra anterior
   Cexpert.setCloseprice(mrate[1].close);    // Fechamento da barra anterior
//--- Checar a posi��o de compra
   if(Cexpert.checkBuy()==true)
     {
      // Estamos prontos para abrir uma posi��o de compra
      if(Buy_opened)
        {
         Alert("N�s j� temo uma posi��o de compra aberta!!");
         return; //N�o abre uma nova posi��o comprada
        }
      double aprice = NormalizeDouble(last_price.ask,Digits());           //Pre�o atual de venda
      double stl = NormalizeDouble(last_price.ask - STP*Point(),Digits());  //Stop Loss
      double tkp = NormalizeDouble(last_price.ask + TKP*Point(),Digits());  //Tack Profit
      int mdev = 100;                                                        //m�ximo desvio
      //Coloca a ordem
      Cexpert.openBuy(ORDER_TYPE_BUY,aprice,stl,tkp,mdev);
     }
//--- Checar a posi��o de venda
   if(Cexpert.checkSell()==true)
     {
      // Estamos prontos para abrir uma posi��o de venda
      if(Sell_opened)
        {
         Alert("N�s j� temo uma posi��o de venda aberta!!");
         return; //N�o abre uma nova posi��o comprada
        }
      double bprice = NormalizeDouble(last_price.bid,Digits());              //Pre�o atual de compra
      double bstl = NormalizeDouble(last_price.bid - STP*Point(),Digits());  //Stop Loss
      double btkp = NormalizeDouble(last_price.bid + TKP*Point(),Digits());  //Tack Profit
      int bdev = 100;                                                        //m�ximo desvio
      //Coloca a ordem
      Cexpert.openSell(ORDER_TYPE_SELL,bprice,bstl,btkp,bdev);
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
