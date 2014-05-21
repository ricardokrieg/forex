//+------------------------------------------------------------------+
//| Ibuk's Bread'nButter Dashboard.mq4
//| Copyright © 2011, Squalou
//+------------------------------------------------------------------+

#property copyright "Copyright © 2011, Squalou"
#property link      "http://www.forexfactory.com/showthread.php?t=305246"

#define VERSION "1.0"
#define DATE    "2011.07.28"

/* Dashboard for Ibuk's 24EMA Bread and Butter System, by Squalou
 * Displays the distance from the 24EMA on mutliple pairs (option) and multiple timeframes (H1,H4,D1 defaults)
 */
 
#property indicator_chart_window

extern bool		ShowCurrentPairOnly  = false; //	Dispaly only chart Pair
extern string	PairsToTrade = "EURUSD,GBPUSD,NZDUSD,USDCAD,USDCHF,USDJPY,GBPJPY,EURJPY,AUDJPY,NZDJPY,CADJPY,CHFJPY,GBPCHF,AUDCAD,AUDCHF,AUDNZD,AUDUSD,CADCHF,EURAUD,EURCAD,EURCHF,EURGBP,EURNZD";
extern string	PeriodsToTrade = "H1,H4,D1";//,W1,MN"; // Time Frames to display are user defined

extern int     MaPeriod=24;
extern int     BufferPips = 20;

extern int     MaMethod=MODE_EMA;
extern int     MaShift=0;
extern int     MaAppliedPrice=0;
extern string  mame="Method: 0=sma; 1=ema; 2=smma;  3=lwma";
extern string  maap="Applied price: 0=Close; 1=Open; 2=High";
extern string  maap1="3=Low; 4=Median; 5=Typical; 6=Weighted";

extern color	colorCodeAboveBand=DodgerBlue;
extern color	colorCodeBelowBand=Red;
extern color	colorCodeAboveMA=Aqua;
extern color	colorCodeBelowMA=Gold;
extern color	colorCodeNoSignal=Gray;


extern string	pdi="----Pair display inputs----";
extern int		FontSize=10;
extern color	FontColour=Yellow;
extern string	Font_Font = "Arial";
extern string	Font_Bold = "Arial Black";
extern double	DisplayStarts_X=5;	//from top right corner
extern double	DisplayStarts_Y=15;

//Pair extraction
int		NoOfPairs;				// Holds the number of pairs passed by the user via the inputs screen
int		NoOfPeriods;			// Holds the number of periods passed by the user via the inputs screen
string	TradePair[];			//Array to hold the pairs traded by the user
string	TradePeriod[];			//Array to hold the periods traded by the user
int		TradePeriodTF[];		//Array to hold the periods traded by the user
double TradeTrendDiffs[][5];	//Array to hold the pairs diffs from MA
color 	Trend[][5];	//Array to hold the pairs trend color
color 	TrendColor[5];	//Array to hold the trend colors
bool  	AlertSent[];

#define NOSIGNAL  0
#define ABOVEMA   1
#define BELOWMA   2
#define ABOVEBAND 3
#define BELOWBAND 4

int WindowNo = 0;

string objPrefix ;	// all objects drawn by this indicator will be prefixed with this
string buff_str ;	// all objects drawn by this indicator will be prefixed with this


//double pip;
int pipMult,pipMultTab[]={1,10,1,10,1,10,100}; // multiplier to convert pips to Points;

string _type[]= {"SMA","EMA","SMMA","LWMA"};


//+------------------------------------------------------------------+
int init()
//+------------------------------------------------------------------+
{
	int i, j;
	objPrefix = WindowExpertName();

//  pipMult = pipMultTab[Digits];
//  pip = Point * pipMult;

  TrendColor[NOSIGNAL] = colorCodeNoSignal;
  TrendColor[ABOVEBAND]= colorCodeAboveBand;
  TrendColor[BELOWBAND]= colorCodeBelowBand;
  TrendColor[ABOVEMA]  = colorCodeAboveMA;
  TrendColor[BELOWMA]  = colorCodeBelowMA;


	if(!ShowCurrentPairOnly)
	{
		//Extract the pairs traded by the user
		NoOfPairs = StringFindCount(PairsToTrade,",")+1;
		ArrayResize(TradePair, NoOfPairs);
		string AddChar = StringSubstr(Symbol(),6,4);
		StrPairToStringArray(PairsToTrade, TradePair, AddChar);
	}
	else
	{
		//Fill the array with only chart pair
		NoOfPairs = 1;
		ArrayResize(TradePair, NoOfPairs);
		TradePair[0] = Symbol();
	}
	
	NoOfPeriods = StringFindCount(PeriodsToTrade, ",")+1;
	ArrayResize(TradePeriod, NoOfPeriods);
	ArrayResize(TradePeriodTF, NoOfPeriods);
	StrToStringArray(PeriodsToTrade, TradePeriod);
	
	for(j=0; j<NoOfPeriods; j++)
	{
		TradePeriodTF[j] = StrToTF(TradePeriod[j]);	//this is for display Periods from topleft corner
		//TradePeriodTF[NoOfPeriods-j] = StrToTF(TradePeriod[j]);	//this is for display Periods from topright corner
	}
//----	
	ArrayResize(Trend, NoOfPairs);
	ArrayInitialize(Trend, NOSIGNAL);
	ArrayResize(TradeTrendDiffs, NoOfPairs);
	ArrayInitialize(TradeTrendDiffs, 0);
//----
	return(0);
}// End init()

