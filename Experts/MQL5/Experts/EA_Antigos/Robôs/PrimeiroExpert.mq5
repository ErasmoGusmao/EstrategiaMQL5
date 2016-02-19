//+------------------------------------------------------------------+
//|                                               PrimeiroExpert.mq5 |
//|                                                           Erasmo |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Erasmo"
#property link      ""
#property version   "1.00"
//--- input parameters
input double   Pre�o=15.0;
input double   Volume=100.0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
//--- modificado de 60s para 5s
   EventSetTimer(5);
   Alert("C�digo in�cio " + string(Pre�o));
      
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
   Alert("C�digo final");      
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   Alert("C�digo que vai rodar em 5 em 5 segundos");
  }
//+------------------------------------------------------------------+
