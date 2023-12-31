//+------------------------------------------------------------------+ 
//|  TRO_Multi_Meter_CandleColor                                     | 
//|                                                                  | 
//|   Copyright � 2007, Avery T. Horton, Jr. aka TheRumpledOne       |
//|                                                                  |
//|   PO BOX 43575, TUCSON, AZ 85733                                 |
//|                                                                  |
//|   GIFT AND DONATIONS ACCEPTED                                    | 
//|                                                                  |
//|   therumpldone@gmail.com                                         |  
//+------------------------------------------------------------------+ 
//|                                                                  |
//| go to www.kreslik.com for the latest indicator updates           |  
//+------------------------------------------------------------------+ 
//|                                                                  |
//| Use http://therumpledone.mbtrading.com/fx/ as your forex broker  |  
//| ...tell them therumpledone sent you!                             |  
//+------------------------------------------------------------------+ 

// thank you Xard777 from www.forex-tsd.com for showing me how to delete the objects properly.
// thank you mladen from www.forex-tsd.com for showing me I had a locals and global variables with same name 


#property indicator_chart_window

extern bool Show_Heading = true;
 
extern string IndName = "CAN" ; // change

extern bool Corner_of_Chart_RIGHT_TOP = true;

extern int Shift_UP_DN =0; 
extern int Adjust_Side_to_side  = 20; // 20

extern color BarLabel_color     = SteelBlue;
extern color CommentLabel_color = SteelBlue;

extern color Up_color = Lime;
extern color Eq_color = Yellow;
extern color Dn_color = Red;
//******************* 
// change inputs for your indicator 

extern int MA_Fast = 1;
extern int MA_Slow = 5;
extern int MA_MODE = 1;
extern int MA_PRICE_TYPE = 0;

//*******************

string ObjHead01,ObjHead02,ObjHead03,ObjHead04,ObjHead05,ObjHead06,ObjHead07,ObjHead08,ObjHead09,ObjHead10,ObjHead11;  

string Obj0001,Obj0002,Obj0003,Obj0004,Obj0005,Obj0006,Obj0007,Obj0008,Obj0009,Obj0010,Obj0011;  

string symbol, tChartPeriod,  tShortName ;  
int    digits, period  ; 

string LabelTime="";

   string CAN_ObjHead01 ="M1 " ;
   string CAN_ObjHead02 ="M5  " ;     
   string CAN_ObjHead03 ="M15 " ;
   string CAN_ObjHead04 =" M30 " ;
   string CAN_ObjHead05 ="H1  " ;     
   string CAN_ObjHead06 ="H4  " ;
   string CAN_ObjHead07 ="D1  " ;
   string CAN_ObjHead08 ="W1  " ;
   string CAN_ObjHead09 ="MN1" ;   


//+---------------
double prDiff(int i, int j)
{
  double _Diff = ( iClose( NULL , i,j) - iOpen( NULL , i,j) ) ;
  return (_Diff);
}

//+------------------------------------------------------------------+
int init()
  {
//---- 
   period       = Period() ;   
   tChartPeriod = TimeFrameToString(period) ;
   symbol       = Symbol() ;
   LabelTime    = symbol + tChartPeriod  ;  



//ObjectsDeleteAll(0); 


   ObjHead01 = "CANColHead01"  ; 
   ObjHead02 = "CANColHead02"  ; 
   ObjHead03 = "CANColHead03"  ; 
   ObjHead04 = "CANColHead04"  ; 
   ObjHead05 = "CANColHead05"  ; 
   ObjHead06 = "CANColHead06"  ; 
   ObjHead07 = "CANColHead07"  ; 
   ObjHead08 = "CANColHead08"  ; 
   ObjHead09 = "CANColHead09"  ; 
         
   Obj0002 = "CANSignalM1t" ; 
   Obj0003 = "CANSignalM1" ;  
   Obj0004 = "CANSignalM5" ;  
   Obj0005 = "CANSignalM15" ;    
   Obj0006 = "CANSignalM30" ;    
   Obj0007 = "CANSignalM60" ;     
   Obj0008 = "CANSignalM240" ;   
   Obj0009 = "CANSignalM1440" ;   
   Obj0010 = "CANSignalW1" ;  
   Obj0011 = "CANSignalMN1" ;      
 
deleteObject() ; 
   
//----
   return(0);
  }


