
#property copyright "Copyright © 2007, MetaQuotes Software Corp." // Modifications Author: file45
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_minimum 0.0
#property indicator_maximum 0.1

#define SYMBOLS_MAX 1024
#define DEALS          0
#define BUY_LOTS       1
#define BUY_PRICE      2
#define SELL_LOTS      3
#define SELL_PRICE     4
#define NET_LOTS       5
#define PROFIT         6

//**** START OF DEFAULT OPTIONS ***********************************************************************************
extern color Symbols = LightSlateGray;
extern bool p_as_Points = false;
extern color Pips_or_Points = DarkOrange;
extern color Lots_Long = Lime;
extern color Lots_Short = Red;
extern string Currency_Symbol = "£";
extern color Prof_Gain = Lime;
extern color Prof_Loss = Red;

extern int corner = 1; //0 - for top-left corner, 1 - top-right, 2 - bottom-left, 3 - bottom-right
extern int   Line1_Distance_Y = 1;
extern double X_Distance_Multiplier = 1.5;
extern int Font_Size = 8;
extern string Font_Face = "Arial Bold";
//**** END OF DEFAULT OPTIONS *********************************************************************************

color Menu_0 = Black;
color Deals_2 = Red;
color Buy_3 = DarkOrange;
color Sell_4 = DarkOrange;

int Prof = 320;

//ADDED
//extern bool normalize = false; //If true

double Poin;
int n_digits = 1;
double divider = 1;
//ADDED

string ExtName="Exposure";
//int ExtNamee =0;
string ExtSymbols[SYMBOLS_MAX];
int    ExtSymbolsTotal=0;
double ExtSymbolsSummaries[SYMBOLS_MAX][7];
int    ExtLines=-1;
string ExtCols[]={"",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  ""};
//int    ExtShifts[8]={ 10, 130, 190, 270, 360, 440, 530, 610 };
//int    ExtShifts[8]={ 10, 150, 220, 270, 360, 410, 500, 570 };
//int    ExtShifts[8]={ 22,,,,,,180,250 };
//ADDED
int    ExtShifts[8]= { 22,,,,,140,220,320 };
int    ExtVertShift=18;

double ExtMapBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init()
{
   IndicatorShortName( ExtName );
   SetIndexBuffer( 0, ExtMapBuffer );
   SetIndexStyle( 0, DRAW_NONE );
   IndicatorDigits( 0 );
	SetIndexEmptyValue( 0, 0.0 );

   if (p_as_Points == false){
      n_digits=1;}
   else{
      n_digits=0;}  
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deinit()
{
   int windex = WindowIsVisible( 0 );
   if( windex > 0 ) ObjectsDeleteAll( windex );
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void start()
{
   string name;
   int i,col,line,windex = WindowIsVisible( 0 );
   
   if( windex < 0 ) return;
   
   //---- header line
   if( ExtLines < 0 ) {
      for( col=0; col<8; col++ ) {
         name = "Head_" + col;
         if( ObjectCreate( name, OBJ_LABEL, windex, 0, 0 ) ) {
            ObjectSet( name, OBJPROP_XDISTANCE, ExtShifts[col] );
            ObjectSet( name, OBJPROP_YDISTANCE, ExtVertShift );
            ObjectSet( name, OBJPROP_YDISTANCE,  Line1_Distance_Y );
            ObjectSetText( name, ExtCols[col], 10, Font_Face, Menu_0 );
         }
      }
      ExtLines = 0;
   }
   
   //----
   ArrayInitialize( ExtSymbolsSummaries, 0.0 );
   int total = Analyze();
   
   if( total > 0 ) {
      line = 0;
      for( i=0; i<ExtSymbolsTotal; i++ ) {
         if( ExtSymbolsSummaries[i][DEALS] <= 0 ) continue;
         line++;
         //---- add line
         if( line > ExtLines ) {
            int y_dist = ExtVertShift*(line+1)-34;
            for( col=0; col<8; col++ ) {
               if( col == 1  ||  col == 2  ||  col == 3  ||  col == 4 ) continue;
               name = "Line_" + line + "_" + col;
               if( ObjectCreate( name, OBJ_LABEL, windex, 0, 0 ) ) {
                  ObjectCreate( name, OBJ_LABEL, 0, 0, 0 );
                  ObjectSet( name, OBJPROP_XDISTANCE, ExtShifts[col] * X_Distance_Multiplier );
                  ObjectSet( name, OBJPROP_YDISTANCE, y_dist );
                  ObjectSet( name, OBJPROP_CORNER, corner );
               }
            }
            
            ExtLines++;
         }
         
         //---- set line
         int    digits = MarketInfo( ExtSymbols[i], MODE_DIGITS );
         double buy_lots = ExtSymbolsSummaries[i][BUY_LOTS];
         double sell_lots = ExtSymbolsSummaries[i][SELL_LOTS];
         double buy_price = 0.0;
         double sell_price = 0.0;
         
         if( buy_lots != 0 )  buy_price = ExtSymbolsSummaries[i][BUY_PRICE]/buy_lots;
         if( sell_lots != 0 ) sell_price = ExtSymbolsSummaries[i][SELL_PRICE]/sell_lots;
         
         name = "Line_" + line + "_0";
         ObjectSetText( name, ExtSymbols[i], 10,Font_Face, Symbols );
         
         name = "Line_" + line + "_1";
         ObjectSetText( name, DoubleToStr(ExtSymbolsSummaries[i][DEALS],2), 10, Font_Face, Deals_2 );
         
         name = "Line_" + line + "_2";
         ObjectSetText( name, DoubleToStr(buy_lots,2), 10, Font_Face, Buy_3 );
         
         //MOD FOR BUY COLUMN
         name = "Line_" + line + "_3";
         //ObjectSetText(name,DoubleToStr(buy_price,digits),10,Font_Face, Buy_3);
           ObjectSetText(name,DoubleToStr(NormalizeDouble(buy_price/divider,1),n_digits), 10, Font_Face, Pips_or_Points );
         if( sell_lots != 0 ) ObjectSetText( name, DoubleToStr(NormalizeDouble(buy_price/divider,1),n_digits), 1, Font_Face, Black );
         
         name = "Line_" + line + "_4";
         ObjectSetText( name, DoubleToStr(sell_lots,2), 10, Font_Face, Sell_4 );
         
         //MOD FOR SELL COLUMN
         name = "Line_" + line + "_5";
         
         if( sell_lots > 0 ) ObjectSetText( name, DoubleToStr(sell_price,digits), 10, Font_Face, Sell_4 );
         ObjectSetText( name, DoubleToStr(NormalizeDouble(sell_price/divider,1),n_digits)+ " p", 10, Font_Face, Pips_or_Points );
         
         if( buy_lots > 0 ) ObjectSetText( name, DoubleToStr(NormalizeDouble(buy_price/divider,1),n_digits)+ " p", 10, Font_Face, Pips_or_Points );
         
         // if(buy_lots!=0)
        /// ObjectSetText(name,DoubleToStr(NormalizeDouble(sell_price/divider,1),n_digits)+" p",10,Font_Face,CLR_NONE);
         
         name = "Line_" + line + "_6";
         ObjectSetText( name, DoubleToStr(buy_lots-sell_lots,2)+" L", 10, Font_Face, Lots_Long );
         
         if( buy_lots-sell_lots < 0 ) ObjectSetText( name, DoubleToStr(buy_lots-sell_lots,2)+" L", 10, Font_Face, Lots_Short );
         
         name = "Line_" + line + "_7";
         ObjectSetText( name, Currency_Symbol+" "+NumberToStr(ExtSymbolsSummaries[i][PROFIT], ",T12.2"), 10, Font_Face, Prof_Gain );
         if( ExtSymbolsSummaries[i][PROFIT] < 0 ) ObjectSetText( name, Currency_Symbol+" "+NumberToStr(ExtSymbolsSummaries[i][PROFIT], ",T12.2"), 10, Font_Face, Prof_Loss );
      }
   }
   
   //---- remove lines
   if( total < ExtLines ) {
      for( line=ExtLines; line>total; line-- ) {
         name = "Line_" + line + "_0";
         ObjectSetText( name, "" );
         name = "Line_" + line + "_1";
         ObjectSetText( name, "" );
         name = "Line_" + line + "_2";
         ObjectSetText( name, "" );
         name = "Line_" + line + "_3";
         ObjectSetText( name, "" );
         name = "Line_" + line + "_4";
         ObjectSetText( name, "" );
         name = "Line_" + line + "_5";
         ObjectSetText( name, "" );
         name = "Line_" + line + "_6";
         ObjectSetText( name, "" );
         name = "Line_" + line + "_7";
         ObjectSetText( name, "");
      }
   }
   
   //---- to avoid minimum==maximum
   ExtMapBuffer[Bars-1]=-1;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Analyze()
{
   double profit;
   int i,index,type;
   int total = OrdersTotal();
   
   //----
   for( i=0; i<total; i++ ) {
      if( !OrderSelect(i,SELECT_BY_POS) ) continue;
      
      type = OrderType();
      
      if( type != OP_BUY  &&  type != OP_SELL ) continue;
      
      index = SymbolsIndex( OrderSymbol() );
      
      if( index < 0  ||  index >= SYMBOLS_MAX ) continue;
      
      //----
      ExtSymbolsSummaries[index][DEALS]++;
      profit = OrderProfit()+OrderCommission()+OrderSwap();
      
      ExtSymbolsSummaries[index][PROFIT] += profit;
      
      if( type == OP_BUY ) {
         ExtSymbolsSummaries[index][BUY_LOTS] += OrderLots();
         // ExtSymbolsSummaries[index][BUY_PRICE]+=OrderOpenPrice()*OrderLots();
         ExtSymbolsSummaries[index][BUY_PRICE] += ( (OrderClosePrice()-OrderOpenPrice())*OrderLots() ) / GetPoint( OrderSymbol() ); //MarketInfo( OrderSymbol(), MODE_POINT );
      }
      else //if( type == OP_SELL )
      {
         ExtSymbolsSummaries[index][SELL_LOTS] += OrderLots();
         //ExtSymbolsSummaries[index][SELL_PRICE]+=OrderOpenPrice()*OrderLots();
         // ExtSymbolsSummaries[index][SELL_PRICE]+=((OrderOpenPrice()-OrderClosePrice())*OrderLots())/ MarketInfo( OrderSymbol(), MODE_POINT);
         ExtSymbolsSummaries[index][SELL_PRICE] += ( (OrderOpenPrice()-OrderClosePrice())*OrderLots() ) / GetPoint( OrderSymbol() ); //MarketInfo( OrderSymbol(), MODE_POINT );
      }
   }
   
   //----
   total = 0;
   for( i=0; i<ExtSymbolsTotal; i++ ) {
      if( ExtSymbolsSummaries[i][DEALS] > 0 ) total++;
   }
   
   //----
   return( total );
}



double GetPoint( string symbol )
{
   int digits = MarketInfo( symbol, MODE_DIGITS );
   double point = MarketInfo( symbol, MODE_POINT );
   
   if( digits == 5  ||  ( digits == 3  &&  StringFind( symbol, "JPY" ) != -1 ) ) point *= 10;
   return( point );
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SymbolsIndex(string SymbolName)
  {
   bool found=false;
//----
   for(int i=0; i<ExtSymbolsTotal; i++)
     {
      if(SymbolName==ExtSymbols[i])
        {
         found=true;
         break;
        }
     }
//----
   if(found) return(i);
   if(ExtSymbolsTotal>=SYMBOLS_MAX) return(-1);
//----
   i=ExtSymbolsTotal;
   ExtSymbolsTotal++;
   ExtSymbols[i]=SymbolName;
   ExtSymbolsSummaries[i][DEALS]=0;
   ExtSymbolsSummaries[i][BUY_LOTS]=0;
   ExtSymbolsSummaries[i][BUY_PRICE]=0;
   ExtSymbolsSummaries[i][SELL_LOTS]=0;
   ExtSymbolsSummaries[i][SELL_PRICE]=0;
   ExtSymbolsSummaries[i][NET_LOTS]=0;
   ExtSymbolsSummaries[i][PROFIT]=0;
  
//----
   return(i);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
string NumberToStr(double n, string mask)
//+------------------------------------------------------------------+
// Formats a number using a mask, and returns the resulting string
// Usage:    string result = NumberToStr(number,mask)
// 
// Mask parameters:
// n = number of digits to output, to the left of the decimal point
// n.d = output n digits to left of decimal point; d digits to the right
// -n.d = floating minus sign at left of output
// n.d- = minus sign at right of output
// +n.d = floating plus/minus sign at left of output
// ( or ) = enclose negative number in parentheses
// $ or £ or ¥ or € = include floating currency symbol at left of output
// % = include trailing % sign
// , = use commas to separate thousands
// Z or z = left fill with zeros instead of spaces
// R or r = round result in rightmost displayed digit
// B or b = blank entire field if number is 0
// * = show asterisk in leftmost position if overflow occurs
// ; = switch use of comma and period (European format)
// L or l = left align final string 
// T ot t = trim end result

{
  if (MathAbs(n) == 2147483647)
    n = 0;
    
  mask = StringUpper(mask);
  int dotadj = 0;
  int dot    = StringFind(mask,".",0);
  if (dot < 0)  {
    dot    = StringLen(mask);
    dotadj = 1;
  }  

  int nleft  = 0;
  int nright = 0;
  for (int i=0; i<dot; i++)  {
    string char = StringSubstr(mask,i,1);
    if (char >= "0" && char <= "9")   nleft = 10 * nleft + StrToInteger(char);
  }
  if (dotadj == 0)   {
    for (i=dot+1; i<=StringLen(mask); i++)  {
      char = StringSubstr(mask,i,1);
      if (char >= "0" && char <= "9")  nright = 10 * nright + StrToInteger(char);
  } }
  nright = MathMin(nright,7);

  if (dotadj == 1)  {
    for (i=0; i<StringLen(mask); i++)  {
      char = StringSubstr(mask,i,1);
      if (char >= "0" && char <= "9")  {
        dot = i;
        break;
  } } }

  string csym = "";
  if (StringFind(mask,"$",0) >= 0)   csym = "$";
  if (StringFind(mask,"£",0) >= 0)   csym = "£";
  if (StringFind(mask,"€",0) >= 0)   csym = "€";
  if (StringFind(mask,"¥",0) >= 0)   csym = "¥";

  string leadsign  = "";
  string trailsign = "";
  if (StringFind(mask,"+",0) >= 0 && StringFind(mask,"+",0) < dot)  {
    leadsign = " ";
    if (n > 0)   leadsign  = "+";
    if (n < 0)   leadsign  = "-";
  }    
  if (StringFind(mask,"-",0) >= 0 && StringFind(mask,"-",0) < dot)
    if (n < 0)  leadsign  = "-"; else leadsign = " ";
  if (StringFind(mask,"-",0) >= 0 && StringFind(mask,"-",0) > dot)
    if (n < 0)  trailsign  = "-"; else trailsign = " ";
  if (StringFind(mask,"(",0) >= 0 || StringFind(mask,")",0) >= 0)  {
    leadsign  = " ";
    trailsign = " ";
    if (n < 0)  { 
      leadsign  = "("; 
      trailsign = ")";
  } }    

  if (StringFind(mask,"%",0) >= 0)   trailsign = "%";

  if (StringFind(mask,",",0) >= 0) bool comma = true; else comma = false;
  if (StringFind(mask,"Z",0) >= 0) bool zeros = true; else zeros = false;
  if (StringFind(mask,"B",0) >= 0) bool blank = true; else blank = false;
  if (StringFind(mask,"R",0) >= 0) bool round = true; else round = false;
  if (StringFind(mask,"*",0) >= 0) bool overf = true; else overf = false;
  if (StringFind(mask,"L",0) >= 0) bool lftsh = true; else lftsh = false;
  if (StringFind(mask,";",0) >= 0) bool swtch = true; else swtch = false;
  if (StringFind(mask,"T",0) >= 0) bool trimf = true; else trimf = false;

  if (round) n = MathFix(n,nright);
  string outstr = n;

  int dleft = 0;
  for (i=0; i<StringLen(outstr); i++)  {
    char = StringSubstr(outstr,i,1);
    if (char >= "0" && char <= "9")   dleft++;
    if (char == ".")   break;
  }
  
// Insert fill characters.......
  if (zeros) string fill = "0"; else fill = " ";
  if (n < 0)
    outstr = "-" + StringRepeat(fill,nleft-dleft) + StringSubstr(outstr,1,StringLen(outstr)-1);
  else  
    outstr = StringRepeat(fill,nleft-dleft) + StringSubstr(outstr,0,StringLen(outstr));

  outstr = StringSubstr(outstr,StringLen(outstr)-9-nleft,nleft+1+nright-dotadj);

// Insert the commas.......  
  if (comma)   {
    bool digflg = false;
    bool stpflg = false;
    string out1 = "";
    string out2 = "";
    for (i=0; i<StringLen(outstr); i++)  {
      char = StringSubstr(outstr,i,1);
      if (char == ".")   stpflg = true;
      if (!stpflg && (nleft-i == 3 || nleft-i == 6 || nleft-i == 9)) 
        if (digflg)   out1 = out1 + ","; else out1 = out1 + " "; 
      out1 = out1 + char;    
      if (char >= "0" && char <= "9")   digflg = true;
    }  
    outstr = out1;
  }  
// Add currency symbol and signs........  
  outstr = csym + leadsign + outstr + trailsign;

// 'Float' the currency symbol/sign.......
  out1 = "";
  out2 = "";
  bool fltflg = true;
  for (i=0; i<StringLen(outstr); i++)   {
    char = StringSubstr(outstr,i,1);
    if (char >= "0" && char <= "9")   fltflg = false;
    if ((char == " " && fltflg) || (blank && n == 0) )   out1 = out1 + " ";   else   out2 = out2 + char;
  }   
  outstr = out1 + out2;

// Overflow........  
  if (overf && dleft > nleft)  outstr = "*" + StringSubstr(outstr,1,StringLen(outstr)-1);

// Left shift.......
  if (lftsh)   {
    int len = StringLen(outstr);
    outstr = StringLeftTrim(outstr);
    outstr = outstr + StringRepeat(" ",len-StringLen(outstr));
  }

// Switch period and comma.......
  if (swtch)   {
    out1 = "";
    for (i=0; i<StringLen(outstr); i++)   {
      char = StringSubstr(outstr,i,1);
      if (char == ".")   out1 = out1 + ",";     else
      if (char == ",")   out1 = out1 + ".";     else
      out1 = out1 + char;
    }    
    outstr = out1;
  }  

  if (trimf)    outstr = StringTrim(outstr);
  return(outstr);
}

//+------------------------------------------------------------------+
string StringRepeat(string str, int n)
//+------------------------------------------------------------------+
// Repeats the string STR N times
// Usage:    string x=StringRepeat("-",10)  returns x = "----------"
{
  string outstr = "";
  for(int i=0; i<n; i++)  {
    outstr = outstr + str;
  }
  return(outstr);
}
 
string StringUpper(string str)
//+------------------------------------------------------------------+
// Converts any lowercase characters in a string to uppercase
// Usage:    string x=StringUpper("The Quick Brown Fox")  returns x = "THE QUICK BROWN FOX"
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
 
double MathFix(double n, int d)
//+------------------------------------------------------------------+
// Returns N rounded to D decimals - works around a precision bug in MQL4
{
  return(MathRound(n*MathPow(10,d)+0.000000000001*MathSign(n))/MathPow(10,d));
}

//+------------------------------------------------------------------+
string StringLeftTrim(string str)
//+------------------------------------------------------------------+
// Removes all leading spaces from a string
// Usage:    string x=StringLeftTrim("  XX YY  ")  returns x = "XX  YY  "
{
  bool   left = true;
  string outstr = "";
  for(int i=0; i<StringLen(str); i++)  {
    if (StringSubstr(str,i,1) != " " || !left) {
      outstr = outstr + StringSubstr(str,i,1);
      left = false;
  } }
  return(outstr);
}

//+------------------------------------------------------------------+
string StringTrim(string str)
//+------------------------------------------------------------------+
// Removes all spaces (leading, traing embedded) from a string
// Usage:    string x=StringUpper("The Quick Brown Fox")  returns x = "TheQuickBrownFox"
{
  string outstr = "";
  for(int i=0; i<StringLen(str); i++)  {
    if (StringSubstr(str,i,1) != " ")
      outstr = outstr + StringSubstr(str,i,1);
  }
  return(outstr);
}  

//+------------------------------------------------------------------+
int MathSign(double n)
//+------------------------------------------------------------------+
// Returns the sign of a number (i.e. -1, 0, +1)
// Usage:   int x=MathSign(-25)   returns x=-1
{
  if (n > 0) return(1);
  else if (n < 0) return (-1);
  else return(0);
}

