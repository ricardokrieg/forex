#property copyright "Krieg Corp"
#property link      "http://www.kriegcorp.com"

extern double TakeProfit = 4;
extern double StopLoss = 8;
extern double HedgingDistance = 4;
extern int TurnLimit = 3;

int sell_stop_orders[10];
int buy_stop_orders[10];
int sell_stop_orders_index = 0;
int buy_stop_orders_index = 0;

int init() {
    return(0);
}

int deinit() {
    return(0);
}

double calculate_point_value() {
    if (MarketInfo(OrderSymbol(), MODE_POINT) == 0.00001) return(0.0001);
    if (MarketInfo(OrderSymbol(), MODE_POINT) == 0.001) return(0.01);
    return(MarketInfo(OrderSymbol(), MODE_POINT));
}

bool check_stop_orders() {
    int current_order = OrderTicket();

    for (int i = 0; i < sell_stop_orders_index; i++) {
        OrderSelect(sell_stop_orders[i]);

        if (OrderType() == OP_SELL) {

        }
    }

    OrderSelect(current_order);
}

bool start_order(double take_profit, double stop_loss, double hedging_distance) {
    if (OrderType() == OP_BUY) {
        if (!OrderModify(OrderTicket(), OrderOpenPrice(), stop_loss, OrderTakeProfit(), Red)) {
            Print("ERROR: Can't create StopLoss! code #", GetLastError());
            return(false);
        }

        order_name = "SSO_" + OrderTicket();
        int ticket = OrderSend(Symbol(), OP_SELLSTOP, OrderLots()*3, hedging_distance, 3, take_profit, 0, order_name, 9999, 0, Yellow);
        if (ticket < 0) {
            Print("ERROR: Can't create Sell Stop Order! code #", GetLastError());
            return(false);
        }

        sell_stop_orders[sell_stop_orders_index] = ticket;
        sell_stop_orders_index++;

        check_stop_orders();
    } else if (OrderType() == OP_SELL) {
        if (!OrderModify(OrderTicket(), OrderOpenPrice(), stop_loss, OrderTakeProfit(), Red)) {
            Print("ERROR: Can't create StopLoss! code #", GetLastError());
            return(false);
        }

        order_name = "BSO_" + OrderTicket();
        int ticket = OrderSend(Symbol(), OP_BUYSTOP, OrderLots()*3, hedging_distance, 3, take_profit, 0, order_name, 9999, 0, Yellow);
        if (ticket < 0) {
            Print("ERROR: Can't create Buy Stop Order! code #", GetLastError());
            return(false);
        }

        buy_stop_orders[buy_stop_orders_index] = ticket;
        buy_stop_orders_index++;
    }

    return(true);
}

// bool update_order() {
//     string take_profit_line = "TP" + OrderTicket();
//     string hedging_distance_line = "HD" + OrderTicket();

//     if (ObjectFind(hedging_distance_line) == -1) {
//         Print("ERROR: Couldn't find HedgingDistance Line! code #", GetLastError());
//         return(false);
//     }

//     double hedging_distance = ObjectGet(hedging_distance_line, OBJPROP_PRICE1);

//     if (OrderType() == OP_BUY) {
//         if (Bid < hedging_distance) {

//         }
//     }
// }

int start() {
    for (int order_id = 0; order_id < OrdersTotal(); order_id++) {
        OrderSelect(order_id, SELECT_BY_POS, MODE_TRADES);

        double point_value = calculate_point_value();

        double take_profit = TakeProfit * point_value;
        double stop_loss = StopLoss * point_value;
        double hedging_distance = HedgingDistance * point_value;

        double buy_take_profit = OrderOpenPrice() + take_profit;
        double buy_stop_loss = OrderOpenPrice() - stop_loss;
        double buy_hedging_distance = OrderOpenPrice() - hedging_distance;

        double sell_take_profit = OrderOpenPrice() - take_profit;
        double sell_stop_loss = OrderOpenPrice() + stop_loss;
        double sell_hedging_distance = OrderOpenPrice() + hedging_distance;

        if (OrderStopLoss() == 0) {
            if (OrderType() == OP_BUY) {
                start_order(buy_take_profit, buy_stop_loss, buy_hedging_distance);
            } else if (OrderType() == OP_SELL) {
                start_order(sell_take_profit, sell_stop_loss, sell_hedging_distance);
            }
        }

        // if (OrderType() == OP_BUY) {
        //     if (!update_order()) {
        //         return(0);
        //     }
        // }
    }

    return(0);
}
