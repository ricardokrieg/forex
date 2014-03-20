//-------------------------------------------------------------------
// MetaTrader4 Indicator BH-Ergodic.mq4
// 2007, Bruce Hellstrom
// bhweb@speakeasy.net
// Version:  1.0
// Version Date: 15 Apr 2007
// Last change by: bruceh
// Based on code written by Danny Feng, Ergodic.mq4
//+-------------------------------------------------------------------

#property copyright "2007 Brucehvn, bhweb@speakeasy.net"
#property link      "http: //www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 DarkTurquoise
#property indicator_color2 Yellow
#property indicator_style1 0
#property indicator_style2 2

//---- input parameters
extern int BarDiff = 1;     // calculations are taken between current bar and current bar + BarDiff
extern int r = 2;           // First moving average on mean values
extern int s = 10;          // Second moving average applied to first
extern int u = 5;           // Third moving average applied to division
extern int trigger = 3;     // Final moving average or smoothing
extern int PriceType = 0;   // 0=Close, 1=Open, 2=High, 3=Low, 4=Median, 5=Typical, 6=Weighted

//---- buffers
double ErgBuffer[];
double ema_ErgBuffer[];
double Price_Delta1_Buffer[];
double Price_Delta2_Buffer[];
double r_ema1_Buffer[];
double r_ema2_Buffer[];
double s_ema1_Buffer[];
double s_ema2_Buffer[];
string ShortNameBase = "";
string IndVersion = "1.0";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
    ShortNameBase = "BH-Ergodic v" + IndVersion + " (" + r + "," + s + "," + u + ") Trigger(" + trigger + ")";
    //---- additional buffers are used for counting.
    IndicatorBuffers( 8 );
    SetIndexBuffer( 0, ema_ErgBuffer );
    SetIndexLabel( 0, "Trigger" );
    SetIndexBuffer( 1, ErgBuffer );
    SetIndexLabel( 1, "Ergodic" );
    SetIndexBuffer( 2, Price_Delta1_Buffer );
    SetIndexBuffer( 3, Price_Delta2_Buffer );
    SetIndexBuffer( 4, r_ema1_Buffer );
    SetIndexBuffer( 5, r_ema2_Buffer );
    SetIndexBuffer( 6, s_ema1_Buffer );
    SetIndexBuffer( 7, s_ema2_Buffer );

    //---- indicator lines
    SetIndexStyle( 0, DRAW_LINE );
    SetIndexStyle( 1, DRAW_LINE );
    //---- name for DataWindow and indicator subwindow label
    IndicatorShortName( ShortNameBase );
    //----
    SetIndexDrawBegin( 0, r + s + u + trigger );
    SetIndexDrawBegin( 1, r + s + u + trigger );
    //----
    Print( ShortNameBase );
    Print( "2007 - brucehvn, bhweb@speakeasy.net" );
    return( 0 );
}

//+------------------------------------------------------------------+
//| True Strength Index                                          |
//+------------------------------------------------------------------+
int start() {
    int i, limit;
    double mean1, mean2;
    
    if ( PriceType < PRICE_CLOSE || PriceType > PRICE_WEIGHTED ) {
        PriceType = PRICE_CLOSE;
    }
    
    int counted_bars = IndicatorCounted();

    if ( counted_bars > 0 ) {
        counted_bars--;
    }
    limit = Bars - counted_bars;

    for ( i = 0; i < limit; i++ ) {
        switch( PriceType ) {
            case PRICE_CLOSE:
                mean1 = Close[i];
                mean2 = Close[i+BarDiff];
                break;
                
            case PRICE_OPEN:
                mean1 = Open[i];
                mean2 = Open[i+BarDiff];
                break;
                
            case PRICE_HIGH:
                mean1 = High[i];
                mean2 = High[i+BarDiff];
                break;
                    
            case PRICE_LOW:
                mean1 = Low[i];
                mean2 = Low[i+BarDiff];
                break;
                    
            case PRICE_MEDIAN:
                mean1 = ( High[i] - Low[i] ) / 2;
                mean2 = ( High[i+BarDiff] - Low[i+BarDiff] ) / 2;
                break;
                
            case PRICE_TYPICAL:
                mean1 = ( High[i] + Low[i] + Close[i] ) / 3;
                mean2 = ( High[i+BarDiff] + Low[i+BarDiff] + Close[i+BarDiff] ) / 3;
                break;
                
            case PRICE_WEIGHTED:
                mean1 = ( High[i] + Low[i] + Close[i] + Close[i] ) / 4;
                mean2 = ( High[i+BarDiff] + Low[i+BarDiff] + Close[i+BarDiff] + Close[i+BarDiff] ) / 4;
                break;
        }

        Price_Delta1_Buffer[i] = mean1 - mean2;
        Price_Delta2_Buffer[i] = MathAbs( mean1 - mean2 );
    }

    for ( i = 0; i < limit; i++ ) {
        r_ema1_Buffer[i] = iMAOnArray( Price_Delta1_Buffer, Bars, r, 0, MODE_EMA, i );
        r_ema2_Buffer[i] = iMAOnArray( Price_Delta2_Buffer, Bars, r, 0, MODE_EMA, i );
    }

    for ( i = 0; i < limit; i++ ) {
        s_ema1_Buffer[i] = iMAOnArray( r_ema1_Buffer, Bars, s, 0, MODE_EMA, i );
        s_ema2_Buffer[i] = iMAOnArray( r_ema2_Buffer, Bars, s, 0, MODE_EMA, i );
    }

    for ( i = 0; i < limit; i++ ) {
        double ma1 = iMAOnArray( s_ema1_Buffer, Bars, u, 0, MODE_EMA, i );
        double ma2 = iMAOnArray( s_ema2_Buffer, Bars, u, 0, MODE_EMA, i );
        
        if ( ma2 != 0 ) {
            ErgBuffer[i] = ( 100 * ma1 ) / ma2;
        }
        else {
            ErgBuffer[i] = 0.0;
        }
    }

    for ( i = 0; i < limit; i++ ) {
        ema_ErgBuffer[i] = iMAOnArray( ErgBuffer, Bars, trigger, 0, MODE_EMA, i );
    }
    
    string shortname = ShortNameBase;
    
    if ( ema_ErgBuffer[0] > ErgBuffer[0] ) {
        shortname = StringConcatenate( shortname, " SHORT" );
    }
    else if ( ema_ErgBuffer[0] < ErgBuffer[0] ) {
        shortname = StringConcatenate( shortname, " LONG" );
    }
    else {
        shortname = StringConcatenate( shortname, " NEUTRAL" );
    }
    IndicatorShortName( shortname );
        
    return( 0 );
}

//+------------------------------------------------------------------+


