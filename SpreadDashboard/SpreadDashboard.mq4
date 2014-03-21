#property copyright "Ricardo Franco"
#property link      "ricardo.krieg@gmail.com"
#property strict
#property indicator_chart_window

extern int SpreadLimit = 5;
extern color Color = clrWhite;
extern color HighlightColor = clrYellow;
extern string Font = "Arial";
extern int FontSize = 12;
extern int DistanceX = 10;
extern int DistanceY = 20;
extern bool DisplayLegend = true;

string indicator_name = "SpreadDashboard";

class Pair {
    public:
        Pair(int i, string n) {
            this.index = i;
            this.name = n;
            this.spread = 0;
            this.col = Color;
            this.label_name = StringConcatenate(indicator_name, this.name);
            this.label_spread = StringConcatenate(this.label_name, "SPREAD");
        }

        void update(void) {
            this.spread = SymbolInfoInteger(this.name, SYMBOL_SPREAD);

            this.draw();
        }

        void draw(void) {
            if (!this.create_labels()) return;

            ObjectSetString(0, this.label_spread, OBJPROP_TEXT, IntegerToString(this.spread, 2));

            this.col = Color;
            if (this.spread <= SpreadLimit) {
                this.col = HighlightColor;
            }

            ObjectSetInteger(0, this.label_name, OBJPROP_COLOR, this.col);
            ObjectSetInteger(0, this.label_spread, OBJPROP_COLOR, this.col);
        }

        bool create_labels(void) {
            if (ObjectFind(0, this.label_name) < 0) {
                if (ObjectCreate(0, this.label_name, OBJ_LABEL, 0, 0, 0)) {
                    TextSetFont(Font, FontSize);
                    ObjectSetString(0, this.label_name, OBJPROP_TEXT, this.name);
                    ObjectSetInteger(0, this.label_name, OBJPROP_COLOR, this.col);
                    ObjectSetInteger(0, this.label_name, OBJPROP_XDISTANCE, DistanceX);
                    ObjectSetInteger(0, this.label_name, OBJPROP_YDISTANCE, DistanceY+this.index*(FontSize+2));
                } else {
                    Print("Error ObjectCreate: ", GetLastError());
                    return(false);
                }
            }

            if (ObjectFind(0, this.label_spread) < 0) {
                if (ObjectCreate(0, this.label_spread, OBJ_LABEL, 0, 0, 0)) {
                    TextSetFont(Font, FontSize);
                    ObjectSetString(0, this.label_spread, OBJPROP_TEXT, "--");
                    ObjectSetInteger(0, this.label_spread, OBJPROP_COLOR, this.col);
                    ObjectSetInteger(0, this.label_spread, OBJPROP_XDISTANCE, DistanceX+FontSize*6+10);
                    ObjectSetInteger(0, this.label_spread, OBJPROP_YDISTANCE, DistanceY+this.index*(FontSize+2));
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

Pair *pairs[];
int pairs_size = 0;

int OnInit() {
    IndicatorShortName(indicator_name);

    pairs_size = SymbolsTotal(true);

    ArrayResize(pairs, pairs_size);

    for (int i = 0; i < pairs_size; i++) {
        pairs[i] = new Pair(i, SymbolName(i, true));
    }

    if (DisplayLegend) {
        draw_legend();
        DistanceY += 20;
    }

    return(INIT_SUCCEEDED);
}

int start() {
    for (int i = 0; i < pairs_size; i++) {
        pairs[i].update();
    }

    return(0);
}

void draw_legend(void) {
    string legend_name = StringConcatenate(indicator_name, "LEGEND");

    if (ObjectCreate(0, legend_name, OBJ_LABEL, 0, 0, 0)) {
        TextSetFont("Arial", 14);
        ObjectSetString(0, legend_name, OBJPROP_TEXT, "Spread Dashboard");
        ObjectSetInteger(0, legend_name, OBJPROP_COLOR, Color);
        ObjectSetInteger(0, legend_name, OBJPROP_XDISTANCE, DistanceX);
        ObjectSetInteger(0, legend_name, OBJPROP_YDISTANCE, DistanceY);
    } else {
        Print("Error ObjectCreate: ", GetLastError());
    }
}
