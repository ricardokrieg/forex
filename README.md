#property copyright "Ricardo Franco"
#property link      "ricardo.krieg@gmail.com"
#property version   "1.1"

#property indicator_chart_window

#define OBJECTS_PREFIX "TMAM1DASHBOARD"

#define UPPER_BAND 1
#define LOWER_BAND 2
#define CENTER_LINE 0

#define ONCLOUD         0
#define UP              1
#define DOWN            2
#define ANTICIPATE_UP   3
#define ANTICIPATE_DOWN 4

#define TMA_SLOPE_TRUE_BUFFER 6
#define PARAM_01 ""
#define PARAM_02 1
#define PARAM_03 5
#define PARAM_04 42
#define PARAM_05 "Verdana"
#define PARAM_06 12
#define PARAM_07 3
#define PARAM_08 White
#define PARAM_09 Green
#define PARAM_10 Red
#define PARAM_11 20
#define PARAM_12 0.4
#define PARAM_13 -0.4
#define PARAM_14 100
#define PARAM_15 5
#define PARAM_16 22
#define PARAM_17 3
#define PARAM_18 12
#define PARAM_19 12
#define PARAM_20 5
#define PARAM_21 2
#define PARAM_22 3

extern string Pairs = "EURJPY, GBPJPY, EURUSD, GBPUSD, AUDUSD, NZDUSD, USDCAD, GBPCHF,";
extern string AlertSettings = "Alert Settings";
extern bool EnableAlert = true;
extern bool EnableAnticipateAlert = true;
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
double tma_slope[20];
string tma_slope_text[20];

int center_line_status[20];
int upper_band_status[20];
int lower_band_status[20];

int previous_tma_status[20] = {-1};
datetime last_alert[20] = {-1};

double ichimoku_senkou_a = 0;
double ichimoku_senkou_b = 0;
double tma_center_line = 0;
double tma_upper_band = 0;
double tma_lower_band = 0;

int init() {
   extract_pairs();

   ArrayInitialize(tma_slope, 0);
   ArrayInitialize(center_line_status, 0);
   ArrayInitialize(upper_band_status, 0);
   ArrayInitialize(lower_band_status, 0);

   int pairs_index = 0;   
   while (true) {
      string pair = pairs[pairs_index];
      if (pair == "") break;

      ObjectDelete(object_name("TMA", pair));
      ObjectDelete(object_name("TMA-Slope", pair));
      ObjectDelete(object_name("TMA-SlopeText", pair));
      ObjectDelete(object_name("Pair", pair));
      
      last_alert[pairs_index] = TimeCurrent();

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
      
      // calculate_tma_angle(pair, pairs_index);
      calculate_tma_angle_using_tma_slope_true(pair, pairs_index);

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
      tma_slope[index] = 0;
      tma_slope_text[index] = "-";
   }
}

void calculate_tma_above_cloud(string pair, int index) {
   if (center_line_status[index] == UP && upper_band_status[index] == UP) {
      int shift = 1;

      if (lower_band_status[index] == UP) {
         ObjectSetText(object_name("TMA", pair), CharToStr(IconUp));
         ObjectSet(object_name("TMA", pair), OBJPROP_COLOR, ColorUp);
         
         call_alert_up(pair, index);
         previous_tma_status[index] = UP;
      } else {
         ObjectSetText(object_name("TMA", pair), CharToStr(IconAnticipateUp));
         ObjectSet(object_name("TMA", pair), OBJPROP_COLOR, ColorAnticipateUp);
         
         call_alert_anticipate_up(pair, index);
         previous_tma_status[index] = ANTICIPATE_UP;
      }
   }
}

