//+------------------------------------------------------------------+
//|                                               CoinFlip EA V21.mq4 |
//|                                    Copyright 2014, Zheng zuodong |
//|                                                    yczzd@163.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Zheng zuodong"
#property link      "yczzd@163.com"
#property version   "2.10"
#property strict

extern string TimezoneSetup    = "---Setup time for London Open Bar";
extern int    LocalGMTOffset   = 8;
extern int    BrokerGMTOffset  = 2;
extern string  LondonOpenTime  = "9:00";

extern string RiskSetup     = "---Setup Risk Reward ratio";
extern double EquityPercent = 0.2;                 
extern double HardSL        = 45.0;              
extern bool   DynamicLots   = true;
extern double FixedLots     = 0.1;

extern int    MagicNumber   = 777;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  ObjectsDeleteAll(); 
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
  int DayOfDST;
  int LondonGMTOffset;
  int OP;
  double YesterdayHigh, YesterdayLow;
  double SLamount, SLprice;
  string comm;
  int    i, ExistOrderFlag;
  int    LondonOpenBarShift, pre_LondonOpenBarShift;
  datetime LondonTime, LOTinBroker, pre_LOTinBroker;

  if(Period()!=60)
  {
    Comment("The EA run in H1 Chart.....");
    return;
  }
//+---London time  
  DayOfDST = TimeDayOfYear(TimeCurrent());
  if(DayOfDST>=84 && DayOfDST<=298)            //London DST
    LondonGMTOffset=1;
  else
    LondonGMTOffset=0;
  LondonTime = TimeCurrent()-(BrokerGMTOffset-LondonGMTOffset)*3600;
  LOTinBroker= StrToTime(LondonOpenTime)+(BrokerGMTOffset-LondonGMTOffset)*3600;
  if(TimeDayOfWeek(TimeCurrent())==1)
    pre_LOTinBroker = LOTinBroker-3*24*3600;
  else
    pre_LOTinBroker = LOTinBroker-24*3600;
  ObjectCreate("LondonOpen",OBJ_VLINE,0,LOTinBroker,0);
  ObjectCreate("pre-LondonOpen",OBJ_VLINE,0,pre_LOTinBroker,0);
  ObjectSet("LondonOpen",OBJPROP_COLOR,Pink);
  ObjectSet("pre-LondonOpen",OBJPROP_COLOR,Pink);
  LondonOpenBarShift=iBarShift(Symbol(),0,LOTinBroker);
  pre_LondonOpenBarShift=iBarShift(Symbol(),0,pre_LOTinBroker);
  YesterdayHigh=High[iHighest(Symbol(),0,MODE_HIGH,pre_LondonOpenBarShift-LondonOpenBarShift,LondonOpenBarShift)];
  YesterdayLow =Low[iLowest(Symbol(),0,MODE_LOW,pre_LondonOpenBarShift-LondonOpenBarShift,LondonOpenBarShift)];
  ObjectCreate("pre-high",OBJ_HLINE,0,0,YesterdayHigh);
  ObjectCreate("pre-low",OBJ_HLINE,0,0,YesterdayLow);
  ObjectSet("pre-high",OBJPROP_COLOR,Yellow);
  ObjectSet("pre-low",OBJPROP_COLOR,Yellow);
  
//  comm ="\n"+ "LondonTime Now = "+TimeToStr(LondonTime,TIME_DATE|TIME_SECONDS)+"\n"
//        +"LondonOpen in Broker Time = "+TimeToStr(LOTinBroker,TIME_DATE|TIME_MINUTES)+"\n";

  for(i=0; i<OrdersTotal(); i++) 
  {
    if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==false)
      Print("OrderSelect() Function error = ",GetLastError());
    if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
    {  
       ExistOrderFlag=1;
       break;
    }
    else  ExistOrderFlag=0;
  }
//+---when London session open, Close order 
  if(TimeHour(TimeCurrent())==TimeHour(LOTinBroker))
  {
     CloseOrdersByMagicNumber(MagicNumber);
     ExistOrderFlag=0;
  }
     
//+------Open a order at end of 1th h1 bar(or start of 2th h1 bar)
  if(TimeHour(TimeCurrent())==TimeHour(LOTinBroker)+1) 
  {
//+---long if 1th h1 bar is bull     
     if(Close[1]-Open[1]>0 && ExistOrderFlag==0)
     {
        OP=OP_BUY;
        if((Ask-YesterdayLow)>=HardSL*Point)
        {  SLprice=Ask-HardSL*Point;  SLamount=HardSL;  }
        else
        {  SLprice=YesterdayLow;  SLamount=(Ask-YesterdayLow)/Point; }
        
        OpenOrderByMagicNumber(Symbol(),OP,Ask,SLamount,SLprice,"CF_BUY "+IntegerToString(MagicNumber,0));
        ExistOrderFlag=1;
     }
//+---short if 2th h1 bar is bear
     if(Close[1]-Open[1]<0 && ExistOrderFlag==0)
     {
        OP=OP_SELL;
        if((YesterdayHigh-Bid)>=HardSL*Point)
        {  SLprice=Bid+HardSL*Point;  SLamount=HardSL;  }
        else
        {  SLprice=YesterdayHigh; SLamount=(YesterdayHigh-Bid)/Point; }
        
        OpenOrderByMagicNumber(Symbol(),OP,Bid,SLamount,SLprice,"CF_SELL"+IntegerToString(MagicNumber,0));
        ExistOrderFlag=1;
     }
//+---if 2th h1 bar is doji
     if(Close[1]==Open[1])
     {
        if(Close[1]-Open[2]>0 && ExistOrderFlag==0)
        {
           OP=OP_BUY;
           if((Ask-YesterdayLow)>=HardSL*Point)
           {  SLprice=Ask-HardSL*Point;  SLamount=HardSL;  }
           else
           {  SLprice=YesterdayLow;  SLamount=(Ask-YesterdayLow)/Point; }
        
           OpenOrderByMagicNumber(Symbol(),OP,Ask,SLamount,SLprice,"CF_BUY "+IntegerToString(MagicNumber,0));
           ExistOrderFlag=1;
        }
        if(Close[1]-Open[2]<0 && ExistOrderFlag==0) 
        {
           OP=OP_SELL;
           if((YesterdayHigh-Bid)>=HardSL*Point)
           {  SLprice=Bid+HardSL*Point;  SLamount=HardSL;  }
           else
           {  SLprice=YesterdayHigh; SLamount=(YesterdayHigh-Bid)/Point; }
        
           OpenOrderByMagicNumber(Symbol(),OP,Bid,SLamount,SLprice,"CF_SELL"+IntegerToString(MagicNumber,0));
           ExistOrderFlag=1;       
        }
     }
  }
