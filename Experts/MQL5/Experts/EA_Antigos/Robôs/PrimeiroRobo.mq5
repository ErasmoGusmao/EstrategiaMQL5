//+------------------------------------------------------------------+
//|                                                 PrimeiroRobo.mq5 |
//|                                                           Erasmo |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Erasmo"
#property link      "https://www.mql5.com"
#property version   "1.00"
//---input parameters
input double quantidade =100.0;
input double porcentagem = 3.0;
input int    horasInicio = 10;
input int    minInicio = 07;
input int   horasFim = 16;
input int   minFim = 20;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(15);
   
      if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))//Verifica se a negocia��o automatizada n�o est� ligada
        {
         Alert("Verifique se a Negocia��o Automatizada est� ligada!");
         ExpertRemove();
        }
        else if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         Alert("Verifique se a Negocia��o Automatizada est� proibida  nas op��es do Exper Advisor:", __FILE__);
         ExpertRemove();        
        }      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
      
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
      datetime    horaAtualDT = TimeTradeServer();
      MqlDateTime horaAtual;
      TimeToStruct(horaAtualDT,horaAtual);
      
      MqlRates    infoCandles[];
      ArraySetAsSeries(infoCandles,true);
      CopyRates(Symbol(),PERIOD_D1,0,2,infoCandles);
//+------------------------------------------------------------------+
//| Compra                                                           |
//+------------------------------------------------------------------+
      
      string strHorarioEscolhido = horaAtual.year + "." + horaAtual.mon + "." + horaAtual.day + " " + horasInicio + ":" + minInicio;
      datetime horarioCompra = StringToTime(strHorarioEscolhido);
      
      if(PositionSelect(Symbol()) == false && SymbolInfoDouble(Symbol(),SYMBOL_BID)>=infoCandles[1].close*(1+porcentagem/100) && infoCandles[0].open >= (infoCandles[1].open+infoCandles[1].close)/2)
        {
         if(horaAtual.day_of_week >= 1 && horaAtual.day_of_week <= 5 && TimeTradeServer()>= horarioCompra && horaAtual.hour < horasFim)//horaAtual.day_of_week >= 1 (se est� entre segunda e sexta feira)
           {
            MqlTradeRequest requisicao;
            ZeroMemory(requisicao);  //Sempre tem que zerar a requisi��o
            requisicao.action = TRADE_ACTION_DEAL; //Coloca um ordem de negocia��o para execu��o imediata com os par�metros espec�ficos (ordem a mercado)
            requisicao.symbol = Symbol();
            requisicao.volume = quantidade;
            requisicao.type = ORDER_TYPE_BUY;
            requisicao.type_time = ORDER_TIME_DAY;
            MqlTradeResult resultado;
            ZeroMemory(resultado);
            if(!OrderSend(requisicao,resultado))//Ordem n�o enviada
               {
                Alert("Erro ao enviar a Ordem na fun��o: " + __FUNCTION__ + "Ultimo erro: " + GetLastError() + " Erro da vari�vel resultado: " + resultado.retcode);
               }
           }
        }
        
//+------------------------------------------------------------------+
//| Venda                                                           |
//+------------------------------------------------------------------+
      
      string strHorarioEscolhido2 = horaAtual.year + "." + horaAtual.mon + "." + horaAtual.day + " " + horasInicio + ":" + minInicio;
      datetime horarioVenda = StringToTime(strHorarioEscolhido2);
      
      if(PositionSelect(Symbol()) == true && TimeTradeServer() >= horarioVenda)
        {
         if(horaAtual.day_of_week >= 1 && horaAtual.day_of_week <= 5)
           {
            MqlTradeRequest requisicao2;
            ZeroMemory(requisicao2);
            requisicao2.action = TRADE_ACTION_DEAL; //Coloca um ordem de negocia��o para execu��o imediata com os par�metros espec�ficos (ordem a mercado)
            requisicao2.symbol = Symbol();
            requisicao2.volume = quantidade;
            requisicao2.type = ORDER_TYPE_SELL;
            requisicao2.type_time = ORDER_TIME_DAY;
            MqlTradeResult resultado2;
            ZeroMemory(resultado2);
            if(!OrderSend(requisicao2,resultado2))//Ordem n�o enviada
               {
                Alert("Erro ao enviar a Ordem na fun��o: " + __FUNCTION__ + "Ultimo erro: " + GetLastError() + " Erro da vari�vel resultado: " + resultado2.retcode);
               }
               Sleep(12*60*60*1000);//Sleep de 12h
           }
        }   
  }
//+------------------------------------------------------------------+
