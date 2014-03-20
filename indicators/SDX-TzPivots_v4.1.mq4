
//+------------------------------------------------------------------+
//|                                                     TZ-Pivot.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright Shimodax"
#property link      "http://www.strategybuilderfx.com"

/*------------------------------------------------------------------------------------
Introduction:

   Calculation of pivot and similar levels based on time zones.
   If you want to modify the colors, please scroll down to line
   200 and below (where it says "Calculate Levels") and change
   the colors.  Valid color names can be obtained by placing
   the curor on a color name (e.g. somewhere in the word "Orange"
   and pressing F1).
   
   Time-Zone Inputs:

   LocalTimeZone: TimeZone for which MT4 shows your local time, 
                  e.g. 1 or 2 for Europe (GMT+1 or GMT+2 (daylight 
                  savings time).  Use zero for no adjustment.                 
                  The MetaQuotes demo server uses GMT +2.
                  
   DestTimeZone:  TimeZone for the session from which to calculate
                  the levels (e.g. 1 or 2 for the European session
                  (without or with daylight savings time).  
                  Use zero for GMT
                             
   Example: If your MT server is living in the EST (Eastern Standard Time, 
            GMT-5) zone and want to calculate the levels for the London trading
            session (European time in summer GMT+1), then enter -5 for 
            LocalTimeZone, 1 for Dest TimeZone. 
            
            Please understand that the LocalTimeZone setting depends on the
            time on your MetaTrader charts (for example the demo server 
            from MetaQuotes always lives in CDT (+2) or CET (+1), no matter
            what the clock on your wall says. If in doubt, leave everything to zero.

   The following doesn't work yet, please leave it to 0/24:                 
            TradingHoursFrom: First hour of the trading session in the destination
            time zone.                    
            TradingHoursTo: Last hour of the trading session in the destination
            time zone (the hour starting with this value is excluded, i.e. 18 means
            up to 17:59 o'clock)
                   
   Example: If you are living in the EST (Eastern Standard Time, GMT-5) 
            zone and want to calculate the levels for the London trading
            session (European time GMT+1, 08:00 - 17:00), then enter
            -5 for LocalTimeZone, 1 for Dest TimeZone, 8 for HourFrom
            and 17 for hour to.
---------------------------------------------------------------------------------------

SDX-TzPivots_v4:

This version is the combination and culmination of all stages of revision/upgrade
subsequent to the original released by Shimodax.  Shimodax has created a wonderful
indicator.  Much has been added in the way of cosmetics and flexibility, but the
core time coding by Shimodax is unchanged. 

In the original, you could display both Daily pivots and Fib pivots, but the Fibs
were not per standard formula. You could display mid-pivots, yesterday H/L, todays
Open, Camarilla and SweetSpots.  Line style and colors were hard coded, meaning if
you wanted to change line styles here and there, or colors, you had to change them
in the code and re-complile the indicator.  In this area, a lot has been added.
Of all the original functions intended, only SweetSpots is eliminated, as Shimodax
has created a separate and better SDX-SweetSpots indicator.

This _v4 upgrade provides for full customization of all lines and labels....color,
style, thickness, font style, font size.  Period Separator lines can be displayed,
or not.  Their display can be at the top or bottom of the screen, eliminating some
congestion.  Their labels can be displayed, or not.  Additional cosmetic changes
include label changes, and better label positioning and justification to improve
the overall look.  

Aside from the many cosmetic changes and additions, functionality is improved. 
The original indicator would not draw lines on charts at the open of a session 
until one timeframe of a chart was complete.  This meant you had to wait 30 minutes
for the lines to appear on a 30 minute chart.  This is corrected.  In the original
indicator, line labels/values in time disappeared off the screen on lower timeframes
Two methods have been employed to deal with this.  "Sensing" relabeler code restores
these labels.  And another display mode (FullScreenLinesMarginPrices = "true")
has been added that produces lines with price labels in the right margin of the chart.
Line labels, which can include price, can be used in either mode.  When lines are
full screen, the position of labels is adjustable to the left and right.  The Daily
and Fibonacci pivots cannot both be displayed at the same time, but you can easily
switch.  Two additional levels have been added to the Fibonacci pivots and the user
also has the option to show quarter levels, which provides an extra level between 
a pivot level and a midpivot level.

Additional comments regarding some of the many Indicator Window inputs:
                              
Local__HrsServerTZFromGMT:
     Enter the number of hours difference between GMT and the time zone your
     platform server is in.  MT4 demo servers are GMT +2 hrs.  Use default value
     "0" for normal, non-time shifted pivot calculations.
     
Destination__HrsNewTzfromGMT:
     Enter the number of hours difference between GMT and the new time zone you
     are selecting as the basis for pivots calculations.  For example, if
     you wish to have the day start at NY time, then enter "-5".  If you wish to 
     have the day start at Zurich time, then enter "1".  Use the default value of
     "0" for normal, non-time shifted pivot calculations. 

Show_1Daily_2FibonacciPivots:
     Either formula can be used to produce the main pivot line
      
FullScreenLinesMarginPrices:
     "true" displays lines across entire screen with prices in the right margin.
     "false" displays lines starting at the "Today" Period Separator and which
     do not have margin labels.  For these lines, you will want to add labels.

MoveLabels_LR_DecrIncr:
     Increasing the number moves the line labels to the right on the chart.
     Decreasing the number moves the line labels to the left on the chart.
     This feature is absent in the original indicator.  It is for the
     "FullLinesMarginPrices = true" mode, to relocate line ID labels.  It
     also is used in the "FullLinesMarginPrices = false" mode once the
     Relabeler code takes over and is producing full screen lines.
              
Color Choices for lines and labels:
     Enter the colors of your choice.
     
LineStyle_01234:
     Your number entry selects the line style for the lines.  0=solid, 1=dash,
     2=dashdot, 3=dashdot, and 4=dashdotdot.
     
SolidLineThickness:
     Your number entry selects the width of solid lines.  0 and 1 = single width.
     2, 3, 4 graduate the thickness.  Coding assures that no matter what number
     this is set at, non-solid line styles selected will still display without
     having to change this entry back to 0, or 1.
     
_Label_Norm_Bold_Black_123:
     Entry of "1" produces Arial.  Entry of "2" produces Arial Bold.  And an
     entry of "3" produces Arial Black font style.    
          
ShowPeriodSeparatorLines:
     The choice of "true" will place a pair of vertical lines on the chart showing
     the start and stop of the new "Destination" 24 hour period you have selected
     for pivot calculations.  Choosing "false" cancels display of these lines and
     their "Yesterday" and "Today" labels.
     
PlaceAt_TopBot_12_OfChart:
     "1" will place the Period Separator labels "Yesterday" and "Today" at the
     top of the screen.  "2" will place them at the bottom.  The charts are less
     congested.  If the screen is enlarged, downsized, or scrolled, these labels
     will move.  But the next data tick restores their position.
 
LineLabelsIncludePrice:
     Line labels have IDs such as R#, PV, or S#, but selecting "true" will add the
     price anytime you have these labels on the chart.          
    
Relabeler_Adjustment:
     This number is used in the FullScreenLinesMarginPrices = "false"  mode to 
     trigger when the relabeler puts labels on the screen. It works under the
     assumption that the Today Period Separator is soon to go off-screen, taking
     the labels with it.  The ideal number would trigger the relabeler when the
     first labels are about to move off the left of the chart.  Lowering the
     number triggers sooner and raising it delays triggering.  The number is
     the number of candles between the Today Separator and the chart left border.
     For example, a value of "10" will trigger the relabeler when the Today Period
     Separator is 10 candles from the chart left border.  A value of "0" triggers
     when the Today Period Separator hits the left border.  This feature allows 
     for fine tuning charts of different scales and timeframes.  In most cases
     either of the example values is sufficient.  If the chart timeframe and
     scale is such that full sessions are displayed without the Today Separator
     ever disappearing, then relabeling and this adjustment to it, will not be
     required.  It only comes into play when the scale is such that the Today
     Period Separator will move off the left of the screen, taking the labels
     with it, before the next session Separators can come on-screen.  Scaling
     down to make larger candles causes more timeframes to require this feature,
     The coding takes this into account and use of this adjustment is really
     only for fine tuning whenever the user desires to do so.
     
Show_Relabeler_Comment: 
     If "true" then Relabeler related data appears in chart upper left. It
     serves to help a new user better understand the Relabeler.
          
Show_Data_Comment:
     If "true" then key prior/current day pip data appears in chart upper left.
     
                                                - Traderathome, December 20, 2008
---------------------------------------------------------------------------------*/                                               

