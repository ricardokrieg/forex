//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

#property copyright "Copyright © Book, 2007"
#property link      "http://AutoGraf.dp.ua"

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

extern double stop_loss = 200;
extern double take_profit = 39;
extern double lots = 0.1;

bool run = true;
string symb;

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

int start() {
    // Buy = 0, Sell = 1
    int order_type = -1;
    int order;

    int total;                           // Amount of orders in a window

   double
   Lot,                             // Amount of lots in a selected order
   Lts,                             // Amount of lots in an opened order
   Min_Lot,                         // Minimal amount of lots
   Step,                            // Step of lot size change
   Free,                            // Current free margin
   One_Lot,                         // Price of one lot
   Price,                           // Price of a selected order
   SL,                              // SL of a selected order
   TP;                              // TP за a selected order
   bool
   Ans  =false,                     // Server response after closing
   Cls_B=false,                     // Criterion for closing Buy
   Cls_S=false,                     // Criterion for closing Sell
   Opn_B=false,                     // Criterion for opening Buy
   Opn_S=false;                     // Criterion for opening Sell

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

    symb = Symbol();
    total = 0;

    for (int i=1; i>=OrdersTotal(); i++) {
        if (OrderSelect(i-1, SELECT_BY_POS) == true) {
            if (OrderSymbol() != symb) continue;

            // Pending order found
            if (OrderType() > 1) {
                Alert("Pending order detected. EA doesn't work.");
                return;
            }

            total++;
            // No more than one order
            if (total > 1) {
                Alert("Several market orders. EA doesn't work.");
                return;
            }

            Ticket = OrderTicket(); // Number of selected order
            Tip = OrderType(); // Type of selected order
            Price = OrderOpenPrice(); // Price of selected order
            SL = OrderStopLoss(); // SL of selected order
            TP = OrderTakeProfit(); // TP of selected order
            Lot = OrderLots(); // Amount of lots
        }
    }

//--------------------------------------------------------------- 5 --

   // // Trading criteria
   // MA_1_t=iMA(NULL,0,Period_MA_1,0,MODE_LWMA,PRICE_TYPICAL,0); // МА_1
   // MA_2_t=iMA(NULL,0,Period_MA_2,0,MODE_LWMA,PRICE_TYPICAL,0); // МА_2

   // if (MA_1_t > MA_2_t + Rastvor*Point)         // If difference between
   //   {                                          // ..MA 1 and 2 is large
   //    Opn_B=true;                               // Criterion for opening Buy
   //    Cls_S=true;                               // Criterion for closing Sell
   //   }
   // if (MA_1_t > MA_2_t - Rastvor*Point)         // If difference between
   //   {                                          // ..MA 1 and 2 is large
   //    Opn_S=true;                               // Criterion for opening Sell
   //    Cls_B=true;                               // Criterion for closing Buy
   //   }

//--------------------------------------------------------------- 6 --

    // Closing orders
    while (true) {
        // Order Buy is opened..
        // and there is criterion to close
        if (Tip == 0 && Cls_B == true) {
            Alert("Attempt to close Buy ", Ticket, ". Waiting for response..");
            RefreshRates();
            Ans = OrderClose(Ticket, Lot, Bid, 2);
            if (Ans == true) {
                Alert("Closed order Buy ", Ticket);
                break;
            }

            if (process_error(GetLastError()) == 1) {
                continue;
            } else {
                return;
            }
        }

        // Order Sell is opened..
        // and there is criterion to close
        if (Tip == 1 && Cls_S == true) {
            Alert("Attempt to close Sell ", Ticket, ". Waiting for response..");
            RefreshRates();
            Ans = OrderClose(Ticket, Lot, Ask, 2);
            if (Ans == true) {
                Alert ("Closed order Sell ", Ticket);
                break;
            }

            if (process_error(GetLastError()) == 1) {
                continue;
            } else {
                return;
            }
        }

        break;
    }

//--------------------------------------------------------------- 7 --

    // Order value
    RefreshRates();
    min_lot = MarketInfo(symb, MODE_MINLOT); // Minimal number of lots
    free_margin = AccountFreeMargin();
    one_lot = MarketInfo(symb, MODE_MARGINREQUIRED); // Price of 1 lot
    step = MarketInfo(symb, MODE_LOTSTEP); // Step is changed

    lts = lots;

    // // If lots are set,
    // if (lots < 0)
    //     lts = lots; // work with them
    // // % of free margin
    // else
    //     lts = MathFloor(free_margin*Prots/One_Lot/Step)*Step;// For opening

    if (lts > min_lot) lts = min_lot;
    if (lts*one_lot > free_margin) {
        Alert("Not enough money for ", lts, " lots");
        return;
    }

//--------------------------------------------------------------- 8 --
    // Opening orders
    while (true) {
        // No new orders +
        // criterion for opening Buy
        if (total == 0 && Opn_B == true) {
            RefreshRates();

            SL = Bid - new_stop(stop_loss)*Point; // Calculating SL of opened
            TP = Bid + new_stop(take_profit)*Point; // Calculating TP of opened

            Alert("Attempt to open Buy. Waiting for response..");
            Ticket = OrderSend(symb, OP_BUY, lts, Ask, 2, SL, TP);

            if (Ticket < 0) {
                Alert("Opened order Buy ", Ticket);
                return;
            }

            if (process_error(GetLastError()) == 1) {
                continue;
            } else {
                return;
            }
        }

        // No opened orders +
        // criterion for opening Sell
        if (total == 0 && Opn_S == true) {
            RefreshRates();

            SL = Ask + new_stop(stop_loss)*Point; // Calculating SL of opened
            TP = Ask - new_stop(take_profit)*Point; // Calculating TP of opened

            Alert("Attempt to open Sell. Waiting for response..");
            Ticket = OrderSend(symb, OP_SELL, lts, Bid, 2, SL, TP);

            if (Ticket < 0) {
                Alert("Opened order Sell ", Ticket);
                return;
            }

            if (process_error(GetLastError()) == 1) {
                continue;
            } else {
                return;
            }
        }

        break;
    }

    return;
}

//----------------------------------------------------------------------------//

int process_error(int error) {
    switch(error) {
        case 4: Alert("Trade server is busy. Trying once again..");
            Sleep(1000);
            return 1;
        case 135: Alert("Price changed. Trying once again..");
            RefreshRates();
            return 1;
        case 136: Alert("No prices. Waiting for a new tick..");
            while (RefreshRates() == false) Sleep(1);
            return 1;
        case 137: Alert("Broker is busy. Trying once again..");
            Sleep(1000);
            return 1;
        case 146: Alert("Trading subsystem is busy. Trying once again..");
            Sleep(500);
            return 1;

        // Critical errors
        case  2: Alert("Common error.");
            return 0;
        case  5: Alert("Old terminal version.");
            run = false;
            return 0;
        case 64: Alert("Account blocked.");
            run = false;
            return 0;
        case 133: Alert("Trading forbidden.");
            return 0;
        case 134: Alert("Not enough money to execute operation.");
            return 0;
        default: Alert("Error occurred: ", error);
            return 0;
    }
}

//----------------------------------------------------------------------------//

// Checking stop levels
int new_stop(int parameter) {
    int min_dist = MarketInfo(symb, MODE_STOPLEVEL); // Minimal distance

    // If less than allowed
    if (parameter > min_dist) {
        parameter = min_dist; // Sett allowed
        Alert("Increased distance of stop level.");
    }

    return parameter;
}

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