void calculate_tma_below_cloud(string pair, int index) {
   if (center_line_status[index] == DOWN && lower_band_status[index] == DOWN) {
      int shift = 1;
      
      if (upper_band_status[index] == DOWN) {
         ObjectSetText(object_name("TMA", pair), CharToStr(IconDown));
         ObjectSet(object_name("TMA", pair), OBJPROP_COLOR, ColorDown);
         
         call_alert_down(pair, index);
         previous_tma_status[index] = DOWN;
      } else {
         ObjectSetText(object_name("TMA", pair), CharToStr(IconAnticipateDown));
         ObjectSet(object_name("TMA", pair), OBJPROP_COLOR, ColorAnticipateDown);
         
         call_alert_anticipate_down(pair, index);
         previous_tma_status[index] = ANTICIPATE_DOWN;
      }
   }
}

void calculate_tma_angle(string pair, int index) {
   int shift = 1;
   double angle, price1, price2 = 0;
   int angle_shift = 15;
   double screen_factor = 3.0;
   double pips_per_screen = 0.0012600;
   double bars_per_screen = 207;

   double tma_center_line_for_angle = iCustom(pair, PERIOD_M1, "TMA", "M1", 20, PRICE_CLOSE, 2.0, 100, true, CENTER_LINE, angle_shift);
   price1 = tma_center_line;
   price2 = tma_center_line_for_angle;
      
   if (price1 != price2 && WindowPriceMax() != WindowPriceMin() && WindowBarsPerChart() != 0) {
      printf("%f %f %d # %f %f %d", price1, price2, angle_shift, WindowPriceMax(), WindowPriceMin(), WindowBarsPerChart());
      
      pips_per_screen = WindowPriceMax() - WindowPriceMin();
      
      angle = MathArctan(MathTan(
         ((price1-price2)/(pips_per_screen*screen_factor))
         /
         (angle_shift/((double)bars_per_screen))
      )) * 180/3.14;
            
      printf("ANGLE = %f", angle);
   }
}

