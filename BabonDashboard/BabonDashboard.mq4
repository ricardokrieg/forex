#property copyright "Ricardo Franco"
#property link      "ricardo.krieg@gmail.com"
#property strict
#property indicator_chart_window

#define CENTER_LINE 0
#define UPPER_BAND 1
#define LOWER_BAND 2

#define ONCLOUD 0
#define UP 1
#define DOWN 2

#define NAME "BabonDashboard"

//------------------------------------------------------------------------------

extern int SlopeBars = 20;
extern int SpreadThreshold = 10;
extern string Font = "Arial";
extern int FontSize = 16;
extern int Corner = 0;
extern int DistanceX = 20;
extern int DistanceY = 20;
extern int PaddingY = 6;

//------------------------------------------------------------------------------

color SpreadColor = clrWhite;
color BadSpreadColor = clrRed;

//------------------------------------------------------------------------------

class Pair {
   public:
      Pair(int i, string n) {
         this.index = i;
         this.name = n;
         this.highlighted = false;
         this.point_value = this.calculate_point_value();

         this.label_name = StringConcatenate(NAME, this.name);
         this.label_star = StringConcatenate(this.label_name, "STAR");
         this.label_tma = StringConcatenate(this.label_name, "TMA");
         this.label_tma_slope = StringConcatenate(this.label_name, "SLOPE");
         this.label_tma_highest_slope = StringConcatenate(this.label_name, "HIGHESTSLOPE");
         this.label_spread = StringConcatenate(this.label_name, "SPREAD");
      }

      void update(void) {
         this.update_spread();

         this.update_ichimoku();
         this.update_tma();
         this.update_tma_status();

         this.draw();
      }

      void draw(void) {
         if (!this.create_labels()) return;

         this.draw_spread();

         bool on_cloud = true;

         if (this.check_tma_above_cloud()) on_cloud = false;
         if (this.check_tma_below_cloud()) on_cloud = false;

         if (on_cloud) {
            ObjectSetInteger(0, this.label_star, OBJPROP_COLOR, clrBlack);
            ObjectSetString(0, this.label_tma, OBJPROP_TEXT, CharToStr(232));
            ObjectSetInteger(0, this.label_tma, OBJPROP_COLOR, clrGray);
            ObjectSetInteger(0, this.label_tma_slope, OBJPROP_COLOR, clrGray);
            ObjectSetInteger(0, this.label_tma_highest_slope, OBJPROP_COLOR, clrGray);
            ObjectSetString(0, this.label_tma_slope, OBJPROP_TEXT, "--");
            ObjectSetString(0, this.label_tma_highest_slope, OBJPROP_TEXT, "--");
         }
      }

