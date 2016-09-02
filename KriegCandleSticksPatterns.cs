//
// Copyright (C) 2016, Ricardo Franco <ricardo.krieg@gmail.com>.
// Ricardo Franco reserves the right to modify or overwrite this NinjaScript component with each release.
//

#region Using declarations
using System;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.ComponentModel;
using System.Xml.Serialization;
using NinjaTrader.Cbi;
using NinjaTrader.Data;
using NinjaTrader.Gui.Chart;
#endregion

// This namespace holds all indicators and is required. Do not change it.
namespace NinjaTrader.Indicator
{
    /// <summary>
    /// Detects common candlestick patterns and marks them on the chart.
    /// </summary>
    [Description("Detects common candlestick patterns and marks them on the chart.")]
    public class KriegCandleStickPattern : Indicator
    {
#region Variables
    private Color 			downColor;
    private bool			downTrend;
    private Color 			upColor;
    private bool			upTrend;
    private ChartPattern 	pattern 							= ChartPattern.MorningStar;
    private int 			patternsFound;
    private Font 			textFont 							= new Font("Arial", 12, FontStyle.Bold);
    private int				trendStrength						= 4;
    private Color 			txtColor;
#endregion

        /// <summary>
        /// This method is used to configure the indicator and is called once before any bar data is loaded.
        /// </summary>
    protected override void Initialize()
        {
            Add(new Plot(Color.Transparent, "Pattern Found"));
            Overlay				= true;
        }

        /// <summary>
        /// Called on each bar update event (incoming tick)
        /// </summary>
    protected override void OnBarUpdate()
        {
            if (CurrentBar == 0 && ChartControl != null)
            {
                downColor = ChartControl.GetAxisBrush(ChartControl.BackColor).Color;
                txtColor = downColor;
                if (downColor == Color.Black)
                    upColor = Color.Transparent;
                else
                    upColor = Color.Black;
            }

            // Calculates trend lines and prevailing trend for patterns that require a trend
            if (TrendStrength > 0 && CurrentBar >= TrendStrength)
                CalculateTrendLines();

            Value.Set(0);

            // TODO call functions here

            DrawTextFixed("Count", patternsFound.ToString() + " patterns found", TextPosition.BottomRight);
        }

#region Properties
        /// <summary>
        /// Gets a value indicating if a pattern was found
        /// </summary>
        [Browsable(false)]
        [XmlIgnore()]
    public DataSeries PatternFound
                {
                        get { return Values[0]; }
                }

        [Description("Number of bars required to define a trend when a pattern requires a prevailing trend. A value of zero will disable trend requirement.")]
        [GridCategory("Parameters")]
        [Gui.Design.DisplayName("Trend strength")]
    public int TrendStrength
                {
                        get { return trendStrength; }
                        set { trendStrength = Math.Max(0, value); }
                }

        [Description("Choose a candlestick pattern to chart.")]
        [GridCategory("Parameters")]
        [Gui.Design.DisplayName("Chart Pattern")]
    public ChartPattern Pattern
                {
                        get { return pattern; }
                        set { pattern = value; }
                }
#endregion

#region Misc
    public override string ToString()
        {
            return Name + "(" + pattern + ")";
        }

