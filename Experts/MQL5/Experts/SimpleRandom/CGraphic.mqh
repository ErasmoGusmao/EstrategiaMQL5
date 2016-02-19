//+------------------------------------------------------------------+
//|                                                     CGraphic.mqh |
//|                                                           Erasmo |
//|                             https://www.mql5.com/pt/articles/703 |
//+------------------------------------------------------------------+
#property copyright "Erasmo"
#property link      "https://www.mql5.com/pt/articles/703"
#property version   "1.00"

#include <Trade\SymbolInfo.mqh>
#include <Arrays\ArrayObj.mqh>
//+------------------------------------------------------------------+
//| Class CGrapic                                                    |
//+------------------------------------------------------------------+
class CGraphic
  {
protected:
   ENUM_TIMEFRAMES   m_period;            // Tempo do gr�fico
   string            m_pair;              // Par do gr�fico
   CSymbolInfo*      m_symbol;            // CSymbolInfo object
   CArrayObj*        m_bars;              // Array of bars
   
public:
   //---- Construtor e destrutor
                     CGraphic(string pair);
                    ~CGraphic(void);
   //--- Chama os m�todos
   string            GetPair(void);
   CSymbolInfo      *GetSymbol(void);
   CArrayObj        *GetBars(void);
   //--- Seta os m�todos
   void              SetPair(string pair);
   void              SetSymbol(CSymbolInfo *symbol);
   void              SetBar(CObject *bar);                    
  };
//+------------------------------------------------------------------+
//| Construtor                                                       |
//+------------------------------------------------------------------+
CGraphic::CGraphic(string pair)
  {
   m_period=PERIOD_M1;
   m_pair=pair;
  }
//+------------------------------------------------------------------+
//| Destrutor                                                        |
//+------------------------------------------------------------------+
CGraphic::~CGraphic()
  {
  }
//+------------------------------------------------------------------+
//| GetPair                                                          |
//+------------------------------------------------------------------+
string CGraphic::GetPair(void)
  {
   return m_pair;
  }
//+------------------------------------------------------------------+
//| GetSymbol                                                        |
//+------------------------------------------------------------------+
CSymbolInfo *CGraphic::GetSymbol(void)
  {
   return m_symbol;
  }
//+------------------------------------------------------------------+
//| GetBars                                                          |
//+------------------------------------------------------------------+
CArrayObj *CGraphic::GetBars(void)
  {
   return m_bars;
  }
//+------------------------------------------------------------------+
//| SetPair                                                          |
//+------------------------------------------------------------------+
void CGraphic::SetPair(string pair)
  {
   m_pair=pair;
  }
//+------------------------------------------------------------------+
//| SetSymbol                                                        |
//+------------------------------------------------------------------+
void CGraphic::SetSymbol(CSymbolInfo *symbol)
  {
   m_symbol=symbol;
  }
//+------------------------------------------------------------------+
//| SetBar                                                           |
//+------------------------------------------------------------------+
void CGraphic::SetBar(CObject *bar)
  {
   m_bars.Add(bar);
  }
//+------------------------------------------------------------------+
