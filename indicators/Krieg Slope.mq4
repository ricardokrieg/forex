#property copyright "Krieg Corp"
#property link      "ricardo.krieg@gmail.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 White
#property indicator_color2 Red

extern int period = 10;
extern int method = 3;
extern int price = 0;

double Uptrend[];
double Dntrend[];
double ExtMapBuffer[];

int last_bar;
int current_trend;
int up_trend;
int down_trend;
bool first_run;

int init() {
    IndicatorBuffers(3);

    SetIndexBuffer(0, Uptrend);
    SetIndexBuffer(1, Dntrend);
    SetIndexBuffer(2, ExtMapBuffer);

    ArraySetAsSeries(ExtMapBuffer, true);

    SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
    SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2);

    IndicatorShortName("Slope Direction Line("+period+")");

    last_bar = 0;
    current_trend = 0;
    up_trend = 0;
    down_trend = 0;
    first_run = true;

    GlobalVariableSet("KriegSlopeOpenOrder", 0);

    return(0);
}

int deinit() {return(0);}

double WMA(int x, int p) {
    return(iMA(NULL, 0, p, 0, method, price, x));
}

int start() {
    if (Bars <= last_bar) return(0);

    int counted_bars = IndicatorCounted();

    if (counted_bars < 0)
        return(-1);

    int x = 0;
    int p = MathSqrt(period);
    int e = Bars - counted_bars + period + 1;

    double vect[], trend[];

    if (e > Bars)
        e = Bars;

    ArrayResize(vect, e);
    ArraySetAsSeries(vect, true);
    ArrayResize(trend, e);
    ArraySetAsSeries(trend, true);

    for (x=0; x < e; x++) {
        vect[x] = 2*WMA(x, period/2) - WMA(x, period);
    }

    for (x=0; x < e-period; x++) {
        ExtMapBuffer[x] = iMAOnArray(vect, 0, p, 0, method, x);
    }

    for (x=e-period; x >= 0; x--) {
        trend[x] = trend[x+1];

        if (ExtMapBuffer[x] > ExtMapBuffer[x+1]) trend[x] = 1;
        if (ExtMapBuffer[x] < ExtMapBuffer[x+1]) trend[x] = -1;

        if (trend[x] > 0) {
            Uptrend[x] = ExtMapBuffer[x];
            if (trend[x+1] < 0) Uptrend[x+1] = ExtMapBuffer[x+1];
            Dntrend[x] = EMPTY_VALUE;
        } else if (trend[x] < 0) {
            Dntrend[x] = ExtMapBuffer[x];
            if (trend[x+1] > 0) Dntrend[x+1] = ExtMapBuffer[x+1];
            Uptrend[x] = EMPTY_VALUE;
        }
    }

    if (Uptrend[0] != EMPTY_VALUE) {
        up_trend++;

        if (up_trend == 2) {
            down_trend = 0;
            current_trend = 1;
        }
    } else if (Dntrend[0] != EMPTY_VALUE) {
        down_trend++;

        if (down_trend == 2) {
            up_trend = 0;
            current_trend = 2;
        }
    }

    if (current_trend != 0) {
        if (!first_run) {
            GlobalVariableSet("KriegSlopeOpenOrder", current_trend);
            Print("GlobalVariableSet=", current_trend);

            current_trend = 0;
        }

        first_run = false;
    }

    last_bar = Bars;

    return(0);
}