        // Calculate trend lines and prevailing trend
    private void CalculateTrendLines()
        {
            // Calculate up trend line
            int upTrendStartBarsAgo		= 0;
            int upTrendEndBarsAgo 		= 0;
            int upTrendOccurence 		= 1;

            while (Low[upTrendEndBarsAgo] <= Low[upTrendStartBarsAgo])
            {
                upTrendStartBarsAgo 	= Swing(TrendStrength).SwingLowBar(0, upTrendOccurence + 1, CurrentBar);
                upTrendEndBarsAgo 		= Swing(TrendStrength).SwingLowBar(0, upTrendOccurence, CurrentBar);

                if (upTrendStartBarsAgo < 0 || upTrendEndBarsAgo < 0)
                    break;

                upTrendOccurence++;
            }


            // Calculate down trend line
            int downTrendStartBarsAgo	= 0;
            int downTrendEndBarsAgo 	= 0;
            int downTrendOccurence 		= 1;

            while (High[downTrendEndBarsAgo] >= High[downTrendStartBarsAgo])
            {
                downTrendStartBarsAgo 		= Swing(TrendStrength).SwingHighBar(0, downTrendOccurence + 1, CurrentBar);
                downTrendEndBarsAgo 		= Swing(TrendStrength).SwingHighBar(0, downTrendOccurence, CurrentBar);

                if (downTrendStartBarsAgo < 0 || downTrendEndBarsAgo < 0)
                    break;

                downTrendOccurence++;
            }

            if (upTrendStartBarsAgo > 0 && upTrendEndBarsAgo > 0 && upTrendStartBarsAgo < downTrendStartBarsAgo)
            {
                upTrend 	= true;
                downTrend 	= false;
            }
            else if (downTrendStartBarsAgo > 0 && downTrendEndBarsAgo > 0  && upTrendStartBarsAgo > downTrendStartBarsAgo)
            {
                upTrend 	= false;
                downTrend 	= true;
            }
            else
            {
                upTrend 	= false;
                downTrend 	= false;
            }
        }

#endregion

#region CandleStick Patterns Functions
    public void BearishBeltHold() {
            if (CurrentBar < 1 || (TrendStrength > 0 && !upTrend))
                return;

            if (Close[1] > Open[1] && Open[0] > Close[1] + 5 * TickSize && Open[0] == High[0] && Close[0] < Open[0])
            {
                if (ChartControl != null)
                {
                    BarColorSeries.Set(CurrentBar - 1, upColor);
                    CandleOutlineColorSeries.Set(CurrentBar - 1, downColor);
                    BarColor									= downColor;
                }

                DrawText("Bearish Belt Hold" + CurrentBar, false, "Bearish Belt Hold", 0, High[0], 10, txtColor, textFont, StringAlignment.Center, Color.Transparent, Color.Transparent, 0);

                patternsFound++;
                Value.Set(1);
            }
        }

    public void BearishEngulfing() {
        if (CurrentBar < 1 || (TrendStrength > 0 && !upTrend))
            return;

        if (Close[1] > Open[1] && Close[0] < Open[0] && Open[0] > Close[1] && Close[0] < Open[1])
        {
            BarColor = downColor;
            DrawText("Bearish Engulfing" + CurrentBar, false, "Bearish Engulfing", 0, Low[0], -10, txtColor, textFont, StringAlignment.Center, Color.Transparent, Color.Transparent, 0);
            patternsFound++;
            Value.Set(1);
        }
    }

    public void BearishHarami() {
            if (CurrentBar < 1 || (TrendStrength > 0 && !upTrend))
                return;

            if (Close[0] < Open[0] && Close[1] > Open[1] && Low[0] >= Open[1] && High[0] <= Close[1]) {
                BarColor = downColor;
                DrawText("Bearish Harami" + CurrentBar, false, "Bearish Harami", 0, Low[0], -10, txtColor, textFont,
                         StringAlignment.Center, Color.Transparent, Color.Transparent, 0);
                patternsFound++;
                Value.Set(1);
            }
        }

            public void BearishHaramiCross() {
                if (CurrentBar < 1 || (TrendStrength > 0 && !upTrend))
                    return;

                if ((High[0] <= Close[1]) && (Low[0] >= Open[1]) && Open[0] <= Close[1] && Close[0] >= Open[1] && ((Close[0] >= Open[0] && Close[0] <= Open[0] + TickSize) || (Close[0] <= Open[0] && Close[0] >= Open[0] - TickSize)))
                {
                    BarColor = downColor;
                    DrawText("Bearish Harami Cross" + CurrentBar, false, "Bearish Harami Cross", 0, Low[0], -10, txtColor, textFont, StringAlignment.Center, Color.Transparent, Color.Transparent, 0);
                    patternsFound++;
                    Value.Set(1);
                }
            }

            public void BullishBeltHold() {
                if (CurrentBar < 1 || (TrendStrength > 0 && !downTrend))
                    return;

                if (Close[1] < Open[1] && Open[0] < Close[1] - 5 * TickSize && Open[0] == Low[0] && Close[0] > Open[0])
                {
                    if (ChartControl != null)
                    {
                        BarColorSeries.Set(CurrentBar - 1, downColor);
                        BarColor								= upColor;
                        CandleOutlineColorSeries.Set(CurrentBar, downColor);
                    }

                    DrawText("Bullish Belt Hold" + CurrentBar, false, "Bullish Belt Hold", 0, Low[0], -10, txtColor, textFont, StringAlignment.Center, Color.Transparent, Color.Transparent, 0);

                    patternsFound++;
                    Value.Set(1);
                }
            }

