//+------------------------------------------------------------------+
//|                                              Hull Moving Average |
//|                                                           mladen |
//| Modified from Bernardo @ http://www.forexfactory.com/ber_tdf     |
//+------------------------------------------------------------------+
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1  Blue
#property indicator_color2  Red
#property indicator_color3  Red
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2

extern string TimeFrame        = "Current time frame";
extern int    HMAPeriod        = 10;
extern int    HMAPrice         = PRICE_CLOSE;
extern double HMASpeed         = 1.8;

extern bool   ShowArrows       = true;
extern string arrowsIdentifier = "HMA arrows";
extern color  arrowsUpColor    = Blue;
extern color  arrowsDnColor    = Red;

extern bool   Filter1M         = false;
extern bool   Filter5M         = false;

extern bool   EMAFilter        = false;
extern int    EMAPeriod        = 50;

extern bool   alertsOn         = false;
extern bool   alertsOnCurrent  = true;
extern bool   alertsMessage    = true;
extern bool   alertsSound      = false;
extern bool   alertsEmail      = false;

double hma[];
double hmada[];
double hmadb[];
double work[];
double trend[];

int    HalfPeriod;
int    HullPeriod;

string indicatorFileName;
bool   returnBars;
bool   calculateValue;
bool   tDraw = FALSE;
int    timeFrame;
double tMA[5];

int tBarTime, tBarChange;

int init() {
   IndicatorBuffers(5);
   SetIndexBuffer(0,hma);
   SetIndexBuffer(1,hmada);
   SetIndexBuffer(2,hmadb);
   SetIndexBuffer(3,trend);
   SetIndexBuffer(4,work);
      
   HMAPeriod  = MathMax(2,HMAPeriod);
   HalfPeriod = MathFloor(HMAPeriod/HMASpeed);
   HullPeriod = MathFloor(MathSqrt(HMAPeriod));

   indicatorFileName = WindowExpertName();
   calculateValue    = TimeFrame=="calculateValue"; if (calculateValue) { return(0); }
   returnBars        = TimeFrame=="returnBars";     if (returnBars)     { return(0); }
   timeFrame         = stringToTimeFrame(TimeFrame);

   IndicatorShortName(timeFrameToString(timeFrame) + " HMA (" + HMAPeriod + ")");
   tBarTime = Time[1];
   return(0);
}

int deinit() {
   if (ShowArrows) deleteArrows();

   tBarTime = Time[1];
   return(0); 
}

int start() {
   if (tBarTime == Time[0]) {
      return (0);
   }
   tBarTime = Time[0];
   
   int i,counted_bars = IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;   
           int limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { hma[0] = MathMin(limit+1,Bars-1); return(0); }

   if (calculateValue || timeFrame == Period()) {
      if (trend[limit] == -1) CleanPoint(limit,hmada,hmadb);
      for(i=limit; i>=0; i--) work[i] = 2.0*iMA(NULL,0,HalfPeriod,0,MODE_LWMA,HMAPrice,i)-iMA(NULL,0,HMAPeriod,0,MODE_LWMA,HMAPrice,i);
      for(i=limit; i>=0; i--)
      {
         hma[i]   = iMAOnArray(work,0,HullPeriod,0,MODE_LWMA,i);
         hmada[i] = EMPTY_VALUE;
         hmadb[i] = EMPTY_VALUE;
         trend[i] = trend[i+1];
         if (hma[i] > hma[i+1]) trend[i] =  1;
         if (hma[i] < hma[i+1]) trend[i] = -1;
         if (trend[i] == -1) PlotPoint(i,hmada,hmadb,hma);
            
         tMA[0] = iMA(NULL, 0, EMAPeriod, 0, MODE_EMA, PRICE_CLOSE, i);
         tMA[3] = tMA[2];
         tMA[2] = tMA[1];
         tMA[1] = iMA(NULL, 0, EMAPeriod, 0, MODE_EMA, PRICE_CLOSE, i + 1);
            
         manageArrow(i);
      
      }      
      manageAlerts();
      return(0);
   }
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   if (trend[limit]==-1) CleanPoint(limit,hmada,hmadb);
   for (i=limit; i>=0; i--) {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         trend[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",HMAPeriod,HMAPrice,HMASpeed,3,y);
         hma[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",HMAPeriod,HMAPrice,HMASpeed,0,y);
         hmada[i] = EMPTY_VALUE;
         hmadb[i] = EMPTY_VALUE;
         manageArrow(i);
   }
   for (i=limit;i>=0;i--) if (trend[i]==-1) PlotPoint(i,hmada,hmadb,hma);
   manageAlerts();
   
   return(0);
         
}

void manageAlerts() {
   if (!calculateValue && alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] ==  1) doAlert(whichBar,"up");
         if (trend[whichBar] == -1) doAlert(whichBar,"down");
      }
   }
}

