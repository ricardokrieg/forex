#property copyright "Ricardo Franco"
#property link      "ricardo.krieg@gmail.com"

string Indicator_Name = "CSM Chart";

#property indicator_separate_window
#property indicator_buffers 11

//------------------------------------------------------------------------------

extern int MA_Method = 2;
extern int Price = 3;

extern string Timeframe = "M1";

extern bool USD = true;
extern bool EUR = true;
extern bool GBP = true;
extern bool CHF = true;
extern bool JPY = true;
extern bool AUD = true;
extern bool CAD = true;
extern bool NZD = true;
extern bool USDIX = true;
extern bool GOLD = true;
extern bool SILVER = true;

extern color Color_USD = White;
extern color Color_EUR = DodgerBlue;
extern color Color_GBP = Red;
extern color Color_CHF = Aqua;
extern color Color_JPY = Yellow;
extern color Color_AUD = MediumOrchid;
extern color Color_CAD = Chartreuse;
extern color Color_NZD = DarkOrange;
extern color Color_USDIX = SteelBlue;
extern color Color_GOLD = RosyBrown;
extern color Color_SILVER = Khaki;

extern int Line_Thickness = 3;

extern int mn_slow = 12;
extern int mn_fast = 3;
extern int w1_slow = 9;
extern int w1_fast = 3;
extern int d1_slow = 5;
extern int d1_fast = 3;
extern int h4_slow = 18;
extern int h4_fast = 6;
extern int h1_slow = 24;
extern int h1_fast = 6;
extern int m30_slow = 25;
extern int m30_fast = 3;
extern int m15_slow = 25;
extern int m15_fast = 3;
extern int m5_slow = 25;
extern int m5_fast = 3;
extern int m1_slow = 25;
extern int m1_fast = 3;

extern int PosX = 10;
extern int PosY = 20;

//------------------------------------------------------------------------------

class Currency {
    public:
        Currency(int i, string n, color c, bool in) {
            this.index = i;
            this.name = n;
            this.col = c;
            this.inverse = in;
            this.metal = false;
            this.pip_division = 1;

            this.configure_array();
            this.set_priority();
        }

        void draw_label(int pos_x) {
            int window = WindowFind(Indicator_Name);
            string ID = Indicator_Name + objs;

            Print("ID:", ID);
            objs++;

            if (ObjectCreate(ID, OBJ_LABEL, window, 0, 0)) {
                ObjectSet(ID, OBJPROP_XDISTANCE, pos_x);
                ObjectSet(ID, OBJPROP_YDISTANCE, PosY);
                ObjectSetText(ID, this.name, 8, "Arial Black", this.col);
            }
        }

        void configure_array(void) {
            SetIndexStyle(this.index, DRAW_LINE, DRAW_LINE, Line_Thickness, this.col);
            SetIndexBuffer(this.index, this.array);
            SetIndexLabel(this.index, this.name);
        }

        bool calculate_ma(int tf, int slow_period, int fast_period, int i) {
            string pair = this.merge();

            this.slow = iMA(pair, tf, slow_period, 0, MA_Method, Price, i)/this.pip_division;
            this.fast = iMA(pair, tf, fast_period, 0, MA_Method, Price, i)/this.pip_division;

            return(this.slow && this.fast);
        }

        bool is_USD(void) {
            return(StringCompare(this.name, "USD") == 0);
        }

        bool is_metal(void) {
            return(this.metal);
        }

        string merge(void) {
            if (this.is_USD()) return "";

            if (this.metal) {
                return(this.name);
            } else {
                if (this.inverse) {
                    return(StringConcatenate("USD", this.name));
                } else {
                    return(StringConcatenate(this.name, "USD"));
                }
            }
        }

        void set_priority(void) {
            string priority_array[8] = {"USD", "EUR", "GBP", "AUD", "NZD", "CAD", "CHF", "JPY"};

            this.priority = 100;

            for (int i = 0; i < 8; i++) {
                if (StringCompare(this.name, priority_array[i]) == 0) {
                    this.priority = i;
                    return;
                }
            }
        }

        bool has_priority(Currency *currency) {
            return(this.priority < currency.priority);
        }

