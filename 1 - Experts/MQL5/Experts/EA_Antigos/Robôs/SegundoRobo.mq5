//+------------------------------------------------------------------+
//|                                                  SegundoRobo.mq5 |
//|                                                           Erasmo |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Erasmo"
#property link      "https://www.mql5.com"
#property version   "1.00"
//---input parameters
input double quantidade =100.0;
input int    horasInicio = 10;
input int    minInicio = 07;
input int   horasFim = 16;
input int   minFim = 20;
input double RetornoPorRisco = 3.0;
input double PorcentagemDePerda =5.0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(15);
   
      if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))//Verifica se a negociação automatizada não está ligada
        {
         Alert("Verifique se a Negociação Automatizada está ligada!");
         ExpertRemove();
        }
        else if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         Alert("Verifique se a Negociação Automatizada está proibida  nas opções do Exper Advisor:", __FILE__);
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
      CopyRates(Symbol(),PERIOD_D1,0,6,infoCandles);
//+------------------------------------------------------------------+
//| Compra                                                           |
//+------------------------------------------------------------------+
      
      string strHorarioEscolhido = horaAtual.year + "." + horaAtual.mon + "." + horaAtual.day + " " + horasInicio + ":" + minInicio;
      datetime horarioCompra = StringToTime(strHorarioEscolhido);
      
      if(PositionSelect(Symbol()) == false && infoCandles[5].close < infoCandles[5].open && infoCandles[4].close < infoCandles[5].close && infoCandles[4].close < infoCandles[4].open && infoCandles[3].close < infoCandles[4].close && infoCandles[3].close < infoCandles[3].open && infoCandles[2].close > infoCandles[2].open & infoCandles[1].close > infoCandles[2].close && SymbolInfoDouble(Symbol(),SYMBOL_BID)>infoCandles[0].open && SymbolInfoDouble(Symbol(),SYMBOL_BID)>infoCandles[2].open)
        {
         if(horaAtual.day_of_week >= 1 && horaAtual.day_of_week <= 5 && TimeTradeServer()>= horarioCompra && horaAtual.hour < horasFim)//horaAtual.day_of_week >= 1 (se está entre segunda e sexta feira)
           {
            MqlTradeRequest requisicao;
            ZeroMemory(requisicao);  //Sempre tem que zerar a requisição
            requisicao.action = TRADE_ACTION_DEAL; //Coloca um ordem de negociação para execução imediata com os parâmetros específicos (ordem a mercado)
            requisicao.symbol = Symbol();
            requisicao.volume = quantidade;
            requisicao.sl = SymbolInfoDouble(Symbol(),SYMBOL_BID)*(1-PorcentagemDePerda/100);                        //stopLoss
            requisicao.tp = SymbolInfoDouble(Symbol(),SYMBOL_BID)*(1+(PorcentagemDePerda*RetornoPorRisco)/100);     //lucro
            requisicao.type = ORDER_TYPE_BUY;
            requisicao.type_time = ORDER_TIME_DAY;
            MqlTradeResult resultado;
            ZeroMemory(resultado);
            if(!OrderSend(requisicao,resultado))//Ordem não enviada
               {
                Alert("Erro ao enviar a Ordem na função: " + __FUNCTION__ + "Ultimo erro: " + GetLastError() + " Erro da variável resultado: " + resultado.retcode);
               }
           }
        }
        
//+------------------------------------------------------------------+
//| Venda                                                           |
//+------------------------------------------------------------------+
/*      
      string strHorarioEscolhido2 = horaAtual.year + "." + horaAtual.mon + "." + horaAtual.day + " " + horasInicio + ":" + minInicio;
      datetime horarioVenda = StringToTime(strHorarioEscolhido2);
      
      if(PositionSelect(Symbol()) == true && TimeTradeServer() >= horarioVenda)
        {
         if(horaAtual.day_of_week >= 1 && horaAtual.day_of_week <= 5)
           {
            MqlTradeRequest requisicao2;
            ZeroMemory(requisicao2);
            requisicao2.action = TRADE_ACTION_DEAL; //Coloca um ordem de negociação para execução imediata com os parâmetros específicos (ordem a mercado)
            requisicao2.symbol = Symbol();
            requisicao2.volume = quantidade;
            requisicao2.type = ORDER_TYPE_SELL;
            requisicao2.type_time = ORDER_TIME_GTC;//Até cancelar
            MqlTradeResult resultado2;
            ZeroMemory(resultado2);
            if(!OrderSend(requisicao2,resultado2))//Ordem não enviada
               {
                Alert("Erro ao enviar a Ordem na função: " + __FUNCTION__ + "Ultimo erro: " + GetLastError() + " Erro da variável resultado: " + resultado2.retcode);
               }
               Sleep(24*60*60*1000);//Sleep de 24h
           }
        }
*/ 
  }
//+------------------------------------------------------------------+
