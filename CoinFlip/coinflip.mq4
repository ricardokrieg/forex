//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

#property copyright "Copyright 2014, Ricardo Krieg"
#property link      "ricardo.krieg@gmail.com"
#property version   "1.0"
#property strict

//------------------------------------------------------------------------------

#define LONDON_DST_START    84
#define LONDON_DST_END      298

//------------------------------------------------------------------------------

extern int    LocalGMTOffset   = 8;
extern int    BrokerGMTOffset  = 2;
extern string LondonOpenTime   = "9:00";

extern double EquityPercent = 1;
extern double HardSL        = 340.0;
extern bool   DynamicLots   = true;
extern double FixedLots     = 0.1;

extern int    MagicNumber   = 666;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

class Manager {
    public:
        Manager(void) {
            this.magic_number = MagicNumber;
            this.equity_percent = EquityPercent;
            this.tick_value = this.calculate_tick_value();
            this.pair = Symbol();
            this.fixed_lot_size = FixedLots;
        }

        void update(void) {
        }

        void deinit(const int reason) {
            ObjectsDeleteAll();
        }

        bool close_orders(void) {
            int count, total, orders_closed;

            orders_closed = 0;
            total = OrdersTotal();

            for (count=0; count < total; count++) {
                if (OrderSelect(count, SELECT_BY_POS, MODE_TRADES)) {
                    if (OrderMagicNumber() == this.magic_number) {
                        double close_price = -1;

                        if (OrderType() == OP_SELL)
                            close_price = Ask;
                        else if (OrderType() == OP_BUY)
                            close_price = Bid;

                        if (OrderClose(OrderTicket(), OrderLots(), close_price, 3, clrRed))
                            orders_closed++;
                        else
                            Print("OrderClose() Function error = ", GetLastError());
                    }
                } else {
                    Print("OrderSelect() Function error = ", GetLastError());
                }
            }

            return (orders_closed > 0);
        }

        bool open_order(int operation, double op_price, double stoploss, double stopprice, string comm) {
            double lots = this.get_lot_size(stoploss);

            if (!OrderSend(this.pair, operation, lots, op_price, 3, NormalizeDouble(stopprice, Digits), 0, comm, this.magic_number, 0, clrGreen)) {
                Print("OrderSend function error = ", GetLastError());
                return false;
            }

            return true;
        }

        double calculate_lot_size(double stoploss) {
            double risk_account;
            double tick_value;
            double lot_size;

            risk_account = AccountEquity() * this.equity_percent;

            lot_size = (risk_account/stoploss) / this.tick_value;

            if (lot_size < MarketInfo(Symbol(), MODE_MINLOT))
                lot_size = MarketInfo(Symbol(), MODE_MINLOT);
            if (lot_size > MarketInfo(Symbol(), MODE_MAXLOT))
                lot_size = MarketInfo(Symbol(), MODE_MAXLOT);

            if (MarketInfo(Symbol(), MODE_LOTSTEP) == 0.1)
                lot_size = NormalizeDouble(lot_size, 1);
            else
                lot_size = NormalizeDouble(lot_size, 2);

            return(lot_size);
        }

        void display_info(string label_name, string label_doc, int corner, int pos_x, int pos_y, int doc_size, string doc_style, color doc_color) {
            ObjectCreate(label_name, OBJ_LABEL, 0, 0, 0);
            ObjectSetText(label_name, label_doc, doc_size, doc_style, doc_color);
            ObjectSet(label_name, OBJPROP_CORNER, corner);
            ObjectSet(label_name, OBJPROP_XDISTANCE, pos_x);
            ObjectSet(label_name, OBJPROP_YDISTANCE, pos_y);

            return;
        }

        double calculate_tick_value(void) {
            double tick_value = MarketInfo(Symbol(), MODE_TICKVALUE);

            if (Digits == 3 || Digits == 5) return (tick_value * 10);
            return tick_value;
        }