#property indicator_chart_window
extern bool   Indicator_On?                  = true;
extern int    Local__HrsServerTzFromGMT      = 2;    //Data collection Tz of your server
extern int    Destination__HrsNewTZfromGMT   = 2;    //New destination Tz governing data
extern int    Show_1Daily_2FibonacciPivots   = 2;
extern bool   FullScreenLines                = true;
extern bool   __withMarginPrices             = false;
extern int    MoveLabels_LR_DecrIncr         = 0;    //-# to move left, +# to move right
extern color  R5_Color                       = FireBrick;
extern int    R5_LineStyle_01234             = 2;
extern int    R5_SolidLineThickness          = 1; 
extern color  R4_Color                       = FireBrick;
extern int    R4_LineStyle_01234             = 2;
extern int    R4_SolidLineThickness          = 1; 
extern color  R3_Color                       = FireBrick;
extern int    R3_LineStyle_01234             = 2;
extern int    R3_SolidLineThickness          = 1; 
extern color  R2_Color                       = FireBrick;
extern int    R2_LineStyle_01234             = 2;
extern int    R2_SolidLineThickness          = 1; 
extern color  R1_Color                       = FireBrick;
extern int    R1_LineStyle_01234             = 2;
extern int    R1_SolidLineThickness          = 1; 
extern color  CentralPivotColor              = Magenta;
extern int    CentralPivotLineStyle_01234    = 2;
extern int    CentralPivotSolidLineThickness = 1; 
extern color  S1_Color                       = ForestGreen;
extern int    S1_LineStyle_01234             = 2;
extern int    S1_SolidLineThickness          = 1; 
extern color  S2_Color                       = ForestGreen;
extern int    S2_LineStyle_01234             = 2;
extern int    S2_SolidLineThickness          = 1; 
extern color  S3_Color                       = ForestGreen;
extern int    S3_LineStyle_01234             = 2;
extern int    S3_SolidLineThickness          = 1; 
extern color  S4_Color                       = ForestGreen;
extern int    S4_LineStyle_01234             = 2;
extern int    S4_SolidLineThickness          = 1; 
extern color  S5_Color                       = ForestGreen;
extern int    S5_LineStyle_01234             = 2;
extern int    S5_SolidLineThickness          = 1; 
extern color  MidPivotsColor                 = DarkSlateGray;
extern int    MidPivotsLineStyle_01234       = 2;
extern int    MidPivotsLineThickness         = 1; 
extern bool   ShowMidPivots                  = true;
extern color  QtrPivotsColor                 = DarkSlateGray;
extern int    QtrPivotsLineStyle_01234       = 2;
extern int    QtrPivotsLineThickness         = 1; 
extern bool   ShowQtrPivots                  = false;
extern color  YesterdayHighLowColor          = Orchid;
extern int    HighLowLineStyle_01234         = 2;
extern int    HighLowSolidLineThickness      = 1; 
extern bool   ShowYesterdayHighLow           = false;
extern color  TodayOpenColor                 = LightSeaGreen;
extern int    TodayOpenLineStyle_01234       = 2;
extern int    TodayOpenSolidLineThickness    = 1; 
extern bool   ShowTodayOpen                  = true;
extern color  CamarillaColor                 = Magenta;
extern int    CamarillaLineStyle_01234       = 2;
extern int    CamarillaSolidLineThickness    = 1; 
extern bool   ShowCamarilla                  = false;
extern color  PeriodSeparatorLinesColor      = Olive;
extern int    SeparatorLinesStyle_01234      = 0;
extern int    SeparatorLinesThickness        = 1;
extern bool   ShowPeriodSeparatorLines       = true;
extern color  PeriodSeparatorsLabelsColor    = Red;
extern int    PlaceAt_TopBot_12_OfChart      = 2;
extern int    SeparatorLabelFontSize         = 10;
extern int    S_Label_Norm_Bold_Black_123    = 2;
extern bool   ShowPeriodSeparatorLabels      = true;
extern color  PivotLinesLabelColor           = DarkGray;
extern int    LineLabelsFontSize             = 8;
extern int    L_Label_Norm_Bold_Black_123    = 1;
extern bool   LineLabelsIncludePrice         = false;
extern int    Relabeler_Adjustment           = 10;       //-# to advance trigger, +# to delay trigger
extern bool   Show_Relabeler_Comment         = false;
extern bool   Show_Data_Comment              = false;

