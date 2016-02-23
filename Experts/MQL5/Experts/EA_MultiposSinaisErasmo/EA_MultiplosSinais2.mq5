//+------------------------------------------------------------------+
//|                                          EA_MultiplosSinais2.mq5 |
//|        Copyright 2016, MetaQuotes Software Corp. & Erasmo Gusmão |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp. & Erasmo Gusmão"
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\Signal\SignalMA.mqh>
#include <Expert\Signal\SignalMACD.mqh>
#include <Expert\Signal\SignalRSI.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingParabolicSAR.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title                 ="EA_MultiplosSinais2"; // Document name
ulong                    Expert_MagicNumber           =21453;                 // 
bool                     Expert_EveryTick             =false;                 // 
//--- inputs for main signal
input int                Signal_ThresholdOpen         =19;                    // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose        =12;                    // Signal threshold value to close [0...100]
input double             Signal_PriceLevel            =0.0;                   // Price level to execute a deal
input double             Signal_StopLevel             =50.0;                  // Stop Loss level (in points)
input double             Signal_TakeLevel             =150.0;                  // Take Profit level (in points)
input int                Signal_Expiration            =4;                     // Expiration of pending orders (in bars)
input int                Signal_0_MA_PeriodMA         =10;                    // Moving Average(10,0,...) Period of averaging
input int                Signal_0_MA_Shift            =0;                     // Moving Average(10,0,...) Time shift
input ENUM_MA_METHOD     Signal_0_MA_Method           =MODE_EMA;              // Moving Average(10,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_0_MA_Applied          =PRICE_CLOSE;           // Moving Average(10,0,...) Prices series
input double             Signal_0_MA_Weight           =0.3;                   // Moving Average(10,0,...) Weight [0...1.0]
input int                Signal_1_MA_PeriodMA         =15;                    // Moving Average(15,0,...) Period of averaging
input int                Signal_1_MA_Shift            =0;                     // Moving Average(15,0,...) Time shift
input ENUM_MA_METHOD     Signal_1_MA_Method           =MODE_EMA;              // Moving Average(15,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_1_MA_Applied          =PRICE_CLOSE;           // Moving Average(15,0,...) Prices series
input double             Signal_1_MA_Weight           =0.3;                   // Moving Average(15,0,...) Weight [0...1.0]
input int                Signal_2_MA_PeriodMA         =20;                    // Moving Average(20,0,...) Period of averaging
input int                Signal_2_MA_Shift            =0;                     // Moving Average(20,0,...) Time shift
input ENUM_MA_METHOD     Signal_2_MA_Method           =MODE_EMA;              // Moving Average(20,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_2_MA_Applied          =PRICE_CLOSE;           // Moving Average(20,0,...) Prices series
input double             Signal_2_MA_Weight           =0.3;                   // Moving Average(20,0,...) Weight [0...1.0]
input int                Signal_MACD_PeriodFast       =12;                    // MACD(12,26,9,PRICE_CLOSE) Period of fast EMA
input int                Signal_MACD_PeriodSlow       =26;                    // MACD(12,26,9,PRICE_CLOSE) Period of slow EMA
input int                Signal_MACD_PeriodSignal     =9;                     // MACD(12,26,9,PRICE_CLOSE) Period of averaging of difference
input ENUM_APPLIED_PRICE Signal_MACD_Applied          =PRICE_CLOSE;           // MACD(12,26,9,PRICE_CLOSE) Prices series
input double             Signal_MACD_Weight           =0.7;                   // MACD(12,26,9,PRICE_CLOSE) Weight [0...1.0]
input int                Signal_RSI_PeriodRSI         =9;                     // Relative Strength Index(9,...) Period of calculation
input ENUM_APPLIED_PRICE Signal_RSI_Applied           =PRICE_CLOSE;           // Relative Strength Index(9,...) Prices series
input double             Signal_RSI_Weight            =0.7;                   // Relative Strength Index(9,...) Weight [0...1.0]
//--- inputs for trailing
input double             Trailing_ParabolicSAR_Step   =0.02;                  // Speed increment
input double             Trailing_ParabolicSAR_Maximum=0.2;                   // Maximum rate
//--- inputs for money
input double             Money_FixLot_Percent         =10.0;                  // Percent
input double             Money_FixLot_Lots            =100.0;                 // Fixed volume
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initializing expert
if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Creating signal
   CExpertSignal *signal=new CExpertSignal;
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//---
   ExtExpert.InitSignal(signal);
   signal.ThresholdOpen(Signal_ThresholdOpen);
   signal.ThresholdClose(Signal_ThresholdClose);
   signal.PriceLevel(Signal_PriceLevel);
   signal.StopLevel(Signal_StopLevel);
   signal.TakeLevel(Signal_TakeLevel);
   signal.Expiration(Signal_Expiration);
