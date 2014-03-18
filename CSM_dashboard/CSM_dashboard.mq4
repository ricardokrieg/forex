string Indicator_Name = "CSM Dashboard";
int objs = 0;

#property indicator_separate_window
#property indicator_buffers 120

//------------------------------------------------------------------------------

extern int MA_Method = 2;
extern int Price = 3;

extern bool Enable_M1 = false;
extern bool Enable_M5 = true;
extern bool Enable_M15 = true;
extern bool Enable_M30 = true;
extern bool Enable_H1 = true;
extern bool Enable_H4 = false;
extern bool Enable_D1 = false;
extern bool Enable_W1 = false;
extern bool Enable_MN = false;

extern bool USD = 1;
extern bool EUR = 1;
extern bool GBP = 1;
extern bool CHF = 1;
extern bool JPY = 1;
extern bool AUD = 1;
extern bool CAD = 1;
extern bool NZD = 1;
extern bool USDIX = 0;
extern bool GOLD = 0;
extern bool SILVER = 0;

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
extern int Thin_Line_Thickness = 1;
extern int IDX_Line_Thickness = 3;

extern int All_Bars = 0;
extern int Last_Bars = 0;

// MN
extern int mn_slow = 12;
extern int mn_fast = 3;
// W1
extern int w1_slow = 9;
extern int w1_fast = 3;
// D1
extern int d1_slow = 5;
extern int d1_fast = 3;
// H4
extern int h4_slow = 18;
extern int h4_fast = 6;
// H1
extern int h1_slow = 24;
extern int h1_fast = 6;
// M30
extern int m30_slow = 25;
extern int m30_fast = 3;
// M15
extern int m15_slow = 25;
extern int m15_fast = 3;
// M5
extern int m5_slow = 25;
extern int m5_fast = 3;
// M1
extern int m1_slow = 25;
extern int m1_fast = 3;

extern bool Use_Alert = False;
extern bool EMail_Signals = False;
extern bool AlertAfterCross = False;

//------------------------------------------------------------------------------

class Chart {
    public:
        Chart(int i, int s, int f) {
            this.index = i*12;
            this.slow = s;
            this.fast = f;
        }