int MoveLabels, MoveLabels2;
int A,B; //relabeler triggers
int digits; //decimal digits for symbol's price 

//int TradingHoursFrom= 0;
//int TradingHoursTo= 24;     

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
	if (Ask>10) digits=2; else digits=4;
   Print("Period= ", Period()); 
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
int deinit()
{
   int obj_total= ObjectsTotal();
   string gvname;   
   for (int i= obj_total; i>=0; i--)
      {
      string name= ObjectName(i);   
      if (StringSubstr(name,0,7)=="[PIVOT]")  ObjectDelete(name);
      }    
   Comment(" ");
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   if (Indicator_On? == false) { return(0);}
   MoveLabels = (WindowFirstVisibleBar()/3)- MoveLabels_LR_DecrIncr+10;
   MoveLabels2= (WindowFirstVisibleBar()/2)- MoveLabels_LR_DecrIncr+8;
   static datetime timelastupdate= 0;
   static datetime lasttimeframe= 0;  
   datetime startofday= 0,
            startofyesterday= 0,
            startline= 0,
            startlabel= 0;
   double today_high= 0,
            today_low= 0,
            today_open= 0,
            yesterday_high= 0,
            yesterday_open= 0,
            yesterday_low= 0,
            yesterday_close= 0;
   int idxfirstbaroftoday= 0,
       idxfirstbarofyesterday= 0,
       idxlastbarofyesterday= 0;  
    
   //if (CurTime()-timelastupdate<60 && Period()==lasttimeframe)  return (0); //no need to update too often     
   lasttimeframe= Period();
   timelastupdate= CurTime();   

   //---- exit if period is greater than daily charts--------------------------------------------------
   //if(Period() > 1440) {Alert("TzPivots Error - Chart TF > 1 day.");return(-1);} // then exit  
   string gvname; double gvval;
 
   //-----let's find out which hour bars make today and yesterday--------------------------------------
   ComputeDayIndices( Local__HrsServerTzFromGMT,   Destination__HrsNewTZfromGMT    ,
           idxfirstbaroftoday, idxfirstbarofyesterday, idxlastbarofyesterday);
   startofday= Time[idxfirstbaroftoday];  // datetime (x-value) for labes on horizontal bars
   gvname=Symbol()+"st";
   gvval=startofday;
   GlobalVariableSet(gvname,gvval);
   startofyesterday= Time[idxfirstbarofyesterday];  // datetime (x-value) for labes on horizontal bars

   //-----walk forward through yestday's start and collect high/lows within the same day-------------------
   yesterday_high= -99999;  // not high enough to remain alltime high
   yesterday_low=  +99999;  // not low enough to remain alltime low   
   for (int idxbar= idxfirstbarofyesterday; idxbar>=idxlastbarofyesterday; idxbar--)
          {
          if (yesterday_open==0)  // grab first value for open
          yesterday_open= Open[idxbar];                           
          yesterday_high= MathMax(High[idxbar], yesterday_high);
          yesterday_low= MathMin(Low[idxbar], yesterday_low);      
          // overwrite close in loop until we leave with the last iteration's value
          yesterday_close= Close[idxbar];
          }
 
   //------walk forward through today and collect high/lows within the same day------------------------------
   today_open= Open[idxfirstbaroftoday];  // should be open of today start trading hour
   today_high= -99999; // not high enough to remain alltime high
   today_low=  +99999; // not low enough to remain alltime low
   for (int j= idxfirstbaroftoday; j>=0; j--) 
      {
      today_high= MathMax(today_high, High[j]);
      today_low= MathMin(today_low, Low[j]);
      }       

   //----relabeler code--------------------------------------------------------------------------------------
   if (FullScreenLines == true && __withMarginPrices == true) {B = 1;} //B=1 asserts margin labels
   if (FullScreenLines == true && __withMarginPrices == false){B = 0;} //B=0 prevents margin labels
   if (FullScreenLines == false)
      {
      B = 0;
      int AA = WindowFirstVisibleBar();  //# of visible bars on chart
      int BB = ((Time[0]-Time[idxfirstbaroftoday])/Period()/60); //# of bars btwn current time and Today Separator
      int RR = (AA - BB); //# number of bars btwn Today Separator and chart left margin
      int AL = Relabeler_Adjustment; //default of zero activates relabeler as Today Separator goes off-screen
      if (RR >  AL){A = 0;} //labels not near enough to chart left margin to trigger relabeler
      if (RR <= AL){A = 1;if(__withMarginPrices == true)B = 1;} //labels close enough - switch to full-screen 
      } 
   //----Autolabeler test comment
   string test = "";   
   test = "Current time to Separator = "+BB+" candles.";
   test = test + "   Separator to Chart left = "+RR+" candles.";
   test = test + "   Total candles visable = "+WindowFirstVisibleBar();
   test = test + "   Relabeler is set to trigger when Separator is  "+AL+"  candles from chart left.";
   if(Show_Relabeler_Comment ==true){Comment(test);}else {Comment (" ");}
   //----relabeler first clears old objects
   if (A==1)
      {
      int obj_total= ObjectsTotal(); 
      for (int k= obj_total; k>=0; k--)
         {
         string name= ObjectName(k);   
         if (StringSubstr(name,0,7)=="[PIVOT]")  ObjectDelete(name);
         }    
      }

   //------draw the vertical bars/labels that mark the session spans------------------------------------------
   if(ShowPeriodSeparatorLines == true)
      {
      if(SeparatorLinesStyle_01234>0) {SeparatorLinesThickness=1;}
      double top = WindowPriceMax();
   	double bottom = WindowPriceMin();
   	double scale = top - bottom;	
   	double YadjustTop = scale/5000; //250;
   	double YadjustBot = scale/(350/SeparatorLabelFontSize); 	
      double level = top - YadjustTop; if (PlaceAt_TopBot_12_OfChart==2){level = bottom + YadjustBot;}
      SetTimeLine("YesterdayStart", "Yesterday", idxfirstbarofyesterday+0,  PeriodSeparatorsLabelsColor,level);
      SetTimeLine("YesterdayEnd", "Today", idxfirstbaroftoday+0,  PeriodSeparatorsLabelsColor,level);    
      }
    
   //---- Calculate Pivot Levels ------------------------------------------------------------------------------- 
   double p, q, d, r1,r2,r3,r4,r5, s1,s2,s3,s4,s5;   
   d = (today_high - today_low);
   q = (yesterday_high - yesterday_low);
   p = (yesterday_high + yesterday_low + yesterday_close) / 3;  
   if(Show_1Daily_2FibonacciPivots == 1) 
   {
   r1 = (2*p)-yesterday_low;
   r2 = p+(yesterday_high - yesterday_low);  //r2 = p-s1+r1;
   r3 = (2*p)+(yesterday_high-(2*yesterday_low));
   s1 = (2*p)-yesterday_high;
   s2 = p-(yesterday_high - yesterday_low);  //s2 = p-r1+s1;
   s3 = (2*p)-((2* yesterday_high)-yesterday_low);
   }
   if(Show_1Daily_2FibonacciPivots == 2)
   {
   r1 = p+ (q * 0.382);   
   r2 = p+ (q * 0.618);  
 	r3 = p+q;  
   r4 = p+ (q * 1.618);
   r5 = p+ (q * 2.618);
   s2 = p- (q * 0.618);   
   s1 = p- (q * 0.382); 
  	s3 = p-q; 
   s4 = p- (q * 1.618);
   s5 = p- (q * 2.618);
   }
   if(FullScreenLines==false&&A==0) //lines start at separators, no margin labels in this mode
       {
       startlabel= Time[idxfirstbaroftoday]; 
       startline = Time[idxfirstbaroftoday+1];  //was "+1", "+0" stops line at Separator
       if (Time[0] > Time[idxfirstbaroftoday]){startline = Time[idxfirstbaroftoday];}
       }
   if(FullScreenLines==false&&A==1) //lines started at separators, but switched to full screen, value of B governs margin labels
       {
       startlabel= Time[MoveLabels];
       startline = WindowFirstVisibleBar();
       }      
   if(FullScreenLines==true) //lines selected to be full screen, margin labels governed by value of B in relabeler code
       {
       startlabel=Time[MoveLabels];     
       startline = WindowFirstVisibleBar();
       } 
   if(R5_LineStyle_01234>0){R5_SolidLineThickness=0;} 
   if(R4_LineStyle_01234>0){R4_SolidLineThickness=0;}
   if(R3_LineStyle_01234>0){R3_SolidLineThickness=0;} 
   if(R2_LineStyle_01234>0){R2_SolidLineThickness=0;}
   if(R1_LineStyle_01234>0){R1_SolidLineThickness=0;} 
   if(S1_LineStyle_01234>0){S1_SolidLineThickness=0;}
   if(S2_LineStyle_01234>0){S2_SolidLineThickness=0;} 
   if(S3_LineStyle_01234>0){S3_SolidLineThickness=0;}
   if(S4_LineStyle_01234>0){S4_SolidLineThickness=0;} 
   if(S5_LineStyle_01234>0){S5_SolidLineThickness=0;} 
   SetLevel("     R5 ", r5, R3_Color, R4_LineStyle_01234, R3_SolidLineThickness, startline,startlabel, B);  
   SetLevel("     R4 ", r4, R3_Color, R5_LineStyle_01234, R3_SolidLineThickness, startline,startlabel, B);
   SetLevel("     R3 ", r3, R3_Color, R3_LineStyle_01234, R3_SolidLineThickness, startline,startlabel, B);   
   SetLevel("     R2 ", r2, R2_Color, R2_LineStyle_01234, R2_SolidLineThickness, startline,startlabel, B); 
   SetLevel("     R1 ", r1, R1_Color, R1_LineStyle_01234, R1_SolidLineThickness, startline,startlabel, B); 
   if(Show_1Daily_2FibonacciPivots == 1){     
   SetLevel("     DPV ", p, CentralPivotColor, CentralPivotLineStyle_01234 ,
               CentralPivotSolidLineThickness, startline,startlabel, B);}
   if(Show_1Daily_2FibonacciPivots == 2){  
   SetLevel("     FPV ", p, CentralPivotColor, CentralPivotLineStyle_01234 ,
               CentralPivotSolidLineThickness, startline,startlabel, B);}    
   SetLevel("     S1 ", s1, S1_Color, S1_LineStyle_01234, S1_SolidLineThickness, startline,startlabel, B);
   SetLevel("     S2 ", s2, S2_Color, S2_LineStyle_01234, S2_SolidLineThickness, startline,startlabel, B);
   SetLevel("     S3 ", s3, S3_Color, S3_LineStyle_01234, S3_SolidLineThickness, startline,startlabel, B);    
   SetLevel("     S4 ", s4, S3_Color, S4_LineStyle_01234, S3_SolidLineThickness, startline,startlabel, B);
   SetLevel("     S5 ", s5, S3_Color, S5_LineStyle_01234, S3_SolidLineThickness, startline,startlabel, B);
   
   //------ Midpoints Pivots (mid-levels between pivots)
   if (ShowMidPivots==true) 
      {
      if(FullScreenLines==false&&A==0)
         {
         startlabel= Time[idxfirstbaroftoday]; 
         startline = Time[idxfirstbaroftoday+1];  //was "+1", "+0" stops line at Separator
         if (Time[0] > Time[idxfirstbaroftoday]){startline = Time[idxfirstbaroftoday];}
         }
      if(FullScreenLines==false&&A==1)
         {
         startlabel= Time[MoveLabels];
         startline = WindowFirstVisibleBar();
         } 
      if(FullScreenLines==true)
         {
         startlabel=Time[MoveLabels];     
         startline = WindowFirstVisibleBar();
         }          
      if(MidPivotsLineStyle_01234>0){MidPivotsLineThickness=0;}
      SetLevel("   MR5", (r4+r5)/2, MidPivotsColor, MidPivotsLineStyle_01234, MidPivotsLineThickness, startline,startlabel, B);
      SetLevel("   MR4", (r3+r4)/2, MidPivotsColor, MidPivotsLineStyle_01234, MidPivotsLineThickness, startline,startlabel, B);
      SetLevel("   MR3", (r2+r3)/2, MidPivotsColor, MidPivotsLineStyle_01234, MidPivotsLineThickness, startline,startlabel, B);
      SetLevel("   MR2", (r1+r2)/2, MidPivotsColor, MidPivotsLineStyle_01234, MidPivotsLineThickness, startline,startlabel, B);
      SetLevel("   MR1", (p+r1)/2,  MidPivotsColor, MidPivotsLineStyle_01234, MidPivotsLineThickness, startline,startlabel, B);
      SetLevel("   MS1", (p+s1)/2,  MidPivotsColor, MidPivotsLineStyle_01234, MidPivotsLineThickness, startline,startlabel, B);
      SetLevel("   MS2", (s1+s2)/2, MidPivotsColor, MidPivotsLineStyle_01234, MidPivotsLineThickness, startline,startlabel, B);
      SetLevel("   MS3", (s2+s3)/2, MidPivotsColor, MidPivotsLineStyle_01234, MidPivotsLineThickness, startline,startlabel, B);
      SetLevel("   MS4", (s3+s4)/2, MidPivotsColor, MidPivotsLineStyle_01234, MidPivotsLineThickness, startline,startlabel, B);
      SetLevel("   MS5", (s4+s5)/2, MidPivotsColor, MidPivotsLineStyle_01234, MidPivotsLineThickness, startline,startlabel, B);
      }

   //------ Quarterpoint Pivots (qtr-levels between pivots)
   if (ShowQtrPivots==true) 
      {
      if(FullScreenLines==false&&A==0)
         {
         startlabel= Time[idxfirstbaroftoday]; 
         startline = Time[idxfirstbaroftoday+1];  //was "+1", "+0" stops line at Separator
         if (Time[0] > Time[idxfirstbaroftoday]){startline = Time[idxfirstbaroftoday];}
         }
      if(FullScreenLines==false&&A==1)
         {
         startlabel= Time[MoveLabels];
         startline = WindowFirstVisibleBar();
         } 
      if(FullScreenLines==true)
         {
         startlabel=Time[MoveLabels];     
         startline = WindowFirstVisibleBar();
         }         
      if(QtrPivotsLineStyle_01234>0){QtrPivotsLineThickness=0;} 
      SetLevel("  q3R5", r4+((r5-r4)/4)*3, QtrPivotsColor, QtrPivotsLineStyle_01234, QtrPivotsLineThickness, startline,startlabel, B);
      SetLevel("  q1R5", r4+(r5-r4)/4,     QtrPivotsColor, QtrPivotsLineStyle_01234, QtrPivotsLineThickness, startline,startlabel, B);
      SetLevel("  q3R4", r3+((r4-r3)/4)*3, QtrPivotsColor, QtrPivotsLineStyle_01234, QtrPivotsLineThickness, startline,startlabel, B);
      SetLevel("  q1R4", r3+(r4-r3)/4,     QtrPivotsColor, QtrPivotsLineStyle_01234, QtrPivotsLineThickness, startline,startlabel, B);
      SetLevel("  q3R3", r2+((r3-r2)/4)*3, QtrPivotsColor, QtrPivotsLineStyle_01234, QtrPivotsLineThickness, startline,startlabel, B);
      SetLevel("  q1R3", r2+(r3-r2)/4,     QtrPivotsColor, QtrPivotsLineStyle_01234, QtrPivotsLineThickness, startline,startlabel, B);
      SetLevel("  q3R2", r1+((r2-r1)/4)*3, QtrPivotsColor, QtrPivotsLineStyle_01234, QtrPivotsLineThickness, startline,startlabel, B);
      SetLevel("  q1R2", r1+(r2-r1)/4,     QtrPivotsColor, QtrPivotsLineStyle_01234, QtrPivotsLineThickness, startline,startlabel, B);
      SetLevel("  q3R1", p+((r1-p)/4)*3,   QtrPivotsColor, QtrPivotsLineStyle_01234, QtrPivotsLineThickness, startline,startlabel, B);
      SetLevel("  q1R1", p+(r1-p)/4,       QtrPivotsColor, QtrPivotsLineStyle_01234, QtrPivotsLineThickness, startline,startlabel, B);     
      SetLevel("  q1S1", p-(p-s1)/4,       QtrPivotsColor, QtrPivotsLineStyle_01234, QtrPivotsLineThickness, startline,startlabel, B);
      SetLevel("  q3S1", p-((p-s1)/4)*3,   QtrPivotsColor, QtrPivotsLineStyle_01234, QtrPivotsLineThickness, startline,startlabel, B);     
      SetLevel("  q1S2", s1-(s1-s2)/4,     QtrPivotsColor, QtrPivotsLineStyle_01234, QtrPivotsLineThickness, startline,startlabel, B);
      SetLevel("  q3S2", s1-((s1-s2)/4)*3, QtrPivotsColor, QtrPivotsLineStyle_01234, QtrPivotsLineThickness, startline,startlabel, B); 
      SetLevel("  q1S3", s2-(s2-s3)/4,     QtrPivotsColor, QtrPivotsLineStyle_01234, QtrPivotsLineThickness, startline,startlabel, B);
      SetLevel("  q3S3", s2-((s2-s3)/4)*3, QtrPivotsColor, QtrPivotsLineStyle_01234, QtrPivotsLineThickness, startline,startlabel, B);     
      SetLevel("  q1S4", s3-(s3-s4)/4,     QtrPivotsColor, QtrPivotsLineStyle_01234, QtrPivotsLineThickness, startline,startlabel, B);
      SetLevel("  q3S4", s3-((s3-s4)/4)*3, QtrPivotsColor, QtrPivotsLineStyle_01234, QtrPivotsLineThickness, startline,startlabel, B); 
      SetLevel("  q1S5", s4-(s4-s5)/4,     QtrPivotsColor, QtrPivotsLineStyle_01234, QtrPivotsLineThickness, startline,startlabel, B);
      SetLevel("  q3S5", s4-((s4-s5)/4)*3, QtrPivotsColor, QtrPivotsLineStyle_01234, QtrPivotsLineThickness, startline,startlabel, B); 
      }

   //---- Yesterday High/Low
   if (ShowYesterdayHighLow == true)
      {
      if(FullScreenLines==false&&A==0)
         {
         startlabel= Time[idxfirstbaroftoday+10]; 
         startline = Time[idxfirstbarofyesterday+1];  //was "+1", "+0" stops line at Separator
         if (Time[0] > Time[idxfirstbaroftoday]){startline = Time[idxfirstbarofyesterday];}
         }
      if(FullScreenLines==false&&A==1)
         {
         startlabel= Time[MoveLabels2];
         startline = WindowFirstVisibleBar(); 
         } 
      if(FullScreenLines==true)
         {
        startlabel=Time[MoveLabels2];     
        startline = WindowFirstVisibleBar();
         }  
      if(HighLowLineStyle_01234>0){HighLowSolidLineThickness=0;}
      SetLevel("yHigh",yesterday_high,YesterdayHighLowColor,HighLowLineStyle_01234,
                   HighLowSolidLineThickness,startline,startlabel,B);      
      SetLevel("yLow ",yesterday_low,YesterdayHighLowColor,HighLowLineStyle_01234,
                   HighLowSolidLineThickness,startline,startlabel,B);
      }

   //---- Today Open
   if (ShowTodayOpen == true)
      {
      if(FullScreenLines==false&&A==0)
         {
         startlabel= Time[idxfirstbaroftoday+10]; 
         startline = Time[idxfirstbaroftoday+1];  //was "+1", "+0" stops line at Separator
         if (Time[0] > Time[idxfirstbaroftoday]){startline = Time[idxfirstbaroftoday];}
         }
      if(FullScreenLines==false&&A==1)
         {
         startlabel= Time[MoveLabels2];
         startline = WindowFirstVisibleBar();
         } 
      if(FullScreenLines==true)
         {
         startlabel=Time[MoveLabels2];     
         startline = WindowFirstVisibleBar();
         }  
      if(TodayOpenLineStyle_01234>0){TodayOpenSolidLineThickness=0;} 
      SetLevel("Open",today_open,TodayOpenColor,TodayOpenLineStyle_01234,
                   TodayOpenSolidLineThickness,startline,startlabel, B);
      }

   //----- Camarilla Lines
   if (ShowCamarilla==true) 
      {
      if(FullScreenLines==false&&A==0)
         {
         startlabel= Time[idxfirstbaroftoday+10]; 
         startline = Time[idxfirstbaroftoday+1];  //was "+1", "+0" stops line at Separator
         if (Time[0] > Time[idxfirstbaroftoday]){startline = Time[idxfirstbaroftoday];}
         }
      if(FullScreenLines==false&&A==1)
         {
         startlabel= Time[MoveLabels2];
         startline = WindowFirstVisibleBar();
         }   
      if(FullScreenLines==true)
         {
         startlabel=Time[MoveLabels2];     
         startline = WindowFirstVisibleBar();
         } 
      if(CamarillaLineStyle_01234>0){CamarillaSolidLineThickness=0;}
      double cr2, cr1, cs1,cs2;
	   cr2 = (q*0.55)+yesterday_close;
	   cr1 = (q*0.27)+yesterday_close;
	   cs1 = yesterday_close-(q*0.27);	
	   cs2 = yesterday_close-(q*0.55);		   
      SetLevel("CR1", cr1, CamarillaColor, CamarillaLineStyle_01234, CamarillaSolidLineThickness, startline, startlabel, B);
      SetLevel("CR2", cr2, CamarillaColor, CamarillaLineStyle_01234, CamarillaSolidLineThickness, startline, startlabel, B);
      SetLevel("CS1", cs1, CamarillaColor, CamarillaLineStyle_01234, CamarillaSolidLineThickness, startline, startlabel, B);
      SetLevel("CS2", cs2, CamarillaColor, CamarillaLineStyle_01234, CamarillaSolidLineThickness, startline, startlabel, B);
      }

   //------ Comment for upper left corner
   if (Show_Data_Comment) {
      string comment= "  ";      
      comment= comment + "-- Good luck with your trading! ---\n";
      comment= comment + "Range: Yesterday "+DoubleToStr(MathRound(q/Point),0) 
                       +" pips, Today "+DoubleToStr(MathRound(d/Point),0)+" pips" + "\n";
      comment= comment + "Highs: Yesterday "+DoubleToStr(yesterday_high,Digits)  
                       +", Today "+DoubleToStr(today_high,Digits) +"\n";
      comment= comment + "Lows:  Yesterday "+DoubleToStr(yesterday_low,Digits)  
                       +", Today "+DoubleToStr(today_low,Digits)  +"\n";
      comment= comment + "Close: Yesterday "+DoubleToStr(yesterday_close,Digits) + "\n";
   // comment= comment + "Pivot: " + DoubleToStr(p,Digits) + ", S1/2/3: " + DoubleToStr(s1,Digits)
   //                  + "/" + DoubleToStr(s2,Digits) + "/" + DoubleToStr(s3,Digits) + "\n" ;
   // comment= comment + "Fibos: " + DoubleToStr(yesterday_low + q*0.382, Digits) + ", " 
   //                  + DoubleToStr(yesterday_high - q*0.382,Digits) + "\n";     
      Comment(comment); 
   }
   return(0);
} 