            public void BullishEngulfing() {
                if (CurrentBar < 1 || (TrendStrength > 0 && !downTrend))
                    return;

                if (Close[1] < Open[1] && Close[0] > Open[0] && Close[0] > Open[1] && Open[0] < Close[1])
                {
                    if (ChartControl != null)
                    {
                        BarColor								= upColor;
                        CandleOutlineColorSeries.Set(CurrentBar, downColor);
                    }

                    DrawText("Bullish Engulfing" + CurrentBar, false, "Bullish Engulfing", 0, Low[0], -10, txtColor, textFont, StringAlignment.Center, Color.Transparent, Color.Transparent, 0);

                    patternsFound++;
                    Value.Set(1);
                }
            }

            public void BullishHarami() {
                if (CurrentBar < 1 || (TrendStrength > 0 && !downTrend))
                    return;

                if (Close[0] > Open[0] && Close[1] < Open[1] && Low[0] >= Close[1] && High[0] <= Open[1])
                {
                    if (ChartControl != null)
                    {
                        BarColor								= upColor;
                        CandleOutlineColorSeries.Set(CurrentBar, downColor);
                    }

                    DrawText("Bullish Harami" + CurrentBar, false, "Bullish Harami", 0, Low[0], -10, txtColor, textFont, StringAlignment.Center, Color.Transparent, Color.Transparent, 0);

                    patternsFound++;
                    Value.Set(1);
                }
            }

            public void BullishHaramiCross() {
                if (CurrentBar < 1 || (TrendStrength > 0 && !downTrend))
                    return;

                if ((High[0] <= Open[1]) && (Low[0] >= Close[1]) && Open[0] >= Close[1] && Close[0] <= Open[1] && ((Close[0] >= Open[0] && Close[0] <= Open[0] + TickSize) || (Close[0] <= Open[0] && Close[0] >= Open[0] - TickSize)))
                {
                    if (ChartControl != null)
                    {
                        BarColor								= upColor;
                        CandleOutlineColorSeries.Set(CurrentBar, downColor);
                    }

                    DrawText("Bullish Harami Cross" + CurrentBar, false, "Bullish Harami Cross", 0, Low[0], -10, txtColor, textFont, StringAlignment.Center, Color.Transparent, Color.Transparent, 0);

                    patternsFound++;
                    Value.Set(1);
                }
            }

            public void DarkCloudCover() {
                if (CurrentBar < 1 || (TrendStrength > 0 && !upTrend))
                    return;

                if (Open[0] > High[1] && Close[1] > Open[1] && Close[0] < Open[0] && Close[0] <= Close[1] - (Close[1] - Open[1]) / 2 && Close[0] >= Open[1])
                {
                    if (ChartControl != null)
                    {
                        CandleOutlineColorSeries.Set(CurrentBar - 1, downColor);
                        BarColorSeries.Set(CurrentBar - 1, upColor);
                        BarColor									= downColor;
                    }

                    DrawText("Dark Cloud Cover" + CurrentBar, false, "Dark Cloud Cover", 1, High[0], 10, txtColor, textFont, StringAlignment.Center, Color.Transparent, Color.Transparent, 0);

                    patternsFound++;
                    Value.Set(1);
                }
            }

            public void Doji() {
                if (Math.Abs(Close[0] - Open[0]) <= (High[0] - Low[0]) * 0.07)
                {
                    if (ChartControl != null)
                    {
                        BarColor								= upColor;
                        CandleOutlineColorSeries.Set(CurrentBar, downColor);
                    }

                    int yOffset = Close[0] > Close[Math.Min(1, CurrentBar)] ? 10 : -10;
                    DrawText("Doji Text" + CurrentBar, false, "Doji", 0, (yOffset > 0 ? High[0] : Low[0]), yOffset, txtColor, textFont, StringAlignment.Center, Color.Transparent, Color.Transparent, 0);

                    patternsFound++;
                    Value.Set(1);
                }
            }