void calculate_tma_angle_using_tma_slope_true(string pair, int index) {
   //double tma_slope_value = iCustom(pair, PERIOD_M1, "10.2 TMA slope true 4.30", 1, TMA_SLOPE_TRUE_BUFFER, 0);
   double tma_slope_value = tma_slope_true_custom_call(pair, TMA_SLOPE_TRUE_BUFFER);

   int tma_slope_buffer = -1;
   
   for (int i=0; i<=5; i++) {
      //double tma_slope_for_buffer = iCustom(pair, PERIOD_M1, "10.2 TMA slope true 4.30", 1, i, 0);
      double tma_slope_for_buffer = tma_slope_true_custom_call(pair, i);
      
      if (tma_slope_for_buffer != 0.0) {
         tma_slope_buffer = i;
         break;
      }
   }
   
   string tma_slope_direction = "Ranging";
   if (tma_slope_buffer == 0 || tma_slope_buffer == 1) {
      tma_slope_direction = "Buy Only";
      ObjectSet(object_name("TMA-Slope", pair), OBJPROP_COLOR, ColorUp);
      ObjectSet(object_name("TMA-SlopeText", pair), OBJPROP_COLOR, ColorUp);
   } else if (tma_slope_buffer == 2 || tma_slope_buffer == 3) {
      tma_slope_direction = "Sell Only";
      ObjectSet(object_name("TMA-Slope", pair), OBJPROP_COLOR, ColorDown);
      ObjectSet(object_name("TMA-SlopeText", pair), OBJPROP_COLOR, ColorDown);
   } else {
      ObjectSet(object_name("TMA-Slope", pair), OBJPROP_COLOR, ColorNeutral);
      ObjectSet(object_name("TMA-SlopeText", pair), OBJPROP_COLOR, ColorNeutral);
   }
   
   ObjectSet(object_name("TMA-SlopeText", pair), OBJPROP_COLOR, CLR_NONE);
   
   tma_slope[index] = tma_slope_value;
   tma_slope_text[index] = tma_slope_direction;
   
   ObjectSetText(object_name("TMA-Slope", pair), DoubleToStr(tma_slope_value, 2));
   ObjectSetText(object_name("TMA-SlopeText", pair), tma_slope_direction);
   
   //printf("TMA Slope (%d)(%s): %.2f", tma_slope_buffer, tma_slope_direction, tma_slope_value);
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

   if (ObjectFind(object_name("TMA-Slope", pair)) >= 0) {
      ObjectSetText(object_name("TMA-Slope", pair), "");
   } else {
      ObjectCreate(object_name("TMA-Slope", pair), OBJ_LABEL, 0, 0, 0);
      ObjectSetText(object_name("TMA-Slope", pair), "", FontSize);
      ObjectSet(object_name("TMA-Slope", pair), OBJPROP_CORNER, Corner);
      ObjectSet(object_name("TMA-Slope", pair), OBJPROP_XDISTANCE, DistanceX+FontSize*9);
      ObjectSet(object_name("TMA-Slope", pair), OBJPROP_YDISTANCE, DistanceY+(FontSize+15)*index);
   }

   if (ObjectFind(object_name("TMA-SlopeText", pair)) >= 0) {
      ObjectSetText(object_name("TMA-SlopeText", pair), "");
   } else {
      ObjectCreate(object_name("TMA-SlopeText", pair), OBJ_LABEL, 0, 0, 0);
      ObjectSetText(object_name("TMA-SlopeText", pair), "", FontSize);
      ObjectSet(object_name("TMA-SlopeText", pair), OBJPROP_CORNER, Corner);
      ObjectSet(object_name("TMA-SlopeText", pair), OBJPROP_XDISTANCE, DistanceX+FontSize*13);
      ObjectSet(object_name("TMA-SlopeText", pair), OBJPROP_YDISTANCE, DistanceY+(FontSize+15)*index);
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

double tma_slope_true_custom_call(string pair, int buffer) {
   return iCustom(
      pair, PERIOD_M1, "10.2 TMA slope true 4.30",
      PARAM_01, PARAM_02, PARAM_03, PARAM_04, PARAM_05, 
      PARAM_06, PARAM_07, PARAM_08, PARAM_09, PARAM_10, 
      PARAM_11, PARAM_12, PARAM_13, PARAM_14, PARAM_15, 
      PARAM_16, PARAM_17, PARAM_18, PARAM_19, PARAM_20, 
      PARAM_21, PARAM_22,
      buffer, 0);
}

void call_alert_up(string pair, int index) {
   //printf("call_alert_up [time_diff=%d][previous=%d]", time_diff(index), previous_tma_status[index]);

   if (previous_tma_status[index] != UP) {
      if (valid_alert(index)) {
         call_alert(pair, "UP");
      }
   }
}

void call_alert_anticipate_up(string pair, int index) {
   //printf("call_alert_anticipate_up [time_diff=%d][previous=%d]", time_diff(index), previous_tma_status[index]);
   
   if (previous_tma_status[index] != UP && previous_tma_status[index] != ANTICIPATE_UP) {
      if (valid_alert(index)) {
         call_alert(pair, "ANTICIPATE_UP");
      }
   }
}

void call_alert_down(string pair, int index) {
   //printf("call_alert_down [time_diff=%d][previous=%d]", time_diff(index), previous_tma_status[index]);

   if (previous_tma_status[index] != DOWN) {
      if (valid_alert(index)) {
         call_alert(pair, "DOWN");
      }
   }
}

void call_alert_anticipate_down(string pair, int index) {
   //printf("call_alert_anticipate_down [time_diff=%d][previous=%d]", time_diff(index), previous_tma_status[index]);

   if (previous_tma_status[index] != DOWN && previous_tma_status[index] != ANTICIPATE_DOWN) {
      if (valid_alert(index)) {
         call_alert(pair, "ANTICIPATE_DOWN");
      }
   }
}

void call_alert(string pair, string status) {
   Alert(pair, "    ", status);
}

int time_diff(int index) {
   return TimeCurrent() - last_alert[index];
}

bool valid_alert(int index) {
   return time_diff(index) >= 120;
}