//+------------------------------------------------------------------+
//| Compute index of first/last bar of yesterday and today           |
//+------------------------------------------------------------------+
void ComputeDayIndices(int tzlocal, int tzdest, int &idxfirstbaroftoday,
       int &idxfirstbarofyesterday, int &idxlastbarofyesterday)
{     
   int tzdiff= tzlocal - tzdest,
       tzdiffsec= tzdiff*3600,
       dayminutes= 24 * 60,
       barsperday= dayminutes/Period();
   
   int dayofweektoday= TimeDayOfWeek(Time[0] - tzdiffsec),  // what day is today in the dest timezone?
       dayofweektofind= -1; 
      // due to gaps in the data, and shift of time around weekends (due 
      // to time zone) it is not as easy as to just look back for a bar 
      // with 00:00 time  
      idxfirstbaroftoday= 0;
      idxfirstbarofyesterday= 0;
      idxlastbarofyesterday= 0;      
   switch (dayofweektoday) 
      { 
      case 6: // sat
      case 0: // sun
      case 1: // mon
            dayofweektofind= 5; // yesterday in terms of trading was previous friday
            break;           
      default:
            dayofweektofind= dayofweektoday -1; 
            break;
      }           
   //----search  backwards for the last occrrence (backwards) of the day today (today's first bar)-----------
   for (int i=1; i<=barsperday+1; i++) 
      {
      datetime timet= Time[i] - tzdiffsec;
      if (TimeDayOfWeek(timet)!=dayofweektoday) {idxfirstbaroftoday= i-1; break;}
      }
   // search  backwards for the first occrrence (backwards) of the weekday we are looking for (yesterday's last bar)
   for (int j= 0; j<=2*barsperday+1; j++)
      {
      datetime timey= Time[i+j] - tzdiffsec;
      if (TimeDayOfWeek(timey)==dayofweektofind) {  // ignore saturdays (a Sa may happen due to TZ conversion)
      idxlastbarofyesterday= i+j; break;}
      }
   // search  backwards for the first occurrence of weekday before yesterday (to determine yesterday's first bar)
   for (j= 1; j<=barsperday; j++)
      {
      datetime timey2= Time[idxlastbarofyesterday+j] - tzdiffsec;
      if (TimeDayOfWeek(timey2)!=dayofweektofind) {  // ignore saturdays (a Sa may happen due to TZ conversion)
      idxfirstbarofyesterday= idxlastbarofyesterday+j-1; break;}
      } 
}

