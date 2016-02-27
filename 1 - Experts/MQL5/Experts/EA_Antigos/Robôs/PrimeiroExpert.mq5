//+------------------------------------------------------------------+
//|                                               PrimeiroExpert.mq5 |
//|                                                           Erasmo |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Erasmo"
#property link      ""
#property version   "1.00"
//--- input parameters
input double   Preço=15.0;
input double   Volume=100.0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
//--- modificado de 60s para 5s
   EventSetTimer(5);
   Alert("Código início " + string(Preço));
      
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
   Alert("Código final");      
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   Alert("Código que vai rodar em 5 em 5 segundos");
  }
//+------------------------------------------------------------------+