//+------------------------------------------------------------------+
int deinit()
//+------------------------------------------------------------------+
{
//----
	Comment("");   
	RemoveObjects(objPrefix);
	return(0);
}

//+------------------------------------------------------------------+
int start()
//+------------------------------------------------------------------+
{
   GetPairTrends(TradeTrendDiffs, Trend);
   PrintPairTrends();

}

//-------------------------------------------------------------------+
void RemoveObjects(string Pref)
//+------------------------------------------------------------------+
{   
	int i;
	string objname = "";

	for (i = ObjectsTotal(); i >= 0; i--)
	{
		objname = ObjectName(i);
		if (StringFind(objname, Pref, 0) > -1) ObjectDelete(objname);
	}
	return(0);
} // End void RemoveObjects(string Pref)

//+------------------------------------------------------------------+
int StringFindCount(string str, string str2)
//+------------------------------------------------------------------+
// Returns the number of occurrences of STR2 in STR
// Usage:   int x = StringFindCount("ABCDEFGHIJKABACABB","AB")   returns x = 3
{
  int c = 0;
  for (int i=0; i<StringLen(str); i++)
    if (StringSubstr(str,i,StringLen(str2)) == str2)  c++;
  return(c);
} // End int StringFindCount(string str, string str2)

//+------------------------------------------------------------------+
void StrPairToStringArray(string str, string &a[], string p_suffix, string delim=",")
//+------------------------------------------------------------------+
{
	int z1=-1, z2=0;
	for (int i=0; i<ArraySize(a); i++)
	{
		z2 = StringFind(str,delim,z1+1);
		a[i] = StringSubstr(str,z1+1,z2-z1-1) + p_suffix;
		if (z2 >= StringLen(str)-1)   break;
		z1 = z2;
	}
	return(0);
}

//+------------------------------------------------------------------+
void StrToStringArray(string str, string &a[], string delim=",")
//+------------------------------------------------------------------+
{
	int z1=-1, z2=0;
	for (int i=0; i<ArraySize(a); i++)
	{
		z2 = StringFind(str,delim,z1+1);
		a[i] = StringSubstr(str,z1+1,z2-z1-1);
		if (z2 >= StringLen(str)-1)   break;
		z1 = z2;
	}
	return(0);
}

//+------------------------------------------------------------------+
// Converts a timeframe string to its MT4-numeric value
// Usage:   int x=StrToTF("M15")   returns x=15
int StrToTF(string str)
//+------------------------------------------------------------------+
{
  str = StringUpper(str);
  str = StringTrimLeft(str);
  str = StringTrimRight(str);
  
  if (str == "M1")   return(1);
  if (str == "M5")   return(5);
  if (str == "M15")  return(15);
  if (str == "M30")  return(30);
  if (str == "H1")   return(60);
  if (str == "H4")   return(240);
  if (str == "D1")   return(1440);
  if (str == "W1")   return(10080);
  if (str == "MN")   return(43200);
  return(0);
}  

//+------------------------------------------------------------------+
// Converts any lowercase characters in a string to uppercase
// Usage:    string x=StringUpper("The Quick Brown Fox")  returns x = "THE QUICK BROWN FOX"
string StringUpper(string str)
//+------------------------------------------------------------------+
{
  string outstr = "";
  string lower  = "abcdefghijklmnopqrstuvwxyz";
  string upper  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  for(int i=0; i<StringLen(str); i++)  {
    int t1 = StringFind(lower,StringSubstr(str,i,1),0);
    if (t1 >=0)  
      outstr = outstr + StringSubstr(upper,t1,1);
    else
      outstr = outstr + StringSubstr(str,i,1);
  }
  return(outstr);
}  

