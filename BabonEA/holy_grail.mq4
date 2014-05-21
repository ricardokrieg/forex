//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

#property copyright "Ricardo Franco"
#property link      "ricardo.krieg@gmail.com"
#property strict

#define ONCLOUD 0
#define UP 1
#define DOWN 2

extern double LotSize = 0.1;
extern int StopLoss = 5;
extern int TakeProfit = 5;
extern int BackBars = 20;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

class Manager {
    public:
        Manager(void) {
            this.point_value = this.calculate_point_value();

            this.status = -1;
        }

        void update(void) {
            this.update_ichimoku();
            this.update_status();

            Print("STATUS = ", this.status);
        }

        void update_ichimoku(void) {
            this.ichimoku_senkou_a = iIchimoku(Symbol(), PERIOD_M1, 9, 26, 52, MODE_SENKOUSPANA, 0);
            this.ichimoku_senkou_b = iIchimoku(Symbol(), PERIOD_M1, 9, 26, 52, MODE_SENKOUSPANB, 0);
        }

        void update_status(void) {
            this.status = ONCLOUD;
            if (Price > this.ichimoku_senkou_a && Price > this.ichimoku_senkou_b) {
                this.status = UP;
            } else if (Price < this.ichimoku_senkou_a && Price < this.ichimoku_senkou_b) {
                this.status = DOWN;
            }

            if (this.status == UP || this.status == DOWN) {
                int shift = 1;
                double ichimoku_senkou_a = 0;
                double ichimoku_senkou_b = 0;
                double low_prices, high_prices;

                CopyLow(Symbol(), PERIOD_M1, 0, BackBars, low_prices);
                CopyHigh(Symbol(), PERIOD_M1, 0, BackBars, high_prices);
                ArraySetAsSeries(low_prices, true);
                ArraySetAsSeries(high_prices, true);

                while (true) {
                    ichimoku_senkou_a = iIchimoku(Symbol(), PERIOD_M1, 9, 26, 52, MODE_SENKOUSPANA, shift);
                    ichimoku_senkou_b = iIchimoku(Symbol(), PERIOD_M1, 9, 26, 52, MODE_SENKOUSPANB, shift);

                    if (this.status == UP) {
                        if (low_prices[shift] < ichimoku_senkou_a || price_for_angle < ichimoku_senkou_b)
                            bad_candles++;
                        else
                            good_candles++;
                    } else if (this.status == DOWN) {
                       if (price_for_angle > ichimoku_senkou_a || price_for_angle > ichimoku_senkou_b)
                          break;
                    }

                    if (shift++ >= BackBars) break;
                }
            }

            // if (this.status != this.last_status) {
            //     this.open_trade();
            // }
        }

        void open_trade(void) {
            if (OrdersTotal() == 0) {
                // MqlTradeRequest request = {0};
                // MqlTradeResult result = {0};

                // request.action = TRADE_ACTION_DEAL;
                // request.symbol = Symbol();
                // request.volume = LotSize;

                // request.sl = ;
                // request.tp = ;

                int operation = -1;
                double price = -1;
                double sl = -1;
                double tp = -1;
                if (this.status == UP) {
                    operation = OP_BUY;
                    price = Ask;
                    sl = Ask - StopLoss/this.point_value;
                    tp = Ask + TakeProfit/this.point_value;
                    // request.type = ORDER_TYPE_BUY;
                } else if (this.status == DOWN) {
                    operation = OP_SELL;
                    price = Bid;
                    sl = Bid + StopLoss/this.point_value;
                    tp = Bid - TakeProfit/this.point_value;
                    // request.type = ORDER_TYPE_SELL;
                } else return;

                Print("PV = ", this.point_value, "; Price = ", price, "; SL = ", sl, "; TP = ", tp);

                if (OrderSend(Symbol(), operation, LotSize, price, 10, sl, tp) >= 0) {
                    Print("Order Placed!");
                } else {
                    Print("ERROR: Can't create Order! code #", GetLastError());
                }
            }
        }

        double calculate_point_value(void) {
           if (MarketInfo(Symbol(), MODE_POINT) == 0.00001) return(10000);
           if (MarketInfo(Symbol(), MODE_POINT) == 0.001) return(100);
           return(MarketInfo(Symbol(), MODE_POINT)*100000);
        }

        double point_value;

        double ichimoku_senkou_a;
        double ichimoku_senkou_b;
        int status;
};

//------------------------------------------------------------------------------

Manager *manager;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

int OnInit() {
    manager = new Manager();

    return(0);
}

void OnTick() {
    manager.update();
}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
