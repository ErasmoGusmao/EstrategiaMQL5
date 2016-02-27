//+------------------------------------------------------------------+
//|                               EA_Long_short_Orientado_Objeto.mq5 |
//|                                                           Erasmo |
//|                             https://www.mql5.com/pt/articles/116 |
//+------------------------------------------------------------------+
#property copyright "Erasmo"
#property link      "https://www.mql5.com/pt/articles/116"
#property version   "1.00"
//--- Incluir classe
//#include "my_expert_class.mqh" //Se estiver no mesmo diretório do EA
#include <ERASMO\my_expert_class.mqh>
//--- input parameters
input int      StopLoss=30;         //Stop Loss(Somente de leitura) - em pontos (se for ação 1 ponto = R$0,01)
input int      TackProfit=100;      //Take Profit(Somente de leitura) - em pontos (se for ação 1 ponto = R$0,01)
input int      ADX_Period=14;       //Período do indicador ADX
input int      MA_Period=10;        //Príodo da média
input int      EA_Magic=54321;      //Número mágico ID do EA
input double   ADX_Min=22.0;        //Menor valor do ADX
input double   Lot=100.0;           //Lotes para operações de Trade
input int      Margin_Chk=0;        //Checar Margem antes de negociar (0=Não, 1=SIM)
input double   Trd_percent=15.0;    // Porcentage de margem lçivre para negociar
//--- Outros parâmetro
int STP,TKP;                        //Manipular os valores do Stop Loss e no Take Profit, pois esses parâmetros de entrada são somente de leitura
//--- Criando o objeto na nossa classe my_expert_class.mqh
MyExpert Cexpert;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Inicializando função
   Cexpert.doInit(ADX_Period,MA_Period);
//--- setando todas as outras variáveis necessárias para nossa classe objeto
   Cexpert.setPeriod(Period());     //Seta o perído do gráfico
   Cexpert.setSymbol(Symbol());     //Seta o simbolo atual do papel do gráfico
   Cexpert.setMagic(EA_Magic);
   Cexpert.setadxmin(ADX_Min);      //Seta o menor valor para ADX
   Cexpert.setLOTS(Lot);
   Cexpert.setchkMAG(Margin_Chk);   //Seta checagem de margem
   Cexpert.setTRpct(Trd_percent);   //Seta o percentual de margem livre
//--- Trabalhar com pares de preços como 5 ou 3 dígitos  em vez de 4
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
//--- Desinicialização do EA
   Cexpert.doUninit();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Esperar que tenhamos barras sufucientes para trabalhar
   int Mybars=Bars(Symbol(),Period());
   if(Mybars<60)           //Se o total de barras é menor que 60
     {
      Alert("Nós temos menos de 60 barras, o EA irá sair!!");
      return;
     }
//--- Define algumas MQL5 estruturas para negociar
   MqlTick last_price;   //Será usado para pegar a cotação mais recente de preço
   MqlRates mrate[];      //Será usado para armazenar preço, volume, sprede de cada barra
//--- Organizando dados
   ArraySetAsSeries(mrate,true);
//--- Pegar a ultima cotação dos preços usando a estrutura do MQL5 MqlTick
   if(!SymbolInfoTick(Symbol(),last_price))
     {
      Alert("Erro ao pegar a cotação do ultimo preço - erro: ", GetLastError(),"!!");
      return;
     }
//--- Pegar os detalhes das ultimas 3 barras
   if(CopyRates(Symbol(),Period(),0,3,mrate)<0)
     {
      Alert("Erro ao copiar ratas/histórico dos dados - erro: ", GetLastError(),"!!");
      return;
     }
//--- O EA deve apenas checar para o novo negócio se temos uma nova barra
   static datetime Prev_time;
//--- Pegar o tempo inicial da barra atual
   datetime Bar_time[1];
//--- copia o tempo
   Bar_time[0]=mrate[0].time;
//--- Não teremos uma nova barra se o tempo for o mesmo
   if(Prev_time == Bar_time[0])
     {
      return;
     }
//--- Copia Prev_time para valor estático
   Prev_time = Bar_time[0];
//--- Não temo erro, então continue
//--- Verificar se temos posição aberta
   bool Buy_opened = false, Sell_opened = false;      //Variáveis para asegura a abertura da posição
   if(PositionSelect(Symbol())==true) //Estamos posicionados
     {
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         Buy_opened = true; // Está comprado
        }
      else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         Sell_opened = true; //Está vendido
        }
     }
//--- Copiar o preço da barra anterior
   Cexpert.setCloseprice(mrate[1].close);    // Fechamento da barra anterior
//--- Checar a posição de compra
   if(Cexpert.checkBuy()==true)
     {
      // Estamos prontos para abrir uma posição de compra
      if(Buy_opened)
        {
         Alert("Nós já temo uma posição de compra aberta!!");
         return; //Não abre uma nova posição comprada
        }
      double aprice = NormalizeDouble(last_price.ask,Digits());           //Preço atual de venda
      double stl = NormalizeDouble(last_price.ask - STP*Point(),Digits());  //Stop Loss
      double tkp = NormalizeDouble(last_price.ask + TKP*Point(),Digits());  //Tack Profit
      int mdev = 100;                                                        //máximo desvio
      //Coloca a ordem
      Cexpert.openBuy(ORDER_TYPE_BUY,aprice,stl,tkp,mdev);
     }
//--- Checar a posição de venda
   if(Cexpert.checkSell()==true)
     {
      // Estamos prontos para abrir uma posição de venda
      if(Sell_opened)
        {
         Alert("Nós já temo uma posição de venda aberta!!");
         return; //Não abre uma nova posição comprada
        }
      double bprice = NormalizeDouble(last_price.bid,Digits());              //Preço atual de compra
      double bstl = NormalizeDouble(last_price.bid - STP*Point(),Digits());  //Stop Loss
      double btkp = NormalizeDouble(last_price.bid + TKP*Point(),Digits());  //Tack Profit
      int bdev = 100;                                                        //máximo desvio
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
