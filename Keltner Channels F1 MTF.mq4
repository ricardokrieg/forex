//+------------------------------------------------------------------+
//|                                               KeltnerChannel.mq4 |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 DarkGray
#property indicator_color2 DarkGray
#property indicator_color3 DarkGray
#property indicator_style2 STYLE_DOT

//
//
//
//
//
//

extern string TimeFrame   = "1440";
extern int    MA_PERIOD   = 1;
extern int    MA_MODE     = 3;
extern int    PRICE_MODE  = 4;
extern int    ATR_PERIOD  = 20;
extern double K           = 1.0;
extern bool   ATR_MODE    = false;
extern bool   Interpolate = true;

//
//
//
//
//

double upper[];
double middle[];
double lower[];

//
//
//
//
//

string IndicatorFileName;
int    timeFrame;
bool   calculateKcn;
bool   returningBars;

//+------------------------------------------------------------------+
//|                                                                   
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   SetIndexBuffer(0,upper);
   SetIndexBuffer(1,middle);
   SetIndexBuffer(2,lower);
   
      //
      //
      //
      //
      //
      
      IndicatorFileName = WindowExpertName();
      calculateKcn      = (TimeFrame=="calculateKcn");
      returningBars     = (TimeFrame=="returnBars");
      timeFrame         = stringToTimeFrame(TimeFrame);
   return(0);
}
int deinit()
{
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                   
//+------------------------------------------------------------------+
//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,limit;
   
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit=MathMin(Bars-counted_bars,Bars-1);
         if (returningBars)  { upper[0] = limit; return(0); }

   //
   //
   //
   //
   //
   
   if (calculateKcn || timeFrame==Period())
   {
      for(i=limit; i>=0; i--)
      {
         middle[i] = iMA(NULL,0,MA_PERIOD,0,MA_MODE,PRICE_MODE,i);

         if (ATR_MODE) double avg  = iATR(NULL,0,ATR_PERIOD,i);
         else 
         {
               double sum=0;
               for (int x=0; x<ATR_PERIOD; x++) sum += High[i+x]-Low[i+x];
                                                avg = sum/ATR_PERIOD;
         }
         upper[i] = middle[i] + K*avg;
         lower[i] = middle[i] - K*avg;
      }
      return(0);
   }      
   
   //
   //
   //
   //
   //
   
   if (timeFrame > Period()) limit = MathMax(limit,MathMin(Bars,iCustom(NULL,timeFrame,IndicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for (i=limit;i>=0;i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         upper[i]  = iCustom(NULL,timeFrame,IndicatorFileName,"CalculateKcn",MA_PERIOD,MA_MODE,PRICE_MODE,ATR_PERIOD,K,ATR_MODE,0,y);
         middle[i] = iCustom(NULL,timeFrame,IndicatorFileName,"CalculateKcn",MA_PERIOD,MA_MODE,PRICE_MODE,ATR_PERIOD,K,ATR_MODE,1,y);
         lower[i]  = iCustom(NULL,timeFrame,IndicatorFileName,"CalculateKcn",MA_PERIOD,MA_MODE,PRICE_MODE,ATR_PERIOD,K,ATR_MODE,2,y);

         //
         //
         //
         //
         //
      
         if (timeFrame <= Period() || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;
         if (!Interpolate) continue;

         //
         //
         //
         //
         //

         datetime time = iTime(NULL,timeFrame,y);
            for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            double factor = 1.0 / n;
            for(int k = 1; k < n; k++)
            {
               upper[i+k]  = k*factor*upper[i+n]  + (1.0-k*factor)*upper[i];
               middle[i+k] = k*factor*middle[i+n] + (1.0-k*factor)*middle[i];
               lower[i+k]  = k*factor*lower[i+n]  + (1.0-k*factor)*lower[i];
            }               
   }
   
   //
   //
   //
   //
   //
   
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = StringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}

//
//
//
//
//

string StringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int char = StringGetChar(s, length);
         if((char > 96 && char < 123) || (char > 223 && char < 256))
                     s = StringSetChar(s, length, char - 32);
         else if(char > -33 && char < 0)
                     s = StringSetChar(s, length, char + 224);
   }
   return(s);
}