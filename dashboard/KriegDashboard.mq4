#property copyright "Ricardo Franco"
#property link      "ricardo.krieg@gmail.com"

#property indicator_chart_window

#define UPPER_BAND 1
#define LOWER_BAND 2
#define CENTER_LINE 0

#define ONCLOUD 0
#define UP 1
#define DOWN 2

//------------------------------------------------------------------------------

extern string Pairs = "EURJPY, GBPJPY, EURUSD, GBPUSD, AUDUSD, NZDUSD, USDCAD, GBPCHF,";
extern int FontSize = 20;
extern int Corner = 0;
extern int DistanceX = 20;
extern int DistanceY = 20;

//------------------------------------------------------------------------------

class Pair {
   public:
      Pair(string n) {
         this.name = n;
      }

      void update(void) {
         this.update_ichimoku();
         this.update_tma();
         this.update_tma_status();
      }

      void update_ichimoku(void) {
         this.ichimoku_senkou_a = iIchimoku(this.name, PERIOD_M1, 9, 26, 52, MODE_SENKOUSPANA, 0);
         this.ichimoku_senkou_b = iIchimoku(this.name, PERIOD_M1, 9, 26, 52, MODE_SENKOUSPANB, 0);
      }

      void update_tma(void) {
         this.tma_center_line = iCustom(this.name, PERIOD_M1, "TMA", "M1", 20, PRICE_CLOSE, 2.0, 100, true, CENTER_LINE, 0);
         this.tma_upper_band = iCustom(this.name, PERIOD_M1, "TMA", "M1", 20, PRICE_CLOSE, 2.0, 100, true, UPPER_BAND, 0);
         this.tma_lower_band = iCustom(this.name, PERIOD_M1, "TMA", "M1", 20, PRICE_CLOSE, 2.0, 100, true, LOWER_BAND, 0);
      }

      void update_tma_status(int index) {
         this.upper_band_status = ONCLOUD;
         if (this.tma_upper_band > this.ichimoku_senkou_a && this.tma_upper_band > this.ichimoku_senkou_b) {
            this.upper_band_status = UP;
         } else if (this.tma_upper_band < this.ichimoku_senkou_a && this.tma_upper_band < this.ichimoku_senkou_b) {
            this.upper_band_status = DOWN;
         }

         this.lower_band_status = ONCLOUD;
         if (this.tma_lower_band > this.ichimoku_senkou_a && this.tma_lower_band > this.ichimoku_senkou_b) {
            this.lower_band_status = UP;
         } else if (this.tma_lower_band < this.ichimoku_senkou_a && this.tma_lower_band < this.ichimoku_senkou_b) {
            this.lower_band_status = DOWN;
         }

         this.center_line_status = ONCLOUD;
         if (this.tma_center_line > this.ichimoku_senkou_a && this.tma_center_line > this.ichimoku_senkou_b) {
            this.center_line_status = UP;
         } else if (this.tma_center_line < this.ichimoku_senkou_a && this.tma_center_line < this.ichimoku_senkou_b) {
            this.center_line_status = DOWN;
         } else {
            this.tma_slope = 0;
            this.tma_highest_slope = 0;
         }
      }

      void check_tma_above_cloud(void) {
         if (this.center_line_status == UP && this.upper_band_status == UP) {
            this.update_tma_slope(1);

            ObjectSetText(object_name("TMA-Slope", this.name), DoubleToStr(this.tma_slope*this.point_value()*100, 0));
            ObjectSetText(object_name("TMA-HighestSlope", this.name), DoubleToStr(this.tma_highest_slope*this.point_value()*100, 0));

            if (this.lower_band_status == UP) {
               ObjectSetText(object_name("TMA", this.name), CharToStr(233));
               ObjectSet(object_name("TMA", this.name), OBJPROP_COLOR, Lime);
               ObjectSet(object_name("TMA-Slope", this.name), OBJPROP_COLOR, Lime);
               ObjectSet(object_name("TMA-HighestSlope", this.name), OBJPROP_COLOR, ForestGreen);
            } else {
               ObjectSetText(object_name("TMA", this.name), CharToStr(236));
               ObjectSet(object_name("TMA", this.name), OBJPROP_COLOR, Orange);
               ObjectSet(object_name("TMA-Slope", this.name), OBJPROP_COLOR, Orange);
               ObjectSet(object_name("TMA-HighestSpeed", this.name), OBJPROP_COLOR, DarkGoldenrod);
            }
         }
      }