            public void DownsideTasukiGap() {
                if (CurrentBar < 2)
                    return;

                if (Close[2] < Open[2] && Close[1] < Open[1] && Close[0] > Open[0]
                    && High[1] < Low[2]
                    && Open[0] > Close[1] && Open[0] < Open[1]
                    && Close[0] > Open[1] && Close[0] < Close[2])
                {
                    if (ChartControl != null)
                    {
                        BarColor								= upColor;
                        CandleOutlineColorSeries.Set(CurrentBar, downColor);
                        BarColorSeries.Set(CurrentBar - 1, downColor);
                        BarColorSeries.Set(CurrentBar - 2, downColor);
                    }

                    DrawText("Downside Tasuki Gap" + CurrentBar, false, "Downside Tasuki Gap", 1, High[2], 10, txtColor, textFont, StringAlignment.Center, Color.Transparent, Color.Transparent, 0);

                    patternsFound++;
                    Value.Set(1);
                }
            }

            public void EveningStar() {
                if (CurrentBar < 2)
                    return;

                if (Close[2] > Open[2] && Close[1] > Close[2] && Open[0] < (Math.Abs((Close[1] - Open[1])/2) + Open[1]) && Close[0] < Open[0])
                {
                    if (ChartControl != null)
                    {
                        if (Close[0] > Open[0])
                        {
                            BarColor								= upColor;
                            CandleOutlineColorSeries.Set(CurrentBar, downColor);
                        }
                        else
                            BarColor								= downColor;

                        if (Close[1] > Open[1])
                        {
                            BarColorSeries.Set(CurrentBar - 1, upColor);
                            CandleOutlineColorSeries.Set(CurrentBar - 1, downColor);
                        }
                        else
                            BarColorSeries.Set(CurrentBar - 1, downColor);

                        if (Close[2] > Open[2])
                        {
                            BarColorSeries.Set(CurrentBar - 2, upColor);
                            CandleOutlineColorSeries.Set(CurrentBar - 2, downColor);
                        }
                        else
                            BarColorSeries.Set(CurrentBar - 2, downColor);
                    }

                    DrawText("Evening Star Text" + CurrentBar, false, "Evening Star", 1, High[1], 10, txtColor, textFont, StringAlignment.Center, Color.Transparent, Color.Transparent, 0);

                    patternsFound++;
                    Value.Set(1);
                }
            }

            public void FallingThreeMethods() {
                if (CurrentBar < 5)
                    return;

                if (Close[4] < Open[4] && Close[0] < Open[0] && Close[0] < Low[4]
                    && High[3] < High[4] && Low[3] > Low[4]
                    && High[2] < High[4] && Low[2] > Low[4]
                    && High[1] < High[4] && Low[1] > Low[4])
                {
                    if (ChartControl != null)
                    {
                        BarColor						= downColor;
                        BarColorSeries.Set(CurrentBar - 4, downColor);

                        int x = 1;
                        while (x < 4)
                        {
                            if (Close[x] > Open[x])
                            {
                                BarColorSeries.Set(CurrentBar - x, upColor);
                                CandleOutlineColorSeries.Set(CurrentBar - x, downColor);
                            }
                            else
                                BarColorSeries.Set(CurrentBar - x, downColor);
                            x++;
                        }
                    }

                    DrawText("Falling Three Methods" + CurrentBar, false, "Falling Three Methods", 2, Math.Max(High[0], High[4]), 10, txtColor, textFont, StringAlignment.Center, Color.Transparent, Color.Transparent, 0);

                    patternsFound++;
                    Value.Set(1);
                }
            }

            public void Hammer() {
                if (TrendStrength > 0)
                {
                    if (!downTrend || MIN(Low, TrendStrength)[0] != Low[0])
                        return;
                }

                if (Low[0] < Open[0] - 5 * TickSize && Math.Abs(Open[0] - Close[0]) < (0.10 * (High[0] - Low[0])) && (High[0] - Close[0]) < (0.25 * (High[0] - Low[0])))
                {
                    if (ChartControl != null)
                    {
                        if (Close[0] > Open[0])
                        {
                            BarColor								= upColor;
                            CandleOutlineColorSeries.Set(CurrentBar, downColor);
                        }
                        else
                            BarColor								= downColor;
                    }

                    DrawText("Hammer" + CurrentBar, false, "Hammer", 0, Low[0], -10, txtColor, textFont, StringAlignment.Center, Color.Transparent, Color.Transparent, 0);

                    patternsFound++;
                    Value.Set(1);
                }
            }

