//+------------------------------------------------------------------+
//|                                             SignalADX_Era.mqh    |
//|                                 Criado por: Erasmo de Melo Gusmão|
//|                                                                  |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
// Descrição
//+------------------------------------------------------------------+
//| Descrição da classe                                              |
//| Title=Signals of indicator 'Average Directional Index'           |
//| Type=SignalAdvanced                                              |
//| Name=Average Directional Index                                   |
//| ShortName=ADX                                                    |
//| Class=CSignalADX_Era                                             |
//| Page=signal_adx_era                                              |
//| Parameter=PeriodADX,int,20,Period of averaging                   |
//| Parameter=Menor valor para ADX                                   |
//+------------------------------------------------------------------+
// Descrição final
//+------------------------------------------------------------------+
//| Class CSignalMA_Era.                                             |
//| Purpose: Classe para gerar sinal de negocoação basiado no        |
//|          indicador ADX "Ínidici direcional da tendência"         |
//| É derivada da classe CExpertSignal                               |
//+------------------------------------------------------------------+
class CSignalADX_Era : public CExpertSignal
  {
protected:
   CiADX             m_adxEra;             // object-indicator
   //--- adjusted parameters
   int               m_adxEra_period;      // the "period of averaging" parameter of the indicator
   double            m_adxMinimo;          // Menor valor para indicada força da tendência do indicador
   //--- "weights" of market models (0-100)
   int               m_pattern_0;          // model 0 "Padrão de tendência está ganhando força sinal ADX cescente e é maior que 25"
   int               m_pattern_1;          // model 1 "Padrão de tendência está perdendo força sinal ADX decescente e é maior que 25"

public:
                     CSignalADX_Era(void);
                    ~CSignalADX_Era(void);
   //--- methods of setting adjustable parameters
   void              PeriodADX_Era(int value)            { m_adxEra_period=value;     }
   void              MenorADX_Era(double value)          { m_adxMinimo = value;       }
   //--- methods of adjusting "weights" of market models
   void              Pattern_0(int value)                { m_pattern_0=value;          }
   void              Pattern_1(int value)                { m_pattern_1=value;          }
   //--- method of verification of settings
   virtual bool      ValidationSettings(void);
   //--- method of creating the indicator and timeseries
   virtual bool      InitIndicators(CIndicators *indicators);
   //--- methods of checking if the market models are formed
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);

protected:
   //--- method of initialization of the indicator
   bool              InitADX_Era(CIndicators *indicators);
   //--- methods of getting data
   double            ADX_Era(int ind)                    { return(m_adxEra.Main(ind)); }
   double            Plus_Era(int ind)                   { return(m_adxEra.Plus(ind)); }
   double            Minus_Era(int ind)                  { return(m_adxEra.Minus(ind));}
   double            DiffPlusDIMinusDI(int ind)          { return(Plus_Era(ind)-Minus_Era(ind));} //Verificar se diferença entre +DI e -DI é negativo ou positivo indicando a tendência
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalADX_Era::CSignalADX_Era(void) : m_adxEra_period(20),
                             m_adxMinimo(25),
                             m_pattern_0(100),
                             m_pattern_1(60)
  {
//--- initialization of protected data
   m_used_series=USE_SERIES_OPEN+USE_SERIES_HIGH+USE_SERIES_LOW+USE_SERIES_CLOSE;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignalADX_Era::~CSignalADX_Era(void)
  {
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//+------------------------------------------------------------------+
bool CSignalADX_Era::ValidationSettings(void)
  {
//--- validation settings of additional filters
   if(!CExpertSignal::ValidationSettings())
      return(false);
//--- initial data checks
   if(m_adxEra_period<=0)
     {
      printf(__FUNCTION__+": period ADX must be greater than 0");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create indicators.                                               |
//+------------------------------------------------------------------+
bool CSignalADX_Era::InitIndicators(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- initialization of indicators and timeseries of additional filters
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
//--- create and initialize MA indicator
   if(!InitADX_Era(indicators))
      return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialize MA indicators.                                        |
//+------------------------------------------------------------------+
bool CSignalADX_Era::InitADX_Era(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- add object to collection
   if(!indicators.Add(GetPointer(m_adxEra)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- initialize object
   if(!m_adxEra.Create(m_symbol.Name(),m_period,m_adxEra_period))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int CSignalADX_Era::LongCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
//--- Análise da posição entre o +DI e o -DI
   if(DiffPlusDIMinusDI(idx)>0.0)
     {//--- Provavel tendência de subida
      
      if(IS_PATTERN_USAGE(0) && Plus_Era(idx+2)>Minus_Era(idx+2) && Plus_Era(idx+1)>Minus_Era(idx+1) && Plus_Era(idx+1)>Plus_Era(idx+2) && ADX_Era(idx+1)> ADX_Era(idx+2) && ADX_Era(idx+1)> m_adxMinimo)
        {
         //--- Sinal +DI está crescendo e é maior que -DI e o sinal ADX está crescendo e é maior que menorValor para ADX
         result=m_pattern_0;
        }
      if(IS_PATTERN_USAGE(1) && Plus_Era(idx+2)>Minus_Era(idx+2) && Plus_Era(idx+1)>Minus_Era(idx+1) && ADX_Era(idx+1) < ADX_Era(idx+2) && ADX_Era(idx+1) > m_adxMinimo)
        {//--- Sinal +DI é maior que -DI, mas pode não está crescendo e o sinal ADX está decrescendo, mas ainda é maior que menorValor para ADX
         result=m_pattern_1;
        }
     }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int CSignalADX_Era::ShortCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
//--- Análise da posição entre o +DI e o -DI
   if(DiffPlusDIMinusDI(idx)<0.0)
     {//--- Provavel tendência de queda
      
      if(IS_PATTERN_USAGE(0) && Plus_Era(idx+2)<Minus_Era(idx+2) && Plus_Era(idx+1)<Minus_Era(idx+1) && Minus_Era(idx+1)>Minus_Era(idx+2) && ADX_Era(idx+1)> ADX_Era(idx+2) && ADX_Era(idx+1)> m_adxMinimo)
        {
         //--- Sinal -DI está crescendo e é maior que +DI e o sinal ADX está crescendo e é maior que menorValor para ADX
         result=m_pattern_0;
        }
      if(IS_PATTERN_USAGE(1) && Plus_Era(idx+2)<Minus_Era(idx+2) && Plus_Era(idx+1)<Minus_Era(idx+1) && ADX_Era(idx+1) < ADX_Era(idx+2) && ADX_Era(idx+1) > m_adxMinimo)
        {//--- Sinal _DI é maior que +DI, mas pode não está crescendo e o sinal ADX está decrescendo, mas ainda é maior que menorValor para ADX
         result=m_pattern_1;
        }
     }   
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
