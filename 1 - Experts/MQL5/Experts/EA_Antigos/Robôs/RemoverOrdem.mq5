//+------------------------------------------------------------------+
//|                                                 RemoverOrdem.mq5 |
//|                                                           Erasmo |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Erasmo"
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(5);
   
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
 bool comprado = false;
if(comprado == false) //Travo o sistema para enviar uma �nica ordem
  {
  comprado = true;
  
   //Remover ordem   
   MqlTradeRequest requisicao;
   ZeroMemory(requisicao);  //Sempre tem que zerar a requisi��o
   requisicao.order = OrderGetTicket(0);
   requisicao.action = TRADE_ACTION_REMOVE; //Exclui uma ordem pendente colocada anteriormente
   MqlTradeResult resultado;
   ZeroMemory(resultado);
   
   if(!OrderSend(requisicao,resultado))//Ordem n�o enviada
     {
      Alert("Erro ao enviar a Ordem na fun��o: " + __FUNCTION__ + "Ultimo erro: " + GetLastError() + " Erro da vari�vel resultado: " + resultado.retcode);
     }     
  }    
  }
//+------------------------------------------------------------------+
