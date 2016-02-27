//+------------------------------------------------------------------+
//|                                                   CEvolution.mqh |
//|                                                           Erasmo |
//|                             https://www.mql5.com/pt/articles/703 |
//+------------------------------------------------------------------+
#property copyright "Erasmo"
#property link      "https://www.mql5.com/pt/articles/703"
#property version   "1.00"

#include <Indicators\Indicators.mqh>
#include <ERASMO\Include\Enums.mqh>

//+------------------------------------------------------------------+
//| Classe CEvolution                                                |
//+------------------------------------------------------------------+
class CEvolution
  {
protected:
   ENUM_STATUS_EA    m_status;            //O estado atual do EA
   CArrayObj*        m_operations;         // História de operações antes do EA
   
public:
   //---- Construtor e destrutor ----
                     CEvolution(ENUM_STATUS_EA status);
                    ~CEvolution(void);
  //---- Chama métodos ----
  ENUM_STATUS_EA     GetStatus(void);
  CArrayObj         *GetOperations(void);
  //---- Seta métodos
  void               SetStatus(ENUM_STATUS_EA status);
  void               SetOperation(CObject *operation);
  };
//+------------------------------------------------------------------+
//| Construtor                                                       |
//+------------------------------------------------------------------+
CEvolution::CEvolution(ENUM_STATUS_EA status)
  {
   m_status=status;
   m_operations=new CArrayObj;
  }
//+------------------------------------------------------------------+
//| Destruidor                                                       |
//+------------------------------------------------------------------+
CEvolution::~CEvolution()
  {
   delete(m_operations);
  }
//+------------------------------------------------------------------+
//| GetStatus                                                        |
//+------------------------------------------------------------------+
ENUM_STATUS_EA CEvolution::GetStatus(void)
 {
   return m_status;
 }
//+------------------------------------------------------------------+
//| GetOperations                                                    |
//+------------------------------------------------------------------+
CArrayObj *CEvolution::GetOperations(void)
 {
   return m_operations;
 }
//+------------------------------------------------------------------+
//| SetStatus                                                        |
//+------------------------------------------------------------------+
void CEvolution::SetStatus(ENUM_STATUS_EA status)
  {
   m_status=status;
  }
//+------------------------------------------------------------------+
//| SetOperation                                                     |
//+------------------------------------------------------------------+
void CEvolution::SetOperation(CObject *operation)
  {
   m_operations.Add(operation);
  }