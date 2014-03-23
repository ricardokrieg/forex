#property copyright "Ricardo Franco"
#property link      "ricardo.krieg@gmail.com"
#property strict
#property indicator_chart_window

#define UPPER_BAND 1
#define LOWER_BAND 2
#define CENTER_LINE 0

#define ONCLOUD 0
#define UP 1
#define DOWN 2

#define NAME "BabonDashboard"

//------------------------------------------------------------------------------

extern string Font = "Arial";
extern int FontSize = 16;
extern int Corner = 0;
extern int DistanceX = 20;
extern int DistanceY = 20;
extern int PaddingY = 4;

//------------------------------------------------------------------------------

class Pair {
   public:
      Pair(int i, string n) {
         this.index = i;
         this.name = n;
         this.highlighted = false;
         this.point_value = this.calculate_point_value();

         this.label_name = StringConcatenate(NAME, this.name);
         this.label_tma = StringConcatenate(this.label_name, "TMA");
         this.label_tma_slope = StringConcatenate(this.label_name, "SLOPE");
         this.label_tma_highest_slope = StringConcatenate(this.label_name, "HIGHESTSLOPE");
         this.label_spread = StringConcatenate(this.label_name, "SPREAD");
      }

      void update(void) {
         this.spread = SymbolInfoInteger(this.name, SYMBOL_SPREAD);

         this.update_ichimoku();
         this.update_tma();
         this.update_tma_status();

         this.draw();
      }

      void draw(void) {
         if (!this.create_labels()) return;

         ObjectSetString(0, this.label_spread, OBJPROP_TEXT, IntegerToString(this.spread, 2));

         this.check_tma_above_cloud();
         this.check_tma_below_cloud();
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

      void update_tma_status(void) {
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

            ObjectSetString(0, this.label_tma_slope, OBJPROP_TEXT, DoubleToStr(this.tma_slope*this.point_value*100, 0));
            ObjectSetString(0, this.label_tma_highest_slope, OBJPROP_TEXT, DoubleToStr(this.tma_highest_slope*this.point_value*100, 0));

            if (this.lower_band_status == UP) {
               ObjectSetString(0, this.label_tma, OBJPROP_TEXT, CharToStr(233));
               ObjectSetInteger(0, this.label_tma, OBJPROP_COLOR, Lime);
               ObjectSetInteger(0, this.label_tma_slope, OBJPROP_COLOR, Lime);
               ObjectSetInteger(0, this.label_tma_highest_slope, OBJPROP_COLOR, ForestGreen);
            } else {
               ObjectSetString(0, this.label_tma, OBJPROP_TEXT, CharToStr(236));
               ObjectSetInteger(0, this.label_tma, OBJPROP_COLOR, Orange);
               ObjectSetInteger(0, this.label_tma_slope, OBJPROP_COLOR, Orange);
               ObjectSetInteger(0, this.label_tma_highest_slope, OBJPROP_COLOR, DarkGoldenrod);
            }
         }
      }