//+------------------------------------------------------------------+
//| Helper                                                           |
//+------------------------------------------------------------------+
void SetLevel(string text, double level, color col1, int linestyle,
        int thickness, datetime startline, datetime startlabel, int CC)
{
   int digits= Digits; 
   string labelname= "[PIVOT] " + text + " Label", linename= "[PIVOT] " + text + " Line", pricelabel; 

   //----create or move the horizontal line-------------------------------------------------------      
   int Z;
   if (CC == 0){Z = OBJ_TREND;}
   if (CC == 1){Z = OBJ_HLINE;}   
   if (ObjectFind(linename) != 0) 
       {
       ObjectCreate(linename, Z, 0, startline, level, Time[0], level);
       ObjectSet   (linename, OBJPROP_STYLE, linestyle);
       ObjectSet   (linename, OBJPROP_COLOR, col1);
       ObjectSet   (linename, OBJPROP_WIDTH, thickness);
       }
   else
       {
       ObjectMove  (linename, 1, Time[0],level);
       ObjectMove  (linename, 0, startline, level);
       }     
 
   //----create or move the labels----------------------------------------------------------------- 
     string FontStyle;   
     if (L_Label_Norm_Bold_Black_123 <= 1){FontStyle = "Arial";}
     if (L_Label_Norm_Bold_Black_123 == 2){FontStyle = "Arial Bold";}
     if (L_Label_Norm_Bold_Black_123 >= 3){FontStyle = "Arial Black";}
   
     if (ObjectFind(labelname) != 0)
        {
        ObjectCreate(labelname, OBJ_TEXT, 0, startlabel, level);
        }
     else
        {
        ObjectMove(labelname, 0, startlabel, level);
        }   
     pricelabel= "                         " + text;
     if (LineLabelsIncludePrice && StrToInteger(text)==0) pricelabel= pricelabel + ": "+DoubleToStr(level, Digits);   
     ObjectSetText(labelname, pricelabel, LineLabelsFontSize , FontStyle, PivotLinesLabelColor);
}

