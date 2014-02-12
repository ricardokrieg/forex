#property copyright "Krieg Corp"
#property link      "http://www.kriegcorp.com"

extern int ShortEma = 1;
extern int LongEma = 12;

int init() {return(0);}
int deinit() {return(0);}

int crossed(double line1 , double line2) {
    static int last_direction = 0;
    static int current_direction = 0;

    static bool first_time = true;
    if (first_time == true) {
        first_time = false;
        return (0);
    }

    if (line1 > line2)
        current_direction = 1;
    if (line1 < line2)
        current_direction = 2;

    if (current_direction != last_direction) {
        last_direction = current_direction;
        return(last_direction);
    } else {
        return (0);
    }
}

int start() {
    int cnt, ticket, total;
    double short_ema, long_ema;

    short_ema = iMA(NULL, 0, ShortEma, 0, MODE_EMA, PRICE_CLOSE, 0);
    long_ema = iMA(NULL, 0, LongEma, 0, MODE_EMA, PRICE_CLOSE, 0);

    static int is_crossed = 0;
    is_crossed = crossed(long_ema, short_ema);

    if (is_crossed == 1 || is_crossed == 2) {
        Alert("EMA Crossed!");
    }

    return(0);
}