//+------------------------------------------------------------------+
int start()
{    



   
   
        
    if (Corner_of_Chart_RIGHT_TOP == true)
    { int Col01x = 170+Adjust_Side_to_side ;                 
      int Col01y = 28+Shift_UP_DN ;
    }
    if (Corner_of_Chart_RIGHT_TOP == false)
   { Col01x = 159+Adjust_Side_to_side ;       
     Col01y = 24+Shift_UP_DN ;
    } 
    
   int ColAdj = -20 ; 
   int Col02x = Col01x + ColAdj ;   
   int Col03x = Col01x + ColAdj*2 ; 
   int Col04x = Col01x + ColAdj*3 ; 
   int Col05x = Col01x + ColAdj*4 ; 
   int Col06x = Col01x + ColAdj*5 ; 
   int Col07x = Col01x + ColAdj*6 ;    
   int Col08x = Col01x + ColAdj*7 ; 
   int Col09x = Col01x + ColAdj*8 ;     
   
   if ( Show_Heading) {        
   ObjectCreate(ObjHead01, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(ObjHead01,CAN_ObjHead01 , 7, "Tahoma Narrow", BarLabel_color);
   ObjectSet(ObjHead01, OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet(ObjHead01, OBJPROP_XDISTANCE, Col01x);
   ObjectSet(ObjHead01, OBJPROP_YDISTANCE, Col01y); 

   ObjectCreate(ObjHead02, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(ObjHead02,CAN_ObjHead02 , 7, "Tahoma Narrow", BarLabel_color);
   ObjectSet(ObjHead02, OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet(ObjHead02, OBJPROP_XDISTANCE, Col02x);
   ObjectSet(ObjHead02, OBJPROP_YDISTANCE, Col01y);   
       
   ObjectCreate(ObjHead03, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(ObjHead03,CAN_ObjHead03 , 7, "Tahoma Narrow", BarLabel_color);
   ObjectSet(ObjHead03, OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet(ObjHead03, OBJPROP_XDISTANCE, Col03x);
   ObjectSet(ObjHead03, OBJPROP_YDISTANCE, Col01y); 
 
   ObjectCreate(ObjHead04, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(ObjHead04,CAN_ObjHead04 , 7, "Tahoma Narrow", BarLabel_color);
   ObjectSet(ObjHead04, OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet(ObjHead04, OBJPROP_XDISTANCE, Col04x);
   ObjectSet(ObjHead04, OBJPROP_YDISTANCE, Col01y); 
   
   ObjectCreate(ObjHead05, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(ObjHead05,CAN_ObjHead05 , 7, "Tahoma Narrow", BarLabel_color);
   ObjectSet(ObjHead05, OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet(ObjHead05, OBJPROP_XDISTANCE, Col05x);
   ObjectSet(ObjHead05, OBJPROP_YDISTANCE, Col01y); 
            
   ObjectCreate(ObjHead06, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(ObjHead06,CAN_ObjHead06 , 7, "Tahoma Narrow", BarLabel_color);
   ObjectSet(ObjHead06, OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet(ObjHead06, OBJPROP_XDISTANCE, Col06x);
   ObjectSet(ObjHead06, OBJPROP_YDISTANCE, Col01y); 

   ObjectCreate(ObjHead07, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(ObjHead07,CAN_ObjHead07 , 7, "Tahoma Narrow", BarLabel_color);
   ObjectSet(ObjHead07, OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet(ObjHead07, OBJPROP_XDISTANCE, Col07x);
   ObjectSet(ObjHead07, OBJPROP_YDISTANCE, Col01y); 
         
   ObjectCreate(ObjHead08, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(ObjHead08,CAN_ObjHead08 , 7, "Tahoma Narrow", BarLabel_color);
   ObjectSet(ObjHead08, OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet(ObjHead08, OBJPROP_XDISTANCE, Col08x);
   ObjectSet(ObjHead08, OBJPROP_YDISTANCE, Col01y); 

   ObjectCreate(ObjHead09, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(ObjHead09,CAN_ObjHead09 , 7, "Tahoma Narrow", BarLabel_color);
   ObjectSet(ObjHead09, OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet(ObjHead09, OBJPROP_XDISTANCE, Col09x);
   ObjectSet(ObjHead09, OBJPROP_YDISTANCE, Col01y); 
       
} // Show_Heading
 
 
    
    string M1_CAN= "-",M5_CAN= "-", M15_CAN= "-", M30_CAN= "-", H1_CAN= "-", H4_CAN= "-", D1_CAN= "-",PRC1, W1_CAN= "-", MN1_CAN= "-";

    color  color_CANm1,color_CANm5,color_CANm15,color_CANm30,color_CANH1,color_CANH4,color_CAND1,color_CANW1,color_CANMN1;     
         

   //CAN Signals

 
    double CAN_M1  = prDiff( PERIOD_M1, 0 );
    double CAN_M5  = prDiff( PERIOD_M5, 0 );
    double CAN_M15 = prDiff( PERIOD_M15, 0 );
    double CAN_M30 = prDiff( PERIOD_M30, 0 );
    double CAN_H1  = prDiff( PERIOD_H1, 0 );
    double CAN_H4  = prDiff( PERIOD_H4, 0 ); 
    double CAN_D1  = prDiff( PERIOD_D1, 0 );
    double CAN_W1  = prDiff( PERIOD_W1, 0 );
    double CAN_MN1 = prDiff( PERIOD_MN1, 0 );
 
   
    if ( CAN_M1 > 0 ) color_CANm1 = Up_color; 
    else {
    if ( CAN_M1 < 0 )  color_CANm1 = Dn_color; 
    else color_CANm1 = Eq_color; }
      
    if (CAN_M5 >0)  color_CANm5 = Up_color; 
    else {
    if (CAN_M5 <0)  color_CANm5 = Dn_color; 
    else color_CANm5 = Eq_color; }
        
    if (CAN_M15>0) color_CANm15 = Up_color; 
    else {
    if (CAN_M15<0)   color_CANm15 = Dn_color; 
    else color_CANm15 = Eq_color; }
    
    if (CAN_M30>0) color_CANm30 = Up_color; 
    else {
    if (CAN_M30<0) color_CANm30 = Dn_color; 
    else color_CANm30 = Eq_color; }

    if ( CAN_H1>0) color_CANH1 = Up_color; 
    else {
    if ( CAN_H1<0) color_CANH1 = Dn_color; 
    else color_CANH1 = Eq_color; }

    if (CAN_H4>0) color_CANH4 = Up_color; 
    else {
    if (CAN_H4<0) color_CANH4 = Dn_color; 
    else color_CANH4 = Eq_color; }

    if (CAN_D1>0) color_CAND1 = Up_color; 
    else {
    if (CAN_D1<0) color_CAND1 = Dn_color; 
    else color_CAND1 = Eq_color; }

    if (CAN_W1>0)  color_CANW1 = Up_color; 
    else {
    if (CAN_W1<0)  color_CANW1 = Dn_color; 
    else color_CANW1 = Eq_color; }

    if (CAN_MN1>0)  color_CANMN1 = Up_color; 
    else {
    if (CAN_MN1<0)   color_CANMN1 = Dn_color; 
    else color_CANMN1 = Eq_color; }

             
    
 //*******************          
    
    int Col00x = Col01x + 20 ;
    int Col00y = 50+Shift_UP_DN ;
    
    Col01y = 20+Shift_UP_DN ;
    
             
           ObjectCreate(Obj0002, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(Obj0002,IndName, 7, "Tahoma Narrow",  BarLabel_color);  
   ObjectSet(Obj0002, OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet(Obj0002, OBJPROP_XDISTANCE, Col00x);
   ObjectSet(Obj0002, OBJPROP_YDISTANCE, Col00y);  // 50+Shift_UP_DN

      
           ObjectCreate(Obj0003, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(Obj0003, M1_CAN, 40, "Tahoma Narrow",  color_CANm1);
   ObjectSet(Obj0003, OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet(Obj0003, OBJPROP_XDISTANCE, Col01x);
   ObjectSet(Obj0003, OBJPROP_YDISTANCE, Col01y); 

          
           ObjectCreate(Obj0004, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(Obj0004, M5_CAN, 40, "Tahoma Narrow",  color_CANm5);
   ObjectSet(Obj0004, OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet(Obj0004, OBJPROP_XDISTANCE, Col02x);
   ObjectSet(Obj0004, OBJPROP_YDISTANCE, Col01y); 
      

   ObjectCreate(Obj0005, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(Obj0005, M15_CAN, 40, "Tahoma Narrow",  color_CANm15);
   ObjectSet(Obj0005, OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet(Obj0005, OBJPROP_XDISTANCE, Col03x);
   ObjectSet(Obj0005, OBJPROP_YDISTANCE, Col01y); 
      

   ObjectCreate(Obj0006, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(Obj0006, M30_CAN, 40, "Tahoma Narrow",  color_CANm30);
   ObjectSet(Obj0006, OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet(Obj0006, OBJPROP_XDISTANCE, Col04x);
   ObjectSet(Obj0006, OBJPROP_YDISTANCE, Col01y); 

    
           ObjectCreate(Obj0007, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(Obj0007, H1_CAN, 40, "Tahoma Narrow",  color_CANH1);
   ObjectSet(Obj0007, OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet(Obj0007, OBJPROP_XDISTANCE, Col05x);
   ObjectSet(Obj0007, OBJPROP_YDISTANCE, Col01y); 

          
           ObjectCreate(Obj0008, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(Obj0008, H4_CAN, 40, "Tahoma Narrow",  color_CANH4);
   ObjectSet(Obj0008, OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet(Obj0008, OBJPROP_XDISTANCE, Col06x);
   ObjectSet(Obj0008, OBJPROP_YDISTANCE, Col01y);

    
           ObjectCreate(Obj0009, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(Obj0009, D1_CAN, 40, "Tahoma Narrow",  color_CAND1);
   ObjectSet(Obj0009, OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet(Obj0009, OBJPROP_XDISTANCE, Col07x);
   ObjectSet(Obj0009, OBJPROP_YDISTANCE, Col01y);
   
    
           ObjectCreate(Obj0010, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(Obj0010, W1_CAN, 40, "Tahoma Narrow",  color_CANW1);
   ObjectSet(Obj0010, OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet(Obj0010, OBJPROP_XDISTANCE, Col08x);
   ObjectSet(Obj0010, OBJPROP_YDISTANCE, Col01y);   
   
   
           ObjectCreate(Obj0011, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(Obj0011, MN1_CAN, 40, "Tahoma Narrow",  color_CANMN1);
   ObjectSet(Obj0011, OBJPROP_CORNER, Corner_of_Chart_RIGHT_TOP);
   ObjectSet(Obj0011, OBJPROP_XDISTANCE, Col09x);
   ObjectSet(Obj0011, OBJPROP_YDISTANCE, Col01y); 
     
   WindowRedraw() ;   
 
   return(0);
  }
//+------------------------------------------------------------------+

int deinit()
{
 
   deleteObject() ;
 
   return(0);
}

//+------------------------------------------------------------------+
  
void deleteObject()
{ 

if (ObjectFind(Obj0002) != -1) {ObjectDelete(Obj0002); }
if (ObjectFind(Obj0003) != -1) {ObjectDelete(Obj0003); } 
if (ObjectFind(Obj0004) != -1) {ObjectDelete(Obj0004); } 
if (ObjectFind(Obj0005) != -1) {ObjectDelete(Obj0005); } 
if (ObjectFind(Obj0006) != -1) {ObjectDelete(Obj0006); } 
if (ObjectFind(Obj0007) != -1) {ObjectDelete(Obj0007); } 
if (ObjectFind(Obj0008) != -1) {ObjectDelete(Obj0008); } 
if (ObjectFind(Obj0009) != -1) {ObjectDelete(Obj0009); } 
if (ObjectFind(Obj0010) != -1) {ObjectDelete(Obj0010); } 
if (ObjectFind(Obj0011) != -1) {ObjectDelete(Obj0011); } 

ObjectDelete(ObjHead01);  
ObjectDelete(ObjHead02); 
ObjectDelete(ObjHead03); 
ObjectDelete(ObjHead04); 
ObjectDelete(ObjHead05); 
ObjectDelete(ObjHead06); 
ObjectDelete(ObjHead07); 
ObjectDelete(ObjHead08); 
ObjectDelete(ObjHead09); 


 
  }

//+------------------------------------------------------------------+
 
string TimeFrameToString(int tf)
{
   string tfs;
   switch(tf) {
      case PERIOD_M1:  tfs="M1"  ; break;
      case PERIOD_M5:  tfs="M5"  ; break;
      case PERIOD_M15: tfs="M15" ; break;
      case PERIOD_M30: tfs="M30" ; break;
      case PERIOD_H1:  tfs="H1"  ; break;
      case PERIOD_H4:  tfs="H4"  ; break;
      case PERIOD_D1:  tfs="D1"  ; break;
      case PERIOD_W1:  tfs="W1"  ; break;
      case PERIOD_MN1: tfs="MN";
   }
   return(tfs);
}

//+------------------------------------------------------------------+
 
/*

   ObjHead01 = "CANColHead01" + LabelTime ; 
   ObjHead02 = "CANColHead02" + LabelTime ; 
   ObjHead03 = "CANColHead03" + LabelTime ; 
   ObjHead04 = "CANColHead04" + LabelTime ; 
   ObjHead05 = "CANColHead05" + LabelTime ; 
   ObjHead06 = "CANColHead06" + LabelTime ; 
   ObjHead07 = "CANColHead07" + LabelTime ; 
   ObjHead08 = "CANColHead08" + LabelTime ; 
   ObjHead09 = "CANColHead09" + LabelTime ; 
 

ObjectDelete(CAN_ObjHead01);  
ObjectDelete(CAN_ObjHead02); 
ObjectDelete(CAN_ObjHead03); 
ObjectDelete(CAN_ObjHead04); 
ObjectDelete(CAN_ObjHead05); 
ObjectDelete(CAN_ObjHead06); 
ObjectDelete(CAN_ObjHead07); 
ObjectDelete(CAN_ObjHead08); 
ObjectDelete(CAN_ObjHead09);  
 

   Obj0002 = "CANSignalM1t" + LabelTime ; 
   Obj0003 = "CANSignalM1" + LabelTime ;  
   Obj0004 = "CANSignalM5" + LabelTime ;  
   Obj0005 = "CANSignalM15" + LabelTime ;    
   Obj0006 = "CANSignalM30" + LabelTime ;    
   Obj0007 = "CANSignalM60" + LabelTime ;     
   Obj0008 = "CANSignalM240" + LabelTime ;   
   Obj0009 = "CANSignalM1440" + LabelTime ;   
   Obj0010 = "CANSignalW1" + LabelTime ;  
   Obj0011 = "CANSignalMN1" + LabelTime ;      
  
         
*/