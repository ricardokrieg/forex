//+------------------------------------------------------------------+
//|       NOTE: SMOOTHER v for 15M                                                    Updated 11/09 by OROMEK
//|                                         Strength Change now email alerted
  //+------------------------------------------------------------------+
#property copyright "SemSemFX@rambler.ru"
#property link      "http://onix-trade.net/forum/index.php?showtopic=107"
//----
string Indicator_Name = "V1.0_15M ";
int Objs =0;
//----
#property indicator_separate_window 
#property indicator_buffers 8
//---- parameters
extern int MA_Method = 2;
extern int Price = 3;
extern bool USD = 1;
extern bool EUR = 0;
extern bool GBP = 1;
extern bool CHF = 0;
extern bool JPY = 0;
extern bool AUD = 0;
extern bool CAD = 0;
extern bool NZD = 0;
extern color Color_USD = LawnGreen;
extern color Color_EUR = Pink;
extern color Color_GBP = DarkBlue;
extern color Color_CHF = CLR_NONE;
extern color Color_JPY = Yellow;
extern color Color_AUD = CLR_NONE;
extern color Color_CAD = CLR_NONE;
extern color Color_NZD = CLR_NONE;
extern int Line_Thickness = 3;
extern int All_Bars = 0;
extern int Last_Bars = 0;
// for monthly
extern int mn_per = 12;
extern int mn_fast = 3;
// for weekly
extern int w_per = 9;
extern int w_fast = 3;
// for daily
extern int d_per = 5;
extern int d_fast = 3;
// for H4
extern int h4_per = 18;
extern int h4_fast = 6;
// for H1
extern int h1_per = 24;
extern int h1_fast = 8;
// for M30
extern int m30_per = 8;
extern int m30_fast = 2;
// for M15
extern int m15_per = 25;
extern int m15_fast = 1;
// for M5
extern int m5_per = 5;
extern int m5_fast = 1;
// for M1
extern int m1_per = 10;
extern int m1_fast = 1;
extern bool Use_Alert=False;
extern bool EMail_Signals=False;
extern bool AlertAfterCross=False;
//----
double arrUSD[];
double arrEUR[];
double arrGBP[];
double arrCHF[];
double arrJPY[];
double arrAUD[];
double arrCAD[];
double arrNZD[];
int currBars,currBars1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   if(USD)
       Indicator_Name = StringConcatenate(Indicator_Name, " USD");
   if(EUR)
       Indicator_Name = StringConcatenate(Indicator_Name, " EUR");
   if(GBP)
       Indicator_Name = StringConcatenate(Indicator_Name, " GBP");
   if(CHF)
       Indicator_Name = StringConcatenate(Indicator_Name, " CHF");
   if(AUD)
       Indicator_Name = StringConcatenate(Indicator_Name, " AUD");
   if(CAD)
       Indicator_Name = StringConcatenate(Indicator_Name, " CAD");
   if(JPY)
       Indicator_Name = StringConcatenate(Indicator_Name, " JPY");
   if(NZD)
       Indicator_Name = StringConcatenate(Indicator_Name, " NZD");
   IndicatorShortName(Indicator_Name);
   int cur = 19; 
   int st = 23; 
   if(USD)
     {
       sl("~", cur, Color_USD);
       cur += st;
     }
   if(EUR)
     {
       sl("~", cur, Color_EUR); 
       cur += st;
     }
   if(GBP)
     {
       sl("~", cur, Color_GBP);
       cur += st;
     }
   if(CHF)
     {
       sl("~", cur, Color_CHF);
       cur += st;
     }
   if(AUD)
     {
       sl("~", cur, Color_AUD);
       cur+=st;
     }
   if(CAD)
     {
       sl("~", cur, Color_CAD);
       cur+=st;
     }
   if(JPY)
     {
       sl("~", cur, Color_JPY);
       cur += st;
     }
   if(NZD)
     {
       sl("~", cur, Color_NZD);
       cur+=st;
     }