        double get_lot_size(double stoploss) {
            if (DynamicLots)
                return calculate_lot_size(this.equity_percent, stoploss);
            else
                return this.fixed_lot_size;
        }

    private:
        int magic_number;
        double equity_percent;
        double tick_value;
        double fixed_lot_size;
        string pair;
};

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

Manager *manager;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

int OnInit() {
    manager = new Manager();

    return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
    manager->deinit(reason);
}

void OnTick() {
    manager.update();
}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

void OnTick() {
    int day_of_dst;
    int london_GMT_offset;
    int operation;
    double yesterday_high, yesterday_low;
    double stoploss_amount, stoploss_price;
    string comm;
    int    i, exist_order_flag;
    int    london_open_bar_shift, pre_london_open_bar_shift;
    datetime london_time, lot_in_broker, pre_lot_in_broker;

    if (Period()!= 60) {
        Comment("The EA run in H1 Chart...");
        return;
    }

    // London time
    day_of_dst = TimeDayOfYear(TimeCurrent());
    if (day_of_dst >= LONDON_DST_START && day_of_dst <= LONDON_DST_END)
        london_GMT_offset = 1;
    else
        london_GMT_offset = 0;

    london_time = TimeCurrent()-(BrokerGMTOffset-london_GMT_offset)*3600;
    lot_in_broker = StrToTime(LondonOpenTime)+(BrokerGMTOffset-london_GMT_offset)*3600;

    if (TimeDayOfWeek(TimeCurrent()) == 1)
        pre_lot_in_broker = lot_in_broker-3*24*3600;
    else
        pre_lot_in_broker = lot_in_broker-24*3600;

    ObjectCreate("LondonOpen", OBJ_VLINE, 0, lot_in_broker, 0);
    ObjectCreate("pre-LondonOpen", OBJ_VLINE, 0, pre_lot_in_broker, 0);
    ObjectSet("LondonOpen", OBJPROP_COLOR, clrPink);
    ObjectSet("pre-LondonOpen", OBJPROP_COLOR, clrPink);

    london_open_bar_shift = iBarShift(Symbol(), 0, lot_in_broker);
    pre_london_open_bar_shift = iBarShift(Symbol(), 0, pre_lot_in_broker);
    yesterday_high = High[iHighest(Symbol(), 0, MODE_HIGH, pre_london_open_bar_shift-london_open_bar_shift, london_open_bar_shift)];
    yesterday_low = Low[iLowest(Symbol(), 0, MODE_LOW, pre_london_open_bar_shift-london_open_bar_shift, london_open_bar_shift)];

    ObjectCreate("pre-high", OBJ_HLINE, 0, 0, yesterday_high);
    ObjectCreate("pre-low", OBJ_HLINE, 0, 0, yesterday_low);
    ObjectSet("pre-high", OBJPROP_COLOR, clrYellow);
    ObjectSet("pre-low", OBJPROP_COLOR, clrYellow);

//  comm ="\n"+ "london_time Now = "+TimeToStr(london_time,TIME_DATE|TIME_SECONDS)+"\n"
//        +"LondonOpen in Broker Time = "+TimeToStr(lot_in_broker,TIME_DATE|TIME_MINUTES)+"\n";

    for (i=0; i<OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) {
            Print("OrderSelect() Function error = ", GetLastError());
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
                exist_order_flag = 1;
                break;
            } else {
                exist_order_flag = 0;
            }
        }
    }

    //+---when London session open, Close order
    if (TimeHour(TimeCurrent()) == TimeHour(lot_in_broker)) {
        close_orders_by_magic_number(MagicNumber);
        exist_order_flag = 0;
    }

