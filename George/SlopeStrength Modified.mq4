//+------------------------------------------------------------------+
//|                                                SlopeStrength.mq4 |
//|                      Copyright 2012, Deltabron - Paul Geirnaerdt |
//|                                          http://www.deltabron.nl |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Deltabron - Paul Geirnaerdt"
#property link      "http://www.deltabron.nl"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_minimum 0.0
#property indicator_maximum 0.1

#define version            "v1.0.3"

//+------------------------------------------------------------------+
//| Release Notes                                                    |
//+------------------------------------------------------------------+
// v1.0.0 (alpha), 6/1/12
// * Added support to auto create symbol names
// * Improved justification on column headers for brokers with extra characters on symbols
// v1.0.0, 6/4/12
// * BUG: added (almost) unique identifier for objects to get multiple instances in one window (thanks, Verb)
// * Code optimization
// * Introduced 'fontSize' user setting, indicator does some *very* simple font scaling 
// * Added arrow icon for every symbol to indicate slope trend controlled by user setting 'showTrendIcon' to show or hide
// * New default for user setting 'symbolsToWeigh', it now has all symbols that the NanningBob 10.2 system looks at
// v1.0.1, 6/5/12
// * Limited output of symbols to first six characters, truncating the brokers extra character (if any)
// v1.0.2, 6/6/12
// * Added extra information to (almost) unique identifier making it even 'more' unique
// * Code optimization, added else commands where possible
// * Added option to show information about the slope of the immediate lower timeframe
// v1.0.3, 6/27/12
// * Added more fontsizes in the simple font scaling routine

#define EPSILON            0.00000001
#define CURRENCYCOUNT      8

extern string  gen               = "----General inputs----";
extern bool    autoSymbols       = false;
extern string	symbolsToWeigh    = "AUDCAD,AUDCHF,AUDNZD,AUDJPY,AUDUSD,CADCHF,CADJPY,CHFJPY,EURAUD,EURCAD,EURCHF,EURGBP,EURNZD,EURJPY,EURUSD,GBPNZD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPUSD,NZDUSD,NZDJPY,NZDCHF,NZDCAD,USDCAD,USDCHF,USDJPY";

extern string  nonPropFont       = "Lucida Console";
extern int     fontSize          = 9;

extern string  ind               = "----Indicator inputs----";
extern string  ind_tf            = "timeFrame 'M5' or 'H4'";
extern string  timeFrame         = "M15";
extern bool    showLowerTimeFrame= true;
extern bool    showTrendIcon     = true;

extern string  col               = "----Colo(u)rs----";
extern color   headerColor       = White;
extern color   bodyColor         = Gold;
extern color   slopeOver8Color   = Lime;
extern color   slopeOver4Color   = DarkSeaGreen;
extern color   slopeOver0Color   = DarkOliveGreen;
extern color   slopeUnder0Color  = RosyBrown;
extern color   slopeUnder4Color  = Magenta;
extern color   slopeUnder8Color  = Red;
extern color   slopeLowerTFOver4Color  = 0x006000; // Very dark green
extern color   slopeLowerTFUnder4Color = 0x000060; // Very dark green

// global indicator variables
string indicatorName = "SlopeStrength";
double mapBuffer[];
string shortName;
int userTimeFrame;
string almostUniqueIndex;

// symbol & currency variables
int symbolCount;
string symbolNames[];
double symbolValues[][4];                    // 0: Slope, 1: Index counter currency, 2: Index base currency, 3: Original index
double symbolValuesTemp[][4];
string currencyNames[CURRENCYCOUNT] = { "AUD", "CAD", "CHF", "GBP", "EUR", "JPY", "NZD", "USD" };
double currencyValues[CURRENCYCOUNT][2];     // 0: Currency slope, 1: Original index
double currencyOccurrences[CURRENCYCOUNT];   // Holds the number of occurrences of each currency in symbols

// object parameters
int verticalShift = 14;
int verticalOffset = 30;
int horizontalShift = 100;
int horizontalOffset = 10;
int horizontalOffsetTrend = 85;
int horizontalOffsetHeader = 32;