            public void HangingMan() {
                if (TrendStrength > 0)
                {
                    if (!upTrend || MAX(High, TrendStrength)[0] != High[0])
                        return;
                }

                if (Low[0] < Open[0] - 5 * TickSize && Math.Abs(Open[0] - Close[0]) < (0.10 * (High[0] - Low[0])) && (High[0] - Close[0]) < (0.25 * (High[0] - Low[0])))
                {
                    if (ChartControl != null)
                    {
                        if (Close[0] > Open[0])
                        {
                            BarColor								= upColor;
                            CandleOutlineColorSeries.Set(CurrentBar, downColor);
                        }
                        else
                            BarColor								= downColor;
                    }

                    DrawText("Hanging Man" + CurrentBar, false, "Hanging Man", 0, Low[0], -10, txtColor, textFont, StringAlignment.Center, Color.Transparent, Color.Transparent, 0);

                    patternsFound++;
                    Value.Set(1);
                }
            }

            public void InvertedHammer() {
                if (TrendStrength > 0)
                {
                    if (!upTrend || MAX(High, TrendStrength)[0] != High[0])
                        return;
                }

                if (High[0] > Open[0] + 5 * TickSize && Math.Abs(Open[0] - Close[0]) < (0.10 * (High[0] - Low[0])) && (Close[0] - Low[0]) < (0.25 * (High[0] - Low[0])))
                {
                    if (ChartControl != null)
                    {
                        if (Close[0] > Open[0])
                        {
                            BarColor								= upColor;
                            CandleOutlineColorSeries.Set(CurrentBar, downColor);
                        }
                        else
                            BarColor								= downColor;
                    }

                    DrawText("Inverted Hammer" + CurrentBar, false, "InvertedHammer", 0, High[0] + 5 * TickSize, 0, txtColor, textFont, StringAlignment.Center, Color.Transparent, Color.Transparent, 0);

                    patternsFound++;
                    Value.Set(1);
                }
            }

            public void MorningStar() {
                if (CurrentBar < 2)
                    return;

                if (Close[2] < Open[2] && Close[1] < Close[2] && Open[0] > (Math.Abs((Close[1] - Open[1])/2) + Open[1]) && Close[0] > Open[0])
                {
                    if (ChartControl != null)
                    {
                        if (Close[0] > Open[0])
                        {
                            BarColor								= upColor;
                            CandleOutlineColorSeries.Set(CurrentBar, downColor);
                        }
                        else
                            BarColor								= downColor;

                        if (Close[1] > Open[1])
                        {
                            BarColorSeries.Set(CurrentBar - 1, upColor);
                            CandleOutlineColorSeries.Set(CurrentBar - 1, downColor);
                        }
                        else
                            BarColorSeries.Set(CurrentBar - 1, downColor);

                        if (Close[2] > Open[2])
                        {
                            BarColorSeries.Set(CurrentBar - 2, upColor);
                            CandleOutlineColorSeries.Set(CurrentBar - 2, downColor);
                        }
                        else
                            BarColorSeries.Set(CurrentBar - 2, downColor);
                    }

                    DrawText("Morning Star Text" + CurrentBar, false, "Morning Star", 1, Low[1], -10, txtColor, textFont, StringAlignment.Center, Color.Transparent, Color.Transparent, 0);

                    patternsFound++;
                    Value.Set(1);
                }
            }

            public void PiercingLine() {
                if (CurrentBar < 1 || (TrendStrength > 0 && !downTrend))
                    return;

                if (Open[0] < Low[1] && Close[1] < Open[1] && Close[0] > Open[0] && Close[0] >= Close[1] + (Open[1] - Close[1]) / 2 && Close[0] <= Open[1])
                {
                    if (ChartControl != null)
                    {
                        CandleOutlineColorSeries.Set(CurrentBar - 1, downColor);
                        BarColorSeries.Set(CurrentBar - 1, upColor);
                        BarColor									= downColor;
                    }

                    DrawText("Piercing Line" + CurrentBar, false, "Piercing Line", 1, Low[0], -10, txtColor, textFont, StringAlignment.Center, Color.Transparent, Color.Transparent, 0);

                    patternsFound++;
                    Value.Set(1);
                }

            }

