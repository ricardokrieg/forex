#property copyright "Ricardo Franco"
#property link      "ricardo.krieg@gmail.com"

#property indicator_chart_window

#define UPPER_BAND 1
#define LOWER_BAND 2
#define CENTER_LINE 0

#define ONCLOUD 0
#define UP 1
#define DOWN 2

#define TDI_GREEN 4
#define TDI_RED 5

extern string Pairs = "EURJPY, GBPJPY, EURUSD, GBPUSD, AUDUSD, NZDUSD, USDCAD, GBPCHF,";
extern int FontSize = 20;
extern int Corner = 0;
extern int DistanceX = 20;
extern int DistanceY = 20;

string pairs[20];
double tma_speed[20];
double tma_higher_speed[20];
double tdi_distance[20];
double ivar_value[20];
double heiken_ashi_size[20];

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
   ArrayInitialize(tdi_distance, 0);
   ArrayInitialize(ivar_value, 0);
   ArrayInitialize(heiken_ashi_size, 0);
   
   int pairs_index = 0;   
   while (true) {
      string pair = pairs[pairs_index];
      if (pair == "") break;
      
      ObjectDelete(object_name("TMA", pair));
      ObjectDelete(object_name("TMA-Speed", pair));
      ObjectDelete(object_name("TMA-HigherSpeed", pair));
      ObjectDelete(object_name("Pair", pair));
      
      ObjectDelete(object_name("TDI", pair));
      ObjectDelete(object_name("IVAR", pair));
      ObjectDelete(object_name("HEIKEN-ASHI", pair));
      
      pairs_index++;
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
      
      calculate_indicators(pair, pairs_index);
      calculate_tma_status(pairs_index);

      create_labels(pair, pairs_index);
      draw_indicators(pair, pairs_index);
   
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
   
   //tdi_distance[index] = MathAbs(iCustom(pair, PERIOD_M1, "TDI Red Green", TDI_GREEN, 0) - iCustom(pair, PERIOD_M1, "TDI Red Green", TDI_RED, 0));
   ivar_value[index] = iCustom(pair, PERIOD_H1, "iVAR", 0, 0)*100;
   
   double heiken_ashi_open = iCustom(pair, PERIOD_H1, "Heiken Ashi", 3, 0);
   double heiken_ashi_close = iCustom(pair, PERIOD_H1, "Heiken Ashi", 2, 0);
   heiken_ashi_size[index] = (heiken_ashi_open - heiken_ashi_close)*point_value(pair);
}

void draw_indicators(string pair, int index) {
   //ObjectSetText(object_name("TDI", pair), DoubleToStr(tdi_distance[index], 5));
   
   if (ivar_value[index] >= 50) {
      ObjectSet(object_name("IVAR", pair), OBJPROP_COLOR, Red);
   }
   ObjectSetText(object_name("IVAR", pair), DoubleToStr(ivar_value[index], 0));
   
   if (heiken_ashi_size[index] < 0) {
      ObjectSet(object_name("HEIKEN-ASHI", pair), OBJPROP_COLOR, Red);
   }
   double abs_heiken_ashi = MathAbs(heiken_ashi_size[index]);
   if (abs_heiken_ashi < 10)
      ObjectSetText(object_name("HEIKEN-ASHI", pair), CharToStr(76));
   else if (abs_heiken_ashi < 30)
      ObjectSetText(object_name("HEIKEN-ASHI", pair), CharToStr(75));
   else
      ObjectSetText(object_name("HEIKEN-ASHI", pair), CharToStr(74));
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
      while (true) { 
         double ichimoku_senkou_a_for_angle = iIchimoku(pair, PERIOD_M1, 9, 26, 52, MODE_SENKOUSPANA, shift);
         double ichimoku_senkou_b_for_angle = iIchimoku(pair, PERIOD_M1, 9, 26, 52, MODE_SENKOUSPANB, shift);
         double tma_center_line_for_angle = iCustom(pair, PERIOD_M1, "TMA", "M1", 20, PRICE_CLOSE, 2.0, 100, true, CENTER_LINE, shift);

         if (tma_center_line_for_angle < ichimoku_senkou_a_for_angle || tma_center_line_for_angle < ichimoku_senkou_b_for_angle) {
            tma_speed[index] = MathAbs((tma_center_line-tma_center_line_for_angle) / shift);
            tma_higher_speed[index] = MathMax(tma_speed[index], tma_higher_speed[index]);
            break;
         }

         shift++;
      }
      
      ObjectSetText(object_name("TMA-Speed", pair), DoubleToStr(tma_speed[index]*point_value(pair)*100, 0));
      ObjectSetText(object_name("TMA-HigherSpeed", pair), DoubleToStr(tma_higher_speed[index]*point_value(pair)*100, 0));
      
      if (lower_band_status[index] == UP) {
         ObjectSetText(object_name("TMA", pair), CharToStr(233));
         ObjectSet(object_name("TMA", pair), OBJPROP_COLOR, Lime);
         ObjectSet(object_name("TMA-Speed", pair), OBJPROP_COLOR, Lime);
         ObjectSet(object_name("TMA-HigherSpeed", pair), OBJPROP_COLOR, ForestGreen);
      } else {
         ObjectSetText(object_name("TMA", pair), CharToStr(236));
         ObjectSet(object_name("TMA", pair), OBJPROP_COLOR, Orange);
         ObjectSet(object_name("TMA-Speed", pair), OBJPROP_COLOR, Orange);
         ObjectSet(object_name("TMA-HigherSpeed", pair), OBJPROP_COLOR, DarkGoldenrod);
      }
   }
}