// grid variables
int row[CURRENCYCOUNT];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   // Global indicator settings
   shortName = indicatorName + " - " + version + " - Timeframe: " + timeFrame;
   IndicatorShortName ( shortName );
   SetIndexBuffer ( 0, mapBuffer );
   SetIndexStyle ( 0, DRAW_NONE );
   IndicatorDigits ( 0 );
   SetIndexEmptyValue ( 0, 0.0 );
   
   // Get the symbols to use
   initSymbols();
   
   // Set almostUniqueIndex to use in object names, not crucial
   string now = TimeCurrent() + userTimeFrame;
   almostUniqueIndex = StringSubstr(now, StringLen(now) - 3);
   
   // Font & object scaling & shifting
   switch (fontSize)
   {
      case 8:
         horizontalShift = 106;
         horizontalOffsetHeader = 40;
         horizontalOffsetTrend = 84;
         break;
      case 9:    
         horizontalShift = 110;
         horizontalOffsetHeader = 36;
         horizontalOffsetTrend = 85;
         break;
      case 10:    
         horizontalShift = 120;
         horizontalOffsetHeader = 46;
         horizontalOffsetTrend = 96;
         break;
      case 11:    
         horizontalShift = 132;
         horizontalOffsetHeader = 54;
         horizontalOffsetTrend = 109;
         break;
      case 12:    
         horizontalShift = 146;
         horizontalOffsetHeader = 60;
         horizontalOffsetTrend = 122;
         break;
      default: 
         horizontalShift = 100 + (10 * (fontSize - 9));
         horizontalOffsetHeader = 60;
         horizontalOffsetTrend = 85 + (12 * (fontSize - 9));
         break;
   }      

   return(0);
}

//+------------------------------------------------------------------+
//| Initialize Symbols Array                                         |
//+------------------------------------------------------------------+
int initSymbols()
{
   int i;
   string symbolExtraChars = StringSubstr(Symbol(), 6, 4);

   symbolsToWeigh = StringTrimLeft(symbolsToWeigh);
   symbolsToWeigh = StringTrimRight(symbolsToWeigh);

   if (StringSubstr(symbolsToWeigh, StringLen(symbolsToWeigh) - 1) != ",")
   {
      symbolsToWeigh = StringConcatenate(symbolsToWeigh, ",");   
   }   

   // Build symbolNames array as the user likes it
   if ( autoSymbols )
   {
      createSymbolNamesArray();
   }
   else
   {
      i = StringFind(symbolsToWeigh, ","); 
      while (i != -1)
      {
         // Resize array
         int size = ArraySize(symbolNames);
         ArrayResize(symbolNames, size + 1);
         // Set array
         symbolNames[size] = StringConcatenate(StringSubstr(symbolsToWeigh, 0, i), symbolExtraChars);
         // Trim symbols
         symbolsToWeigh = StringSubstr(symbolsToWeigh, i + 1);
         i = StringFind(symbolsToWeigh, ","); 
      }
   }
   
   symbolCount = ArraySize(symbolNames);
   ArrayResize(symbolValues, symbolCount);

   // Build symbolValues and currencyOccurrences arrays
   for ( i = 0; i < symbolCount; i++ )   
   {
      // Get index for counter (left/1st) currency in symbol
      int currencyIndex = GetCurrencyIndex(StringSubstr(symbolNames[i], 0, 3));
      // Increment occurrence for currency, set index for currency in symbolValues
      currencyOccurrences[currencyIndex]++;
      symbolValues[i][1] = currencyIndex;
      // Get index for base (right/2nd) currency in symbol
      currencyIndex = GetCurrencyIndex(StringSubstr(symbolNames[i], 3, 3));
      // Increment occurrence for currency, set index for currency in symbolValues
      currencyOccurrences[currencyIndex]++;
      symbolValues[i][2] = currencyIndex;
      // Set original index in currencyValues
      symbolValues[i][3] = i;
   }
   
   ArrayResize(symbolValues, symbolCount * 2);
   ArrayResize(symbolValuesTemp, symbolCount * 2);
   
   userTimeFrame = PERIOD_M5;
   if ( timeFrame == "H4" )
   {
      userTimeFrame = PERIOD_H4;
   }
}