        int index;
        string name;
        double array[];
        color col;
        double slow;
        double fast;
        bool inverse;
        int priority;
        bool metal;
        int pip_division;
};

//------------------------------------------------------------------------------

Currency *currencies[11];
int currencies_index = 0;

int timeframe = 1;
int slow = m1_slow;
int fast = m1_fast;
int objs = 0;

//------------------------------------------------------------------------------

int init() {
    IndicatorShortName(Indicator_Name);

    int window = WindowFind(Indicator_Name);
    string ID = Indicator_Name + objs;
    objs++;
    if (ObjectCreate(ID, OBJ_LABEL, window, 0, 0)) {
        ObjectSet(ID, OBJPROP_XDISTANCE, 10);
        ObjectSet(ID, OBJPROP_YDISTANCE, 40);
        ObjectSetText(ID, Timeframe, 10, "Arial Black", White);
    }

    if (StringCompare(Timeframe, "M1") == 0 ) {
        timeframe = 1;
        slow = m1_slow; fast = m1_fast;
    } else if (StringCompare(Timeframe, "M5") == 0 ) {
        timeframe = 5;
        slow = m5_slow; fast = m5_fast;
    } else if (StringCompare(Timeframe, "M15") == 0 ) {
        timeframe = 15;
        slow = m15_slow;fast = m15_fast;
    } else if (StringCompare(Timeframe, "M30") == 0 ) {
        timeframe = 30;
        slow = m30_slow;fast = m30_fast;
    } else if (StringCompare(Timeframe, "H1") == 0 ) {
        timeframe = 60;
        slow = h1_slow; fast = h1_fast;
    } else if (StringCompare(Timeframe, "H4") == 0 ) {
        timeframe = 240;
        slow = h4_slow; fast = h4_fast;
    } else if (StringCompare(Timeframe, "D1") == 0 ) {
        timeframe = 1440;
        slow = d1_slow; fast = d1_fast;
    } else if (StringCompare(Timeframe, "W1") == 0 ) {
        timeframe = 10080;
        slow = w1_slow; fast = w1_fast;
    } else if (StringCompare(Timeframe, "MN") == 0 ) {
        timeframe = 43200;
        slow = mn_slow; fast = mn_fast;
    }

    int pos_x = PosX;
    int d_x = 40;

    if (USD) {
        Currency *currency = new Currency(currencies_index, "USD", Color_USD, false);
        currencies[currencies_index++] = currency;

        currency.draw_label(pos_x);
        pos_x += d_x;
    }
    if (EUR) {
        Currency *currency = new Currency(currencies_index, "EUR", Color_EUR, false);
        currencies[currencies_index++] = currency;

        currency.draw_label(pos_x);
        pos_x += d_x;
    }
    if (GBP) {
        Currency *currency = new Currency(currencies_index, "GBP", Color_GBP, false);
        currencies[currencies_index++] = currency;

        currency.draw_label(pos_x);
        pos_x += d_x;
    }
    if (CHF) {
        Currency *currency = new Currency(currencies_index, "CHF", Color_CHF, true);
        currencies[currencies_index++] = currency;

        currency.draw_label(pos_x);
        pos_x += d_x;
    }
    if (AUD) {
        Currency *currency = new Currency(currencies_index, "AUD", Color_AUD, false);
        currencies[currencies_index++] = currency;

        currency.draw_label(pos_x);
        pos_x += d_x;
    }
    if (CAD) {
        Currency *currency = new Currency(currencies_index, "CAD", Color_CAD, true);
        currencies[currencies_index++] = currency;

        currency.draw_label(pos_x);
        pos_x += d_x;
    }
    if (JPY) {
        Currency *currency = new Currency(currencies_index, "JPY", Color_JPY, true);
        currency.pip_division = 100;
        currencies[currencies_index++] = currency;

        currency.draw_label(pos_x);
        pos_x += d_x;
    }
    if (NZD) {
        Currency *currency = new Currency(currencies_index, "NZD", Color_NZD, false);
        currencies[currencies_index++] = currency;

        currency.draw_label(pos_x);
        pos_x += d_x;
    }
    if (USDIX) {
        Currency *currency = new Currency(currencies_index, "USDIX", Color_USDIX, true);
        currency.metal = true;
        currencies[currencies_index++] = currency;

        currency.draw_label(pos_x);
        pos_x += d_x;
    }
    if (GOLD) {
        Currency *currency = new Currency(currencies_index, "GOLD", Color_GOLD, true);
        currency.metal = true;
        currencies[currencies_index++] = currency;

        currency.draw_label(pos_x);
        pos_x += d_x;
    }
    if (SILVER) {
        Currency *currency = new Currency(currencies_index, "SILVER", Color_SILVER, true);
        currency.metal = true;
        currencies[currencies_index++] = currency;

        currency.draw_label(pos_x);
        pos_x += d_x;
    }

    return(0);
}

