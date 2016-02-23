using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace ThresholdEstimator
{
    class Program
    {
        static void Main(string[] args)
        {
            //===================  Definido os pesso  do indicadores ====================
            
            double pesoMA_10 = 0.3;                  //Peso do Indicador de MA_10
            double pesoMA_15 = 0.3;                  //Peso do Indicador de MA_15
            double pesoMA_20 = 0.3;                  //Peso do Indicador de MA_20
            double pesoMACD = 0.7;                  //Peso do Indicador de MACD
            double pesoRSI = 0.7;                    //Peso do Indicador de RSI
            double pesoADX = 0.9;                    //Peso do Indicador de ADX

            //=================  Definindo as forças dos padrões  =======================

            //--- Para MA_10
            double[] força_padrão_MA_10 = new double[] {80, 10, 60, 60, -80, -10, -60, -60};
            //--- Para MA_15
            double[] força_padrão_MA_15 = new double[] {80, 10, 60, 60, -80, -10, -60, -60 };
            //--- Para MA_20
            double[] força_padrão_MA_20 = new double[] {80, 10, 60, 60, -80, -10, -60, -60 };
            //--- Para MACD
            double[] força_padrão_MACD = new double[] {10,	30,	80,	50,	60,	100, -10, -30, -80, -50, -60, -100};
            //--- Para RSI
            double[] força_padrão_RSI = new double[] {70, 100, 90, 80, 100, 20, -70, -100, -90, -80, -100, -20};
            //--- Para ADX
            double[] força_padrão_ADX = new double[] { 100, 60, -100, -60};

            //======================== Calculo de todos os cenários ======================
            double SinalMA_10;
            double SinalMA_15;
            double SinalMA_20;
            double SinalMACD;
            double SinalRSI;
            double SinalADX;

            double SinalFinal;
            int cont=0;

            using (StreamWriter writer = new StreamWriter("CenárioSinais.txt")) //Escreve no mesmo diretório da pasta do executavel: bin\Debug
            {    
                writer.WriteLine("Cenário\tMA(10)\tMA(15)\tMA(20)\tMACD\tRSI\tADX\tTotal");
                for (int i = 0; i < força_padrão_MA_10.Length; i++)
                {
                    for (int j = 0; j < força_padrão_MA_15.Length; j++)
                    {
                        for (int k = 0; k < força_padrão_MA_20.Length; k++)
                        {
                            for (int m = 0; m < força_padrão_MACD.Length; m++)
                            {
                                for (int n = 0; n < força_padrão_RSI.Length; n++)
                                {
                                    for (int t = 0; t < força_padrão_ADX.Length; t++)
			                        {
                                    cont += 1;

                                    SinalMA_10 = pesoMA_10 * força_padrão_MA_10[i];
                                    SinalMA_15 = pesoMA_15 * força_padrão_MA_15[j];
                                    SinalMA_20 = pesoMA_20 * força_padrão_MA_20[k];
                                    SinalMACD = pesoMACD * força_padrão_MACD[m];
                                    SinalRSI = pesoRSI * força_padrão_RSI[n];
                                    SinalADX = pesoADX*força_padrão_ADX[t];

                                    SinalFinal = (SinalMA_10 + SinalMA_15 + SinalMA_20 + SinalMACD + SinalRSI + SinalADX) / 6;

                                    Console.WriteLine("{0}. MA(10): {1}\t MA(15): {2}\t MA(20): {3}\t MACD: {4}\t RSI: {5}\t ADX: {6}\t Total: {7}",
                                        cont.ToString(), SinalMA_10.ToString(), SinalMA_15.ToString(), SinalMA_20.ToString(),
                                        SinalMACD.ToString(), SinalRSI.ToString(),SinalADX.ToString() ,SinalFinal.ToString());
                                    //Escrever no .txt
                                    writer.WriteLine("{0}\t{1}\t{2}\t{3}\t{4}\t{5}\t{6}\t{7}",
                                        cont.ToString(), SinalMA_10.ToString(), SinalMA_15.ToString(), SinalMA_20.ToString(),
                                        SinalMACD.ToString(), SinalRSI.ToString(),SinalADX.ToString(), SinalFinal.ToString());
			                        }
                                }   
                            }   
                        }   
                    }
                }
            }
            Console.ReadKey();
        }
    }
}