        Currency *currencies[11]
        int index;
        int slow;
        int fast;
};

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
                ObjectSet(ID, OBJPROP_XDISTANCE, pos_x + 35);
                ObjectSet(ID, OBJPROP_YDISTANCE, 20);
                ObjectSetText(ID, this.name, 8, "Arial Black", this.col);
            }
        }

        void configure_array(void) {
            SetIndexStyle(this.index, DRAW_LINE, DRAW_LINE, width_for(this.name), this.col);
            SetIndexBuffer(this.index, this.array);
            SetIndexLabel(this.index, this.name);
        }

        bool calculate_ma(int slow_period, int fast_period, int i) {
            string pair = this.merge();

            this.slow = iMA(pair, 0, slow_period, 0, MA_Method, Price, i)/this.pip_division;
            this.fast = iMA(pair, 0, fast_period, 0, MA_Method, Price, i)/this.pip_division;

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

int current_bars, current_bars_1;

Currency *currencies[20];
int currencies_index = 0;

Chart *charts[9];
int charts_index = 0;

//------------------------------------------------------------------------------

int init() {
    IndicatorShortName(Indicator_Name);

    if (Enable_M1) {
        Chart *chart = new Chart(charts_index, m1_slow, m1_fast);
        charts[charts_index++] = chart;
    }
    if (Enable_M5) {
        Chart *chart = new Chart(charts_index, m5_slow, m5_fast);
        charts[charts_index++] = chart;
    }
    if (Enable_M15) {
        Chart *chart = new Chart(charts_index, m15_slow, m15_fast);
        charts[charts_index++] = chart;
    }
    if (Enable_M30) {
        Chart *chart = new Chart(charts_index, m30_slow, m30_fast);
        charts[charts_index++] = chart;
    }
    if (Enable_H1) {
        Chart *chart = new Chart(charts_index, h1_slow, h1_fast);
        charts[charts_index++] = chart;
    }
    if (Enable_H4) {
        Chart *chart = new Chart(charts_index, h4_slow, h4_fast);
        charts[charts_index++] = chart;
    }
    if (Enable_D1) {
        Chart *chart = new Chart(charts_index, d1_slow, d1_fast);
        charts[charts_index++] = chart;
    }
    if (Enable_W1) {
        Chart *chart = new Chart(charts_index, w1_slow, w1_fast);
        charts[charts_index++] = chart;
    }
    if (Enable_MN) {
        Chart *chart = new Chart(charts_index, mn_slow, mn_fast);
        charts[charts_index++] = chart;
    }

    int pos_x = 20;
    int d_x = 35;

    if (USD) {
        // TODO
        // loop through all charts and add a instance of currency to chart.currencies
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
    for (int i = 0; i < objs; i++) {
        if (!ObjectDelete(Indicator_Name + i))
            Print("Error: code #", GetLastError());
    }

    return(0);
}

int start() {
    int limit;
    int counted_bars = IndicatorCounted();

    if (counted_bars < 0) return(-1);
    if (counted_bars > 0) counted_bars--;
    limit = Bars - counted_bars;

    for (int ch_i = 0; ch_i < charts_index; ch_i++) {
        int slow = charts[ch_i].slow;
        int fast = charts[ch_i].fast;

        bool run = true;
        for (int i = 0; i < limit; i++) {
            for (int ma_cci = 0; ma_cci < currencies_index; ma_cci++) {
                if (!currencies[ma_cci].is_USD()) {
                    run = currencies[ma_cci].calculate_ma(slow, fast, i);

                    if (!run) break;
                }
            }
            if (!run) break;

            for (int ci = 0; ci < currencies_index; ci++) {
                if (currencies[ci].is_USD()) {
                    currencies[ci].array[i] = 0;

                    for (int u_cci = 0; u_cci < currencies_index; u_cci++) {
                        if (currencies[ci].name != currencies[u_cci].name) {
                            double diff = (currencies[u_cci].inverse || currencies[u_cci].is_metal()) ? (currencies[u_cci].fast - currencies[u_cci].slow) : (currencies[u_cci].slow - currencies[u_cci].fast);

                            currencies[ci].array[i] += diff;
                        }
                    }
                } else if (currencies[ci].is_metal()) {
                    currencies[ci].array[i] = 0;

                    for (int m_cci = 0; m_cci < currencies_index; m_cci++) {
                        if (currencies[ci].name != currencies[m_cci].name) {
                            if (currencies[m_cci].is_USD()) {
                                currencies[ci].array[i] += currencies[ci].slow - currencies[ci].fast;
                            } else {
                                if (currencies[m_cci].inverse || currencies[m_cci].is_metal()) {
                                    currencies[ci].array[i] += currencies[m_cci].fast - currencies[m_cci].slow;
                                } else {
                                    currencies[ci].array[i] += currencies[m_cci].slow - currencies[m_cci].fast;
                                }
                            }
                        }
                    }
                } else {
                    currencies[ci].array[i] = 0;

                    for (int cci = 0; cci < currencies_index; cci++) {
                        if (currencies[ci].name != currencies[cci].name) {
                            if (currencies[cci].is_USD() || currencies[cci].is_metal()) {
                                if (currencies[ci].inverse) {
                                    currencies[ci].array[i] += currencies[ci].slow - currencies[ci].fast;
                                } else {
                                    currencies[ci].array[i] += currencies[ci].fast - currencies[ci].slow;
                                }
                            } else {
                                if (currencies[ci].inverse) {
                                    if (currencies[ci].has_priority(currencies[cci])) {
                                        currencies[ci].array[i] += (currencies[cci].fast/currencies[ci].fast) - (currencies[cci].slow/currencies[ci].slow);
                                    } else {
                                        if (currencies[cci].inverse) {
                                            currencies[ci].array[i] += (currencies[ci].slow/currencies[cci].slow) - (currencies[ci].fast/currencies[cci].fast);
                                        } else {
                                            currencies[ci].array[i] += (currencies[cci].slow*currencies[ci].slow) - (currencies[cci].fast*currencies[ci].fast);
                                        }
                                    }
                                } else {
                                    if (currencies[ci].has_priority(currencies[cci])) {
                                        if (currencies[cci].inverse) {
                                            currencies[ci].array[i] += (currencies[ci].fast*currencies[cci].fast) - (currencies[ci].slow*currencies[cci].slow);
                                        } else {
                                            currencies[ci].array[i] += (currencies[ci].fast/currencies[cci].fast) - (currencies[ci].slow/currencies[cci].slow);
                                        }
                                    } else {
                                        currencies[ci].array[i] += (currencies[cci].slow/currencies[ci].slow) - (currencies[cci].fast/currencies[ci].fast);
                                    }
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

int width_for(string currency) {
    if (StringFind(Symbol(), currency, 0) < 0) {
        return(Thin_Line_Thickness);
    } else {
        return(Line_Thickness);
    }
}