int deinit() {
    return(0);
}

int start() {
    int limit;
    int counted_bars = IndicatorCounted();

    if (counted_bars < 0) return(-1);
    if (counted_bars > 0) counted_bars--;
    limit = Bars - counted_bars;

    int j;
    bool run = true;
    for (int i = 0; i < limit; i++) {
        for (j = 0; j < currencies_index; j++) {
            if (!currencies[j].is_USD()) {
                run = currencies[j].calculate_ma(timeframe, slow, fast, i);

                if (!run) break;
            }
        }
        if (!run) break;

        for (int ci = 0; ci < currencies_index; ci++) {
            Currency *current_currency = currencies[ci];
            Currency *compare_currency;

            current_currency.array[i] = 0;

            if (current_currency.is_USD()) {
                for (j = 0; j < currencies_index; j++) {
                    compare_currency = currencies[j];

                    if (current_currency.name != compare_currency.name) {
                        double diff = (compare_currency.inverse || compare_currency.is_metal()) ? (compare_currency.fast - compare_currency.slow) : (compare_currency.slow - compare_currency.fast);

                        current_currency.array[i] += diff;
                    }
                }
            } else if (current_currency.is_metal()) {
                for (j = 0; j < currencies_index; j++) {
                    compare_currency = currencies[j];

                    if (current_currency.name != compare_currency.name) {
                        if (compare_currency.is_USD()) {
                            current_currency.array[i] += current_currency.slow - current_currency.fast;
                        } else {
                            if (compare_currency.inverse || compare_currency.is_metal()) {
                                current_currency.array[i] += compare_currency.fast - compare_currency.slow;
                            } else {
                                current_currency.array[i] += compare_currency.slow - compare_currency.fast;
                            }
                        }
                    }
                }
            } else {
                for (j = 0; j < currencies_index; j++) {
                    compare_currency = currencies[j];

                    if (current_currency.name != compare_currency.name) {
                        if (compare_currency.is_USD() || compare_currency.is_metal()) {
                            if (current_currency.inverse) {
                                current_currency.array[i] += current_currency.slow - current_currency.fast;
                            } else {
                                current_currency.array[i] += current_currency.fast - current_currency.slow;
                            }
                        } else {
                            if (current_currency.inverse) {
                                if (current_currency.has_priority(compare_currency)) {
                                    current_currency.array[i] += (compare_currency.fast/current_currency.fast) - (compare_currency.slow/current_currency.slow);
                                } else {
                                    if (compare_currency.inverse) {
                                        current_currency.array[i] += (current_currency.slow/compare_currency.slow) - (current_currency.fast/compare_currency.fast);
                                    } else {
                                        current_currency.array[i] += (compare_currency.slow*current_currency.slow) - (compare_currency.fast*current_currency.fast);
                                    }
                                }
                            } else {
                                if (current_currency.has_priority(compare_currency)) {
                                    if (compare_currency.inverse) {
                                        current_currency.array[i] += (current_currency.fast*compare_currency.fast) - (current_currency.slow*compare_currency.slow);
                                    } else {
                                        current_currency.array[i] += (current_currency.fast/compare_currency.fast) - (current_currency.slow/compare_currency.slow);
                                    }
                                } else {
                                    current_currency.array[i] += (compare_currency.slow/current_currency.slow) - (compare_currency.fast/current_currency.fast);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    return(0);
}