void doAlert(int forBar, string doWhat) {
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       message =  Symbol()+" "+timeFrameToString(timeFrame)+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" HMA trend changed to "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(Symbol()+" HMA ",message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

void CleanPoint(int i,double& first[],double& second[]) {
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[]) {
   if (first[i+1] == EMPTY_VALUE)
      {
         if (first[i+2] == EMPTY_VALUE) {
                first[i]   = from[i];
                first[i+1] = from[i+1];
                second[i]  = EMPTY_VALUE;
            }
         else {
                second[i]   =  from[i];
                second[i+1] =  from[i+1];
                first[i]    = EMPTY_VALUE;
            }
      }
   else
      {
         first[i]  = from[i];
         second[i] = EMPTY_VALUE;
      }
}

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

int stringToTimeFrame(string tfs) {
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}

string timeFrameToString(int tf) {
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

string stringUpperCase(string str) {
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

void manageArrow(int i) {
   int j, tPeriod, tSeconds;
   double tPrice;
   bool tEmaUP = FALSE, tEmaDW = FALSE, tEmaChangeUP = FALSE, tEmaChangeDW = FALSE, tArrowPlot;

   if (trend[i] != trend[i+1]) {
      tDraw = FALSE;
      tBarChange = Time[i];
   }
   
   // Determino la tendencia de la EMA
   if (tMA[0] > tMA[1]) {
      tEmaUP = TRUE;
   } else {
      tEmaDW = TRUE;
   }   

   // Determino el cambio en la tendencia de la EMA
   if ((tMA[0] > tMA[1] && tMA[1] < tMA[2]) || (tMA[0] > tMA[1] && tMA[1] > tMA[2] && tMA[2] < tMA[3])) {
      tEmaChangeUP = TRUE;
   }   
   if ((tMA[0] < tMA[1] && tMA[1] > tMA[2]) || (tMA[0] < tMA[1] && tMA[1] < tMA[2] && tMA[2] > tMA[3])) {
      tEmaChangeDW = TRUE;
   }   

   if (ShowArrows && (Time[0] - tBarChange) >= 120) {
//      deleteArrow(Time[i]);

      // Pongo los arrows segun el criterio de Favorite
      if (trend[i + 1] != trend[i + 2] && trend[i] == trend[i + 1] && Filter1M == FALSE && Filter5M == FALSE) {

         if (trend[i] == 1) {
            if (tDraw == FALSE) {
               drawArrow(i, arrowsUpColor, 159, false);
               tDraw = TRUE;
            }
         }

         if (trend[i] == -1) {
            if (tDraw == FALSE) {
               drawArrow(i, arrowsDnColor, 159, true);
               tDraw = TRUE;
            }
         }

      }
         
      for(j = 1; j <= 2; j++) {
      
         switch (j) {
            case 2 : 
               tPeriod  = PERIOD_M5;
               tSeconds = 120;
            break;
            default:
               tPeriod  = PERIOD_M1;
               tSeconds = 60;
         }


         // Verifico las condiciones de las velas en 1 minuto
         if (trend[i] == 1 && (Filter1M == TRUE || Filter5M == TRUE)) {
            tArrowPlot = FALSE;

            if (tDraw == FALSE
               && Filter1M == TRUE
               && (EMAFilter == FALSE || (EMAFilter == TRUE && tEmaUP == TRUE))
               && High[i] > iHigh(NULL, tPeriod, iBarShift(NULL, tPeriod, Time[i]) + 1)
//               && Time[i] - iTime(NULL, tPeriod, iBarShift(NULL, tPeriod, Time[i])) <= tSeconds
               ) {
               tArrowPlot = TRUE;
               tDraw = TRUE;
            }
            
            if (tDraw == FALSE
               && Filter5M == TRUE
               && (EMAFilter == FALSE || (EMAFilter == TRUE && tEmaUP == TRUE))
               && iOpen(NULL, tPeriod, iBarShift(NULL, tPeriod, Time[i]) + 2) > iClose(NULL, tPeriod, iBarShift(NULL, tPeriod, Time[i]) + 2)
               && iOpen(NULL, tPeriod, iBarShift(NULL, tPeriod, Time[i]) + 1) < iClose(NULL, tPeriod, iBarShift(NULL, tPeriod, Time[i]) + 1)
               && High[i] > iHigh(NULL, tPeriod, iBarShift(NULL, tPeriod, Time[i]) + 1)
               && Time[i] - iTime(NULL, tPeriod, iBarShift(NULL, tPeriod, Time[i])) <= tSeconds
               ) {
               tArrowPlot = TRUE;
               tDraw = TRUE;
            
            }

            // Si tengo habilitado el filtro de EMA siempre pongo una flecha cuando hay un cambio de tendencia
            if (tDraw == FALSE && (EMAFilter == TRUE && tEmaChangeUP == TRUE)) {
               tArrowPlot = TRUE;
               tDraw = TRUE;
            }

            if (tArrowPlot == TRUE) {            
               drawArrow(i, arrowsUpColor, 159, false);
               tDraw = TRUE;
            }
         }

         
         if (trend[i] == -1 && (Filter1M == TRUE || Filter5M == TRUE)) {
            tArrowPlot = FALSE;
            
            if (tDraw == FALSE
               && Filter1M == TRUE
               && (EMAFilter == FALSE || (EMAFilter == TRUE && tEmaDW == TRUE))
               && Low[i] < iLow(NULL, tPeriod, iBarShift(NULL, tPeriod, Time[i]) + 1)
//               && Time[i] - iTime(NULL, tPeriod, iBarShift(NULL, tPeriod, Time[i])) <= tSeconds
               ) {
               tArrowPlot = TRUE;
               tDraw = TRUE;
            }

            if (tDraw == FALSE
               && Filter5M == TRUE
               && tDraw == FALSE
               && (EMAFilter == FALSE || (EMAFilter == TRUE && tEmaDW == TRUE))
               && iOpen(NULL, tPeriod, iBarShift(NULL, tPeriod, Time[i]) + 2) < iClose(NULL, tPeriod, iBarShift(NULL, tPeriod, Time[i]) + 2)
               && iOpen(NULL, tPeriod, iBarShift(NULL, tPeriod, Time[i]) + 1) > iClose(NULL, tPeriod, iBarShift(NULL, tPeriod, Time[i]) + 1)
               && Low[i] < iLow(NULL, tPeriod, iBarShift(NULL, tPeriod, Time[i]) + 1)
               && Time[i] - iTime(NULL, tPeriod, iBarShift(NULL, tPeriod, Time[i])) <= tSeconds
               ) {
               tArrowPlot = TRUE;
               tDraw = TRUE;
            }

            // Si tengo habilitado el filtro de EMA siempre pongo una flecha cuando hay un cambio de tendencia
            if (tDraw == FALSE && (EMAFilter == TRUE && tEmaChangeDW == TRUE)) {
               tArrowPlot = TRUE;
               tDraw = TRUE;
            }

            if (tArrowPlot == TRUE) {            
               drawArrow(i, arrowsDnColor, 159, true);
               tDraw = TRUE;
            }

         }
      }
   }
}               

void drawArrow(int i, color theColor, int theCode, bool up) {
   string name = arrowsIdentifier + ": " + Time[i];
   double gap  = 3.0 * iATR(NULL, 0, 20, i) / 4.0;   
   
      ObjectCreate(name, OBJ_ARROW, 0, Time[i], 0);
         ObjectSet(name, OBJPROP_ARROWCODE, theCode);
         ObjectSet(name, OBJPROP_COLOR, theColor);
         if (up)
               ObjectSet(name, OBJPROP_PRICE1, hma[i] + gap);
         else  ObjectSet(name, OBJPROP_PRICE1, hma[i] - gap);
}

void deleteArrows() {
   string lookFor       = arrowsIdentifier+": ";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--) {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
}

void deleteArrow(datetime time) {
   string lookFor = arrowsIdentifier+": " + time; 
   ObjectDelete(lookFor);
}