      void check_tma_below_cloud(void) {
         if (this.center_line_status == DOWN && this.lower_band_status == DOWN) {
            this.update_tma_slope(2);

            ObjectSetString(0, this.label_tma_slope, OBJPROP_TEXT, DoubleToStr(this.tma_slope*this.point_value*100, 0));
            ObjectSetString(0, this.label_tma_highest_slope, OBJPROP_TEXT, DoubleToStr(this.tma_highest_slope*this.point_value*100, 0));

            if (this.upper_band_status == DOWN) {
               ObjectSetString(0, this.label_tma, OBJPROP_TEXT, CharToStr(234));
               ObjectSetInteger(0, this.label_tma, OBJPROP_COLOR, Red);
               ObjectSetInteger(0, this.label_tma_slope, OBJPROP_COLOR, Red);
               ObjectSetInteger(0, this.label_tma_highest_slope, OBJPROP_COLOR, FireBrick);
            } else {
               ObjectSetString(0, this.label_tma, OBJPROP_TEXT, CharToStr(238));
               ObjectSetInteger(0, this.label_tma, OBJPROP_COLOR, Orange);
               ObjectSetInteger(0, this.label_tma_slope, OBJPROP_COLOR, Orange);
               ObjectSetInteger(0, this.label_tma_highest_slope, OBJPROP_COLOR, DarkGoldenrod);
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

      void check_highlighted(void) {
         this.highlighted = false;
      }

      double calculate_point_value(void) {
         if (MarketInfo(this.name, MODE_POINT) == 0.00001) return(10000);
         if (MarketInfo(this.name, MODE_POINT) == 0.001) return(100);
         return(MarketInfo(this.name, MODE_POINT)*100000);
      }

      bool create_labels(void) {
         if (ObjectFind(0, this.label_name) < 0) {
            if (ObjectCreate(0, this.label_name, OBJ_LABEL, 0, 0, 0)) {
               ObjectSetString(0, this.label_name, OBJPROP_FONT, Font);
               ObjectSetInteger(0, this.label_name, OBJPROP_FONTSIZE, FontSize);
               ObjectSetString(0, this.label_name, OBJPROP_TEXT, this.name);
               ObjectSetInteger(0, this.label_name, OBJPROP_COLOR, clrWhite);
               ObjectSetInteger(0, this.label_name, OBJPROP_CORNER, Corner);
               ObjectSetInteger(0, this.label_name, OBJPROP_XDISTANCE, DistanceX);
               ObjectSetInteger(0, this.label_name, OBJPROP_YDISTANCE, DistanceY+this.index*(FontSize+PaddingY));
               ObjectSetInteger(0, this.label_name, OBJPROP_SELECTABLE, false);
            } else {
               Print("Error ObjectCreate: ", GetLastError());
               return(false);
            }
         }

         if (ObjectFind(0, this.label_tma) < 0) {
            if (ObjectCreate(0, this.label_tma, OBJ_LABEL, 0, 0, 0)) {
               ObjectSetString(0, this.label_tma, OBJPROP_FONT, "Wingdings");
               ObjectSetInteger(0, this.label_tma, OBJPROP_FONTSIZE, FontSize);
               ObjectSetString(0, this.label_tma, OBJPROP_TEXT, CharToStr(232));
               ObjectSetInteger(0, this.label_tma, OBJPROP_COLOR, clrGray);
               ObjectSetInteger(0, this.label_tma, OBJPROP_CORNER, Corner);
               ObjectSetInteger(0, this.label_tma, OBJPROP_XDISTANCE, DistanceX+FontSize*6);
               ObjectSetInteger(0, this.label_tma, OBJPROP_YDISTANCE, DistanceY+this.index*(FontSize+PaddingY));
               ObjectSetInteger(0, this.label_tma, OBJPROP_SELECTABLE, false);
            } else {
               Print("Error ObjectCreate: ", GetLastError());
               return(false);
            }
         }

         if (ObjectFind(0, this.label_tma_slope) < 0) {
            if (ObjectCreate(0, this.label_tma_slope, OBJ_LABEL, 0, 0, 0)) {
               ObjectSetString(0, this.label_tma_slope, OBJPROP_FONT, Font);
               ObjectSetInteger(0, this.label_tma_slope, OBJPROP_FONTSIZE, FontSize);
               ObjectSetString(0, this.label_tma_slope, OBJPROP_TEXT, "--");
               ObjectSetInteger(0, this.label_tma_slope, OBJPROP_CORNER, Corner);
               ObjectSetInteger(0, this.label_tma_slope, OBJPROP_XDISTANCE, DistanceX+FontSize*9);
               ObjectSetInteger(0, this.label_tma_slope, OBJPROP_YDISTANCE, DistanceY+this.index*(FontSize+PaddingY));
               ObjectSetInteger(0, this.label_tma_slope, OBJPROP_SELECTABLE, false);
            } else {
               Print("Error ObjectCreate: ", GetLastError());
               return(false);
            }
         }

         if (ObjectFind(0, this.label_tma_highest_slope) < 0) {
            if (ObjectCreate(0, this.label_tma_highest_slope, OBJ_LABEL, 0, 0, 0)) {
               ObjectSetString(0, this.label_tma_highest_slope, OBJPROP_FONT, Font);
               ObjectSetInteger(0, this.label_tma_highest_slope, OBJPROP_FONTSIZE, FontSize);
               ObjectSetString(0, this.label_tma_highest_slope, OBJPROP_TEXT, "--");
               ObjectSetInteger(0, this.label_tma_highest_slope, OBJPROP_CORNER, Corner);
               ObjectSetInteger(0, this.label_tma_highest_slope, OBJPROP_XDISTANCE, DistanceX+FontSize*12);
               ObjectSetInteger(0, this.label_tma_highest_slope, OBJPROP_YDISTANCE, DistanceY+this.index*(FontSize+PaddingY));
               ObjectSetInteger(0, this.label_tma_highest_slope, OBJPROP_SELECTABLE, false);
            } else {
               Print("Error ObjectCreate: ", GetLastError());
               return(false);
            }
         }

         if (ObjectFind(0, this.label_spread) < 0) {
            if (ObjectCreate(0, this.label_spread, OBJ_LABEL, 0, 0, 0)) {
                ObjectSetString(0, this.label_spread, OBJPROP_FONT, Font);
                ObjectSetInteger(0, this.label_spread, OBJPROP_FONTSIZE, FontSize);
                ObjectSetString(0, this.label_spread, OBJPROP_TEXT, "--");
                ObjectSetInteger(0, this.label_spread, OBJPROP_COLOR, clrWhite);
                ObjectSetInteger(0, this.label_spread, OBJPROP_XDISTANCE, DistanceX+FontSize*15);
                ObjectSetInteger(0, this.label_spread, OBJPROP_YDISTANCE, DistanceY+this.index*(FontSize+PaddingY));
                ObjectSetInteger(0, this.label_spread, OBJPROP_SELECTABLE, false);
            } else {
                Print("Error ObjectCreate: ", GetLastError());
                return(false);
            }
         }

         return(true);
      }

      int index;
      string name;
      bool highlighted;

      double tma_slope;
      double tma_highest_slope;

      int center_line_status;
      int upper_band_status;
      int lower_band_status;

      double ichimoku_senkou_a;
      double ichimoku_senkou_b;
      double tma_center_line;
      double tma_upper_band;
      double tma_lower_band;

      long spread;

      double point_value;

      string label_name;
      string label_tma;
      string label_tma_slope;
      string label_tma_highest_slope;
      string label_spread;
};

//------------------------------------------------------------------------------

Pair *pairs[];
int pairs_size = 0;

//------------------------------------------------------------------------------

int OnInit() {
   IndicatorShortName(NAME);

   pairs_size = SymbolsTotal(true);

   ArrayResize(pairs, pairs_size);

   for (int i = 0; i < pairs_size; i++) {
       pairs[i] = new Pair(i, SymbolName(i, true));
   }

   return(0);
}

int deinit() {return(0);}

int start() {
   if (IndicatorCounted() < 0) return(-1);

   for (int i = 0; i < pairs_size; i++) {
      pairs[i].update();
   }

   return(0);
}