//--- Creating filter CSignalMA
CSignalMA *filter0=new CSignalMA;
if(filter0==NULL)
  {
   //--- failed
   printf(__FUNCTION__+": error creating filter0");
   ExtExpert.Deinit();
   return(INIT_FAILED);
  }
signal.AddFilter(filter0);
//--- Set filter parameters
filter0.PeriodMA(Signal_0_MA_PeriodMA);
filter0.Shift(Signal_0_MA_Shift);
filter0.Method(Signal_0_MA_Method);
filter0.Applied(Signal_0_MA_Applied);
filter0.Weight(Signal_0_MA_Weight);
//--- Creating filter CSignalMA
CSignalMA *filter1=new CSignalMA;
if(filter1==NULL)
  {
   //--- failed
   printf(__FUNCTION__+": error creating filter1");
   ExtExpert.Deinit();
   return(INIT_FAILED);
  }
signal.AddFilter(filter1);
//--- Set filter parameters
filter1.PeriodMA(Signal_1_MA_PeriodMA);
filter1.Shift(Signal_1_MA_Shift);
filter1.Method(Signal_1_MA_Method);
filter1.Applied(Signal_1_MA_Applied);
filter1.Weight(Signal_1_MA_Weight);
//--- Creating filter CSignalMA
CSignalMA *filter2=new CSignalMA;
if(filter2==NULL)
  {
   //--- failed
   printf(__FUNCTION__+": error creating filter2");
   ExtExpert.Deinit();
   return(INIT_FAILED);
  }
signal.AddFilter(filter2);
//--- Set filter parameters
filter2.PeriodMA(Signal_2_MA_PeriodMA);
filter2.Shift(Signal_2_MA_Shift);
filter2.Method(Signal_2_MA_Method);
filter2.Applied(Signal_2_MA_Applied);
filter2.Weight(Signal_2_MA_Weight);
//--- Creating filter CSignalMACD
CSignalMACD *filter3=new CSignalMACD;
if(filter3==NULL)
  {
   //--- failed
   printf(__FUNCTION__+": error creating filter3");
   ExtExpert.Deinit();
   return(INIT_FAILED);
  }
signal.AddFilter(filter3);
//--- Set filter parameters
filter3.PeriodFast(Signal_MACD_PeriodFast);
filter3.PeriodSlow(Signal_MACD_PeriodSlow);
filter3.PeriodSignal(Signal_MACD_PeriodSignal);
filter3.Applied(Signal_MACD_Applied);
filter3.Weight(Signal_MACD_Weight);
//--- Creating filter CSignalRSI
CSignalRSI *filter4=new CSignalRSI;
if(filter4==NULL)
  {
   //--- failed
   printf(__FUNCTION__+": error creating filter4");
   ExtExpert.Deinit();
   return(INIT_FAILED);
  }
signal.AddFilter(filter4);
//--- Set filter parameters
filter4.PeriodRSI(Signal_RSI_PeriodRSI);
filter4.Applied(Signal_RSI_Applied);
filter4.Weight(Signal_RSI_Weight);
//--- Creation of trailing object
  CTrailingPSAR *trailing=new CTrailingPSAR;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set trailing parameters
trailing.Step(Trailing_ParabolicSAR_Step);
trailing.Maximum(Trailing_ParabolicSAR_Maximum);
//--- Creation of money object
CMoneyFixedLot *money=new CMoneyFixedLot;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add money to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set money parameters
money.Percent(Money_FixLot_Percent);
money.Lots(Money_FixLot_Lots);
//--- Check all trading objects parameters
   if(!ExtExpert.ValidationSettings())
     {
      //--- failed
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   ExtExpert.OnTick();
  }
//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| "Timer" event handler function                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
