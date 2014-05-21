//+------------------------------------------------------------------+
//|                                              ay-PercentGraph.mq4 |
//|                      Copyright © 2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//| Adapted & edited by George Olulana for 919 Gilead Trading System |
//|    as inspired by God, and thanks to the originator of indicator |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, MetaQuotes Software Corp."
#property link      "ahmad.yani@hotmail.com"

#property indicator_chart_window

//#include <stderror.mqh>
//#include <stdlib.mqh>

//maximum 9 symbols
string aPairs[] = 
   {
   "EURUSD","GBPUSD","USDCHF","USDJPY","USDCAD","AUDUSD","NZDUSD","EURGBP","EURCHF",
   "EURCAD","EURAUD","EURNZD","EURJPY","GBPJPY","CHFJPY","CADJPY","AUDJPY","NZDJPY","GBPCHF",
   "GBPCAD","GBPAUD","GBPNZD","CADCHF","AUDCHF","AUDCAD","AUDNZD","NZDCHF","NZDCAD"
   };  
   

int aPeriods[] = {PERIOD_D1,PERIOD_H1};
string aPeriodsName[] = {"D1", "H1"};

double aPercentHLC[][3][3];
color  aDotClr[] = {LimeGreen, Red, C'25,25,25'};
string aStrHLC[] = {"H","L","C"};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   ArrayResize(aPercentHLC,ArraySize(aPairs));
   layout();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   //----
   ObjectsDeleteAll(); 
   //----
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int    counted_bars=IndicatorCounted();
   int i,j,k,m;
   //----

   //populate percent h,l,c
   for(i=0; i<ArraySize(aPairs); i++)
   {
      for(j=0; j<ArraySize(aPeriods); j++)
      {
         double o= iOpen (aPairs[i], aPeriods[j], 0); 
         double h= iHigh (aPairs[i], aPeriods[j], 0);
         double l= iLow  (aPairs[i], aPeriods[j], 0);
         double c= iClose(aPairs[i], aPeriods[j], 0);  
         
         aPercentHLC[i][j][0] = ((h-o)/o)*100; //percent h;
         aPercentHLC[i][j][1] = ((l-o)/o)*100; //percent l;
         aPercentHLC[i][j][2] = ((c-o)/o)*100; //percent c;
         
      }    
   }
   
   //do the graph thinggggggg.....
   for(i=0; i<ArraySize(aPairs); i++) //loop pair
   {
      ObjectSetText(aPairs[i], aPairs[i] + " " + DoubleToStr(MarketInfo(aPairs[i],MODE_BID), MarketInfo(aPairs[i],MODE_DIGITS)));
      for(j=0; j<ArraySize(aPeriods); j++) //loop tf
      {
         for (k=0; k<3; k++)//loop percent h, l, c and draw the graph, percent of hlc
         {
            double p = aPercentHLC[i][j][k]; 
            string objname, sp;
            int dotcount;
            
            objname = aPairs[i]+aPeriods[j]+"col"+k;
            if (p >=0.0) sp = "+" + DoubleToStr(p,2); else sp=DoubleToStr(p,2);
            ObjectSetText(objname, sp);            
                       
            dotcount = getDot(MathAbs(p));
            for (m=0; m<20; m++)
            {
               //EURUSD43200col0dot0
               color clr;
               if (k==0) if (m<dotcount) clr =aDotClr[0]; else clr = aDotClr[2]; 
               if (k==1) if (m<dotcount) clr =aDotClr[1]; else clr = aDotClr[2];  
               if (k==2) 
                  if (m<dotcount && p>=0) clr = aDotClr[0]; 
                  else if (m<dotcount && p<0) clr = aDotClr[1]; 
                  else clr = aDotClr[2]; 
                                    
               objname = aPairs[i]+aPeriods[j]+"col"+k+"dot"+m;
               ObjectSet(objname, OBJPROP_COLOR,clr);      
            }
         }         
         
      }    
   }   
   
   //----
   return(0);
}
  