//+------------------------------------------------------------------+
//| GetCurrencyIndex(string currency)                                |
//+------------------------------------------------------------------+
int GetCurrencyIndex(string currency)
{
   for (int i = 0; i < CURRENCYCOUNT; i++)
   {
      if (currencyNames[i] == currency)
      {
         return(i);
      }   
   }   
   return (-1);
}

//+------------------------------------------------------------------+
//| createSymbolNamesArray()                                         |
//+------------------------------------------------------------------+
void createSymbolNamesArray()
{
   int hFileName = FileOpenHistory ("symbols.raw", FILE_BIN|FILE_READ );
   int recordCount = FileSize ( hFileName ) / 1936;
   int counter = 0;
   for ( int i = 0; i < recordCount; i++ )
   {
      string tempSymbol = StringTrimLeft ( StringTrimRight ( FileReadString ( hFileName, 12 ) ) );
      if ( MarketInfo ( tempSymbol, MODE_BID ) > 0 && MarketInfo ( tempSymbol, MODE_TRADEALLOWED ) )
      {
         ArrayResize( symbolNames, counter + 1 );
         symbolNames[counter] = tempSymbol;
         counter++;
      }
      FileSeek( hFileName, 1924, SEEK_CUR );
   }
   FileClose( hFileName );
   return ( 0 );
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   int windex = WindowFind ( shortName );
   if ( windex > 0 )
   {
      ObjectsDeleteAll ( windex );
   }   

   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   // initialize variables for this tick
   int i;
   int index;
   int windex = WindowFind ( shortName );
   string objectName;
   string showText;

   for ( i = 0; i < CURRENCYCOUNT; i++ )
   {
      // Array row is a helper to store last used row for all columns
      row[i] = 0;
   }
   
   // Here we go!
   // Copy symbolValues to symbolValuesTemp
   ArrayCopy(symbolValuesTemp, symbolValues);
   ArrayInitialize(currencyValues, 0.0);

   // Get Slope for all symbols and totalize for all currencies   
   for ( i = 0; i < symbolCount; i++)
   {
      // Get Slope for original index
      index = symbolValuesTemp[i][3];
      symbolValuesTemp[i][0] = GetSlope(symbolNames[index], userTimeFrame, 0);
      
      // Copy all values from this iteration of symbolValues to a second one
      // (We need to display all symbols in two currency columns)
      symbolValuesTemp[i + symbolCount][0] = symbolValuesTemp[i][0];
      symbolValuesTemp[i + symbolCount][1] = symbolValuesTemp[i][2];
      symbolValuesTemp[i + symbolCount][2] = symbolValuesTemp[i][1];
      symbolValuesTemp[i + symbolCount][3] = symbolValuesTemp[i][3];
      
      // Calculate total for currencySlope, set in currencyValues
      currencyValues[index][1] = index;
      index = symbolValuesTemp[i][1];
      currencyValues[index][0] += symbolValuesTemp[i][0];
      index = symbolValuesTemp[i][2];
      currencyValues[index][0] -= symbolValuesTemp[i][0];
   }
   
   // Sort symbols to Slope
   ArraySort(symbolValuesTemp, WHOLE_ARRAY, 0, MODE_DESCEND);
   
   //
   // COLUMN HEADERS
   //
   // Loop currency values and header output objects, creating them if necessary 
   for ( i = 0; i < CURRENCYCOUNT; i++ )
   {
      // average
      currencyValues[i][0] /= currencyOccurrences[i];
      
      objectName = almostUniqueIndex + "_obj_header_currency_" + i;
      if ( ObjectFind ( objectName ) == -1 )
      {
         if ( ObjectCreate ( objectName, OBJ_LABEL, windex, 0, 0 ) )
         {
            ObjectSet ( objectName, OBJPROP_XDISTANCE, horizontalShift * i + horizontalOffset );
            ObjectSet ( objectName, OBJPROP_YDISTANCE, verticalOffset - 8 );
         }
      }
      showText = currencyNames[i];
      ObjectSetText ( objectName, showText, fontSize + 3, nonPropFont, headerColor );

      objectName = almostUniqueIndex + "_obj_header_value_" + i;
      if ( ObjectFind ( objectName ) == -1 )
      {
         if ( ObjectCreate ( objectName, OBJ_LABEL, windex, 0, 0 ) )
         {
            ObjectSet ( objectName, OBJPROP_XDISTANCE, horizontalShift * i + horizontalOffset + horizontalOffsetHeader );
            ObjectSet ( objectName, OBJPROP_YDISTANCE, verticalOffset - 8 );
         }
      }
      showText = RightAlign(DoubleToStr(currencyValues[i][0], 2), 5);
      ObjectSetText ( objectName, showText, fontSize + 3, nonPropFont, headerColor );
   }
   
   //
   // GRID SYMBOL OBJECTS
   //
   // Loop Slope values and set output objects, creating them if necessary 
   for ( i = 0; i < symbolCount * 2; i++ )
   {
      // Get original index
      index = symbolValuesTemp[i][3];
      // Get index of currency
      int col = symbolValuesTemp[i][1];
      // Build object name and create if necessary
      objectName = almostUniqueIndex + "_obj_" + row[col] + "_" + col;
      if ( ObjectFind ( objectName ) == -1 )
      {
         if ( ObjectCreate ( objectName, OBJ_LABEL, windex, 0, 0 ) )
         {
            ObjectSet ( objectName, OBJPROP_XDISTANCE, horizontalShift * col + horizontalOffset );
            ObjectSet ( objectName, OBJPROP_YDISTANCE, verticalShift * (row[col] + 1) + verticalOffset );
         }
      }
      // Build text to show
      showText = StringSubstr(symbolNames[index], 0, 6);
      showText = showText + RightAlign(DoubleToStr(symbolValuesTemp[i][0], 2), 6);

      // Determine color to show
      color showColor = slopeUnder8Color;
      if ( symbolValuesTemp[i][0] > -0.8 ) showColor = slopeUnder4Color;
      if ( symbolValuesTemp[i][0] > -0.4 ) showColor = slopeUnder0Color;
      if ( symbolValuesTemp[i][0] > 0.0 ) showColor = slopeOver0Color;
      if ( symbolValuesTemp[i][0] > 0.4 ) showColor = slopeOver4Color;
      if ( symbolValuesTemp[i][0] > 0.8 ) showColor = slopeOver8Color;

      // Show object      
      ObjectSetText ( objectName, showText, fontSize, nonPropFont, showColor );
      
      // Show trend arrow if user wants it.
      if ( showTrendIcon )
      {
         objectName = almostUniqueIndex + "_obj_" + row[col] + "_" + col + "_delta";
         if ( ObjectFind ( objectName ) == -1 )
         {
            if ( ObjectCreate ( objectName, OBJ_LABEL, windex, 0, 0 ) )
            {
               ObjectSet ( objectName, OBJPROP_XDISTANCE, horizontalShift * col + horizontalOffset + horizontalOffsetTrend );
               ObjectSet ( objectName, OBJPROP_YDISTANCE, verticalShift * (row[col] + 1) + verticalOffset );
            }
         }
         // Get past slope values for symbols
         double Slope[3];
         Slope[0] = GetSlope ( symbolNames[index], userTimeFrame, 5 );
         Slope[1] = GetSlope ( symbolNames[index], userTimeFrame, 2 );
         Slope[2] = symbolValuesTemp[i][0];
         // Define which arrow to use
         showText = CharToStr ( 224 );
         if ( Slope[0] < Slope[1] && Slope[1] < Slope[2] ) showText = CharToStr ( 225 );
         else if ( Slope[0] > Slope[1] && Slope[0] < Slope[2] ) showText = CharToStr ( 228 );
         else if ( Slope[0] < Slope[1] && Slope[0] > Slope[2] ) showText = CharToStr ( 230 );
         else if ( Slope[0] > Slope[1] && Slope[1] > Slope[2] ) showText = CharToStr ( 226 );
         // Show object      
         ObjectSetText ( objectName, showText, 6, "Wingdings", showColor );
      }
      
      // Show lower timeframe as bullet
      if ( showLowerTimeFrame )
      {
         // Get slope for immediate lower time frame
         int lowerTimeFrame = PERIOD_H4;
         if ( userTimeFrame == PERIOD_H4 )
         {
            lowerTimeFrame = PERIOD_H1;
         }
         double slopeLowerTimeframe = GetSlope ( symbolNames[index], lowerTimeFrame, 0 );
         // Set color for bullet
         showColor = CLR_NONE;
         if ( slopeLowerTimeframe > 0.4 )
         {
            showColor = slopeLowerTFOver4Color;
         }
         else if ( slopeLowerTimeframe < -0.4 )
         {
            showColor = slopeLowerTFUnder4Color;
         }
         // Show bullet
         if ( showColor != CLR_NONE )
         {
            objectName = almostUniqueIndex + "_obj_" + row[col] + "_" + col + "_background";
            DrawBullet(windex, objectName, horizontalShift * col + horizontalOffset + horizontalOffsetTrend + 8, verticalShift * (row[col] + 1) + verticalOffset - 2, showColor);
         }   
      }

      // Increase row for this column
      row[col]++;
   }

   // Sort currency to values
   ArraySort(currencyValues, WHOLE_ARRAY, 0, MODE_DESCEND);

   //
   // RIGHT HAND CURRENCY COLUMN
   //
   // Loop currency values and header output objects, creating them if necessary 
   for ( i = 0; i < CURRENCYCOUNT; i++ )
   {
      objectName = almostUniqueIndex + "_obj_column_currency_" + i;
      if ( ObjectFind ( objectName ) == -1 )
      {
         if ( ObjectCreate ( objectName, OBJ_LABEL, windex, 0, 0 ) )
         {
            ObjectSet ( objectName, OBJPROP_XDISTANCE, horizontalShift * (CURRENCYCOUNT) + horizontalOffset + 6 );
            ObjectSet ( objectName, OBJPROP_YDISTANCE, (verticalShift + 2) * i + verticalOffset - 8 );
         }
      }
      int tempValue = currencyValues[i][1];
      showText = currencyNames[tempValue];
      ObjectSetText ( objectName, showText, fontSize + 3, nonPropFont, bodyColor );

      objectName = almostUniqueIndex + "_obj_column_value_" + i;
      if ( ObjectFind ( objectName ) == -1 )
      {
         if ( ObjectCreate ( objectName, OBJ_LABEL, windex, 0, 0 ) )
         {
            ObjectSet ( objectName, OBJPROP_XDISTANCE, horizontalShift * (CURRENCYCOUNT) + horizontalOffset + 36 + 6 );
            ObjectSet ( objectName, OBJPROP_YDISTANCE, (verticalShift + 2) * i + verticalOffset - 8 );
         }
      }
      showText = RightAlign(DoubleToStr(currencyValues[i][0], 2), 5);
      ObjectSetText ( objectName, showText, fontSize + 3, nonPropFont, bodyColor );
   }

   return(0);
}

