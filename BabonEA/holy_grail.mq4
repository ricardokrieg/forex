//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

#property copyright "Ricardo Franco"
#property link      "ricardo.krieg@gmail.com"
#property strict

#define ONCLOUD 0
#define UP 1
#define DOWN 2

extern double LotSize = 0.1;
extern int StopLoss = 3;
extern int TakeProfit = 8;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

class Manager {
    public:
        Manager(void) {
            this.point_value = this.calculate_point_value();

            this.status = -1;
            this.last_status = -1;
        }

        void update(void) {
            this.update_ichimoku();
            this.update_tma();

            Print("STATUS = ", this.status);
        }

        void update_ichimoku(void) {
            this.ichimoku_senkou_a = iIchimoku(Symbol(), PERIOD_M1, 9, 26, 52, MODE_SENKOUSPANA, 0);
            this.ichimoku_senkou_b = iIchimoku(Symbol(), PERIOD_M1, 9, 26, 52, MODE_SENKOUSPANB, 0);
        }

        void update_tma(void) {
            this.tma_center_line = iCustom(Symbol(), PERIOD_M1, "TMA", "M1", 20, PRICE_CLOSE, 2.0, 100, true, 0, 0);

            this.last_status = this.status;

            this.status = ONCLOUD;
            if (this.tma_center_line > this.ichimoku_senkou_a && this.tma_center_line > this.ichimoku_senkou_b) {
                this.status = UP;
                if (this.last_status == -1) this.last_status = UP;
            } else if (this.tma_center_line < this.ichimoku_senkou_a && this.tma_center_line < this.ichimoku_senkou_b) {
                this.status = DOWN;
                if (this.last_status == -1) this.last_status = DOWN;
            }

            if (this.status != this.last_status) {
                this.open_trade();
            }

            this.last_status = this.status;
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
        double tma_center_line;
        int status;
        int last_status;
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
