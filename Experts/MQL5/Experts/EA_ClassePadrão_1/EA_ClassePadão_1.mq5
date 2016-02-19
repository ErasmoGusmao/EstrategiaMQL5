//+------------------------------------------------------------------+
//|                                            EA_ClassePadr�o_1.mq5 |
//|                                                           Erasmo |
//|                             https://www.mql5.com/pt/articles/138 |
//+------------------------------------------------------------------+
#property copyright "Erasmo"
#property link      "https://www.mql5.com/pt/articles/138"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Incluir todas as Classes padr�o que ser�o usadas                 |
//+------------------------------------------------------------------+
//--- Incluido a classe de negocia��o
#include <Trade\Trade.mqh>
//--- Incluido a classe de informa��o da posi��o
#include <Trade\PositionInfo.mqh>
//--- Incluido a classe com informa��o da conta
#include <Trade\AccountInfo.mqh>
//--- Incluido a classe SymbolInfo
#include <Trade\SymbolInfo.mqh>
//+------------------------------------------------------------------+
//| Defini��o dos par�metro de entrada                               |
//+------------------------------------------------------------------+
input int      StopLoss=100;                 //Stop Loss (SL em pontos)
input int      TakeProfit=240;               //Take Profit (TK em pontos)
input int      ADX_Period=15;                //Per�odo do indicador ADX
input int      MA_Period=15;                 //Per�odo do indicado de M�dia M�vel
input ulong    EA_Magic=99977;               //ID do Expert Adivisor
input double   Adx_min=24;                 //Menor valor para o ADX
input double   Lot=100.0;                    //Lote de negocia��o
input ulong    dev=100;                      //Desvio
input long     Trail_point=32;               //Pontos para incremento TP/SL
input int      Min_Bar=20;                   //Minimo de barras para o EA negociar
input double   TradePct=25;                  //Porcentagem da conta margem livre para negocia��o
//+------------------------------------------------------------------+
//| Outros par�metros que ser�o usados                               |
//+------------------------------------------------------------------+
int            adxHandle;                    //Manipulador do indicador ADX
int            maHandle;                     //Manipulador do indicador M�dia M�vel
double   plsDI[],minDI[],adxVal[];           //Amazena os valores +DI, -DI e ADX de cada barra
double         maVal[];                      //Armazena os valores da m�dia m�vel de cada barra
double         p_close;                      //Armazena o pre�o de fechamento da barra
int            STP,TKP;                      //Ser� usado para o Stop Loss e Take Profit (valores de entra somente de leitura)
double         TPC;                          //Ser� usado na porcentagem de margem livre da conta
//+------------------------------------------------------------------+
//| Objetos das classes incluidas                                    |
//+------------------------------------------------------------------+
//--- Incluido a classe de negocia��o
CTrade         mytrade;
//--- Incluido a classe de informa��o da posi��o
CPositionInfo  myposition;
//--- Incluido a classe com informa��o da conta
CAccountInfo   myaccount;
//--- Incluido a classe SymbolInfo
CSymbolInfo    mysymbol;
//+------------------------------------------------------------------+
//|  Checar se o Expert Advisor pode seguir com as negocia��es       |
//+------------------------------------------------------------------+
bool checkTrading()
{
   bool can_trade = false;
   //Checar se o termina est� sincronizado com o servidor
   if(myaccount.TradeAllowed() && myaccount.TradeExpert() && mysymbol.IsSynchronized())
     {
      //Temos barras suficientes?
      int mbars = Bars(Symbol(),Period());
      if(mbars>Min_Bar)
        {
         can_trade=true;
        }
     }
     return(can_trade);
}
//+------------------------------------------------------------------+
//|  Confimar se a margem � suficiente para abrir uma ordem
//+------------------------------------------------------------------+
bool ConfirmMargin(ENUM_ORDER_TYPE otype, double price)
{
   bool confirm = false;
   double lot_price = myaccount.MarginCheck(Symbol(),otype,Lot,price);  // Pre�o Lote / Margem
   double act_f_mag = myaccount.FreeMargin();                           //Conta de margem livre
   // Checar se a margem requerida est� o.k
   if(MathFloor(act_f_mag*TPC)>MathFloor(lot_price))
     {
      confirm = true;
     }
     return(confirm);
}
//+------------------------------------------------------------------+
//|  (Sinal 1) Checar as condi��es de negocia��o de compra           |
//+------------------------------------------------------------------+
bool  checkBuy()
{
   bool dobuy = false;
   if((maVal[0] > maVal[1]) && (maVal[1] > maVal[2]) && (p_close > maVal[1])) 
     {//Verifica crescimento da m�dia e se o pre�o anterior fechou acima da m�dia
      if((adxVal[1]>Adx_min) && (plsDI[1] > minDI[1]))
        {//ADX � maior que o m�nimo e +DI � maior que -DI
         dobuy = true;
        }
     }
   return(dobuy);
}
//+------------------------------------------------------------------+
//|  (Sinal 2) Checar as condi��es de negocia��o de venda            |
//+------------------------------------------------------------------+
bool  checkSell()
{
   bool dosell = false;
   if((maVal[0] < maVal[1]) && (maVal[1] < maVal[2]) && (p_close < maVal[1])) 
     {//Verifica decrescimento da m�dia e se o pre�o anterior fechou abaixo da m�dia
      if((adxVal[1]>Adx_min) && (plsDI[1] < minDI[1]))
        {//ADX � maior que o m�nimo e -DI � maior que +DI
         dosell = true;
        }
     }
   return(dosell);
}
//+------------------------------------------------------------------+
//|  Checar se a posi��o aberta pode ser fechada                     |
//+------------------------------------------------------------------+
bool checkClosePos(string ptype, double Closeprice)
{
   bool mark = false;
   if(ptype=="BUY")
     {//Pode fechar essa posi��o
      if(Closeprice < maVal[1])
        {//Se o pre�o de fechameno estiver abaixo da m�dia m�vel
         mark = true;
        }
     }
     if(ptype=="SELL")
       {
        if(Closeprice > maVal[1])
          {//Se o pre�o de fechameno estiver acima da m�dia m�vel
           mark = true;
          }
       }
       return(mark);
}
//+------------------------------------------------------------------+
//| Checar e fechar uma posi��o aberta                                                                |
//+------------------------------------------------------------------+
bool ClosePosition(string ptype, double clp)
{
   bool marker = false;
   if(myposition.Select(Symbol())==true)
     {
      if(myposition.Magic()==EA_Magic && myposition.Symbol()==Symbol())
        {//Verificar se podemos fechar essa posi��o
         if(checkClosePos(ptype,clp)==true)
           {//Checa a posi��o e verifica se fechamos como sucesso
            if(mytrade.PositionClose(Symbol()))
              {//Requisi��o bem sucedida completa
               Alert("Um posi��o aberta foi fechada com sucesso!!");
               marker=true;
              }
            else
              {
               Alert("A requisi��o para o fechamento da posi��o n�o pode ser completada - erro: ",
                     mytrade.ResultRetcodeDescription());
              }  
           }
        }
     }
     return(marker);
}
//+------------------------------------------------------------------+
//|  Checar se podemor modificar um posi��o aberta                   |
//+------------------------------------------------------------------+
bool CheckModify(string otype, double cprc)
{
   bool check = false;
   if(otype == "BUY")
     {
      if((maVal[2] < maVal[1]) && (maVal[1] < maVal[0]) && (cprc > maVal[1]) && (adxVal[1] > Adx_min))
        {
         check = true;
        }
     }
   else if(otype == "SELL")
     {
      if((maVal[2] > maVal[1]) && (maVal[1] > maVal[0]) && (cprc < maVal[1]) && (adxVal[1] > Adx_min))
        {
         check = true;
        }
     }
     return(check);  
}
//+------------------------------------------------------------------+
//| Modifica uma posi��o aberta (Ser� usada no deslocamento)         |
//+------------------------------------------------------------------+
void Modify(string ptype, double stpl, double tkpf)
{//Novo Stop Loss, novo Take Profit, pre�o de compra e pre�o de venda
   double nsp, ntp,pbid,pask;
   long tsp=Trail_point; //Deslocamento
   //--- Ajustar para 5 ou 3 d�gitos
   if(Digits() == 5 || Digits() == 3)
     {
      tsp*=10;
     }
   //--- N�vel do Stop Loss
   long stplevel = mysymbol.StopsLevel();
   //--- Arastar o ponto n�o pode ser menor que o n�vel dos Stops
   if(tsp < stplevel)
     {
      tsp = stplevel;
     }
   if(ptype == "BUY")
     {//Pre�o atual de compra
      pbid = mysymbol.Bid();
      if(tkpf-pbid <= stplevel*Point())
        {//Se a dist�ncia do meu Take Profit for menor ou igual ao n�vel de stop, ent�o aumente
         ntp = pbid + tsp*Point();
         nsp = pbid - tsp*Point();
        }
      else
        {//Se a dist�ncia do meu Take Profit for maior que o n�vel de stop, entam n�o toque no Take Profit
         ntp = tkpf;
         nsp = pbid - tsp*Point();
        }  
     }
   else if(ptype == "SELL")
      {//Pre�o atual de venda
       pask = mysymbol.Ask();
       if(pask - tkpf <= stplevel*Point())
         {
          ntp = pask - tsp*Point();
          nsp = pask + tsp*Point();
         }
       else
         {
          ntp = tkpf;
          nsp = pask + tsp*Point();
         }      
      }
   //--- Modificar e checar o resultado
   if(mytrade.PositionModify(Symbol(),nsp,ntp))
     {//--- Requisi��o concluida com sucesso
      Alert("Uma posi��o de abertura foi modificada com sucesso!!");
      return;
     }
   else
     {
      Alert("A modifica��o da posi��o requisitada n�o pode ser completada - erro: ",
            mytrade.ResultRetcodeDescription());
      return;      
     }           
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setar o nome do papel
   mysymbol.Name(Symbol());
//--- setar o ID do EA
   mytrade.SetExpertMagicNumber(EA_Magic);
//--- setar o desvio m�ximo
   mytrade.SetDeviationInPoints(dev);
//--- pegar o manipulador do indicador ADX
   adxHandle =iADX(NULL,0,ADX_Period);
//--- pegar o manipulador de m�dia m�vel
   maHandle = iMA(Symbol(),Period(),MA_Period,0,MODE_EMA,PRICE_CLOSE);
//--- Validar retorno dos manipuladores dos indicadores
   if(adxHandle<0 || maHandle<0)
     {
      Alert("Erro gerado pelos manipuladore dos indicadores ADX e MA - erro: ", GetLastError(),"!!");
      return(1);
     }
    STP = StopLoss;
    TKP = TakeProfit;
//--- Tratar os pre�os se tiverem 5 ou 3 digitos
   if(Digits() == 5 || Digits() == 3)
     {
      STP*=10;    //Ou STP=STP*100;
      TKP*=10;
     }
//--- Setar a porcentagem de negocia��o
   TPC = TradePct;
   TPC/=100;      //Ou TPC = TPC/100;             
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Liberar todos os tratadores de indicadores
   IndicatorRelease(adxHandle);
   IndicatorRelease(maHandle);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Checar se EA pode negociar
   if(checkTrading() == false)
     {
      Alert("O EA n�o pode negociar porque certas exig�ncias n�o foram satisfeitas!");
      return;
     }
   MqlRates mrate[];       //Ser� usado para armazenar dados do papel
//-- Organizar os dados armazenados adxVal, pulsDI, minDi, maVal
   ArraySetAsSeries(mrate,true);
   ArraySetAsSeries(adxVal,true);
   ArraySetAsSeries(maVal,true);
   ArraySetAsSeries(plsDI,true);
   ArraySetAsSeries(minDI,true);    
  
  //--- Pegar o ultimo pre�o da cota��o
   if(!mysymbol.RefreshRates())
     {
      Alert("Erro ao pegar a ultima cota��o de pre�o - erro: ",GetLastError());
      return;
     }
//--- Pegar dados das 3 barras
   if(CopyRates(Symbol(),Period(),0,3,mrate)<0)
     {
      Alert("Erro ao copiar dados hist�ricos - erro: ", GetLastError());
      return;
     }
//--- EA deve checar um novo neg�cio se tivermos uma nova barra
   static datetime Prev_time;
//--- Vamos pegar o tempo inicial para a barra atual (Bar 0)
   datetime Bar_time[1];
//--- Copiar a barra atual
   Bar_time[0] = mrate[0].time;
   if(Prev_time==Bar_time[0])
     {//N�o temos barra nova
      return;
     }
   Prev_time = Bar_time[0];
//--- Compiar os novos valores dos indicadores no buffer
   if(CopyBuffer(adxHandle,0,0,3,adxVal)<0 || CopyBuffer(adxHandle,1,0,3,plsDI)<0 ||
      CopyBuffer(adxHandle,2,0,3,minDI)<0)
     {
      Alert("Erro ao copiar dados dos indicadores ADX no buffer - erro: ", GetLastError(),"!!");
      return;
     }
   if(CopyBuffer(maHandle,0,0,3,maVal)<0)
     {
      Alert("Erro ao copiar dados dos indicadores de M�dia M�vel no buffer - erro: ", GetLastError());
      return;
     }
//--- N�o temos erros, ent�o continue
//--- Copiar o valor do pre�o de fechamento anterior
   p_close = mrate[1].close;
//--- Verificar se temos ainda alguma posi��o aberta
   bool Buy_opened = false, Sell_opened = false;
      if(myposition.Select(Symbol())==true)
        {//temos uma posi��o aberta
         if(myposition.Type()==POSITION_TYPE_BUY)
           {//Posi��o comprada est� aberta
            Buy_opened=true;
            //Pega meu Stop Lost e Take Profit
            double buysl = myposition.StopLoss();
            double buytp = myposition.TakeProfit();
            //Verificar se podemos fechar ou modificar a posi��o
            if(ClosePosition("BUY",p_close)==true)
              {
               Buy_opened=false;    //Fecha a posi��o
               return;              //Espera a nova barra
              }
            else
              {
               if(CheckModify("BUY",p_close)==true)//n�s podemos modificar
                 {
                  Modify("BUY",buysl,buytp);
                  return;           //Espera a nova barra
                 }
              }  
           }
          else if(myposition.Type()==POSITION_TYPE_SELL)
            {//Posi��o vendida est� aberta
             Sell_opened=true;
             //Pega Stop Loss e Take Profit
             double sellsl = myposition.StopLoss();
             double selltp = myposition.TakeProfit();
             //Verificar se podemos fechar ou modificar a posi��o
             if(ClosePosition("SELL",p_close)==true)
               {
                Sell_opened=false;    //Fecha a posi��o
                return;               //Espera a nova barra
               }
             else
               {
                if(CheckModify("SELL",p_close)==true)//n�s podemos modificar
                  {
                   Modify("BUY",sellsl,selltp);
                   return;
                  }
               }  
            }          
        }
//--- Checar compra        
   if(checkBuy()==true)
     {//Algumap posi��o de compra aberta?
      if(Buy_opened)
        {
         Alert("Ainda temos uma posi��o de compra!!");
         return;
        }
       
       double mprice = NormalizeDouble(mysymbol.Ask(),Digits());     //Ultimo pre�o de venda
       double stloss = NormalizeDouble(mysymbol.Ask() - STP*Point(),Digits()); //Stop Loss
       double tprofit= NormalizeDouble(mysymbol.Ask() + TKP*Point(),Digits()); //Take Profit
       
       //Checar margem 
       if(ConfirmMargin(ORDER_TYPE_BUY,mprice)==false)
         {
          Alert("Voce n�o tem dinheiro suficiente para esse neg�cio!");
          return;
         }
       // Abrir a posi��o de compra e checa o resultado
       if(mytrade.Buy(Lot,Symbol(),mprice,stloss,tprofit))
         {//Requisi��o completa e colocada
          Alert("Uma ordem de compra foi colocada com sucesso com Ticket#: ",mytrade.ResultDeal(),"!!");
         }
       else
         {
          Alert("A requisi��o de ordem de compra com vol: ",mytrade.RequestVolume(),
                ", sl: ",mytrade.RequestSL(),", tp: ",mytrade.RequestTP(),
                ", pre�o: ", mytrade.RequestPrice(),
                ", n�o pode ser completada - erro: ",mytrade.ResultRetcodeDescription());
          return;      
         }
     }
//--- Checar venda 
if(checkSell()==true)
     {//Algumap posi��o de venda aberta?
      if(Sell_opened)
        {
         Alert("Ainda temos uma posi��o de venda!!");
         return;
        }
       
       double sprice = NormalizeDouble(mysymbol.Bid(),Digits());     //Ultimo pre�o de compra
       double sstloss = NormalizeDouble(mysymbol.Bid() + STP*Point(),Digits()); //Stop Loss
       double stprofit= NormalizeDouble(mysymbol.Bid() - TKP*Point(),Digits()); //Take Profit
       
       //Checar margem 
       if(ConfirmMargin(ORDER_TYPE_SELL,sprice)==false)
         {
          Alert("Voce n�o tem dinheiro suficiente para esse neg�cio!");
          return;
         }
       // Abrir a posi��o de venda e checa o resultado
       if(mytrade.Sell(Lot,Symbol(),sprice,sstloss,stprofit))
         {//Requisi��o completa e colocada
          Alert("Uma ordem de venda foi colocada com sucesso com Ticket#: ",mytrade.ResultDeal(),"!!");
         }
       else
         {
          Alert("A requisi��o de ordem de venda com vol: ",mytrade.RequestVolume(),
                ", sl: ",mytrade.RequestSL(),", tp: ",mytrade.RequestTP(),
                ", pre�o: ", mytrade.RequestPrice(),
                ", n�o pode ser completada - erro: ",mytrade.ResultRetcodeDescription());
          return;      
         }
     }
//--- FIM!!  
  }
//+------------------------------------------------------------------+
