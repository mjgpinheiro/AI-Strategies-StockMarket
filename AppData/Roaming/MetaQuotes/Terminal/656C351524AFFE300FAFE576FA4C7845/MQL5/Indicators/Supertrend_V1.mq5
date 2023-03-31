//+------------------------------------------------------------------+
//|                                                Supertrend_V1.mq5 |
//|                                              Copyright 2023, MJP |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MJP"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
//+------------------------------------------------------------------+
//|                                                     SuperTrend.mq5 |
//|                                                                  |
//|                                         Copyright 2016, MetaQuotes |
//|                                             https://www.mql5.com  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
#property indicator_label1  "SuperTrend"
#property indicator_minimum -100
#property indicator_maximum 100

input int       ATR_Period=10;          // ATR period
input double    ATR_Multiplier=2.0;     // ATR multiplier
input ENUM_APPLIED_PRICE   Price = PRICE_CLOSE;  // Price type for calculation
input int       Shift = 0;              // Bar shift for calculation

double UpBuffer[];
double DnBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- check for input parameters
   if(ATR_Period<=0) return(INIT_FAILED);
   if(ATR_Multiplier<=0) return(INIT_FAILED);
//--- indicator buffers mapping
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---
   PlotIndexSetInteger(0,PLOT_EMPTY_VALUE,0);
//--- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"SuperTrend("+ATR_Period+","+ATR_Multiplier+")");
   IndicatorSetString(INDICATOR_LEVELS,"-100;100");
   IndicatorSetString(INDICATOR_LEVELS,"-100;100");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| SuperTrend                                                        |
//+------------------------------------------------------------------+
double SuperTrend(int shift, ENUM_APPLIED_PRICE Price, int ATR_Period, double ATR_Multiplier, double& UpTrend, double& DownTrend)
  {
   double ATR=0,PrevATR=0,UpperBand=0,LowerBand=0,PrevClose=0,PrevUpTrend=0,PrevDownTrend=0;
   double Up=0,Dn=0;
//--- loop for bars
   for(int i=shift;i>=0;i--)
     {
      //--- calculate ATR
      if(i==shift)
        ATR=iATR(NULL,0,ATR_Period);
      else if(i==(shift+1))
        ATR=iATR(NULL,0,ATR_Period);
      else
        {
         PrevATR=ATR;
         ATR=(PrevATR*(ATR_Period-1)+MathMax(High[i],PrevClose)-MathMin(Low[i],PrevClose))/ATR_Period;
        }
      //--- calculate Bands
      UpperBand=(High[i]+Low[i])/2.0+ATR*ATR_Multiplier;
      LowerBand=(High[i]+Low[i])/2.0-ATR*ATR_Multiplier;
      //--- calculate UpTrend & DownTrend
      PrevUpTrend=UpTrend;
      PrevDownTrend=DownTrend
