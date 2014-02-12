//+------------------------------------------------------------------+
//|                                      2Extreme4U Grid Builder.mq4 |
//|                     Copyright © 2005, Siddiqi, Alejandro Galindo |
//|                                              http://elCactus.com |
//|                                                                  |
//|   + modified for Alerter by Tesla                                |
//|                                                      hapalkos    |
//|                                                      2007.03.23  |
//+------------------------------------------------------------------+

#property indicator_chart_window
extern color   exGridColor = DarkBlue;
extern int GridSpace = 25;
extern int AlertBand = 10;       // NOTE: Enter the number of pips from the gridline that you want the Alert to activate.
                                 // NOTE: Added AlertBand for use with Alerter.
double dMult;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators

   if(Digits==3 || Digits==5){
      dMult = MathPow(10,Digits-2);
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   double shift=0;
   double HighPrice=0;
   double LowPrice=0;
   
   HighPrice = MathRound(High[Highest(NULL,0,2, Bars - 2,  2)] * dMult);
   //SL = High[Highest(MODE_HIGH, SLLookback, SLLookback)];
   LowPrice = MathRound(Low[Lowest(NULL,0,1, Bars - 1, 2)] * dMult);
   for(shift=LowPrice;shift<=HighPrice;shift++)
   {
      ObjectDelete("Grid "+DoubleToStr(shift,0));                             //NOTE: added DoubleToStr to remove excess zeros
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   double I=0;
   double HighPrice=0;
   double LowPrice=0;
   int GridS=0;
   int SL=0;
//----    

   HighPrice = MathRound(High[Highest(NULL,0,MODE_HIGH, Bars - 2, 2)] *  dMult);
   //SL = High[Highest(MODE_HIGH, SLLookback, SLLookback)];
   LowPrice = MathRound(Low[Lowest(NULL,0,MODE_LOW, Bars - 1, 2)] * dMult);
   GridS = GridSpace / 5;
   
   for(I=LowPrice;I<=HighPrice;I++)
   {
  //Print("mod(I, GridSpace): " + MathMod(I, GridS) + " I= " + I);
  //Print(LowPrice + " " + HighPrice);
  if (MathMod(I, GridS) == 0) 
  {      
         if (ObjectFind("Grid "+DoubleToStr(I,0)) != 0)                                       //NOTE: added DoubleToStr to remove excess zeros
         {                     
            ObjectCreate("Grid "+DoubleToStr(I,0), OBJ_HLINE, 0, Time[1], I/dMult);         //NOTE: added DoubleToStr to remove excess zeros       
            ObjectSet("Grid "+DoubleToStr(I,0), OBJPROP_STYLE, STYLE_DOT);                  //NOTE: added DoubleToStr to remove excess zeros
            ObjectSet("Grid "+DoubleToStr(I,0), OBJPROP_COLOR,   exGridColor);                       //NOTE: added DoubleToStr to remove excess zeros

            string gridnamedesc = "";                                         //NOTE: Added string for gridline descripton
            ObjectSetText("Grid "+DoubleToStr(I,0),gridnamedesc,10,"Arial",Black);            //NOTE: Added code to set Alert_## text in description
            ObjectSet("Grid "+DoubleToStr(I,0),OBJPROP_BACK, true);                                                                              //NOTE: for use with Tesla's Alerter indicator.
           
         }
//MoveObject(I + "Grid", OBJ_HLINE, Time[Bars - 2], I/1000, Time[1], I/1000, MediumSeaGreen, 1, STYLE_SOLID);
  }
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+