void calculate_tma_below_cloud(string pair, int index) {
   if (center_line_status[index] == DOWN && lower_band_status[index] == DOWN) {
      int shift = 1;
      while (true) { 
         double ichimoku_senkou_a_for_angle = iIchimoku(pair, PERIOD_M1, 9, 26, 52, MODE_SENKOUSPANA, shift);
         double ichimoku_senkou_b_for_angle = iIchimoku(pair, PERIOD_M1, 9, 26, 52, MODE_SENKOUSPANB, shift);
         double tma_center_line_for_angle = iCustom(pair, PERIOD_M1, "TMA", "M1", 20, PRICE_CLOSE, 2.0, 100, true, CENTER_LINE, shift);

         if (tma_center_line_for_angle > ichimoku_senkou_a_for_angle || tma_center_line_for_angle > ichimoku_senkou_b_for_angle) {
            tma_speed[index] = MathAbs((tma_center_line-tma_center_line_for_angle) / shift);
            tma_higher_speed[index] = MathMax(tma_speed[index], tma_higher_speed[index]);
            break;
         }

         shift++;
      }
      
      ObjectSetText(object_name("TMA-Speed", pair), DoubleToStr(tma_speed[index]*point_value(pair)*100, 0));
      ObjectSetText(object_name("TMA-HigherSpeed", pair), DoubleToStr(tma_higher_speed[index]*point_value(pair)*100, 0));
      
      if (upper_band_status[index] == DOWN) {
         ObjectSetText(object_name("TMA", pair), CharToStr(234));
         ObjectSet(object_name("TMA", pair), OBJPROP_COLOR, Red);
         ObjectSet(object_name("TMA-Speed", pair), OBJPROP_COLOR, Red);
         ObjectSet(object_name("TMA-HigherSpeed", pair), OBJPROP_COLOR, FireBrick);
      } else {
         ObjectSetText(object_name("TMA", pair), CharToStr(238));
         ObjectSet(object_name("TMA", pair), OBJPROP_COLOR, Orange);
         ObjectSet(object_name("TMA-Speed", pair), OBJPROP_COLOR, Orange);
         ObjectSet(object_name("TMA-HigherSpeed", pair), OBJPROP_COLOR, DarkGoldenrod);
      }
   }
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
      ObjectSet(object_name("TMA-HigherSpeed", pair), OBJPROP_XDISTANCE, DistanceX+FontSize*11);
      ObjectSet(object_name("TMA-HigherSpeed", pair), OBJPROP_YDISTANCE, DistanceY+(FontSize+15)*index);
   }
   
   if (ObjectFind(object_name("IVAR", pair)) >= 0) {
      ObjectSetText(object_name("IVAR", pair), "");
      ObjectSet(object_name("IVAR", pair), OBJPROP_COLOR, White);
   } else {
      ObjectCreate(object_name("IVAR", pair), OBJ_LABEL, 0, 0, 0);
      ObjectSetText(object_name("IVAR", pair), "", FontSize);
      ObjectSet(object_name("IVAR", pair), OBJPROP_COLOR, White);
      ObjectSet(object_name("IVAR", pair), OBJPROP_CORNER, Corner);
      ObjectSet(object_name("IVAR", pair), OBJPROP_XDISTANCE, DistanceX+FontSize*13);
      ObjectSet(object_name("IVAR", pair), OBJPROP_YDISTANCE, DistanceY+(FontSize+15)*index);
   }
   
   if (ObjectFind(object_name("HEIKEN-ASHI", pair)) >= 0) {
      ObjectSetText(object_name("HEIKEN-ASHI", pair), "", FontSize, "Wingdings");
      ObjectSet(object_name("HEIKEN-ASHI", pair), OBJPROP_COLOR, White);
   } else {
      ObjectCreate(object_name("HEIKEN-ASHI", pair), OBJ_LABEL, 0, 0, 0);
      ObjectSetText(object_name("HEIKEN-ASHI", pair), "", FontSize);
      ObjectSet(object_name("HEIKEN-ASHI", pair), OBJPROP_COLOR, White);
      ObjectSet(object_name("HEIKEN-ASHI", pair), OBJPROP_CORNER, Corner);
      ObjectSet(object_name("HEIKEN-ASHI", pair), OBJPROP_XDISTANCE, DistanceX+FontSize*15);
      ObjectSet(object_name("HEIKEN-ASHI", pair), OBJPROP_YDISTANCE, DistanceY+(FontSize+15)*index);
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