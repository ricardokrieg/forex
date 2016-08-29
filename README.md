
```
#!c++

#property copyright "Ricardo Franco"
#property link      "ricardo.krieg@gmail.com"

#property indicator_chart_window

#define OBJECTS_PREFIX "TMAM1DASHBOARD"

#define UPPER_BAND 1
#define LOWER_BAND 2
#define CENTER_LINE 0

#define ONCLOUD 0
#define UP 1
#define DOWN 2

extern string Pairs = "EURJPY, GBPJPY, EURUSD, GBPUSD, AUDUSD, NZDUSD, USDCAD, GBPCHF,";
extern string MaxBarsToLeft = 30;
extern string VisualSettings = "Visual Settings";
extern int IconNeutral = 232;
extern color ColorNeutral = Gray;
extern int IconAnticipateUp = 236;
extern color ColorAnticipateUp = Orange;
extern int IconUp = 233;
extern color ColorUp = Lime;
extern int IconAnticipateDown = 238;
extern color ColorAnticipateDown = Orange;
extern int IconDown = 234;
extern color ColorDown = Red;
extern int FontSize = 20;
extern color ColorText = White;
extern int Corner = 0;
extern int DistanceX = 20;
extern int DistanceY = 20;

string pairs[20];
bool singlePair = false;
double tma_speed[20];
double tma_higher_speed[20];

int center_line_status[20];
int upper_band_status[20];
int lower_band_status[20];

double ichimoku_senkou_a = 0;
double ichimoku_senkou_b = 0;
double tma_center_line = 0;
double tma_upper_band = 0;
double tma_lower_band = 0;

int init() {
   extract_pairs();
   
   ArrayInitialize(tma_speed, 0);
   ArrayInitialize(tma_higher_speed, 0);
   ArrayInitialize(center_line_status, 0);
   ArrayInitialize(upper_band_status, 0);
   ArrayInitialize(lower_band_status, 0);
   
   int pairs_index = 0;   
   while (true) {
      string pair = pairs[pairs_index];
      if (pair == "") break;
      
      ObjectDelete(object_name("TMA", pair));
      ObjectDelete(object_name("TMA-Speed", pair));
      ObjectDelete(object_name("TMA-HigherSpeed", pair));
      ObjectDelete(object_name("Pair", pair));
            
      pairs_index++;
   }

   return(0);
}

int deinit() {
   ObjectsDeleteAll(0, OBJECTS_PREFIX, -1, -1);

   return(0);
}

int start() {
   if (IndicatorCounted() < 0) return(-1);

   int pairs_index = 0;
   while (true) {
      string pair = pairs[pairs_index];
      if (pair == "") break;
      
      calculate_indicators(pair, pairs_index);
      calculate_tma_status(pairs_index);

      create_labels(pair, pairs_index);
   
      calculate_tma_above_cloud(pair, pairs_index);
      calculate_tma_below_cloud(pair, pairs_index);
      
      pairs_index++;
   }
   
   return(0);
}

void calculate_indicators(string pair, int index) {
   ichimoku_senkou_a = iIchimoku(pair, PERIOD_M1, 9, 26, 52, MODE_SENKOUSPANA, 0);
   ichimoku_senkou_b = iIchimoku(pair, PERIOD_M1, 9, 26, 52, MODE_SENKOUSPANB, 0);

   tma_center_line = iCustom(pair, PERIOD_M1, "TMA", "M1", 20, PRICE_CLOSE, 2.0, 100, true, CENTER_LINE, 0);
   tma_upper_band = iCustom(pair, PERIOD_M1, "TMA", "M1", 20, PRICE_CLOSE, 2.0, 100, true, UPPER_BAND, 0);
   tma_lower_band = iCustom(pair, PERIOD_M1, "TMA", "M1", 20, PRICE_CLOSE, 2.0, 100, true, LOWER_BAND, 0);   
}

void calculate_tma_status(int index) {
   if (tma_upper_band > ichimoku_senkou_a && tma_upper_band > ichimoku_senkou_b) {
      upper_band_status[index] = UP;
   } else if (tma_upper_band < ichimoku_senkou_a && tma_upper_band < ichimoku_senkou_b) {
      upper_band_status[index] = DOWN;
   } else {
      upper_band_status[index] = ONCLOUD;
   }
   
   if (tma_lower_band > ichimoku_senkou_a && tma_lower_band > ichimoku_senkou_b) {
      lower_band_status[index] = UP;
   } else if (tma_lower_band < ichimoku_senkou_a && tma_lower_band < ichimoku_senkou_b) {
      lower_band_status[index] = DOWN;
   } else {
      lower_band_status[index] = ONCLOUD;
   }
   
   if (tma_center_line > ichimoku_senkou_a && tma_center_line > ichimoku_senkou_b) {
      center_line_status[index] = UP;   
   } else if (tma_center_line < ichimoku_senkou_a && tma_center_line < ichimoku_senkou_b) {
      center_line_status[index] = DOWN;
   } else {
      center_line_status[index] = ONCLOUD;
      tma_speed[index] = 0;
      tma_higher_speed[index] = 0;
   }
}

void calculate_tma_above_cloud(string pair, int index) {
   if (center_line_status[index] == UP && upper_band_status[index] == UP) {
      int shift = 1;
      bool valid_pattern = false;
      
      // this block is used to calculate TMA angle (here called speed)
      while (true) { 
         double ichimoku_senkou_a_for_angle = iIchimoku(pair, PERIOD_M1, 9, 26, 52, MODE_SENKOUSPANA, shift);
         double ichimoku_senkou_b_for_angle = iIchimoku(pair, PERIOD_M1, 9, 26, 52, MODE_SENKOUSPANB, shift);
         double tma_center_line_for_angle = iCustom(pair, PERIOD_M1, "TMA", "M1", 20, PRICE_CLOSE, 2.0, 100, true, CENTER_LINE, shift);

         // this is the time (shift) where center line is inside cloud
         // the speed/angle is calculated based on this time (of course this need to be changed)
         if (tma_center_line_for_angle < ichimoku_senkou_a_for_angle || tma_center_line_for_angle < ichimoku_senkou_b_for_angle) {
            tma_speed[index] = MathAbs((tma_center_line-tma_center_line_for_angle) / shift);
            tma_higher_speed[index] = MathMax(tma_speed[index], tma_higher_speed[index]);
            
            // here we count how many bars have passed since the center line was inside the cloud
            // this is used to determine if the TMA channel is crossing the cloud
            // the limit is 30 bars.
            // that means if the channel was not inside the cloud 30 bars ago, then its not a cross, so the pattern is invalid
            if (shift <= MaxBarsToLeft) {
               valid_pattern = true;
            }
            
            break;
         }

         shift++;
      }
      
      if (!valid_pattern) return;
      
      ObjectSetText(object_name("TMA-Speed", pair), DoubleToStr(tma_speed[index]*point_value(pair)*100, 0));
      ObjectSetText(object_name("TMA-HigherSpeed", pair), DoubleToStr(tma_higher_speed[index]*point_value(pair)*100, 0));
      
      if (lower_band_status[index] == UP) {
         ObjectSetText(object_name("TMA", pair), CharToStr(IconUp));
         ObjectSet(object_name("TMA", pair), OBJPROP_COLOR, ColorUp);
         ObjectSet(object_name("TMA-Speed", pair), OBJPROP_COLOR, ColorUp);
         ObjectSet(object_name("TMA-HigherSpeed", pair), OBJPROP_COLOR, ColorUp);
      } else {
         ObjectSetText(object_name("TMA", pair), CharToStr(IconAnticipateUp));
         ObjectSet(object_name("TMA", pair), OBJPROP_COLOR, ColorAnticipateUp);
         ObjectSet(object_name("TMA-Speed", pair), OBJPROP_COLOR, ColorAnticipateUp);
         ObjectSet(object_name("TMA-HigherSpeed", pair), OBJPROP_COLOR, ColorAnticipateUp);
      }
   }
}

void calculate_tma_below_cloud(string pair, int index) {
   if (center_line_status[index] == DOWN && lower_band_status[index] == DOWN) {
      int shift = 1;
      bool valid_pattern = false;
      
      while (true) { 
         double ichimoku_senkou_a_for_angle = iIchimoku(pair, PERIOD_M1, 9, 26, 52, MODE_SENKOUSPANA, shift);
         double ichimoku_senkou_b_for_angle = iIchimoku(pair, PERIOD_M1, 9, 26, 52, MODE_SENKOUSPANB, shift);
         double tma_center_line_for_angle = iCustom(pair, PERIOD_M1, "TMA", "M1", 20, PRICE_CLOSE, 2.0, 100, true, CENTER_LINE, shift);

         if (tma_center_line_for_angle > ichimoku_senkou_a_for_angle || tma_center_line_for_angle > ichimoku_senkou_b_for_angle) {
            tma_speed[index] = MathAbs((tma_center_line-tma_center_line_for_angle) / shift);
            tma_higher_speed[index] = MathMax(tma_speed[index], tma_higher_speed[index]);
            
            if (shift <= MaxBarsToLeft) {
               valid_pattern = true;
            }
            
            break;
         }

         shift++;
      }
      
      if (!valid_pattern) return;
      
      ObjectSetText(object_name("TMA-Speed", pair), DoubleToStr(tma_speed[index]*point_value(pair)*100, 0));
      ObjectSetText(object_name("TMA-HigherSpeed", pair), DoubleToStr(tma_higher_speed[index]*point_value(pair)*100, 0));
      
      if (upper_band_status[index] == DOWN) {
         ObjectSetText(object_name("TMA", pair), CharToStr(IconDown));
         ObjectSet(object_name("TMA", pair), OBJPROP_COLOR, ColorDown);
         ObjectSet(object_name("TMA-Speed", pair), OBJPROP_COLOR, ColorDown);
         ObjectSet(object_name("TMA-HigherSpeed", pair), OBJPROP_COLOR, ColorDown);
      } else {
         ObjectSetText(object_name("TMA", pair), CharToStr(IconAnticipateDown));
         ObjectSet(object_name("TMA", pair), OBJPROP_COLOR, ColorAnticipateDown);
         ObjectSet(object_name("TMA-Speed", pair), OBJPROP_COLOR, ColorAnticipateDown);
         ObjectSet(object_name("TMA-HigherSpeed", pair), OBJPROP_COLOR, ColorAnticipateDown);
      }
   }
}

void create_labels(string pair, int index) {
   if (ObjectFind(object_name("Pair", pair)) == -1) {
      ObjectCreate(object_name("Pair", pair), OBJ_LABEL, 0, 0, 0);
      ObjectSetText(object_name("Pair", pair), pair, FontSize);
      ObjectSet(object_name("Pair", pair), OBJPROP_COLOR, ColorText);
      ObjectSet(object_name("Pair", pair), OBJPROP_CORNER, Corner);
      ObjectSet(object_name("Pair", pair), OBJPROP_XDISTANCE, DistanceX);
      ObjectSet(object_name("Pair", pair), OBJPROP_YDISTANCE, DistanceY+(FontSize+15)*index);
   }

   if (ObjectFind(object_name("TMA", pair)) >= 0) {
      ObjectSetText(object_name("TMA", pair), CharToStr(IconNeutral));
      ObjectSet(object_name("TMA", pair), OBJPROP_COLOR, ColorNeutral);
   } else {
      ObjectCreate(object_name("TMA", pair), OBJ_LABEL, 0, 0, 0);
      ObjectSetText(object_name("TMA", pair), CharToStr(IconNeutral), FontSize, "Wingdings");
      ObjectSet(object_name("TMA", pair), OBJPROP_COLOR, ColorNeutral);
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
      ObjectSet(object_name("TMA-HigherSpeed", pair), OBJPROP_XDISTANCE, DistanceX+FontSize*11);
      ObjectSet(object_name("TMA-HigherSpeed", pair), OBJPROP_YDISTANCE, DistanceY+(FontSize+15)*index);
   }
}

void extract_pairs() {
    int string_find_start = 0;
    int pairs_index = 0;
    
    if (Pairs == "") {
       singlePair = true;
       pairs[0] = Symbol();
       pairs_index++;
    } else {
       while (true) {
           int index = StringFind(Pairs, ",", string_find_start);
           if (index == -1) break;
   
           pairs[pairs_index] = StringTrimRight(StringTrimLeft(StringSubstr(Pairs, string_find_start, index-string_find_start)));
   
           string_find_start = index+1;
           pairs_index++;
       }
    }
    
    pairs[pairs_index] = "";
}

string object_name(string name, string pair) {
   if (singlePair) {
      return(StringConcatenate(OBJECTS_PREFIX, ": ", name, " (", "Symbol", ")"));
   } else {
      return(StringConcatenate(OBJECTS_PREFIX, ": ", name, " (", pair, ")"));
   }
}

double point_value(string pair) {
   if (MarketInfo(pair, MODE_POINT) == 0.00001) return(10000);
   if (MarketInfo(pair, MODE_POINT) == 0.001) return(100);
   return(MarketInfo(pair, MODE_POINT)*100000);
}
```