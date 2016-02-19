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
  
   //Remover ordem   
   MqlTradeRequest requisicao;
   ZeroMemory(requisicao);  //Sempre tem que zerar a requisição
   requisicao.order = OrderGetTicket(0);
   requisicao.action = TRADE_ACTION_REMOVE; //Exclui uma ordem pendente colocada anteriormente
   MqlTradeResult resultado;
   ZeroMemory(resultado);
   
   if(!OrderSend(requisicao,resultado))//Ordem não enviada
     {
      Alert("Erro ao enviar a Ordem na função: " + __FUNCTION__ + "Ultimo erro: " + GetLastError() + " Erro da variável resultado: " + resultado.retcode);
     }     
  }    
  }
//+------------------------------------------------------------------+
