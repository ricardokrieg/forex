//+------------------------------------------------------------------+
//|                                                    MA ribbon.mq4 |
//|                                               mladenfx@gmail.com |
//|                                                                  |
//| original idea by Jose Silva                                      |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 C'58,0,0'  //  C'0,33,0'
#property indicator_color2 C'58,0,0'
#property indicator_color3 DarkGreen
#property indicator_color4 C'92,99,12;'
#property indicator_width1 5
#property indicator_width2 5
#property indicator_width3 1
#property indicator_width4 3

//
//
//
//
//

extern int       MA1Period=20;
extern int       MA1Method=MODE_SMA;
extern int       MA1Price =PRICE_CLOSE;
extern int       MA2Period=55;
extern int       MA2Method=MODE_SMMA;
extern int       MA2Price =PRICE_CLOSE;

//
//
//
//
//

double buffer1[];
double buffer2[];
double buffer3[];
double buffer4[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   SetIndexBuffer(0,buffer3); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,buffer4); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,buffer1);
   SetIndexBuffer(3,buffer2);
   return(0);
}
int deinit()
{
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

int start()
{
   int counted_bars=IndicatorCounted();
   int limit,i;
   
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit=Bars-counted_bars;

   //
   //
   //
   //
   //

   for(i=limit; i>=0; i--)
   {
      buffer1[i] = iMA(NULL,0,MA1Period,0,MA1Method,MA1Price,i);
      buffer2[i] = iMA(NULL,0,MA2Period,0,MA2Method,MA2Price,i);
      buffer3[i] = buffer1[i];
      buffer4[i] = buffer2[i];
   }
   return(0);
}

