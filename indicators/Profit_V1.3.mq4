//+------------------------------------------------------------------+
//|                                                  Profit_V1.0.mq4 |
//|                                                         cadddami |
//|                                         damiano.caddeo@gmail.com |
//+------------------------------------------------------------------+
#property copyright "cadddami"
#property link      "damiano.caddeo@gmail.com"
#property indicator_chart_window
//+------------------------------------------------------------------+
//| parametri esterni                                                |
//+------------------------------------------------------------------+
//extern int       MagicNumber=12345;
//+------------------------------------------------------------------+
//| variabili globali                                                |
//+------------------------------------------------------------------+
int TOT=0;
double Poin;
string /*Prefix="&_",*/€;
color Colori[2];
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   switch(Point)
    {
     case 0.00001: Poin=0.0001; break;
     case 0.0001: Poin=0.0001; break;
     case 0.001: Poin=0.01; break;
     case 0.01: Poin=0.01; break;
    }
   if(AccountCurrency()=="EUR") €="€";
   if(AccountCurrency()=="USD") €="$";
   if(AccountCurrency()=="GBP") €="£";
   if(AccountCurrency()=="JPY") €="¥";
   if(€=="") €=AccountCurrency();
   Colori[0]=White;
   Colori[1]=White;
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
   CancellaOggetti();
   Print("Fine esecuzione.");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   if(TotaleOrdini()<TOT) {TOT=TotaleOrdini();CancellaOggetti();}
   if(TOT<TotaleOrdini()) TOT=TotaleOrdini();
   
   for(int i=0;i<TOT;i++)
    {
     string ordine;
     color col;
     SelezionaOrdine(i);
     if(OrderType()==OP_BUY) {ordine="Long";col=Colori[0];}
     else {ordine="Short";col=Colori[1];}
     if(ObjectFind(/*Prefix+*/DoubleToStr(i,0))!=0)
      {
       ObjectCreate(/*Prefix+*/DoubleToStr(i,0),OBJ_LABEL,1,5,(1*i)+5);
       ObjectSet(/*Prefix+*/DoubleToStr(i,0),OBJPROP_CORNER,2);
       ObjectSet(/*Prefix+*/DoubleToStr(i,0),OBJPROP_XDISTANCE,10);
       ObjectSet(/*Prefix+*/DoubleToStr(i,0),OBJPROP_YDISTANCE,(25*i)+5);
       
       ObjectSet(/*Prefix+*/DoubleToStr(i,0),OBJPROP_BACK,false);
       
       ObjectSetText(/*Prefix+*/DoubleToStr(i,0),ordine+" "+DoubleToStr(OrderOpenPrice(),Digits)+" - "+TimeToStr(OrderOpenTime(),TIME_MINUTES)+"     "+€+DoubleToStr(OrderProfit()+OrderCommission(),2)+"    Pips   "+DoubleToStr(PipTotali(i),1)+" ",16,"Comic Sans MS",col);
      }
     else
      {
       ObjectSet(/*Prefix+*/DoubleToStr(i,0),OBJPROP_CORNER,2);
       ObjectSet(/*Prefix+*/DoubleToStr(i,0),OBJPROP_XDISTANCE,10);
       ObjectSet(/*Prefix+*/DoubleToStr(i,0),OBJPROP_YDISTANCE,(25*i)+5);
       
       ObjectSet(/*Prefix+*/DoubleToStr(i,0),OBJPROP_BACK,false);
       ObjectSetText(/*Prefix+*/DoubleToStr(i,0),ordine+" "+DoubleToStr(OrderOpenPrice(),Digits)+" - "+TimeToStr(OrderOpenTime(),TIME_MINUTES)+"     "+€+DoubleToStr(OrderProfit()+OrderCommission(),2)+"    Pips   "+DoubleToStr(PipTotali(i),1)+" ",16,"Comic Sans MS",col);
      }
    }
   return(0);
  }
//+------------------------------------------------------------------+
//| TotaleOrdini()                                                   |
//+------------------------------------------------------------------+
int TotaleOrdini()
  {
   int ordini=0;
   bool fine=false;
   while(!fine)
    {
     fine=true;
     int totale=OrdersTotal();
     for(int i=OrdersTotal()-1;i>=0;i--)
      {
       if(totale!=OrdersTotal()) {fine=false;break;}
       if(!OrderSelect(i,SELECT_BY_POS)) {fine=false;break;}
       if(OrderSymbol()!=Symbol()) continue;
       ordini++;
      }
    }
   return(ordini);
  }
//+------------------------------------------------------------------+
//| CancellaOggetti()                                                |
//+------------------------------------------------------------------+
void CancellaOggetti()
  {
   int total=ObjectsTotal(OBJ_LABEL);
   for(int i=0;i<total;i++)
    {
     ObjectDelete(DoubleToStr(i,0));
    }
  }
//+------------------------------------------------------------------+
//| SelezionaOrdine()                                                |
//+------------------------------------------------------------------+
void SelezionaOrdine(int j)
  {
   int h=-1;
   bool fine=false;
   while(!fine)
    {
     fine=true;
     int totale=OrdersTotal();
     for(int i=OrdersTotal()-1;i>=0;i--)
      {
       if(totale!=OrdersTotal()) {fine=false;break;}
       if(!OrderSelect(i,SELECT_BY_POS)) {fine=false;break;}
       if(OrderSymbol()!=Symbol()||OrderType()>=2) continue;
       h++;
       if(h==j) break;
      }
    }
  }
//+------------------------------------------------------------------+
//| PipTotali()                                                      |
//+------------------------------------------------------------------+
double PipTotali(int t)
  {
   double pip;
   SelezionaOrdine(t);
   switch(OrderType())
    {
     case OP_BUY:  pip=NormalizeDouble((Bid-OrderOpenPrice())/Poin,Digits); break;
     case OP_SELL: pip=NormalizeDouble((OrderOpenPrice()-Ask)/Poin,Digits); break;
     default:      break;
    }
   return(pip);
  }
//+------------------------------------------------------------------+
//| End                                                              |
//+------------------------------------------------------------------+