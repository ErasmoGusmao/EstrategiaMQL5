//+------------------------------------------------------------------+
//|                                         EA_Trail_ClassePadao.mq5 |
//|                                                           Erasmo |
//|                             https://www.mql5.com/pt/articles/138 |
//+------------------------------------------------------------------+
#property copyright "Erasmo"
#property link      "https://www.mql5.com/pt/articles/138"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Incluir todas as Classes padrão que serão usadas                 |
//+------------------------------------------------------------------+
//--- Incluido a classe de negociação
#include <Trade\Trade.mqh>
//--- Incluido a classe de informação da posição
#include <Trade\PositionInfo.mqh>
//--- Incluido a classe com informação da conta
#include <Trade\AccountInfo.mqh>
//--- Incluido a classe SymbolInfo
#include <Trade\SymbolInfo.mqh>
//+------------------------------------------------------------------+
//| Definição dos parâmetro de entrada                               |
//+------------------------------------------------------------------+
input int      StopLoss=100;                 //Stop Loss (SL em pontos)
input int      TakeProfit=240;               //Take Profit (TK em pontos)
input int      ADX_Period=15;                //Período do indicador ADX
input int      MA_Period=15;                 //Período do indicado de Média Móvel
input ulong    EA_Magic=99977;               //ID do Expert Adivisor
input double   Adx_min=24;                 //Menor valor para o ADX
input double   Lot=100.0;                    //Lote de negociação
input ulong    dev=100;                      //Desvio
input long     Trail_point=32;               //Pontos para incremento TP/SL
input int      Min_Bar=20;                   //Minimo de barras para o EA negociar
input double   TradePct=25;                  //Porcentagem da conta margem livre para negociação
//+------------------------------------------------------------------+
//| Outros parâmetros que serão usados                               |
//+------------------------------------------------------------------+
int            adxHandle;                    //Manipulador do indicador ADX
int            maHandle;                     //Manipulador do indicador Média Móvel
double   plsDI[],minDI[],adxVal[];           //Amazena os valores +DI, -DI e ADX de cada barra
double         maVal[];                      //Armazena os valores da média móvel de cada barra
double         p_close;                      //Armazena o preço de fechamento da barra
int            STP,TKP;                      //Será usado para o Stop Loss e Take Profit (valores de entra somente de leitura)
double         TPC;                          //Será usado na porcentagem de margem livre da conta
//+------------------------------------------------------------------+
//| Objetos das classes incluidas                                    |
//+------------------------------------------------------------------+
//--- Incluido a classe de negociação
CTrade         mytrade;
//--- Incluido a classe de informação da posição
CPositionInfo  myposition;
//--- Incluido a classe com informação da conta
CAccountInfo   myaccount;
//--- Incluido a classe SymbolInfo
CSymbolInfo    mysymbol;
//+------------------------------------------------------------------+
//|  Checar se o Expert Advisor pode seguir com as negociações       |
//+------------------------------------------------------------------+
bool checkTrading()
{
   bool can_trade = false;
   //Checar se o termina está sincronizado com o servidor
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
//|  Confimar se a margem é suficiente para abrir uma ordem
//+------------------------------------------------------------------+
bool ConfirmMargin(ENUM_ORDER_TYPE otype, double price)
{
   bool confirm = false;
   double lot_price = myaccount.MarginCheck(Symbol(),otype,Lot,price);  // Preço Lote / Margem
   double act_f_mag = myaccount.FreeMargin();                           //Conta de margem livre
   // Checar se a margem requerida está o.k
   if(MathFloor(act_f_mag*TPC)>MathFloor(lot_price))
     {
      confirm = true;
     }
     return(confirm);
}
//+------------------------------------------------------------------+
//|  (Sinal 1) Checar as condições de negociação de compra           |
//+------------------------------------------------------------------+
bool  checkBuy()
{
   bool dobuy = false;
   if((maVal[0] > maVal[1]) && (maVal[1] > maVal[2]) && (p_close > maVal[1])) 
     {//Verifica crescimento da média e se o preço anterior fechou acima da média
      if((adxVal[1]>Adx_min) && (plsDI[1] > minDI[1]))
        {//ADX é maior que o mínimo e +DI é maior que -DI
         dobuy = true;
        }
     }
   return(dobuy);
}
//+------------------------------------------------------------------+
//|  (Sinal 2) Checar as condições de negociação de venda            |
//+------------------------------------------------------------------+
bool  checkSell()
{
   bool dosell = false;
   if((maVal[0] < maVal[1]) && (maVal[1] < maVal[2]) && (p_close < maVal[1])) 
     {//Verifica decrescimento da média e se o preço anterior fechou abaixo da média
      if((adxVal[1]>Adx_min) && (plsDI[1] < minDI[1]))
        {//ADX é maior que o mínimo e -DI é maior que +DI
         dosell = true;
        }
     }
   return(dosell);
}
//+------------------------------------------------------------------+
//|  Checar se a posição aberta pode ser fechada                     |
//+------------------------------------------------------------------+
bool checkClosePos(string ptype, double Closeprice)
{
   bool mark = false;
   if(ptype=="BUY")
     {//Pode fechar essa posição
      if(Closeprice < maVal[1])
        {//Se o preço de fechameno estiver abaixo da média móvel
         mark = true;
        }
     }
     if(ptype=="SELL")
       {
        if(Closeprice > maVal[1])
          {//Se o preço de fechameno estiver acima da média móvel
           mark = true;
          }
       }
       return(mark);
}
//+------------------------------------------------------------------+
//| Checar e fechar uma posição aberta                                                                |
//+------------------------------------------------------------------+
bool ClosePosition(string ptype, double clp)
{
   bool marker = false;
   if(myposition.Select(Symbol())==true)
     {
      if(myposition.Magic()==EA_Magic && myposition.Symbol()==Symbol())
        {//Verificar se podemos fechar essa posição
         if(checkClosePos(ptype,clp)==true)
           {//Checa a posição e verifica se fechamos como sucesso
            if(mytrade.PositionClose(Symbol()))
              {//Requisição bem sucedida completa
               Alert("Um posição aberta foi fechada com sucesso!!");
               marker=true;
              }
            else
              {
               Alert("A requisição para o fechamento da posição não pode ser completada - erro: ",
                     mytrade.ResultRetcodeDescription());
              }  
           }
        }
     }
     return(marker);
}
//+------------------------------------------------------------------+
//|  Checar se podemor modificar um posição aberta                   |
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
//| Modifica uma posição aberta (Será usada no deslocamento)         |
//+------------------------------------------------------------------+
void Modify(string ptype, double stpl, double tkpf)
{//Novo Stop Loss, novo Take Profit, preço de compra e preço de venda
   double nsp, ntp,pbid,pask;
   long tsp=Trail_point; //Deslocamento
   //--- Ajustar para 5 ou 3 dígitos
   if(Digits() == 5 || Digits() == 3)
     {
      tsp*=10;
     }
   //--- Nível do Stop Loss
   long stplevel = mysymbol.StopsLevel();
   //--- Arastar o ponto não pode ser menor que o nível dos Stops
   if(tsp < stplevel)
     {
      tsp = stplevel;
     }
   if(ptype == "BUY")
     {//Preço atual de compra
      pbid = mysymbol.Bid();
      if(tkpf-pbid <= stplevel*Point())
        {//Se a distância do meu Take Profit for menor ou igual ao nível de stop, então aumente
         ntp = pbid + tsp*Point();
         nsp = pbid - tsp*Point();
        }
      else
        {//Se a distância do meu Take Profit for maior que o nível de stop, entam não toque no Take Profit
         ntp = tkpf;
         nsp = pbid - tsp*Point();
        }  
     }
   else if(ptype == "SELL")
      {//Preço atual de venda
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
     {//--- Requisição concluida com sucesso
      Alert("Uma posição de abertura foi modificada com sucesso!!");
      return;
     }
   else
     {
      Alert("A modificação da posição requisitada não pode ser completada - erro: ",
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
//--- setar o desvio máximo
   mytrade.SetDeviationInPoints(dev);
//--- pegar o manipulador do indicador ADX
   adxHandle =iADX(NULL,0,ADX_Period);
//--- pegar o manipulador de média móvel
   maHandle = iMA(Symbol(),Period(),MA_Period,0,MODE_EMA,PRICE_CLOSE);
//--- Validar retorno dos manipuladores dos indicadores
   if(adxHandle<0 || maHandle<0)
     {
      Alert("Erro gerado pelos manipuladore dos indicadores ADX e MA - erro: ", GetLastError(),"!!");
      return(1);
     }
    STP = StopLoss;
    TKP = TakeProfit;
//--- Tratar os preços se tiverem 5 ou 3 digitos
   if(Digits() == 5 || Digits() == 3)
     {
      STP*=10;    //Ou STP=STP*100;
      TKP*=10;
     }
//--- Setar a porcentagem de negociação
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
      Alert("O EA não pode negociar porque certas exigências não foram satisfeitas!");
      return;
     }
   MqlRates mrate[];       //Será usado para armazenar dados do papel
//-- Organizar os dados armazenados adxVal, pulsDI, minDi, maVal
   ArraySetAsSeries(mrate,true);
   ArraySetAsSeries(adxVal,true);
   ArraySetAsSeries(maVal,true);
   ArraySetAsSeries(plsDI,true);
   ArraySetAsSeries(minDI,true);    
  
  //--- Pegar o ultimo preço da cotação
   if(!mysymbol.RefreshRates())
     {
      Alert("Erro ao pegar a ultima cotação de preço - erro: ",GetLastError());
      return;
     }
//--- Pegar dados das 3 barras
   if(CopyRates(Symbol(),Period(),0,3,mrate)<0)
     {
      Alert("Erro ao copiar dados históricos - erro: ", GetLastError());
      return;
     }
//--- EA deve checar um novo negócio se tivermos uma nova barra
   static datetime Prev_time;
//--- Vamos pegar o tempo inicial para a barra atual (Bar 0)
   datetime Bar_time[1];
//--- Copiar a barra atual
   Bar_time[0] = mrate[0].time;
   if(Prev_time==Bar_time[0])
     {//Não temos barra nova
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
      Alert("Erro ao copiar dados dos indicadores de Média Móvel no buffer - erro: ", GetLastError());
      return;
     }
//--- Não temos erros, então continue
//--- Copiar o valor do preço de fechamento anterior
   p_close = mrate[1].close;
//--- Verificar se temos ainda alguma posição aberta
   bool Buy_opened = false, Sell_opened = false;
      if(myposition.Select(Symbol())==true)
        {//temos uma posição aberta
         if(myposition.Type()==POSITION_TYPE_BUY)
           {//Posição comprada está aberta
            Buy_opened=true;
            //Pega meu Stop Lost e Take Profit
            double buysl = myposition.StopLoss();
            double buytp = myposition.TakeProfit();
            //Verificar se podemos fechar ou modificar a posição
            if(ClosePosition("BUY",p_close)==true)
              {
               Buy_opened=false;    //Fecha a posição
               return;              //Espera a nova barra
              }
            else
              {
               if(CheckModify("BUY",p_close)==true)//nós podemos modificar
                 {
                  Modify("BUY",buysl,buytp);
                  return;           //Espera a nova barra
                 }
              }  
           }
          else if(myposition.Type()==POSITION_TYPE_SELL)
            {//Posição vendida está aberta
             Sell_opened=true;
             //Pega Stop Loss e Take Profit
             double sellsl = myposition.StopLoss();
             double selltp = myposition.TakeProfit();
             //Verificar se podemos fechar ou modificar a posição
             if(ClosePosition("SELL",p_close)==true)
               {
                Sell_opened=false;    //Fecha a posição
                return;               //Espera a nova barra
               }
             else
               {
                if(CheckModify("SELL",p_close)==true)//nós podemos modificar
                  {
                   Modify("BUY",sellsl,selltp);
                   return;
                  }
               }  
            }          
        }
//--- Checar compra        
   if(checkBuy()==true)
     {//Algumap posição de compra aberta?
      if(Buy_opened)
        {
         Alert("Ainda temos uma posição de compra!!");
         return;
        }
       
       double mprice = NormalizeDouble(mysymbol.Ask(),Digits());     //Ultimo preço de venda
       double stloss = NormalizeDouble(mysymbol.Ask() - STP*Point(),Digits()); //Stop Loss
       double tprofit= NormalizeDouble(mysymbol.Ask() + TKP*Point(),Digits()); //Take Profit
       
       //Checar margem 
       if(ConfirmMargin(ORDER_TYPE_BUY,mprice)==false)
         {
          Alert("Voce não tem dinheiro suficiente para esse negócio!");
          return;
         }
       // Abrir a posição de compra e checa o resultado
       if(mytrade.Buy(Lot,Symbol(),mprice,stloss,tprofit))
         {//Requisição completa e colocada
          Alert("Uma ordem de compra foi colocada com sucesso com Ticket#: ",mytrade.ResultDeal(),"!!");
         }
       else
         {
          Alert("A requisição de ordem de compra com vol: ",mytrade.RequestVolume(),
                ", sl: ",mytrade.RequestSL(),", tp: ",mytrade.RequestTP(),
                ", preço: ", mytrade.RequestPrice(),
                ", não pode ser completada - erro: ",mytrade.ResultRetcodeDescription());
          return;      
         }
     }
//--- Checar venda 
if(checkSell()==true)
     {//Algumap posição de venda aberta?
      if(Sell_opened)
        {
         Alert("Ainda temos uma posição de venda!!");
         return;
        }
       
       double sprice = NormalizeDouble(mysymbol.Bid(),Digits());     //Ultimo preço de compra
       double sstloss = NormalizeDouble(mysymbol.Bid() + STP*Point(),Digits()); //Stop Loss
       double stprofit= NormalizeDouble(mysymbol.Bid() - TKP*Point(),Digits()); //Take Profit
       
       //Checar margem 
       if(ConfirmMargin(ORDER_TYPE_SELL,sprice)==false)
         {
          Alert("Voce não tem dinheiro suficiente para esse negócio!");
          return;
         }
       // Abrir a posição de venda e checa o resultado
       if(mytrade.Sell(Lot,Symbol(),sprice,sstloss,stprofit))
         {//Requisição completa e colocada
          Alert("Uma ordem de venda foi colocada com sucesso com Ticket#: ",mytrade.ResultDeal(),"!!");
         }
       else
         {
          Alert("A requisição de ordem de venda com vol: ",mytrade.RequestVolume(),
                ", sl: ",mytrade.RequestSL(),", tp: ",mytrade.RequestTP(),
                ", preço: ", mytrade.RequestPrice(),
                ", não pode ser completada - erro: ",mytrade.ResultRetcodeDescription());
          return;      
         }
     }
//--- FIM!!  
  }
//+------------------------------------------------------------------+
