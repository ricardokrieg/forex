#property copyright "Krieg Corp"
#property link      "http://www.kriegcorp.com"

extern double TakeProfit = 4;
extern double StopLoss = 4;
extern double LotSize = 0.01;

int init(){return(0);}
int deinit(){return(0);}

double calculate_point_value() {
    if (MarketInfo(Symbol(), MODE_POINT) == 0.00001) return(0.0001);
    if (MarketInfo(Symbol(), MODE_POINT) == 0.001) return(0.01);
    return(MarketInfo(Symbol(), MODE_POINT));
}

int start() {
    if (OrdersTotal() == 0) {
        double point_value = calculate_point_value();

        double take_profit = TakeProfit * point_value;
        double stop_loss = StopLoss * point_value;

        while (true) {
            int buy_ticket = OrderSend(Symbol(), OP_BUY, LotSize, Ask, 3, Ask-stop_loss, 0);
            if (buy_ticket < 0) {
                Print("ERROR: Can't create Buy Order! code #", GetLastError());

                if (GetLastError() == 129) {
                    Print("Retry...");
                    continue;
                } else {
                    return(false);
                }
            }

            break;
        }
        if (!ObjectCreate("TPBuy", OBJ_HLINE, 0, 0, Ask+take_profit)) {
            Print("ERROR: Can't create Buy TakeProfit Line! code #", GetLastError());
            return(false);
        }
        if (!ObjectSet("TPBuy", OBJPROP_COLOR, DodgerBlue)) {
            Print("ERROR: Can't set Buy TakeProfit Color! code #", GetLastError());
            return(false);
        }
        if (!ObjectSet("TPBuy", OBJPROP_STYLE, STYLE_DOT)) {
            Print("ERROR: Can't set Buy TakeProfit Style! code #", GetLastError());
            return(false);
        }


        while (true) {
            int sell_ticket = OrderSend(Symbol(), OP_SELL, LotSize, Bid, 3, Bid+stop_loss, 0);
            if (sell_ticket < 0) {
                Print("ERROR: Can't create Sell Order! code #", GetLastError());

                if (GetLastError() == 129) {
                    Print("Retry...");
                    continue;
                } else {
                    return(false);
                }
            }

            break;
        }

        if (!ObjectCreate("TPSell", OBJ_HLINE, 0, 0, Bid-take_profit)) {
            Print("ERROR: Can't create Sell TakeProfit Line! code #", GetLastError());
            return(false);
        }
        if (!ObjectSet("TPSell", OBJPROP_COLOR, DodgerBlue)) {
            Print("ERROR: Can't set Sell TakeProfit Color! code #", GetLastError());
            return(false);
        }
        if (!ObjectSet("TPSell", OBJPROP_STYLE, STYLE_DOT)) {
            Print("ERROR: Can't set Sell TakeProfit Style! code #", GetLastError());
            return(false);
        }


        if (!ObjectCreate("TimeLine", OBJ_VLINE, 0, Time[0], 0)) {
            Print("ERROR: Can't create Time Line! code #", GetLastError());
            return(false);
        }
        if (!ObjectSet("TimeLine", OBJPROP_COLOR, White)) {
            Print("ERROR: Can't set Time Line Color! code #", GetLastError());
            return(false);
        }
    }

    return(0);
}