            public void RisingThreeMethods() {
                if (CurrentBar < 5)
                    return;

                if (Close[4] > Open[4] && Close[0] > Open[0] && Close[0] > High[4]
                    && High[3] < High[4] && Low[3] > Low[4]
                    && High[2] < High[4] && Low[2] > Low[4]
                    && High[1] < High[4] && Low[1] > Low[4])
                {
                    if (ChartControl != null)
                    {
                        BarColor									= upColor;
                        CandleOutlineColorSeries.Set(CurrentBar, downColor);
                        BarColorSeries.Set(CurrentBar - 4, upColor);
                        CandleOutlineColorSeries.Set(CurrentBar - 4, downColor);

                        int x = 1;
                        while (x < 4)
                        {
                            if (Close[x] > Open[x])
                            {
                                BarColorSeries.Set(CurrentBar - x, upColor);
                                CandleOutlineColorSeries.Set(CurrentBar - x, downColor);
                            }
                            else
                                BarColorSeries.Set(CurrentBar - x, downColor);
                            x++;
                        }
                    }

                    DrawText("Rising Three Methods" + CurrentBar, false, "Rising Three Methods", 2, Math.Min(Low[0], Low[4]), -10, txtColor, textFont, StringAlignment.Center, Color.Transparent, Color.Transparent, 0);

                    patternsFound++;
                    Value.Set(1);
                }
            }

            public void ShootingStar() {
                if (CurrentBar < 1 || (TrendStrength > 0 && !upTrend))
                    return;

                if (High[0] > Open[0] && (High[0] - Open[0]) >= 2 * (Open[0] - Close[0]) && Close[0] < Open[0] && (Close[0] - Low[0]) <= 2 * TickSize)
                {
                    if (ChartControl != null)
                        BarColor = downColor;

                    DrawText("Shooting Star" + CurrentBar, false, "Shooting Star", 0, Low[0], -10, txtColor, textFont, StringAlignment.Center, Color.Transparent, Color.Transparent, 0);

                    patternsFound++;
                    Value.Set(1);
                }
            }

            public void StickSandwich() {
                if (CurrentBar < 2)
                    return;

                if (Close[2] == Close[0] && Close[2] < Open[2] && Close[1] > Open[1] && Close[0] < Open[0])
                {
                    if (ChartControl != null)
                    {
                        BarColor									= downColor;
                        BarColorSeries.Set(CurrentBar - 1, upColor);
                        CandleOutlineColorSeries.Set(CurrentBar - 1, downColor);
                        BarColorSeries.Set(CurrentBar - 2, downColor);
                    }

                    DrawText("Stick Sandwich" + CurrentBar, false, "Stick Sandwich", 1, Math.Min(Low[0], Math.Min(Low[1], Low[2])), -10, txtColor, textFont, StringAlignment.Center, Color.Transparent, Color.Transparent, 0);

                    patternsFound++;
                    Value.Set(1);
                }
            }

            public void ThreeBlackCrows() {
                if (CurrentBar < 2 || (TrendStrength > 0 && !upTrend))
                    return;

                if (Value[1] == 0 && Value[2] == 0
                    && Close[0] < Open[0] && Close[1] < Open[1] && Close[2] < Open[2]
                    && Close[0] < Close[1] && Close[1] < Close[2]
                    && Open[0] < Open[1] && Open[0] > Close[1]
                    && Open[1] < Open[2] && Open[1] > Close[2])
                {
                    if (ChartControl != null)
                    {
                        BarColor						= downColor;
                        BarColorSeries.Set(CurrentBar - 1, downColor);
                        BarColorSeries.Set(CurrentBar - 2, downColor);
                    }

                    DrawText("Three Black Crows" + CurrentBar, false, "Three Black Crows", 1, High[2], 10, txtColor, textFont, StringAlignment.Center, Color.Transparent, Color.Transparent, 0);

                    patternsFound++;
                    Value.Set(1);
                }
            }

            public void ThreeWhiteSoldiers() {
                if (CurrentBar < 2 || (TrendStrength > 0 && !downTrend))
                    return;

                if (Value[1] == 0 && Value[2] == 0
                    && Close[0] > Open[0] && Close[1] > Open[1] && Close[2] > Open[2]
                    && Close[0] > Close[1] && Close[1] > Close[2]
                    && Open[0] < Close[1] && Open[0] > Open[1]
                    && Open[1] < Close[2] && Open[1] > Open[2])
                {
                    if (ChartControl != null)
                    {
                        BarColor									= upColor;
                        CandleOutlineColorSeries.Set(CurrentBar, downColor);
                        BarColorSeries.Set(CurrentBar - 1, upColor);
                        CandleOutlineColorSeries.Set(CurrentBar - 1, downColor);
                        BarColorSeries.Set(CurrentBar - 2, upColor);
                        CandleOutlineColorSeries.Set(CurrentBar - 2, downColor);
                    }

                    DrawText("Three White Soldiers" + CurrentBar, false, "Three White Soldiers", 1, Low[2], -10, txtColor, textFont, StringAlignment.Center, Color.Transparent, Color.Transparent, 0);

                    patternsFound++;
                    Value.Set(1);
                }
            }

