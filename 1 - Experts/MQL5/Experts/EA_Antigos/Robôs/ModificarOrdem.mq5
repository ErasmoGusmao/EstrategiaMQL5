//+------------------------------------------------------------------+
//|                                               ModificarOrdem.mq5 |
//|                                                           Erasmo |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Erasmo"
#property link      "https://www.mql5.com"
#property version   "1.00"
//--- input parameters
input double   Preco = 0.0;
//input double   Quantidade=100.0;
input double   StopLoss=0.0;
input double   Lucro=0.0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(5);
   
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
 bool comprado = false;
if(comprado == false) //Travo o sistema para enviar uma única ordem
  {
  comprado = true;
  
   //Modificar ordem   
   MqlTradeRequest requisicao;
   ZeroMemory(requisicao);  //Sempre tem que zerar a requisição
   requisicao.order = OrderGetTicket(0);
   requisicao.action = TRADE_ACTION_MODIFY; //Modifca os parâmetros de uma ordem coloca anteriormente
   //requisicao.symbol = Symbol();
   //requisicao.volume = Quantidade;
   requisicao.price = Preco;
   requisicao.sl = StopLoss;
   requisicao.tp = Lucro;
   //requisicao.type = ORDER_TYPE_BUY_LIMIT;
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