//+------------------------------------------------------------------+
//| GetSlope()                                                       |
//+------------------------------------------------------------------+
double GetSlope(string symbol, int tf, int shift)
{
   double atr = iATR(symbol, tf, 100, shift + 10) / 10;
   double gadblSlope = 0.0;
   if ( atr != 0 )
   {
      double dblTma = calcTma( symbol, tf, shift );
      double dblPrev = calcTma( symbol, tf, shift + 1 );
      gadblSlope = ( dblTma - dblPrev ) / atr;
   }
   
   return ( gadblSlope );

}//End double GetSlope(int tf, int shift)

//+------------------------------------------------------------------+
//| calcTma()                                                        |
//+------------------------------------------------------------------+
double calcTma( string symbol, int tf,  int shift )
{
   double dblSum  = iClose(symbol, tf, shift) * 21;
   double dblSumw = 21;
   int jnx, knx;
         
   for ( jnx = 1, knx = 20; jnx <= 20; jnx++, knx-- )
   {
      dblSum  += ( knx * iClose(symbol, tf, shift + jnx) );
      dblSumw += knx;

      if ( jnx <= shift )
      {
         dblSum  += ( knx * iClose(symbol, tf, shift - jnx) );
         dblSumw += knx;
      }
   }
   
   return( dblSum / dblSumw );

}// End calcTma()