      void calculate_tma_below_cloud(void) {
         if (this.center_line_status == DOWN && this.lower_band_status == DOWN) {
            this.update_tma_slope(2);

            ObjectSetText(object_name("TMA-Slope", this.name), DoubleToStr(this.tma_slope*this.point_value()*100, 0));
            ObjectSetText(object_name("TMA-HighestSlope", this.name), DoubleToStr(this.tma_highest_slope*this.point_value()*100, 0));

            if (this.upper_band_status == DOWN) {
               ObjectSetText(object_name("TMA", this.name), CharToStr(234));
               ObjectSet(object_name("TMA", this.name), OBJPROP_COLOR, Red);
               ObjectSet(object_name("TMA-Slope", this.name), OBJPROP_COLOR, Red);
               ObjectSet(object_name("TMA-HighestSlope", this.name), OBJPROP_COLOR, FireBrick);
            } else {
               ObjectSetText(object_name("TMA", this.name), CharToStr(238));
               ObjectSet(object_name("TMA", this.name), OBJPROP_COLOR, Orange);
               ObjectSet(object_name("TMA-Slope", this.name), OBJPROP_COLOR, Orange);
               ObjectSet(object_name("TMA-HighestSlope", this.name), OBJPROP_COLOR, DarkGoldenrod);
            }
         }
      }

      void update_tma_slope(int direction) {
         int shift = 1;
         double ichimoku_senkou_a_for_angle = 0;
         double ichimoku_senkou_b_for_angle = 0;
         double tma_center_line_for_angle = 0;

         while (true) {
            ichimoku_senkou_a_for_angle = iIchimoku(this.name, PERIOD_M1, 9, 26, 52, MODE_SENKOUSPANA, shift);
            ichimoku_senkou_b_for_angle = iIchimoku(this.name, PERIOD_M1, 9, 26, 52, MODE_SENKOUSPANB, shift);
            tma_center_line_for_angle = iCustom(this.name, PERIOD_M1, "TMA", "M1", 20, PRICE_CLOSE, 2.0, 100, true, CENTER_LINE, shift);

            // UP
            if (direction == 1) {
               if (tma_center_line_for_angle < ichimoku_senkou_a_for_angle || tma_center_line_for_angle < ichimoku_senkou_b_for_angle)
                  break;
            // DOWN
            } else if (direction == 2) {
               if (tma_center_line_for_angle > ichimoku_senkou_a_for_angle || tma_center_line_for_angle > ichimoku_senkou_b_for_angle)
                  break;
            }

            shift++;
         }

         this.tma_slope = MathAbs((this.tma_center_line-tma_center_line_for_angle) / shift);
         this.tma_highest_slope = MathMax(this.tma_slope, this.tma_highest_slope);
      }

      string name;

      double tma_slope;
      double tma_highest_slope;

      int center_line_status;
      int upper_band_status;
      int lower_band_status;

      double ichimoku_senkou_a = 0;
      double ichimoku_senkou_b = 0;
      double tma_center_line = 0;
      double tma_upper_band = 0;
      double tma_lower_band = 0;
};

//------------------------------------------------------------------------------

Pair *pairs[];
int pairs_index = 0;

//------------------------------------------------------------------------------

int init() {
   for (int i = 0; i < SymbolsTotal(false); i++) {
      Pair *pair = new Pair(SymbolName(i, false));
      pairs[pairs_index++] = pair;
   }

   return(0);
}

int deinit() {return(0);}

int start() {
   if (IndicatorCounted() < 0) return(-1);

   int pairs_index = 0;
   while (true) {
      string pair = pairs[pairs_index];
      if (pair == "") break;

      pair.update();

      create_labels(pair, pairs_index);

      calculate_tma_above_cloud(pair, pairs_index);
      calculate_tma_below_cloud(pair, pairs_index);

      pairs_index++;
   }

   return(0);
}

