#property copyright "Krieg Corp"
#property link      "http://www.kriegcorp.com"

extern int ShortEma = 13;
extern int LongEma = 34;
extern double Pips = 10;
extern int Slippage = 3;

extern double StopLoss = 50;
extern double TakeProfit = 50;
extern double TrailingStop = 10;

extern double LotSize = 0.1;

double pips;

int buy_ticket;
int sell_ticket;

int init() {
    pips = Pips/10000.0;

    Print("Pips=", pips);

    buy_ticket = -1;
    sell_ticket = -1;

    return(0);
}

int deinit() {return(0);}

int crossed(double line1 , double line2) {
    static int last_direction = 0;
    static int current_direction = 0;

    static bool first_time = true;
    if (first_time == true) {
        first_time = false;
        return (0);
    }

    if (line1 > (line2 + pips)) {
        current_direction = 1;
    }
    if ((line1 + pips) < line2) {
        current_direction = 2;
    }

    if (current_direction != last_direction) {
        last_direction = current_direction;
        return(last_direction);
    } else {
        return (0);
    }
}

bool create_order(int trend) {
    double point_value = calculate_point_value();

    double stop_loss = TakeProfit * point_value;

    if (trend == 1) {
        Print("BUY!");

        if (sell_ticket > 0) {
            OrderClose(sell_ticket, LotSize, Ask, Slippage*10, Yellow);
            sell_ticket = -1;
        }

        buy_ticket = OrderSend(Symbol(), OP_BUY, LotSize, Ask, Slippage, Ask-stop_loss, 0);

        if (buy_ticket < 0) {
            Print("ERROR: Can't create Buy Order! code #", GetLastError());
        }
    } else if (trend == 2) {
        Print("SELL!");

        if (buy_ticket > 0) {
            OrderClose(buy_ticket, LotSize, Bid, Slippage*10, Yellow);
            buy_ticket = -1;
        }

        sell_ticket = OrderSend(Symbol(), OP_SELL, LotSize, Bid, Slippage, Bid+stop_loss, 0);

        if (sell_ticket < 0) {
            Print("ERROR: Can't create Sell Order! code #", GetLastError());
            return(false);
        }
    }

    return(true);
}

double calculate_point_value() {
    if (MarketInfo(Symbol(), MODE_POINT) == 0.00001) return(0.0001);
    if (MarketInfo(Symbol(), MODE_POINT) == 0.001) return(0.01);
    return(MarketInfo(Symbol(), MODE_POINT));
}

bool update_trailing_stop() {
    for (int i = 0; i < OrdersTotal(); i++) {
        OrderSelect(i, SELECT_BY_POS, MODE_TRADES);

        double point_value = calculate_point_value();

        double take_profit = TakeProfit * point_value;
        double trailing_stop = TrailingStop * point_value;

        if (OrderType() == OP_BUY) {
            if (Bid - OrderOpenPrice() >= take_profit) {
                if (OrderStopLoss() < Bid - trailing_stop) {
                    if (!OrderModify(OrderTicket(), OrderOpenPrice(), Bid - trailing_stop, OrderTakeProfit(), Red)) {
                        Print("Error setting Buy trailing stop: ", GetLastError());
                    }
                }
            }
        } else if (OrderType() == OP_SELL) {
            if (OrderOpenPrice() - Ask > take_profit) {
                if (OrderStopLoss() > Ask + trailing_stop) {
                    if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ask + trailing_stop, OrderTakeProfit(), Red)) {
                        Print("Error setting Sell trailing stop: ", GetLastError());
                    }
                }
            }
        }
    }
}

int start() {
    double short_ema, long_ema;

    short_ema = iMA(NULL, 0, ShortEma, 0, MODE_EMA, PRICE_CLOSE, 0);
    long_ema = iMA(NULL, 0, LongEma, 0, MODE_EMA, PRICE_CLOSE, 0);

    static int trend = 0;
    trend = crossed(short_ema, long_ema);

    if (trend != 0) {
        Print("Trend=", trend);
        create_order(trend);
    }

    update_trailing_stop();

    return(0);
}