//+-------------------------------------------------------------------------------------------+
//| Helper=draws vertical timelines & gets "yesterday/today" from elsewhere and displays them.|                                                        
//+-------------------------------------------------------------------------------------------+
void SetTimeLine(string objname, string text, int idx, color col1, double vleveltext) 
{
   string FontStyle; string name= "[PIVOT] " + objname; int x= Time[idx];
   if (ObjectFind(name) != 0)
      { 
      ObjectCreate(name, OBJ_TREND, 0, x, 0, x, 100);
      ObjectSet(name, OBJPROP_STYLE, SeparatorLinesStyle_01234);
      ObjectSet(name, OBJPROP_COLOR, PeriodSeparatorLinesColor);
      ObjectSet(name, OBJPROP_WIDTH, SeparatorLinesThickness); 
      }
   else 
      {
      ObjectMove(name, 0, x, 0); 
      ObjectMove(name, 1, x, 100);
      }  
   if(ShowPeriodSeparatorLabels ==true)
      {  
      if (S_Label_Norm_Bold_Black_123 <= 1){FontStyle = "Arial";}
      if (S_Label_Norm_Bold_Black_123 == 2){FontStyle = "Arial Bold";}
      if (S_Label_Norm_Bold_Black_123 >= 3){FontStyle = "Arial Black";}
      if (ObjectFind(name + " Label") != 0) 
         {
         ObjectCreate(name + " Label", OBJ_TEXT, 0, x, vleveltext);     
         }       
      else 
         {
         ObjectMove(name + " Label", 0, x, vleveltext);            
         }     
      ObjectSetText(name + " Label", text, SeparatorLabelFontSize, FontStyle,  PeriodSeparatorsLabelsColor);
      }
}

//------------------------End Program-----------------------------------------------------------------