//  comm=comm+"ExistOrderFlag = "+IntegerToString(ExistOrderFlag,1)+"\n"+"LongdonBar Shift = "+IntegerToString(LondonOpenBarShift,0)+"\n";
    
iDisplayInfo("BrokerTime","BrokerTimeNow   "+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),0,300,20,10,"Courier New",Yellow);
iDisplayInfo("LondonTime","LondonTimeNow   "+TimeToStr(LondonTime,TIME_DATE|TIME_SECONDS),0,300,35,10,"Courier New",Yellow);
iDisplayInfo("LondonOpenTime","LondonOpenTime  "+TimeToStr(StrToTime(LondonOpenTime),TIME_DATE|TIME_MINUTES),0,300,50,10,"Courier New",Lime);
iDisplayInfo("LOTinBroker","LOTInBroker     "+TimeToStr(LOTinBroker,TIME_DATE|TIME_MINUTES),0,300,65,10,"Courier New",Lime);
iDisplayInfo("YesterdayH","YesterdayHigh   "+DoubleToStr(YesterdayHigh,Digits),0,300,80,10,"Courier New",Yellow);
iDisplayInfo("YesterdayL","YesterdayLow    "+DoubleToStr(YesterdayLow,Digits),0,300,95,10,"Courier New",Yellow);
Comment(comm);
//Comment(TimeDayOfYear(TimeCurrent()),"LondonGMTOffset=",LondonGMTOffset);
   
}

//+------------------------------------------------------------------+

void CloseOrdersByMagicNumber(int magic)
{
  int cnt, total;
  total = OrdersTotal();
  for(cnt=0; cnt<total; cnt++) 
  {
    if(OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)==false)
      Print("OrderSelect() Function error = ",GetLastError());
    if(OrderType()==OP_SELL && OrderMagicNumber()==magic) 
    {
      if(OrderClose(OrderTicket(),OrderLots(),Ask,3,Red)==false)
        Print("OrderClose() Function error = ",GetLastError());
    }
    if(OrderType()==OP_BUY && OrderMagicNumber()==magic) 
    {
      if(OrderClose(OrderTicket(),OrderLots(),Bid,3,Red)==false)
        Print("OrderClose() Function error = ",GetLastError());
    }
  }
}

//+-------------------------------------------------------------------+
void OpenOrderByMagicNumber(string pair, int op, double OPprice, double stopnumber, double stopprice, string comm)
{
   double Lots;
   
   if(DynamicLots==true)
     Lots=CalcLots(EquityPercent,stopnumber);
   else
     Lots=FixedLots;

  if(OrderSend(pair,op,Lots,OPprice,3,NormalizeDouble(stopprice,Digits),0,comm,MagicNumber,0,Green)==false)
    Print("OrderSend function error = ",GetLastError());
}


//+-------------------------------------------------------------------+
//http://www.fx110.com/read/read-6-10108.html#top_q
double CalcLots(double equitypercent, double stopless)
{
  double RiskAccount;
  double TickValue;
  double LotSize;
  
  RiskAccount=AccountEquity()*equitypercent;
  TickValue  =MarketInfo(Symbol(),MODE_TICKVALUE);
  
  if(Digits==3 || Digits==5)
    TickValue=TickValue*10;
  
  LotSize=(RiskAccount/stopless)/TickValue;
  
  if(LotSize<MarketInfo(Symbol(),MODE_MINLOT))
     LotSize=MarketInfo(Symbol(),MODE_MINLOT);
  if(LotSize>MarketInfo(Symbol(),MODE_MAXLOT))
     LotSize=MarketInfo(Symbol(),MODE_MAXLOT);
     
  if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.1)
     LotSize=NormalizeDouble(LotSize,1);
  else
     LotSize=NormalizeDouble(LotSize,2);
  
  return(LotSize);   
}

//+------------------------------------------------------------------+
void iDisplayInfo(string LabelName,string LabelDoc,int Corner,int TextX,int TextY,int DocSize,string DocStyle,color DocColor)
{ 
   ObjectCreate(LabelName, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(LabelName, LabelDoc, DocSize, DocStyle,DocColor);
   ObjectSet(LabelName, OBJPROP_CORNER, Corner); 
   ObjectSet(LabelName, OBJPROP_XDISTANCE, TextX); 
   ObjectSet(LabelName, OBJPROP_YDISTANCE, TextY); 
   return; 
}