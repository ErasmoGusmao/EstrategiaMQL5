//+------------------------------------------------------------------+
//|                                           ExpertSimpleRandom.mq5 |
//|                                                           Erasmo |
//|                             https://www.mql5.com/pt/articles/703 |
//+------------------------------------------------------------------+
#property copyright "Erasmo"
#property link      "https://www.mql5.com/pt/articles/703"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Indicators\Indicators.mqh>
#include <ERASMO\Include\Enums.mqh>
#include <..\Experts\SimpleRandom\CSimpleRandom.mqh>

input int            StopLoss;            //Stop Loss
input int            TakeProfit;          //Take Profit
input double         LotSize;             //Lote
input ENUM_LIFE_EA   TimeLife;            //TimeLife

MqlTick tick;
CSimpleRandom *SR=new CSimpleRandom(StopLoss,TakeProfit,LotSize,TimeLife);
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   SR.Init();
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   SR.Deinit();
   delete(SR);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   SymbolInfoTick(_Symbol,tick);
   SR.Go(tick.ask,tick.bid);
  }
//+------------------------------------------------------------------+
