//+------------------------------------------------------------------+
//|                                                CSimpleRandom.mqh |
//|                                                           Erasmo |
//|                             https://www.mql5.com/pt/articles/703 |
//+------------------------------------------------------------------+
#property copyright "Erasmo"
#property link      "https://www.mql5.com/pt/articles/703"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <ERASMO\Include\Enums.mqh>
#include <..\Experts\SimpleRandom\CBrain.mqh>
#include <..\Experts\SimpleRandom\CEvolution.mqh>
#include <..\Experts\SimpleRandom\CGraphic.mqh>

//+------------------------------------------------------------------+
//| Classe CSimpleRandom                                             |
//+------------------------------------------------------------------+
class CSimpleRandom
  {
private:
   CBrain            *m_brain;
   CEvolution        *m_evolution;
   CGraphic          *m_graphic;
   CTrade            *m_trade;
   CPositionInfo     *m_positioInfo;
public:
   //---- Metodo construtor e destruidor
                     CSimpleRandom(int stop_loss, int take_profit,double lot_size,ENUM_LIFE_EA time_life);
                    ~CSimpleRandom(void);
   //---- Pegar métodos                 
   CBrain            *GetBrain(void);
   CEvolution        *GetEvolution(void);
   CGraphic          *GetGraphic(void);
   CTrade            *GetTrade(void);
   CPositionInfo     *GetPositionInfo(void);
   //---- Especificando os métodos da classe CSimplRandom
   bool              Init();
   void              Deinit();
   bool              Go(double ask, double bid);             
  };
//+------------------------------------------------------------------+
//| Construtor                                                       |
//+------------------------------------------------------------------+
CSimpleRandom::CSimpleRandom(int stop_loss, int take_profit,double lot_size,ENUM_LIFE_EA time_life)
  {
   int lifeInSeconds;
   
   switch(time_life)
     {
      case  HOUR:
        lifeInSeconds=3600;  
        break;
      
      case DAY:
         lifeInSeconds=86400;
         break;
        
      case WEEK:
         lifeInSeconds=604800;
         break;
         
      case MONTH:
         lifeInSeconds=2592000;
         break;
         
      // Um ano
        
      default:
         lifeInSeconds=31536000;
        break;
     }
     
     m_brain=new CBrain(TimeLocal(),TimeLocal()+lifeInSeconds,lot_size,stop_loss,take_profit);
     m_evolution=new CEvolution(DO_NOTHING);
     m_graphic=new CGraphic(_Symbol);
     m_trade=new CTrade();
  }
//+------------------------------------------------------------------+
//| Destruidor                                                       |
//+------------------------------------------------------------------+
CSimpleRandom::~CSimpleRandom()
  {
    delete(m_brain);
    delete(m_evolution);
    delete(m_graphic);
    delete(m_trade);
  }
//+------------------------------------------------------------------+
//| GetBrain                                                         |
//+------------------------------------------------------------------+
CBrain *CSimpleRandom::GetBrain(void)
 {
    return m_brain;
 }
//+------------------------------------------------------------------+
//| GetEvolution                                                     |
//+------------------------------------------------------------------+
CEvolution *CSimpleRandom::GetEvolution(void)
 {
    return m_evolution;
 }
//+------------------------------------------------------------------+
//| GetGraphic                                                       |
//+------------------------------------------------------------------+
CGraphic *CSimpleRandom::GetGraphic(void)
 {
   return m_graphic;
 }
//+------------------------------------------------------------------+
//| GetTrade                                                         |
//+------------------------------------------------------------------+
CTrade *CSimpleRandom::GetTrade(void)
 {
   return m_trade;
 }
//+------------------------------------------------------------------+
//| GetPositionInfo                                                  |
//+------------------------------------------------------------------+
CPositionInfo *CSimpleRandom::GetPositionInfo(void)
 {
   return m_positioInfo;
 }
//+------------------------------------------------------------------+
//| CSimpleRandom initialization                                     |
//+------------------------------------------------------------------+
bool  CSimpleRandom::Init(void)
 {
   //Inicializa logica aqui!!!
   return true;
 }
//+------------------------------------------------------------------+
//| CSimpleRandom deinitialization                                   |
//+------------------------------------------------------------------+
void CSimpleRandom::Deinit(void)
 {
   //Desinicializa logica aqui!!!
    delete(m_brain);
    delete(m_evolution);
    delete(m_graphic);
    delete(m_trade);
 }
//+------------------------------------------------------------------+
//| CSimpleRandom Go                                                 |
//+------------------------------------------------------------------+
bool CSimpleRandom::Go(double ask,double bid)
 {
   double tp;
   double sl;
   
   int coin=m_brain.GetRandomNumber(0,1);    //Joga a moeda
   
   // Existe alguma posição aberta?
   
   if(!m_positioInfo.Select(_Symbol))
     {//Não tem posição aberta
      
      if(coin==0)//Moeda == 0
        {
         GetEvolution().SetStatus(BUY);
        }
      else
        {
         GetEvolution().SetStatus(SELL);
        }
     }
     
   // Então deixe trabalhar a expectativa matemática  
   
   else
     {
      GetEvolution().SetStatus(DO_NOTHING);
     }  
   switch(GetEvolution().GetStatus())
     {
      case  BUY:
        
        tp = ask + m_brain.GetTakeProfit()*_Point;                                  //Ajusta Take Profit
        sl = bid - m_brain.GetStopLoss()*_Point;                                    //Ajusta Stop Loss
        
        GetTrade().PositionOpen(_Symbol,ORDER_TYPE_BUY,m_brain.GetSize(),ask,sl,tp);  //Abre a posição de compra
        
        break;
        
      case SELL:
         
        tp = bid - m_brain.GetTakeProfit()*_Point;                                  //Ajusta Take Profit
        sl = ask + m_brain.GetStopLoss()*_Point;                                    //Ajusta Stop Loss
        
        GetTrade().PositionOpen(_Symbol,ORDER_TYPE_SELL,m_brain.GetSize(),bid,sl,tp);  //Abre a posição de compra
         
         break;
           
      case DO_NOTHING:
         // NADA...
        break;
     }
     //Se tiver algum erro, retorna falso, até agora retornamos true
     return(true);
 }      
//+------------------------------------------------------------------+