//+------------------------------------------------------------------+
void GetPairTrends(double &diffs[][], int &trend[][])
//+------------------------------------------------------------------+
{
	int i, j;
	double diff;
	
	for(i=0; i<NoOfPairs; i++)
	{
		for(j=0; j<NoOfPeriods; j++)
		{
			trend[i][j] = NOSIGNAL;

      int digits=MarketInfo(TradePair[i],MODE_DIGITS);
      double point = MarketInfo(TradePair[i],MODE_POINT);
      double pip = point * pipMultTab[digits];
			diff = (iClose(TradePair[i], TradePeriodTF[j], 0) - iMA(TradePair[i], TradePeriodTF[j], MaPeriod, MaShift, MaMethod, MaAppliedPrice, 0))/pip;
  		diffs[i][j] = diff;

			if(diff > 0)
			{
				if(diff > BufferPips)
				{
					trend[i][j] = ABOVEBAND;
				}
				else
				{
					trend[i][j] = ABOVEMA;
				}
			}
			else
			{
				if(diff < -BufferPips)
				{
					trend[i][j] = BELOWBAND;
				}
				else
				{
					trend[i][j] = BELOWMA;
				}
			}
		} //End for(j=0; j<NoOfPeriods; j++)
	} //End for(i=0; i<NoOfPairs; i++)
	return(0);

}

//+------------------------------------------------------------------+
void PrintPairTrends()
//+------------------------------------------------------------------+
{
	RemoveObjects(objPrefix);
	
	int i, j;
	
	buff_str = StringConcatenate(objPrefix, "title");
	ObjectDelete(buff_str);
	ObjectCreate(buff_str,OBJ_LABEL,WindowNo,0,0,0,0);
	ObjectSet(buff_str,OBJPROP_CORNER,1);
	ObjectSet(buff_str,OBJPROP_XDISTANCE,DisplayStarts_X + FontSize*(NoOfPeriods*3));
	ObjectSet(buff_str,OBJPROP_YDISTANCE,DisplayStarts_Y);
	ObjectSetText(buff_str,MaPeriod+_type[MaMethod]+"Distance",FontSize-2,Font_Font,FontColour);

	//Set Trade Pair
	for(i=0; i<NoOfPairs; i++)
	{
		buff_str = StringConcatenate(objPrefix, TradePair[i]);
		ObjectDelete(buff_str);
		ObjectCreate(buff_str,OBJ_LABEL,WindowNo,0,0,0,0);
		ObjectSet(buff_str,OBJPROP_CORNER,1);
		ObjectSet(buff_str,OBJPROP_XDISTANCE,DisplayStarts_X + FontSize*(NoOfPeriods*3));
		ObjectSet(buff_str,OBJPROP_YDISTANCE,DisplayStarts_Y + (i+1)*(FontSize+FontSize/2));
		ObjectSetText(buff_str,TradePair[i],FontSize-2,Font_Font,FontColour);
	}
	//Set Trade Period
	for(j=0; j<NoOfPeriods; j++)
	{
		buff_str = StringConcatenate(objPrefix, TradePeriod[j]);
		ObjectDelete(buff_str);
		ObjectCreate(buff_str,OBJ_LABEL,WindowNo,0,0,0,0);
		ObjectSet(buff_str,OBJPROP_CORNER,1);
		ObjectSet(buff_str,OBJPROP_XDISTANCE,DisplayStarts_X + 1.5*(NoOfPeriods-1-j)*(FontSize*2));
		ObjectSet(buff_str,OBJPROP_YDISTANCE,DisplayStarts_Y);
		ObjectSetText(buff_str,TradePeriod[j],FontSize-2,Font_Font,FontColour);      
	}
	//Set Trade Trend
	for(i=0; i<NoOfPairs; i++)
	{
		for(j=0; j<NoOfPeriods; j++)
		{
			buff_str = StringConcatenate(objPrefix, TradePair[i], TradePeriod[j]);
			ObjectDelete(buff_str);
			ObjectCreate(buff_str,OBJ_LABEL,WindowNo,0,0,0,0);
 			ObjectSet(buff_str,OBJPROP_CORNER,1);
			ObjectSet(buff_str,OBJPROP_XDISTANCE,DisplayStarts_X + 1.5*(NoOfPeriods-1-j)*(FontSize*2));
			ObjectSet(buff_str,OBJPROP_YDISTANCE,DisplayStarts_Y + (i+1)*(FontSize+FontSize/2));
      if (Trend[i][j]>=ABOVEBAND)	
        ObjectSetText(buff_str,DoubleToStr(TradeTrendDiffs[i][j],0),FontSize-2,Font_Font,TrendColor[Trend[i][j]]);
      else
        ObjectSetText(buff_str,DoubleToStr(TradeTrendDiffs[i][j],0),FontSize-2,Font_Bold,TrendColor[Trend[i][j]]);
		}
	}

	return(0);

}

//+------------------------------------------------------------------+

