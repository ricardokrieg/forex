#property copyright "Ricardo Franco"
#property link      "ricardo.krieg@gmail.com"

string Indicator_Name = "CSM Dashboard";

#property indicator_chart_window

//------------------------------------------------------------------------------

extern int MA_Method = 2;
extern int Price = 3;

extern bool Enable_M1 = true;
extern bool Enable_M5 = false;
extern bool Enable_M15 = false;
extern bool Enable_M30 = false;
extern bool Enable_H1 = true;
extern bool Enable_H4 = false;
extern bool Enable_D1 = false;
extern bool Enable_W1 = false;
extern bool Enable_MN = false;

extern bool USD = true;
extern bool EUR = true;
extern bool GBP = true;
extern bool CHF = true;
extern bool JPY = false;
extern bool AUD = false;
extern bool CAD = false;
extern bool NZD = false;
extern bool USDIX = false;
extern bool GOLD = false;
extern bool SILVER = false;

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

extern int Corner = 0;
extern int X = 100;
extern int Y = 100;

//------------------------------------------------------------------------------

int charts_index = 0;
int currencies_index = 0;

//------------------------------------------------------------------------------

class Currency {
    public:
        Currency(string n, color c, bool in) {
            this.name = n;
            this.col = c;
            this.inverse = in;
            this.metal = false;
            this.pip_division = 1;

            this.set_priority();
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

class Chart {
    public:
        Chart(int i, int tf, int s, int f) {
            this.index = i*11;
            this.timeframe = tf;
            this.slow = s;
            this.fast = f;
        }

        Currency *strongest_currency(void) {
            Currency *currency = this.currencies[0];
            double value = currency.array[ArraySize(currency.array)-1];

            double max = value;
            Currency *max_currency = currency;

            for (int i = 1; i < currencies_index; i++) {
                currency = this.currencies[i];
                value = currency.array[ArraySize(currency.array)-1];

                if (value > max) {
                    max = value;
                    max_currency = currency;
                }
            }

            return max_currency;
        }

        Currency *weakest_currency(void) {
            Currency *currency = this.currencies[0];
            double value = currency.array[ArraySize(currency.array)-1];

            double min = value;
            Currency *min_currency = currency;

            for (int i = 1; i < currencies_index; i++) {
                currency = this.currencies[i];
                value = currency.array[ArraySize(currency.array)-1];

                if (value < min) {
                    min = value;
                    min_currency = currency;
                }
            }

            return min_currency;
        }

        Currency *currencies[11];
        int timeframe;
        int index;
        int slow;
        int fast;
};

//------------------------------------------------------------------------------

Chart *charts[9];

//------------------------------------------------------------------------------

int init() {
    IndicatorShortName(Indicator_Name);

    if (Enable_M1) {
        Chart *chart = new Chart(charts_index, 1, m1_slow, m1_fast);
        charts[charts_index++] = chart;
    }
    if (Enable_M5) {
        Chart *chart = new Chart(charts_index, 5, m5_slow, m5_fast);
        charts[charts_index++] = chart;
    }
    if (Enable_M15) {
        Chart *chart = new Chart(charts_index, 15, m15_slow, m15_fast);
        charts[charts_index++] = chart;
    }
    if (Enable_M30) {
        Chart *chart = new Chart(charts_index, 30, m30_slow, m30_fast);
        charts[charts_index++] = chart;
    }
    if (Enable_H1) {
        Chart *chart = new Chart(charts_index, 60, h1_slow, h1_fast);
        charts[charts_index++] = chart;
    }
    if (Enable_H4) {
        Chart *chart = new Chart(charts_index, 240, h4_slow, h4_fast);
        charts[charts_index++] = chart;
    }
    if (Enable_D1) {
        Chart *chart = new Chart(charts_index, 1440, d1_slow, d1_fast);
        charts[charts_index++] = chart;
    }
    if (Enable_W1) {
        Chart *chart = new Chart(charts_index, 10080, w1_slow, w1_fast);
        charts[charts_index++] = chart;
    }
    if (Enable_MN) {
        Chart *chart = new Chart(charts_index, 43200, mn_slow, mn_fast);
        charts[charts_index++] = chart;
    }

    int i;

    if (USD) {
        for (i = 0; i < charts_index; i++) {
            Currency *currency = new Currency("USD", Color_USD, false);
            charts[i].currencies[currencies_index] = currency;
        }
        currencies_index++;
    }
    if (EUR) {
        for (i = 0; i < charts_index; i++) {
            Currency *currency = new Currency("EUR", Color_EUR, false);
            charts[i].currencies[currencies_index] = currency;
        }
        currencies_index++;
    }
    if (GBP) {
        for (i = 0; i < charts_index; i++) {
            Currency *currency = new Currency("GBP", Color_GBP, false);
            charts[i].currencies[currencies_index] = currency;
        }
        currencies_index++;
    }
    if (CHF) {
        for (i = 0; i < charts_index; i++) {
            Currency *currency = new Currency("CHF", Color_CHF, true);
            charts[i].currencies[currencies_index] = currency;
        }
        currencies_index++;
    }
    if (AUD) {
        for (i = 0; i < charts_index; i++) {
            Currency *currency = new Currency("AUD", Color_AUD, false);
            charts[i].currencies[currencies_index] = currency;
        }
        currencies_index++;
    }
    if (CAD) {
        for (i = 0; i < charts_index; i++) {
            Currency *currency = new Currency("CAD", Color_CAD, true);
            charts[i].currencies[currencies_index] = currency;
        }
        currencies_index++;
    }
    if (JPY) {
        for (i = 0; i < charts_index; i++) {
            Currency *currency = new Currency("JPY", Color_JPY, true);
            currency.pip_division = 100;
            charts[i].currencies[currencies_index] = currency;
        }
        currencies_index++;
    }
    if (NZD) {
        for (i = 0; i < charts_index; i++) {
            Currency *currency = new Currency("NZD", Color_NZD, false);
            charts[i].currencies[currencies_index] = currency;
        }
        currencies_index++;
    }
    if (USDIX) {
        for (i = 0; i < charts_index; i++) {
            Currency *currency = new Currency("USDIX", Color_USDIX, true);
            currency.metal = true;
            charts[i].currencies[currencies_index] = currency;
        }
        currencies_index++;
    }
    if (GOLD) {
        for (i = 0; i < charts_index; i++) {
            Currency *currency = new Currency("GOLD", Color_GOLD, true);
            currency.metal = true;
            charts[i].currencies[currencies_index] = currency;
        }
        currencies_index++;
    }
    if (SILVER) {
        for (i = 0; i < charts_index; i++) {
            Currency *currency = new Currency("SILVER", Color_SILVER, true);
            currency.metal = true;
            charts[i].currencies[currencies_index] = currency;
        }
        currencies_index++;
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

    for (int ch_i = 0; ch_i < charts_index; ch_i++) {
        Chart *current_chart = charts[ch_i];

        int slow = current_chart.slow;
        int fast = current_chart.fast;

        int j;
        bool run = true;
        for (int i = 0; i < limit; i++) {
            for (j = 0; j < currencies_index; j++) {
                if (!current_chart.currencies[j].is_USD()) {
                    run = current_chart.currencies[j].calculate_ma(current_chart.timeframe, slow, fast, i);

                    if (!run) break;
                }
            }
            if (!run) break;

            for (int ci = 0; ci < currencies_index; ci++) {
                Currency *current_currency = current_chart.currencies[ci];
                Currency *compare_currency;

                current_currency.array[i] = 0;

                if (current_currency.is_USD()) {
                    for (j = 0; j < currencies_index; j++) {
                        compare_currency = current_chart.currencies[j];

                        if (current_currency.name != compare_currency.name) {
                            double diff = (compare_currency.inverse || compare_currency.is_metal()) ? (compare_currency.fast - compare_currency.slow) : (compare_currency.slow - compare_currency.fast);

                            current_currency.array[i] += diff;
                        }
                    }
                } else if (current_currency.is_metal()) {
                    for (j = 0; j < currencies_index; j++) {
                        compare_currency = current_chart.currencies[j];

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
                        compare_currency = current_chart.currencies[j];

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

                // Print(current_currency.name, "  -  ", current_currency.array[ArraySize(current_currency.array)-1]);
                // Print(current_currency.name, "  -  ", current_currency.array[0]);
                // Print(current_currency.name, "  -  ", current_currency.array[limit-1]);
                Print(current_currency.name, "  -  ", current_currency.array[i]);
            }
        }

        // Print("Chart: ", current_chart.timeframe);
        // Print("            Strong: ", current_chart.strongest_currency().name);
        // Print("              Weak: ", current_chart.weakest_currency().name);
    }

    return(0);
}