            public void UpsideGapTwoCrows() {
                if (CurrentBar < 2 || (TrendStrength > 0 && !upTrend))
                    return;

                if (Close[2] > Open[2] && Close[1] < Open[1] && Close[0] < Open[0]
                    && Low[1] > High[2]
                    && Close[0] > High[2]
                    && Close[0] < Close[1] && Open[0] > Open[1])
                {
                    if (ChartControl != null)
                    {
                        BarColor									= downColor;
                        BarColorSeries.Set(CurrentBar - 1, downColor);
                        BarColorSeries.Set(CurrentBar - 2, upColor);
                        CandleOutlineColorSeries.Set(CurrentBar - 2, downColor);
                    }

                    DrawText("Upside Gap Two Crows" + CurrentBar, false, "Upside Gap Two Crows", 1, Math.Max(High[0], High[1]), 10, txtColor, textFont, StringAlignment.Center, Color.Transparent, Color.Transparent, 0);

                    patternsFound++;
                    Value.Set(1);
                }
            }

            public void UpsideTasukiGap() {
                if (CurrentBar < 2)
                    return;

                if (Close[2] > Open[2] && Close[1] > Open[1] && Close[0] < Open[0]
                    && Low[1] > High[2]
                    && Open[0] < Close[1] && Open[0] > Open[1]
                    && Close[0] < Open[1] && Close[0] > Close[2])
                {
                    if (ChartControl != null)
                    {
                        BarColor									= downColor;
                        BarColorSeries.Set(CurrentBar - 1, upColor);
                        CandleOutlineColorSeries.Set(CurrentBar - 1, downColor);
                        BarColorSeries.Set(CurrentBar - 2, upColor);
                        CandleOutlineColorSeries.Set(CurrentBar - 2, downColor);
                    }

                    DrawText("Upside Tasuki Gap" + CurrentBar, false, "Upside Tasuki Gap", 1, Math.Max(High[0], High[1]), 10, txtColor, textFont, StringAlignment.Center, Color.Transparent, Color.Transparent, 0);

                    patternsFound++;
                    Value.Set(1);
                }
            }

#endregion
        }
    }

    public enum KriegChartPattern
    {
        BearishBeltHold,
        BearishEngulfing,
        BearishHarami,
        BearishHaramiCross,
        BullishBeltHold,
        BullishEngulfing,
        BullishHarami,
        BullishHaramiCross,
        DarkCloudCover,
        Doji,
        DownsideTasukiGap,
        EveningStar,
        FallingThreeMethods,
        Hammer,
        HangingMan,
        InvertedHammer,
        MorningStar,
        PiercingLine,
        RisingThreeMethods,
        ShootingStar,
        StickSandwich,
        ThreeBlackCrows,
        ThreeWhiteSoldiers,
        UpsideGapTwoCrows,
        UpsideTasukiGap,
    }

