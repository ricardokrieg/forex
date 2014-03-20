#property copyright "Krieg Corp"
#property link      "ricardo.krieg@gmail.com"

extern double LotSize = 0.01;

int buy_ticket;
int sell_ticket;

int init() {
    buy_ticket = -1;
    sell_ticket = -1;

    return(0);
}

int deinit() {return(0);}

bool create_order(int trend) {
    if (trend == 1) {
        Print("BUY!");

        if (sell_ticket > 0) {
            if (OrderClose(sell_ticket, LotSize, Ask, 10, Yellow)) {
                sell_ticket = -1;
            } else {
                Print("ERROR: Can't close Sell Order! code #", GetLastError());
                return(false);
            }
        }

        buy_ticket = OrderSend(Symbol(), OP_BUY, LotSize, Ask, 1, 0, 0);

        if (buy_ticket < 0) {
            Print("ERROR: Can't create Buy Order! code #", GetLastError());
        }
    } else if (trend == 2) {
        Print("SELL!");

        if (buy_ticket > 0) {
            if (OrderClose(buy_ticket, LotSize, Bid, 10, Yellow)) {
                buy_ticket = -1;
            } else {
                Print("ERROR: Can't close Buy Order! code #", GetLastError());
                return(false);
            }
        }

        sell_ticket = OrderSend(Symbol(), OP_SELL, LotSize, Bid, 1, 0, 0);

        if (sell_ticket < 0) {
            Print("ERROR: Can't create Sell Order! code #", GetLastError());
            return(false);
        }
    }

    return(true);
}

int start() {
    int trend = GlobalVariableGet("KriegSlopeOpenOrder");
    Print("GlobalVariableSet=", trend);

    if (trend == 1 || trend == 2) {
        GlobalVariableSet("KriegSlopeOpenOrder", 0);

        create_order(trend);
    }

    return(0);
}
