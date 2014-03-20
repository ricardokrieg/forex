#property copyright "Ricardo Franco"
#property link      "ricardo.krieg@gmail.com"
#property strict
#property indicator_chart_window

extern int LowSpread = 5;
extern color Color = clrYellow;

string IndicatorName = "SpreadDashboard";

class Pair {
    public:
        Pair(int i, string n) {
            this.index = i;
            this.name = n;
            this.spread = 0;
            this.col = clrWhite;
            this.label_name = StringConcatenate(IndicatorName, this.name);
            this.label_spread = StringConcatenate(this.label_name, "SPREAD");
        }

        void update(void) {
            this.spread = SymbolInfoInteger(this.name, SYMBOL_SPREAD);

            this.draw();
        }

        void draw(void) {
            if (!this.create_labels()) return;

            ObjectSetString(0, this.label_spread, OBJPROP_TEXT, IntegerToString(this.spread, 2));

            if (this.spread <= LowSpread) {
                this.col = Color;
            } else {
                this.col = clrWhite;
            }

            ObjectSetInteger(0, this.label_name, OBJPROP_COLOR, this.col);
            ObjectSetInteger(0, this.label_spread, OBJPROP_COLOR, this.col);
        }

        bool create_labels(void) {
            if (ObjectFind(0, this.label_name) < 0) {
                if (ObjectCreate(0, this.label_name, OBJ_LABEL, 0, 0, 0)) {
                    TextSetFont("Arial", 12);
                    ObjectSetString(0, this.label_name, OBJPROP_TEXT, this.name);
                    ObjectSetInteger(0, this.label_name, OBJPROP_COLOR, this.col);
                    ObjectSetInteger(0, this.label_name, OBJPROP_XDISTANCE, 0);
                    ObjectSetInteger(0, this.label_name, OBJPROP_YDISTANCE, this.index*(12+2)+20);
                } else {
                    Print("Error ObjectCreate: ", GetLastError());
                    return(false);
                }
            }

            if (ObjectFind(0, this.label_spread) < 0) {
                if (ObjectCreate(0, this.label_spread, OBJ_LABEL, 0, 0, 0)) {
                    TextSetFont("Arial", 12);
                    ObjectSetString(0, this.label_spread, OBJPROP_TEXT, "--");
                    ObjectSetInteger(0, this.label_spread, OBJPROP_COLOR, this.col);
                    ObjectSetInteger(0, this.label_spread, OBJPROP_XDISTANCE, 12*6+20);
                    ObjectSetInteger(0, this.label_spread, OBJPROP_YDISTANCE, this.index*(12+2)+20);
                } else {
                    Print("Error ObjectCreate: ", GetLastError());
                    return(false);
                }
            }

            return(true);
        }

        int index;
        string name;
        long spread;
        string label_name;
        string label_spread;
        color col;
};

Pair *pairs[28];
int pairs_size;

int OnInit() {
    string pair_names[] = {
        "EURUSD",
        "EURGBP",
        "EURJPY",
        "EURCHF",
        "EURAUD",
        "EURCAD",
        "EURNZD",
        "USDJPY",
        "USDCHF",
        "USDCAD",
        "GBPUSD",
        "GBPJPY",
        "GBPCHF",
        "GBPAUD",
        "GBPCAD",
        "GBPNZD",
        "CHFJPY",
        "AUDUSD",
        "AUDJPY",
        "AUDCHF",
        "AUDCAD",
        "AUDNZD",
        "CADJPY",
        "CADCHF",
        "NZDUSD",
        "NZDJPY",
        "NZDCHF",
        "NZDCAD"
    };
    pairs_size = 28;

    for (int i = 0; i < pairs_size; i++) {
        pairs[i] = new Pair(i, pair_names[i]);
    }

    return(INIT_SUCCEEDED);
}

int start() {
    for (int i = 0; i < pairs_size; i++) {
        pairs[i].update();
    }

    return(0);
}
