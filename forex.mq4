//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

#property copyright "Ricardo Franco"
#property link      "ricardo.krieg@gmail.com"

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

extern double user_stop_loss = 200;
extern double user_take_profit = 39;
extern double user_lots = 0.1;

bool run = true;
string symb;

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

int init() {
    start();

    return(0);
}

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

int start() {
    symb = Symbol();

    while (true) {
        RefreshRates();

        double stop_loss = Bid - (normalize_stop(user_stop_loss) * Point);
        double take_profit = Bid + (normalize_stop(user_take_profit) * Point);

        Print("Attempt to open Buy. Waiting for response..");
        int order = OrderSend(symb, OP_BUY, user_lots, Ask, 2, stop_loss, take_profit);

        if (order > 0) {
            Print("Opened order Buy ", order);
            break;
        } else {
            if (process_error(GetLastError()) == 0) break;
        }
    }

    return(0);
}

//----------------------------------------------------------------------------//

int process_error(int error) {
    switch(error) {
        case 4: Print("Trade server is busy. Trying once again..");
            Sleep(1000);
            return(1);
        case 135: Print("Price changed. Trying once again..");
            RefreshRates();
            return(1);
        case 136: Print("No prices. Waiting for a new tick..");
            while (RefreshRates() == false) Sleep(1);
            return(1);
        case 137: Print("Broker is busy. Trying once again..");
            Sleep(1000);
            return(1);
        case 146: Print("Trading subsystem is busy. Trying once again..");
            Sleep(500);
            return(1);

        // Critical errors
        case  2: Print("Common error.");
            return(0);
        case  5: Print("Old terminal version.");
            run = false;
            return(0);
        case 64: Print("Account blocked.");
            run = false;
            return(0);
        case 133: Print("Trading forbidden.");
            return(0);
        case 134: Print("Not enough money to execute operation.");
            return(0);
        default: Print("Error occurred: ", error);
            return(0);
    }
}

//----------------------------------------------------------------------------//

int normalize_stop(int value) {
    int minimal_distance = MarketInfo(symb, MODE_STOPLEVEL);

    if (value < minimal_distance) {
        value = minimal_distance;
        Print("Increased distance of stop level.");
    }

    return(value);
}

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
