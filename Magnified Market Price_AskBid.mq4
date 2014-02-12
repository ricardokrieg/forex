//+------------------------------------------------------------------+
//| Magnified Market Price.mq4        ver1.4             by Habeeb   |
//+------------------------------------------------------------------+

#property indicator_chart_window

  extern string note1 = "Change font colors automatically? True = Yes";
  extern bool   Bid_Ask_Colors = false;
  extern string note2 = "Default Font Color";
  extern color  FontColor = White;
  extern string note3 = "Font Size";
  extern int    FontSize=20;
  extern string note4 = "Font Type";
  extern string FontType="Comic Sans MS";
  extern string note5 = "Display the price in what corner?";
  extern string note6 = "Upper left=0; Upper right=1";
  extern string note7 = "Lower left=2; Lower right=3";
  extern int    WhatCorner=3;

  double        Old_Price_Ask;
  double        Old_Price_Bid;
  color  FontColorAsk;
  color  FontColorBid;

int init()
  {
   FontColorAsk = FontColor;
   FontColorBid = FontColor;
   
   ObjectCreate("Market_Price_Ask", OBJ_LABEL, 1, 0, 0);   
   ObjectSet("Market_Price_Ask", OBJPROP_CORNER, WhatCorner);

   ObjectCreate("Market_Price_Bid", OBJ_LABEL, 1, 0, 0);   
   ObjectSet("Market_Price_Bid", OBJPROP_CORNER, WhatCorner);


   switch(WhatCorner) {
   case 0:
   case 1:
      ObjectSet("Market_Price_Ask", OBJPROP_XDISTANCE, 5);
      ObjectSet("Market_Price_Ask", OBJPROP_YDISTANCE, 1);
      ObjectSet("Market_Price_Bid", OBJPROP_XDISTANCE, 5);
      ObjectSet("Market_Price_Bid", OBJPROP_YDISTANCE, 1+FontSize+5);
      break;
   case 2:
   case 3:
      ObjectSet("Market_Price_Ask", OBJPROP_XDISTANCE, 5);
      ObjectSet("Market_Price_Ask", OBJPROP_YDISTANCE, 1+FontSize+5);
      ObjectSet("Market_Price_Bid", OBJPROP_XDISTANCE, 5);
      ObjectSet("Market_Price_Bid", OBJPROP_YDISTANCE, 1);
      break;
   }   
   
   return(0);
  }

int deinit()
  {
  ObjectDelete("Market_Price_Ask"); 
  ObjectDelete("Market_Price_Bid"); 
  
  return(0);
  }

int start()
  {
   if (Bid_Ask_Colors == True)
   {
    if (Ask > Old_Price_Ask) FontColorAsk = LawnGreen;
    if (Bid < Old_Price_Ask) FontColorAsk = Red;
    Old_Price_Ask = Ask;
    if (Bid > Old_Price_Bid) FontColorBid = LawnGreen;
    if (Bid < Old_Price_Bid) FontColorBid = Red;
    Old_Price_Bid = Bid;
   }
   
   string Price_Ask = DoubleToStr(Ask, Digits);
   string Price_Bid = DoubleToStr(Bid, Digits);
  
   ObjectSetText("Market_Price_Ask", Price_Ask, FontSize, FontType, FontColorAsk);
   ObjectSetText("Market_Price_Bid", Price_Bid, FontSize, FontType, FontColorBid);

  }