//+------------------------------------------------------------------+
//| Right Align Text                                                 |
//+------------------------------------------------------------------+
string RightAlign ( string text, int length = 10, int trailing_spaces = 0 )
{
   string text_aligned = text;
   for ( int i = 0; i < length - StringLen ( text ) - trailing_spaces; i++ )
   {
      text_aligned = " " + text_aligned;
   }
   return ( text_aligned );
}

//+------------------------------------------------------------------+
//| DrawCell(), credits go to Alexandre A. B. Borela                 |
//+------------------------------------------------------------------+
void DrawCell ( int nWindow, string nCellName, double nX, double nY, double nWidth, double nHeight, color nColor )
{
   double   iHeight, iWidth, iXSpace;
   int      iSquares, i;

   if ( nWidth > nHeight )
   {
      iSquares = MathCeil ( nWidth / nHeight ); // Number of squares used.
      iHeight  = MathRound ( ( nHeight * 100 ) / 77 ); // Real height size.
      iWidth   = MathRound ( ( nWidth * 100 ) / 77 ); // Real width size.
      iXSpace  = iWidth / iSquares - ( ( iHeight / ( 9 - ( nHeight / 100 ) ) ) * 2 );

      for ( i = 0; i < iSquares; i++ )
      {
         ObjectCreate   ( nCellName + i, OBJ_LABEL, nWindow, 0, 0 );
         ObjectSetText  ( nCellName + i, CharToStr ( 110 ), iHeight, "Wingdings", nColor );
         ObjectSet      ( nCellName + i, OBJPROP_XDISTANCE, nX + iXSpace * i );
         ObjectSet      ( nCellName + i, OBJPROP_YDISTANCE, nY );
         ObjectSet      ( nCellName + i, OBJPROP_BACK, true );
      }
   }
   else
   {
      iSquares = MathCeil ( nHeight / nWidth ); // Number of squares used.
      iHeight  = MathRound ( ( nHeight * 100 ) / 77 ); // Real height size.
      iWidth   = MathRound ( ( nWidth * 100 ) / 77 ); // Real width size.
      iXSpace  = iHeight / iSquares - ( ( iWidth / ( 9 - ( nWidth / 100 ) ) ) * 2 );

      for ( i = 0; i < iSquares; i++ )
      {
         ObjectCreate   ( nCellName + i, OBJ_LABEL, nWindow, 0, 0 );
         ObjectSetText  ( nCellName + i, CharToStr ( 110 ), iWidth, "Wingdings", nColor );
         ObjectSet      ( nCellName + i, OBJPROP_XDISTANCE, nX );
         ObjectSet      ( nCellName + i, OBJPROP_YDISTANCE, nY + iXSpace * i );
         ObjectSet      ( nCellName + i, OBJPROP_BACK, true );
      }
   }
}

//+------------------------------------------------------------------+
//| DeleteCell()                                                     |
//+------------------------------------------------------------------+
void DeleteCell(string name)
{
   int square = 0;
   while ( ObjectFind( name + square ) > -1 )
   {
      ObjectDelete( name + square );
      square++;
   }   
}

//+------------------------------------------------------------------+
//| DrawBullet()                                                     |
//+------------------------------------------------------------------+
void DrawBullet(int window, string cellName, int col, int row, color bulletColor )
{
   ObjectCreate   ( cellName, OBJ_LABEL, window, 0, 0 );
   ObjectSetText  ( cellName, CharToStr ( 108 ), 9, "Wingdings", bulletColor );
   ObjectSet      ( cellName, OBJPROP_XDISTANCE, col );
   ObjectSet      ( cellName, OBJPROP_YDISTANCE, row );
   ObjectSet      ( cellName, OBJPROP_BACK, true );
}

//+------------------------------------------------------------------+