//----
   int width = 0;
   if(0 > StringFind(Symbol(), "USD", 0))
       width = 1;
   else 
       width = Line_Thickness;
   SetIndexStyle(0, DRAW_LINE, DRAW_LINE, width, Color_USD);
   SetIndexBuffer(0, arrUSD);
   SetIndexLabel(0, "USD"); 
   if(0 > StringFind(Symbol(), "EUR", 0))
       width = 1;
   else 
       width = Line_Thickness;
   SetIndexStyle(1, DRAW_LINE, DRAW_LINE, width, Color_EUR);
   SetIndexBuffer(1, arrEUR);
   SetIndexLabel(1, "EUR"); 
   if(0 > StringFind(Symbol(), "GBP", 0))
       width = 1;
   else 
       width = Line_Thickness;
   SetIndexStyle(2, DRAW_LINE, DRAW_LINE, width, Color_GBP);
   SetIndexBuffer(2, arrGBP);
   SetIndexLabel(2, "GBP"); 
   if(0 > StringFind(Symbol(), "CHF", 0))
       width = 1;
   else 
       width = Line_Thickness;
   SetIndexStyle(3, DRAW_LINE, DRAW_LINE, width, Color_CHF);
   SetIndexBuffer(3, arrCHF);
   SetIndexLabel(3, "CHF"); 
   if(0 > StringFind(Symbol(), "JPY", 0))
       width = 1;
   else 
       width = Line_Thickness;
   SetIndexStyle(4, DRAW_LINE, DRAW_LINE, width, Color_JPY);
   SetIndexBuffer(4, arrJPY);
   SetIndexLabel(4, "JPY"); 
   if(0 > StringFind(Symbol(), "AUD", 0))
       width = 1;
   else 
       width = Line_Thickness;
   SetIndexStyle(5, DRAW_LINE, DRAW_LINE, width, Color_AUD);
   SetIndexBuffer(5, arrAUD);
   SetIndexLabel(5, "AUD"); 
   if(0 > StringFind(Symbol(), "CAD", 0))
       width = 1;
   else 
       width = Line_Thickness;
   SetIndexStyle(6, DRAW_LINE, DRAW_LINE, width, Color_CAD);
   SetIndexBuffer(6, arrCAD);
   SetIndexLabel(6, "CAD"); 
   if(0 > StringFind(Symbol(), "NZD", 0))
       width = 1;
   else 
       width = Line_Thickness;
   SetIndexStyle(7, DRAW_LINE, DRAW_LINE, width, Color_NZD);
   SetIndexBuffer(7, arrNZD);
   SetIndexLabel(7, "NZD"); 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   for(int i = 0; i < Objs; i++)
     {
       if(!ObjectDelete(Indicator_Name + i))
           Print("error: code #", GetLastError());
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars = IndicatorCounted();
//---- �������� �� ��������� ������
   if(counted_bars < 0) 
       return(-1);
//---- ��������� ����������� ��� ����� ����������
//   if(counted_bars>0) counted_bars-=10;
   /*if(All_Bars < 1)
       All_Bars = Bars;
   if(counted_bars > 0 && Last_Bars > 0) 
       counted_bars -= Last_Bars;
   limit = All_Bars - counted_bars;
   if (limit==0) limit=1;*/
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   int Slow, Fast;
   switch(Period())
     {
       case 1:     Slow = m1_per; Fast = m1_fast;  break;
       case 5:     Slow = m5_per; Fast = m5_fast;  break;
       case 15:    Slow = m15_per;Fast = m15_fast; break;
       case 30:    Slow = m30_per;Fast = m30_fast; break;
       case 60:    Slow = h1_per; Fast = h1_fast;  break;
       case 240:   Slow = h4_per; Fast = h4_fast;  break;
       case 1440:  Slow = d_per;  Fast = d_fast;   break;
       case 10080: Slow = w_per;  Fast = w_fast;   break;
       case 43200: Slow = mn_per; Fast = mn_fast;  break;
     }
//---- �������� ����
   for(int i = 0; i < limit; i++)
     {
       // ��������������� �������
       if(EUR)
         {
           double EURUSD_Fast = ma("EURUSD", Fast, MA_Method, Price, i);
           double EURUSD_Slow = ma("EURUSD", Slow, MA_Method, Price, i);
           if (!EURUSD_Fast || !EURUSD_Slow)
               break;
         }
       if(GBP)
         {
           double GBPUSD_Fast = ma("GBPUSD", Fast, MA_Method, Price, i);
           double GBPUSD_Slow = ma("GBPUSD", Slow, MA_Method, Price, i);
           if(!GBPUSD_Fast || !GBPUSD_Slow)
               break;
         }
       if(AUD)
         {
           double AUDUSD_Fast = ma("AUDUSD", Fast, MA_Method, Price, i);
           double AUDUSD_Slow = ma("AUDUSD", Slow, MA_Method, Price, i);
           if(!AUDUSD_Fast || !AUDUSD_Slow)
               break;
         }
       if(NZD)
         {
           double NZDUSD_Fast = ma("NZDUSD", Fast, MA_Method, Price, i);
           double NZDUSD_Slow = ma("NZDUSD", Slow, MA_Method, Price, i);
           if(!NZDUSD_Fast || !NZDUSD_Slow)
               break;
         }
       if(CAD)
         {
           double USDCAD_Fast = ma("USDCAD", Fast, MA_Method, Price, i);
           double USDCAD_Slow = ma("USDCAD", Slow, MA_Method, Price, i);
           if(!USDCAD_Fast || !USDCAD_Slow)
               break;
         }
       if(CHF)
         {
           double USDCHF_Fast = ma("USDCHF",Fast,MA_Method,Price,i);
           double USDCHF_Slow = ma("USDCHF",Slow,MA_Method,Price,i);
           if(!USDCHF_Fast || !USDCHF_Slow)
               break;
         }
       if(JPY)
         {
           double USDJPY_Fast = ma("USDJPY", Fast, MA_Method, Price, i) / 
                                100;
           double USDJPY_Slow = ma("USDJPY", Slow, MA_Method, Price, i) / 
                                100;
           if(!USDJPY_Fast || !USDJPY_Slow)
               break;
         }
       // ������� �����
       if(USD)
         {
           arrUSD[i] = 0;
           if(EUR) 
               arrUSD[i] += EURUSD_Slow - EURUSD_Fast;
           if(GBP) 
               arrUSD[i] += GBPUSD_Slow - GBPUSD_Fast;
           if(AUD) 
               arrUSD[i] += AUDUSD_Slow - AUDUSD_Fast;
           if(NZD) 
               arrUSD[i] += NZDUSD_Slow - NZDUSD_Fast;
           if(CHF) 
               arrUSD[i] += USDCHF_Fast - USDCHF_Slow;
           if(CAD) 
               arrUSD[i] += USDCAD_Fast - USDCAD_Slow;
           if(JPY) 
               arrUSD[i] += USDJPY_Fast - USDJPY_Slow;
         }// end if USD
       if(EUR)
         {
           arrEUR[i] = 0;
           if(USD) 
               arrEUR[i] += EURUSD_Fast - EURUSD_Slow;
           if(GBP) 
               arrEUR[i] += EURUSD_Fast / GBPUSD_Fast - EURUSD_Slow / 
                            GBPUSD_Slow;
           if(AUD) 
               arrEUR[i] += EURUSD_Fast / AUDUSD_Fast - EURUSD_Slow / 
                            AUDUSD_Slow;
           if(NZD) 
               arrEUR[i] += EURUSD_Fast / NZDUSD_Fast - EURUSD_Slow / 
                            NZDUSD_Slow;
           if(CHF) 
               arrEUR[i] += EURUSD_Fast*USDCHF_Fast - 
                            EURUSD_Slow*USDCHF_Slow;
           if(CAD) 
               arrEUR[i] += EURUSD_Fast*USDCAD_Fast - 
                            EURUSD_Slow*USDCAD_Slow;
           if(JPY) 
               arrEUR[i] += EURUSD_Fast*USDJPY_Fast - 
                            EURUSD_Slow*USDJPY_Slow;
         }// end if EUR
       if(GBP)
         {
           arrGBP[i] = 0;
           if(USD) 
               arrGBP[i] += GBPUSD_Fast - GBPUSD_Slow;
           if(EUR) 
               arrGBP[i] += EURUSD_Slow / GBPUSD_Slow - EURUSD_Fast / 
                            GBPUSD_Fast;
           if(AUD) 
               arrGBP[i] += GBPUSD_Fast / AUDUSD_Fast - GBPUSD_Slow / 
                            AUDUSD_Slow;
           if(NZD) 
               arrGBP[i] += GBPUSD_Fast / NZDUSD_Fast - GBPUSD_Slow / 
                            NZDUSD_Slow;
           if(CHF) 
               arrGBP[i] += GBPUSD_Fast*USDCHF_Fast - 
                            GBPUSD_Slow*USDCHF_Slow;
           if(CAD) 
               arrGBP[i] += GBPUSD_Fast*USDCAD_Fast - 
                            GBPUSD_Slow*USDCAD_Slow;
           if(JPY)
               arrGBP[i] += GBPUSD_Fast*USDJPY_Fast - 
                            GBPUSD_Slow*USDJPY_Slow;
         }// end if GBP
       if(AUD)
         {
           arrAUD[i] = 0;
           if(USD) 
               arrAUD[i] += AUDUSD_Fast - AUDUSD_Slow;
           if(EUR) 
               arrAUD[i] += EURUSD_Slow / AUDUSD_Slow - EURUSD_Fast / 
                            AUDUSD_Fast;
           if(GBP) 
               arrAUD[i] += GBPUSD_Slow / AUDUSD_Slow - GBPUSD_Fast / 
                            AUDUSD_Fast;
           if(NZD) 
               arrAUD[i] += AUDUSD_Fast / NZDUSD_Fast - AUDUSD_Slow / 
                            NZDUSD_Slow;
           if(CHF) 
               arrAUD[i] += AUDUSD_Fast*USDCHF_Fast - 
                            AUDUSD_Slow*USDCHF_Slow;
           if(CAD) 
               arrAUD[i] += AUDUSD_Fast*USDCAD_Fast - 
                            AUDUSD_Slow*USDCAD_Slow;
           if(JPY) 
               arrAUD[i] += AUDUSD_Fast*USDJPY_Fast - 
                            AUDUSD_Slow*USDJPY_Slow;
         }// end if AUD
       if(NZD)
         {
           arrNZD[i] = 0;
           if(USD) 
               arrNZD[i] += NZDUSD_Fast - NZDUSD_Slow;
           if(EUR) 
               arrNZD[i] += EURUSD_Slow / NZDUSD_Slow - EURUSD_Fast / 
                            NZDUSD_Fast;
           if(GBP) 
               arrNZD[i] += GBPUSD_Slow / NZDUSD_Slow - GBPUSD_Fast / 
                            NZDUSD_Fast;
           if(AUD) 
               arrNZD[i] += AUDUSD_Slow / NZDUSD_Slow - AUDUSD_Fast / 
                            NZDUSD_Fast;
           if(CHF) 
               arrNZD[i] += NZDUSD_Fast*USDCHF_Fast - 
                            NZDUSD_Slow*USDCHF_Slow;
           if(CAD) 
               arrNZD[i] += NZDUSD_Fast*USDCAD_Fast - 
                            NZDUSD_Slow*USDCAD_Slow;
           if(JPY) 
               arrNZD[i] += NZDUSD_Fast*USDJPY_Fast - 
                            NZDUSD_Slow*USDJPY_Slow;
         }// end if NZD
       if(CAD)
         {
           arrCAD[i] = 0;
           if(USD) 
           arrCAD[i] += USDCAD_Slow - USDCAD_Fast;
           if(EUR) 
           arrCAD[i] += EURUSD_Slow*USDCAD_Slow - 
                        EURUSD_Fast*USDCAD_Fast;
           if(GBP) 
           arrCAD[i] += GBPUSD_Slow*USDCAD_Slow - 
                        GBPUSD_Fast*USDCAD_Fast;
           if(AUD) 
           arrCAD[i] += AUDUSD_Slow*USDCAD_Slow - 
                        AUDUSD_Fast*USDCAD_Fast;
           if(NZD) 
           arrCAD[i] += NZDUSD_Slow*USDCAD_Slow - 
                        NZDUSD_Fast*USDCAD_Fast;
           if(CHF) 
           arrCAD[i] += USDCHF_Fast / USDCAD_Fast - 
                        USDCHF_Slow / USDCAD_Slow;
           if(JPY) 
           arrCAD[i] += USDJPY_Fast / USDCAD_Fast - 
                        USDJPY_Slow / USDCAD_Slow;
         }// end if CAD
       if(CHF)
         {
           arrCHF[i] = 0;
           if(USD) 
               arrCHF[i] += USDCHF_Slow - USDCHF_Fast;
           if(EUR) 
               arrCHF[i] += EURUSD_Slow*USDCHF_Slow - 
                            EURUSD_Fast*USDCHF_Fast;
           if(GBP) 
               arrCHF[i] += GBPUSD_Slow*USDCHF_Slow - 
                            GBPUSD_Fast*USDCHF_Fast;
           if(AUD) 
               arrCHF[i] += AUDUSD_Slow*USDCHF_Slow - 
                            AUDUSD_Fast*USDCHF_Fast;
           if(NZD) 
               arrCHF[i] += NZDUSD_Slow*USDCHF_Slow - 
                            NZDUSD_Fast*USDCHF_Fast;
           if(CAD) 
               arrCHF[i] += USDCHF_Slow / USDCAD_Slow - 
                            USDCHF_Fast / USDCAD_Fast;
           if(JPY) 
               arrCHF[i] += USDJPY_Fast / USDCHF_Fast - 
                            USDJPY_Slow / USDCHF_Slow;
         }// end if CHF
       if(JPY)
         {
           arrJPY[i] = 0;
           if(USD) 
           arrJPY[i] += USDJPY_Slow - USDJPY_Fast;
           if(EUR) 
           arrJPY[i] += EURUSD_Slow*USDJPY_Slow - 
                        EURUSD_Fast*USDJPY_Fast;
           if(GBP) 
           arrJPY[i] += GBPUSD_Slow*USDJPY_Slow - 
                        GBPUSD_Fast*USDJPY_Fast;
           if(AUD) 
           arrJPY[i] += AUDUSD_Slow*USDJPY_Slow - 
                        AUDUSD_Fast*USDJPY_Fast;
           if(NZD) 
           arrJPY[i] += NZDUSD_Slow*USDJPY_Slow - 
                        NZDUSD_Fast*USDJPY_Fast;
           if(CAD) 
           arrJPY[i] += USDJPY_Slow / USDCAD_Slow - 
                        USDJPY_Fast / USDCAD_Fast;
           if(CHF) 
           arrJPY[i] += USDJPY_Slow / USDCHF_Slow - 
                        USDJPY_Fast / USDCHF_Fast;
         }// end if JPY
     }//end block for(int i=0; i<limit; i++)
     if (currBars!=Bars)
     {
         if (((arrGBP[2]<0) && (arrGBP[1]>0)) || ((arrGBP[2]>0) && (arrGBP[1]<0)))
         {
            if (Use_Alert) Alert(Symbol(),": Strength Change");
            if (EMail_Signals) SendMail(Symbol()+" Strength Change"," Strength Change"); 
         }
         currBars=Bars;
     }
     
     if (!AlertAfterCross)
     {
         if (arrGBP[0]==0 && currBars1!=Bars)
         {
            if (Use_Alert) Alert(Symbol(),": Strength Change");
            if (EMail_Signals) SendMail(Symbol()+" Strength Change"," Strength Change"); 
            currBars1=Bars;
         }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|  Subroutines                                                     |
//+------------------------------------------------------------------+
double ma(string sym, int per, int Mode, int Price, int i)
  {
    return(iMA(sym, 0, per, 0, Mode, Price, i));
  }   
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void sl(string sym, int y, color col)
  {
   int window = WindowFind(Indicator_Name);
   string ID = Indicator_Name + Objs;
   Print("ID:", ID);
   int tmp = 10 + y;
   Objs++;
   if(ObjectCreate(ID, OBJ_LABEL, window, 0, 0))
     {
       //ObjectSet(ID, OBJPROP_CORNER, 1);
       ObjectSet(ID, OBJPROP_XDISTANCE, y + 35);
       ObjectSet(ID, OBJPROP_YDISTANCE, 0);
       ObjectSetText(ID, sym, 18, "Arial Black", col);
     }
  } 
//+------------------------------------------------------------------+


