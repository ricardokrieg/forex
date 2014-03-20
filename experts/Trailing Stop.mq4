#property copyright "Copyright © 2009-2013, EarnForex.com"
#property link      "http://www.earnforex.com"

extern double TakeProfit = 4;
extern double StopLoss = 6;

int init() {
   return(0);
}

int deinit() {
   return(0);
}

int start() {
  double PointValue;

  for (int i = 0; i < OrdersTotal(); i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);

      //Calculate the point value in case there are extra digits in the quotes
      if (MarketInfo(OrderSymbol(), MODE_POINT) == 0.00001) PointValue = 0.0001;
      else if (MarketInfo(OrderSymbol(), MODE_POINT) == 0.001) PointValue = 0.01;
      else PointValue = MarketInfo(OrderSymbol(), MODE_POINT);

      double take_profit = TakeProfit * PointValue;
      double stop_loss = StopLoss * PointValue;

      double buy_stop_loss_value = OrderOpenPrice() - stop_loss;
      double sell_stop_loss_value = OrderOpenPrice() + stop_loss;

      if (OrderType() == OP_BUY) {
         if (OrderStopLoss() == 0) {
            if (!OrderModify(OrderTicket(), OrderOpenPrice(), buy_stop_loss_value, OrderTakeProfit(), Red))
               Print("Error setting Buy stop-loss: ", GetLastError());
         }

         if (Bid - OrderOpenPrice() >= take_profit) {
            if (OrderStopLoss() < Bid - take_profit) {
               if (!OrderModify(OrderTicket(), OrderOpenPrice(), Bid - take_profit, OrderTakeProfit(), Red))
                  Print("Error setting Buy trailing stop: ", GetLastError());
            }
         }
      } else if (OrderType() == OP_SELL) {
         if (OrderStopLoss() == 0) {
            if (!OrderModify(OrderTicket(), OrderOpenPrice(), sell_stop_loss_value, OrderTakeProfit(), Red))
               Print("Error setting Sell stop-loss: ", GetLastError());
         }

         if (OrderOpenPrice() - Ask > take_profit) {
            if (OrderStopLoss() > Ask + take_profit) {
               if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ask + take_profit, OrderTakeProfit(), Red))
                  Print("Error setting Sell trailing stop: ", GetLastError());
            }
         }
      }
	}

   return(0);
}