void layout()
{   
   int i,j,k, xpair, y, x, miny;
   int row;
   int dot;
   int y1=100, miny1=40, y2=275, miny2=200;
   
   
   for(i=0; i<ArraySize(aPairs); i++) //pair
   {      
      if (i>=14) row=1;
      
      xpair = (i*130)+20;
      if (row == 1) xpair = ((i-14)*130)+20;
      
      //draw pair label
      if (row ==0 ) objCreate(aPairs[i], xpair+15, miny1-35, aPairs[i], 10,"Verdana Bold",Yellow);
      else objCreate(aPairs[i], xpair+15, miny2-35, aPairs[i], 10,"Verdana Bold",Yellow);
      
      for (j=0; j<ArraySize(aPeriods); j++) //tf
      {
      
         x=xpair+((j*55)+15);
         //draw tf label
         if  (row ==0 ) objCreate(aPairs[i]+aPeriods[j], x, miny1-15, aPeriodsName[j], 9,"Verdana Bold",White);
         else objCreate(aPairs[i]+aPeriods[j], x, miny2-15, aPeriodsName[j], 9,"Verdana Bold",White);
         
         // draw the dot graph, percent label and number
         for (k=0; k<3; k++) //percent of h l c
         {         

            if (row==0) {y=y1; miny=miny1;}
            else {y=y2; miny=miny2;}
            
            dot=0;            
            
            while (y>=miny)
            {                           
               objCreate(aPairs[i]+aPeriods[j]+"col"+k+"dot"+dot, x, y, "n",11,"Wingdings",aDotClr[2]);                                                   
               y-=10;
               dot++;
            }
            
            if (row ==0 ) 
            {
               objCreate(aPairs[i]+aPeriods[j]+"col"+k+aStrHLC[k], x+1, y1+53, aStrHLC[k],7,"Tahoma",Goldenrod);
               objCreate(aPairs[i]+aPeriods[j]+"col"+k, x-3, y1+50, "0.00",9,"Verdana",White);
            }
            else 
            {
               objCreate(aPairs[i]+aPeriods[j]+"col"+k+aStrHLC[k], x+1, y2+53, aStrHLC[k],8,"Tahoma",Goldenrod);
               objCreate(aPairs[i]+aPeriods[j]+"col"+k, x-3, y2+50, "0.00",9,"Verdana",White);
            }
             
            ObjectSet(aPairs[i]+aPeriods[j]+"col"+k, OBJPROP_ANGLE, 90);
            x+=15;
            
         }
         
      }
      
   }
   
   
}

int getDot(double percent)
{

   if(percent>=4.00) return(20);
   if(percent>=3.80) return(19);
   if(percent>=3.60) return(18);
   if(percent>=3.40) return(17);
   if(percent>=3.20) return(16);
   if(percent>=3.00) return(15);
   if(percent>=2.80) return(14);
   if(percent>=2.60) return(13);
   if(percent>=2.40) return(12);
   if(percent>=2.20) return(11);
   if(percent>=2.00) return(10);
   if(percent>=1.80) return(9);
   if(percent>=1.60) return(8);
   if(percent>=1.40) return(7);
   if(percent>=1.20) return(6);
   if(percent>=1.00) return(5);
   if(percent>=0.80) return(4);
   if(percent>=0.60) return(3);
   if(percent>=0.40) return(2);
   if(percent>=0.20) return(1);
   if(percent>=0.00) return(1);

}
void objCreate(string name,int x,int y,string text="-",int size=35,
               string font="Arial",color colour=CLR_NONE)
{
 ObjectCreate(name,OBJ_LABEL,0,0,0);
 ObjectSet(name,OBJPROP_CORNER,0);
 ObjectSet(name,OBJPROP_COLOR,colour);
 ObjectSet(name,OBJPROP_XDISTANCE,x);
 ObjectSet(name,OBJPROP_YDISTANCE,y);
 ObjectSetText(name,text,size,font,colour);
}  
//+------------------------------------------------------------------+