#region NinjaScript generated code. Neither change nor remove.
// This namespace holds all indicators and is required. Do not change it.
    namespace NinjaTrader.Indicator
    {
        public partial class Indicator : IndicatorBase
        {
        private KriegCandleStickPattern[] cacheKriegCandleStickPattern = null;

        private static KriegCandleStickPattern checkKriegCandleStickPattern = new KriegCandleStickPattern();

            /// <summary>
            /// Detects common candlestick patterns and marks them on the chart.
            /// </summary>
            /// <returns></returns>
        public KriegCandleStickPattern KriegCandleStickPattern(ChartPattern pattern, int trendStrength)
            {
                return KriegCandleStickPattern(Input, pattern, trendStrength);
            }

            /// <summary>
            /// Detects common candlestick patterns and marks them on the chart.
            /// </summary>
            /// <returns></returns>
        public KriegCandleStickPattern KriegCandleStickPattern(Data.IDataSeries input, ChartPattern pattern, int trendStrength)
            {
                if (cacheKriegCandleStickPattern != null)
                    for (int idx = 0; idx < cacheKriegCandleStickPattern.Length; idx++)
                        if (cacheKriegCandleStickPattern[idx].Pattern == pattern && cacheKriegCandleStickPattern[idx].TrendStrength == trendStrength && cacheKriegCandleStickPattern[idx].EqualsInput(input))
                            return cacheKriegCandleStickPattern[idx];

                lock (checkKriegCandleStickPattern)
                {
                    checkKriegCandleStickPattern.Pattern = pattern;
                    pattern = checkKriegCandleStickPattern.Pattern;
                    checkKriegCandleStickPattern.TrendStrength = trendStrength;
                    trendStrength = checkKriegCandleStickPattern.TrendStrength;

                    if (cacheKriegCandleStickPattern != null)
                        for (int idx = 0; idx < cacheKriegCandleStickPattern.Length; idx++)
                            if (cacheKriegCandleStickPattern[idx].Pattern == pattern && cacheKriegCandleStickPattern[idx].TrendStrength == trendStrength && cacheKriegCandleStickPattern[idx].EqualsInput(input))
                                return cacheKriegCandleStickPattern[idx];

                    KriegCandleStickPattern indicator = new KriegCandleStickPattern();
                    indicator.BarsRequired = BarsRequired;
                    indicator.CalculateOnBarClose = CalculateOnBarClose;
#if NT7
                    indicator.ForceMaximumBarsLookBack256 = ForceMaximumBarsLookBack256;
                indicator.MaximumBarsLookBack = MaximumBarsLookBack;
#endif
                    indicator.Input = input;
                    indicator.Pattern = pattern;
                    indicator.TrendStrength = trendStrength;
                    Indicators.Add(indicator);
                    indicator.SetUp();

                    KriegCandleStickPattern[] tmp = new KriegCandleStickPattern[cacheKriegCandleStickPattern == null ? 1 : cacheKriegCandleStickPattern.Length + 1];
                    if (cacheKriegCandleStickPattern != null)
                        cacheKriegCandleStickPattern.CopyTo(tmp, 0);
                    tmp[tmp.Length - 1] = indicator;
                    cacheKriegCandleStickPattern = tmp;
                    return indicator;
                }
            }
        }
    }

// This namespace holds all market analyzer column definitions and is required. Do not change it.
    namespace NinjaTrader.MarketAnalyzer
    {
        public partial class Column : ColumnBase
        {
            /// <summary>
            /// Detects common candlestick patterns and marks them on the chart.
            /// </summary>
            /// <returns></returns>
            [Gui.Design.WizardCondition("Indicator")]
        public Indicator.KriegCandleStickPattern KriegCandleStickPattern(ChartPattern pattern, int trendStrength)
            {
                return _indicator.KriegCandleStickPattern(Input, pattern, trendStrength);
            }

            /// <summary>
            /// Detects common candlestick patterns and marks them on the chart.
            /// </summary>
            /// <returns></returns>
        public Indicator.KriegCandleStickPattern KriegCandleStickPattern(Data.IDataSeries input, ChartPattern pattern, int trendStrength)
            {
                return _indicator.KriegCandleStickPattern(input, pattern, trendStrength);
            }
        }
    }

// This namespace holds all strategies and is required. Do not change it.
    namespace NinjaTrader.Strategy
    {
        public partial class Strategy : StrategyBase
        {
            /// <summary>
            /// Detects common candlestick patterns and marks them on the chart.
            /// </summary>
            /// <returns></returns>
            [Gui.Design.WizardCondition("Indicator")]
        public Indicator.KriegCandleStickPattern KriegCandleStickPattern(ChartPattern pattern, int trendStrength)
            {
                return _indicator.KriegCandleStickPattern(Input, pattern, trendStrength);
            }

            /// <summary>
            /// Detects common candlestick patterns and marks them on the chart.
            /// </summary>
            /// <returns></returns>
        public Indicator.KriegCandleStickPattern KriegCandleStickPattern(Data.IDataSeries input, ChartPattern pattern, int trendStrength)
            {
                if (InInitialize && input == null)
                    throw new ArgumentException("You only can access an indicator with the default input/bar series from within the 'Initialize()' method");

                return _indicator.KriegCandleStickPattern(input, pattern, trendStrength);
            }
        }
    }
#endregion