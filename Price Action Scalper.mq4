#property copyright "Krieg Corp"
#property link      "http://www.kriegcorp.com"

extern double TakeProfit = 5;
extern double StopLoss = 10;
extern int MinimumPips = 3;
extern double LotSize = 0.01;

int init(){return(0);}
int deinit(){return(0);}

double calculate_point_value() {
    if (MarketInfo(Symbol(), MODE_POINT) == 0.00001) return(0.0001);
    if (MarketInfo(Symbol(), MODE_POINT) == 0.001) return(0.01);
    return(MarketInfo(Symbol(), MODE_POINT));
}

int start() {
    double point_value = calculate_point_value();

    double take_profit = TakeProfit * point_value;
    double stop_loss = StopLoss * point_value;
    int minimum_pips = MinimumPips * point_value;

    static int operation = 0;
    static double last_price = 0;

    Print("Minute = ", TimeMinute(TimeCurrent()));
    Print("Is zero? ", (TimeMinute(TimeCurrent()) == 0));

    if (OrdersTotal() == 0) {
        if (operation == 0 && TimeMinute(TimeCurrent()) == 0) {
            bool h1_close = iClose(Symbol(), PERIOD_H1, 1) > iOpen(Symbol(), PERIOD_H1, 1);
            bool m30_close = iClose(Symbol(), PERIOD_M30, 1) > iOpen(Symbol(), PERIOD_M30, 1);
            bool m15_close = iClose(Symbol(), PERIOD_M15, 1) > iOpen(Symbol(), PERIOD_M15, 1);
            bool m5_close = iClose(Symbol(), PERIOD_M5, 1) > iOpen(Symbol(), PERIOD_M5, 1);

            if (h1_close) Print("H1 GREEN");
            else Print("H1 RED");
            if (m30_close) Print("M30 GREEN");
            else Print("M30 RED");
            if (m15_close) Print("M15 GREEN");
            else Print("M15 RED");
            if (m5_close) Print("M5 GREEN");
            else Print("M5 RED");

            if (h1_close == m30_close && h1_close == m15_close && h1_close == m5_close) {
                if (h1_close == true) {
                    operation = 1;
                    last_price = Ask;
                } else if (h1_close == false) {
                    operation = 2;
                    last_price = Bid;
                }
            }
        }

        if (operation == 1) {
            if (Ask >= last_price + minimum_pips) {
                double buy_stop_loss = (Ask - iLow(Symbol(), PERIOD_H1, 1)) * point_value;
                if (buy_stop_loss > stop_loss) buy_stop_loss = stop_loss;

                if (!OrderSend(Symbol(), OP_BUY, LotSize, Ask, 3, Ask-buy_stop_loss, Ask+take_profit)) {
                    Print("ERROR: Can't create Buy Order! code #", GetLastError());
                    return(0);
                }

                operation = 0;
            }
        } else if (operation == 2) {
            if (Bid <= last_price - minimum_pips) {
                double sell_stop_loss = (Bid + iHigh(Symbol(), PERIOD_H1, 1)) * point_value;
                if (sell_stop_loss > stop_loss) sell_stop_loss = stop_loss;

                if (!OrderSend(Symbol(), OP_SELL, LotSize, Bid, 3, Bid+sell_stop_loss, Bid-take_profit)) {
                    Print("ERROR: Can't create Sell Order! code #", GetLastError());
                    return(0);
                }

                operation = 0;
            }
        }

        if (TimeMinute(TimeCurrent()) == 5) {
            operation = 0;
            last_price = 0;
        }
    }

    return(0);
}