//+------Open a order at end of 1th h1 bar(or start of 2th h1 bar)
    if (TimeHour(TimeCurrent()) == TimeHour(lot_in_broker)+1) {
//+---long if 1th h1 bar is bull
        if (Close[1]-Open[1] > 0 && exist_order_flag == 0) {
            operation = OP_BUY;
            if ((Ask-yesterday_low) >= HardSL*Point) {
                stoploss_price = Ask-HardSL*Point;
                stoploss_amount = HardSL;
            } else {
                stoploss_price = yesterday_low;
                stoploss_amount = (Ask-yesterday_low)/Point;
            }

            open_order_by_magic_number(Symbol(), operation, Ask, stoploss_amount, stoploss_price, "CF_BUY "+IntegerToString(MagicNumber, 0));
            exist_order_flag = 1;
        }
//+---short if 2th h1 bar is bear
        if (Close[1]-Open[1] < 0 && exist_order_flag == 0) {
            operation = OP_SELL;
            if ((yesterday_high-Bid) >= HardSL*Point) {
                stoploss_price = Bid + HardSL*Point;
                stoploss_amount = HardSL;
            } else {
                stoploss_price = yesterday_high;
                stoploss_amount = (yesterday_high-Bid)/Point;
            }

            open_order_by_magic_number(Symbol(), operation, Bid, stoploss_amount, stoploss_price, "CF_SELL"+IntegerToString(MagicNumber, 0));
            exist_order_flag = 1;
        }
//+---if 2th h1 bar is doji
        if (Close[1] == Open[1]) {
            if (Close[1]-Open[2] > 0 && exist_order_flag == 0) {
                operation = OP_BUY;
                if ((Ask-yesterday_low) >= HardSL*Point) {
                    stoploss_price = Ask - HardSL*Point;
                    stoploss_amount = HardSL;
                } else {
                    stoploss_price = yesterday_low;
                    stoploss_amount = (Ask-yesterday_low)/Point;
                }

                open_order_by_magic_number(Symbol(), operation, Ask, stoploss_amount, stoploss_price, "CF_BUY "+IntegerToString(MagicNumber, 0));
                exist_order_flag = 1;
            }

            if (Close[1]-Open[2] < 0 && exist_order_flag == 0) {
                operation = OP_SELL;
                if ((yesterday_high-Bid) >= HardSL*Point) {
                    stoploss_price = Bid + HardSL*Point;
                    stoploss_amount = HardSL;
                } else {
                    stoploss_price = yesterday_high;
                    stoploss_amount = (yesterday_high-Bid)/Point;
                }

                open_order_by_magic_number(Symbol(), operation, Bid, stoploss_amount, stoploss_price, "CF_SELL"+IntegerToString(MagicNumber, 0));
                exist_order_flag = 1;
            }
        }
    }
//  comm=comm+"exist_order_flag = "+IntegerToString(exist_order_flag,1)+"\n"+"LongdonBar Shift = "+IntegerToString(london_open_bar_shift,0)+"\n";

    display_info("BrokerTime", "BrokerTimeNow   "+TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS), 0, 300, 20, 10, "Courier New", clrYellow);
    display_info("london_time", "LondonTimeNow   "+TimeToStr(london_time, TIME_DATE|TIME_SECONDS), 0, 300, 35, 10, "Courier New", clrYellow);
    display_info("LondonOpenTime", "LondonOpenTime  "+TimeToStr(StrToTime(LondonOpenTime), TIME_DATE|TIME_MINUTES), 0, 300, 50, 10, "Courier New", clrLime);
    display_info("lot_in_broker", "LOTInBroker     "+TimeToStr(lot_in_broker, TIME_DATE|TIME_MINUTES), 0, 300, 65, 10, "Courier New", clrLime);
    display_info("YesterdayH", "yesterday_high   "+DoubleToStr(yesterday_high, Digits), 0, 300, 80, 10, "Courier New", clrYellow);
    display_info("YesterdayL", "yesterday_low    "+DoubleToStr(yesterday_low, Digits), 0, 300, 95, 10, "Courier New", clrYellow);
    Comment(comm);
    //Comment(TimeDayOfYear(TimeCurrent()),"LondonGMTOffset=",london_GMT_offset);
}