void create_labels(string pair, int index) {
   if (ObjectFind(object_name("Pair", pair)) == -1) {
      ObjectCreate(object_name("Pair", pair), OBJ_LABEL, 0, 0, 0);
      ObjectSetText(object_name("Pair", pair), pair, FontSize);
      ObjectSet(object_name("Pair", pair), OBJPROP_COLOR, White);
      ObjectSet(object_name("Pair", pair), OBJPROP_CORNER, Corner);
      ObjectSet(object_name("Pair", pair), OBJPROP_XDISTANCE, DistanceX);
      ObjectSet(object_name("Pair", pair), OBJPROP_YDISTANCE, DistanceY+(FontSize+15)*index);
   }

   if (ObjectFind(object_name("TMA", pair)) >= 0) {
      ObjectSetText(object_name("TMA", pair), CharToStr(75));
      ObjectSet(object_name("TMA", pair), OBJPROP_COLOR, Gray);
   } else {
      ObjectCreate(object_name("TMA", pair), OBJ_LABEL, 0, 0, 0);
      ObjectSetText(object_name("TMA", pair), CharToStr(75), FontSize, "Wingdings");
      ObjectSet(object_name("TMA", pair), OBJPROP_COLOR, Gray);
      ObjectSet(object_name("TMA", pair), OBJPROP_CORNER, Corner);
      ObjectSet(object_name("TMA", pair), OBJPROP_XDISTANCE, DistanceX+FontSize*6);
      ObjectSet(object_name("TMA", pair), OBJPROP_YDISTANCE, DistanceY+(FontSize+15)*index);
   }

   if (ObjectFind(object_name("TMA-Speed", pair)) >= 0) {
      ObjectSetText(object_name("TMA-Speed", pair), "");
   } else {
      ObjectCreate(object_name("TMA-Speed", pair), OBJ_LABEL, 0, 0, 0);
      ObjectSetText(object_name("TMA-Speed", pair), "", FontSize);
      ObjectSet(object_name("TMA-Speed", pair), OBJPROP_CORNER, Corner);
      ObjectSet(object_name("TMA-Speed", pair), OBJPROP_XDISTANCE, DistanceX+FontSize*9);
      ObjectSet(object_name("TMA-Speed", pair), OBJPROP_YDISTANCE, DistanceY+(FontSize+15)*index);
   }

   if (ObjectFind(object_name("TMA-HigherSpeed", pair)) >= 0) {
      ObjectSetText(object_name("TMA-HigherSpeed", pair), "");
   } else {
      ObjectCreate(object_name("TMA-HigherSpeed", pair), OBJ_LABEL, 0, 0, 0);
      ObjectSetText(object_name("TMA-HigherSpeed", pair), "", FontSize);
      ObjectSet(object_name("TMA-HigherSpeed", pair), OBJPROP_CORNER, Corner);
      ObjectSet(object_name("TMA-HigherSpeed", pair), OBJPROP_XDISTANCE, DistanceX+FontSize*12);
      ObjectSet(object_name("TMA-HigherSpeed", pair), OBJPROP_YDISTANCE, DistanceY+(FontSize+15)*index);
   }
}

void extract_pairs() {
    int string_find_start = 0;
    int pairs_index = 0;

    while (true) {
        int index = StringFind(Pairs, ",", string_find_start);
        if (index == -1) break;

        pairs[pairs_index] = StringTrimRight(StringTrimLeft(StringSubstr(Pairs, string_find_start, index-string_find_start)));

        string_find_start = index+1;
        pairs_index++;
    }

    pairs[pairs_index] = "";
}

string object_name(string name, string pair) {
   return(StringConcatenate(name, " (", pair, ")"));
}

double point_value(string pair) {
   if (MarketInfo(pair, MODE_POINT) == 0.00001) return(10000);
   if (MarketInfo(pair, MODE_POINT) == 0.001) return(100);
   return(MarketInfo(pair, MODE_POINT)*100000);
}