      void update_spread(void) {
         this.spread = SymbolInfoInteger(this.name, SYMBOL_SPREAD);
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

      void draw_spread(void) {
         if (this.spread <= SpreadThreshold) {
            ObjectSetInteger(0, this.label_spread, OBJPROP_COLOR, SpreadColor);
         } else {
            ObjectSetInteger(0, this.label_spread, OBJPROP_COLOR, BadSpreadColor);
         }

         ObjectSetString(0, this.label_spread, OBJPROP_TEXT, IntegerToString(this.spread, 2));
      }

      bool check_tma_above_cloud(void) {
         if (this.center_line_status == UP && this.upper_band_status == UP) {
            this.update_tma_slope(1);

            string tma_slope_value = DoubleToStr(this.tma_slope*this.point_value*100, 0);
            string tma_highest_slope_value = DoubleToStr(this.tma_highest_slope*this.point_value*100, 0);

            ObjectSetString(0, this.label_tma_slope, OBJPROP_TEXT, tma_slope_value);
            ObjectSetString(0, this.label_tma_highest_slope, OBJPROP_TEXT, tma_highest_slope_value);

            if (this.lower_band_status == UP) {
               if (StringCompare(tma_slope_value, tma_highest_slope_value) == 0)
                  ObjectSetInteger(0, this.label_star, OBJPROP_COLOR, clrLime);
               else
                  ObjectSetInteger(0, this.label_star, OBJPROP_COLOR, clrBlack);

               ObjectSetString(0, this.label_tma, OBJPROP_TEXT, CharToStr(233));
               ObjectSetInteger(0, this.label_tma, OBJPROP_COLOR, clrLime);
               ObjectSetInteger(0, this.label_tma_slope, OBJPROP_COLOR, clrLime);
               ObjectSetInteger(0, this.label_tma_highest_slope, OBJPROP_COLOR, clrForestGreen);
            } else {
               if (StringCompare(tma_slope_value, tma_highest_slope_value) == 0)
                  ObjectSetInteger(0, this.label_star, OBJPROP_COLOR, clrGreen);
               else
                  ObjectSetInteger(0, this.label_star, OBJPROP_COLOR, clrBlack);

               ObjectSetString(0, this.label_tma, OBJPROP_TEXT, CharToStr(236));
               ObjectSetInteger(0, this.label_tma, OBJPROP_COLOR, clrOrange);
               ObjectSetInteger(0, this.label_tma_slope, OBJPROP_COLOR, clrOrange);
               ObjectSetInteger(0, this.label_tma_highest_slope, OBJPROP_COLOR, clrDarkGoldenrod);
            }

            return true;
         }

         return false;
      }

      bool check_tma_below_cloud(void) {
         if (this.center_line_status == DOWN && this.lower_band_status == DOWN) {
            this.update_tma_slope(2);

            string tma_slope_value = DoubleToStr(this.tma_slope*this.point_value*100, 0);
            string tma_highest_slope_value = DoubleToStr(this.tma_highest_slope*this.point_value*100, 0);

            ObjectSetString(0, this.label_tma_slope, OBJPROP_TEXT, tma_slope_value);
            ObjectSetString(0, this.label_tma_highest_slope, OBJPROP_TEXT, tma_highest_slope_value);

            if (this.upper_band_status == DOWN) {
               if (StringCompare(tma_slope_value, tma_highest_slope_value) == 0)
                  ObjectSetInteger(0, this.label_star, OBJPROP_COLOR, clrRed);
               else
                  ObjectSetInteger(0, this.label_star, OBJPROP_COLOR, clrBlack);

               ObjectSetString(0, this.label_tma, OBJPROP_TEXT, CharToStr(234));
               ObjectSetInteger(0, this.label_tma, OBJPROP_COLOR, clrRed);
               ObjectSetInteger(0, this.label_tma_slope, OBJPROP_COLOR, clrRed);
               ObjectSetInteger(0, this.label_tma_highest_slope, OBJPROP_COLOR, clrFireBrick);
            } else {
               if (StringCompare(tma_slope_value, tma_highest_slope_value) == 0)
                  ObjectSetInteger(0, this.label_star, OBJPROP_COLOR, clrFireBrick);
               else
                  ObjectSetInteger(0, this.label_star, OBJPROP_COLOR, clrBlack);

               ObjectSetString(0, this.label_tma, OBJPROP_TEXT, CharToStr(238));
               ObjectSetInteger(0, this.label_tma, OBJPROP_COLOR, clrOrange);
               ObjectSetInteger(0, this.label_tma_slope, OBJPROP_COLOR, clrOrange);
               ObjectSetInteger(0, this.label_tma_highest_slope, OBJPROP_COLOR, clrDarkGoldenrod);
            }

            return true;
         }

         return false;
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

            // // UP
            // if (direction == 1) {
            //    if (tma_center_line_for_angle < ichimoku_senkou_a_for_angle || tma_center_line_for_angle < ichimoku_senkou_b_for_angle)
            //       break;
            // // DOWN
            // } else if (direction == 2) {
            //    if (tma_center_line_for_angle > ichimoku_senkou_a_for_angle || tma_center_line_for_angle > ichimoku_senkou_b_for_angle)
            //       break;
            // }

            if (shift++ >= SlopeBars) break;
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
         if (ObjectFind(0, this.label_star) < 0) {
            if (ObjectCreate(0, this.label_star, OBJ_LABEL, 0, 0, 0)) {
               ObjectSetString(0, this.label_star, OBJPROP_FONT, "Wingdings");
               ObjectSetInteger(0, this.label_star, OBJPROP_FONTSIZE, FontSize);
               ObjectSetString(0, this.label_star, OBJPROP_TEXT, CharToStr(171));
               ObjectSetInteger(0, this.label_star, OBJPROP_COLOR, clrBlack);
               ObjectSetInteger(0, this.label_star, OBJPROP_CORNER, Corner);
               ObjectSetInteger(0, this.label_star, OBJPROP_XDISTANCE, DistanceX);
               ObjectSetInteger(0, this.label_star, OBJPROP_YDISTANCE, DistanceY+this.index*(FontSize+PaddingY));
               ObjectSetInteger(0, this.label_star, OBJPROP_SELECTABLE, false);
            } else {
               Print("Error ObjectCreate: ", GetLastError());
               return(false);
            }
         }

         if (ObjectFind(0, this.label_name) < 0) {
            if (ObjectCreate(0, this.label_name, OBJ_LABEL, 0, 0, 0)) {
               ObjectSetString(0, this.label_name, OBJPROP_FONT, Font);
               ObjectSetInteger(0, this.label_name, OBJPROP_FONTSIZE, FontSize);
               ObjectSetString(0, this.label_name, OBJPROP_TEXT, this.name);
               ObjectSetInteger(0, this.label_name, OBJPROP_COLOR, clrWhite);
               ObjectSetInteger(0, this.label_name, OBJPROP_CORNER, Corner);
               ObjectSetInteger(0, this.label_name, OBJPROP_XDISTANCE, DistanceX+FontSize*2);
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
               ObjectSetInteger(0, this.label_tma, OBJPROP_XDISTANCE, DistanceX+FontSize*8);
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
               ObjectSetInteger(0, this.label_tma_slope, OBJPROP_XDISTANCE, DistanceX+FontSize*11);
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
               ObjectSetInteger(0, this.label_tma_highest_slope, OBJPROP_XDISTANCE, DistanceX+FontSize*14);
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
                ObjectSetInteger(0, this.label_spread, OBJPROP_COLOR, SpreadColor);
                ObjectSetInteger(0, this.label_spread, OBJPROP_XDISTANCE, DistanceX+FontSize*17);
                ObjectSetInteger(0, this.label_spread, OBJPROP_YDISTANCE, DistanceY+this.index*(FontSize+PaddingY));
                ObjectSetInteger(0, this.label_spread, OBJPROP_SELECTABLE, false);
            } else {
                Print("Error ObjectCreate: ", GetLastError());
                return(false);
            }
         }

         return(true);
      }

      void destroy_labels(void) {
         if (ObjectFind(0, this.label_star) >= 0) {
            if (!ObjectDelete(0, this.label_star)) {
               Print("Error ObjectDelete: ", GetLastError());
            }
         }

         if (ObjectFind(0, this.label_name) >= 0) {
            if (!ObjectDelete(0, this.label_name)) {
               Print("Error ObjectDelete: ", GetLastError());
            }
         }

         if (ObjectFind(0, this.label_tma) >= 0) {
            if (!ObjectDelete(0, this.label_tma)) {
               Print("Error ObjectDelete: ", GetLastError());
            }
         }

         if (ObjectFind(0, this.label_tma_slope) >= 0) {
            if (!ObjectDelete(0, this.label_tma_slope)) {
               Print("Error ObjectDelete: ", GetLastError());
            }
         }

         if (ObjectFind(0, this.label_tma_highest_slope) >= 0) {
            if (!ObjectDelete(0, this.label_tma_highest_slope)) {
               Print("Error ObjectDelete: ", GetLastError());
            }
         }

         if (ObjectFind(0, this.label_spread) >= 0) {
            if (!ObjectDelete(0, this.label_spread)) {
               Print("Error ObjectDelete: ", GetLastError());
            }
         }
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
      string label_star;
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

int deinit() {
   for (int i = 0; i < pairs_size; i++) {
      pairs[i].destroy_labels();
   }

   return(0);
}

int start() {
   if (IndicatorCounted() < 0) return(-1);

   for (int i = 0; i < pairs_size; i++) {
      pairs[i].update();
   }

   return(0);
}
