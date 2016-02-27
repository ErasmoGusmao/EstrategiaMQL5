//+------------------------------------------------------------------+
//|                                                       CBrain.mqh |
//|                                                           Erasmo |
//|                             https://www.mql5.com/pt/articles/703 |
//+------------------------------------------------------------------+
#property copyright "Erasmo"
#property link      "https://www.mql5.com/pt/articles/703"
#property version   "1.00"
//+------------------------------------------------------------------+
//| CBrain Class                                                     |
//+------------------------------------------------------------------+
class CBrain
  {
protected:
   ENUM_TIMEFRAMES   m_period;      // O perído deve ser sempre inicializado para ajustar a idéia do sistema
   datetime          m_birth;       // Data em que o robô é inicializado pela primeira vez;
   datetime          m_death;       // Data em que o robô é desligado
   double            m_size;        // Tamanho da posição
   int               m_stopLoss;    // Stop Loss
   int               m_takeProfit;  // Take Profit
   
public:
   //---- Método do construtor e do destruidor
                     CBrain(datetime birth,datetime death, double size, int stopLoss, int takeProfit);
                    ~CBrain(void);
   //---- Chama os métodos
   datetime          GetBirth(void);
   datetime          GetDeath(void);
   double            GetSize(void);
   int               GetStopLoss(void);
   int               GetTakeProfit(void);
   //---- Seta os métodos
   void              SetBirth(datetime birth);
   void              SetDeath(datetime death);
   void              SetSize(double size);
   void              SetStopLoss(int stopLoss);
   void              SetTakeProfit(int takeProfit);
   //---- Cerebro especifica logica
   int               GetRandomNumber(int a, int b);
  };
//+------------------------------------------------------------------+
//| Construtor                                                       |
//+------------------------------------------------------------------+
CBrain::CBrain(datetime birth,datetime death, double size, int stopLoss, int takeProfit)
  {
   MathSrand(GetTickCount());         //Define o ponto inicial para geração de uma série de inteiros pseudo-aleatórios.
   
   m_period=PERIOD_M1;
   m_birth=birth;
   m_death=death;
   m_size=size;
   m_stopLoss=stopLoss;
   m_takeProfit=takeProfit;
  }
//+------------------------------------------------------------------+
//| Destruidor                                                       |
//+------------------------------------------------------------------+
CBrain::~CBrain()
  {
   //Nada...
  }
//+------------------------------------------------------------------+
//| GetBirth                                                         |
//+------------------------------------------------------------------+
datetime CBrain::GetBirth(void)
 {
   return m_birth;
 }
//+------------------------------------------------------------------+
//| GetDeath                                                         |
//+------------------------------------------------------------------+ 
datetime CBrain::GetDeath(void)
 {
   return m_death;
 }
//+------------------------------------------------------------------+
//| GetSize                                                          |
//+------------------------------------------------------------------+
double CBrain::GetSize(void)
 {
   return m_size;
 }
//+------------------------------------------------------------------+
//| GetStopLoss                                                      |
//+------------------------------------------------------------------+
int CBrain::GetStopLoss(void)
 {
   return m_stopLoss;
 }
//+------------------------------------------------------------------+
//| GetTakeProfit                                                    |
//+------------------------------------------------------------------+
int CBrain::GetTakeProfit(void)
 {
   return m_takeProfit;
 } 
//+------------------------------------------------------------------+
//| SetDeath                                                         |
//+------------------------------------------------------------------+
void CBrain::SetDeath(datetime death)
 {
   m_death=death;
 }
//+------------------------------------------------------------------+
//| SetBirth                                                         |
//+------------------------------------------------------------------+
void CBrain::SetBirth(datetime birth)
 {
   m_birth=birth;
 }
//+------------------------------------------------------------------+
//| SetSize                                                          |
//+------------------------------------------------------------------+
void CBrain::SetSize(double size)
 {
   m_size=size;
 }
//+------------------------------------------------------------------+
//| SetStopLoss                                                      |
//+------------------------------------------------------------------+
void CBrain::SetStopLoss(int stopLoss)
 {
   m_stopLoss=stopLoss;
 }
//+------------------------------------------------------------------+
//| SetTakeProfit                                                    |
//+------------------------------------------------------------------+
void CBrain::SetTakeProfit(int takeProfit)
 {
   m_takeProfit=takeProfit;
 }
//+------------------------------------------------------------------+
//| GetRandomNumber                                                  |
//+------------------------------------------------------------------+
int CBrain::GetRandomNumber(int a,int b)
 {
   return( a + MathRand()%(b-a+1));
 } 