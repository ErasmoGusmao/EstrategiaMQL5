//+------------------------------------------------------------------+
//|                                                EA_Long_short.mq5 |
//|                                                           Erasmo |
//|                             https://www.mql5.com/pt/articles/100 |
//+------------------------------------------------------------------+
#property copyright "Erasmo"
#property link      "https://www.mql5.com/pt/articles/100"
#property version   "1.00"
//--- input parameters
input int      StopLoss=30;
input int      TakeProfit=100;
input int      ADX_Period=8;
input int      MA_Period=8;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
      
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
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
