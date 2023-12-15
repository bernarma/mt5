//+------------------------------------------------------------------+
//|                                                    Color RSI.mq5 |
//|                                 Copyright 2023, Mark Bernardinis |
//|                                   https://www.mtnsconsulting.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Mark Bernardinis"
#property link      "https://www.mtnsconsulting.com"

//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing indicator as a three-colored line
#property indicator_type1 DRAW_COLOR_LINE
//---- the following colors are used in a three-colored line
#property indicator_color1 clrRed,clrBlue,clrLime
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the signal line label
#property indicator_label1  "ColorRSI"
//+-----------------------------------+
//|  declaration of constants         |
//+-----------------------------------+
#define RESET  0 // The constant for getting the command for the indicator recalculation back to the terminal

//+-----------------------------------+
//|  declaration of enumerations      |
//+-----------------------------------+
enum WIDTH //Type of constant
  {
   W1 = 1,     //1
   W2,         //2
   W3,         //3
   W4,         //4
   W5          //5
  };
//+-----------------------------------+
//|  declaration of enumerations      |
//+-----------------------------------+
enum STYLE //Type of constant
  {
   SOLID = 0,     //Solid line
   DASH,       //Dashed line
   DOT,        //Dotted line
   DASHDOT,    //Dot-dash line
   DASHDOTDOT     //Dash-dot-dot line
  };
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input int iRSIPeriod=14;                              // RSI period
input ENUM_APPLIED_PRICE   iRSIPrice=PRICE_CLOSE;     // Price timeseries 
input int iHighLevel=60;                              // Overbought level
input int iMiddleLevel=50;                            // Medium of the range
input int iLowLevel=40;                               // Oversold level
input color iColor=clrDarkViolet;                     // Levels color
input STYLE iStyle=STYLE_DASHDOT;                     // levels execution style
input WIDTH iWidth=W1;                                // Levels width

//+-----------------------------------+
//---- declaration of dynamic arrays that further
//---- will be used as indicator buffers
double ColorBuffer[],ExtLineBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- Declaration of integer variables for the indicator handles
int RSI_Handle;
//---- declaration of the integer variables for the start of data calculation
int HighLevel,MiddleLevel,LowLevel;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=iRSIPeriod;
//---- initialization of variables 
   HighLevel=MathMin(100,MathMax(0,iHighLevel));
   MiddleLevel=MathMin(100,MathMax(0,iMiddleLevel));
   LowLevel=MathMin(100,MathMax(0,iLowLevel));
   
//---- get handle of the iRSI indicator
   RSI_Handle=iRSI(NULL,0,iRSIPeriod,iRSIPrice);
   if(RSI_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iRSI indicator");
   
//---- set ExtLineBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"ColorRSI(",iRSIPeriod,")");
//--- create label to display in Data Window
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//---- creating name for displaying if separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determine the accuracy of displaying indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- set dynamic array as as a color index buffer   
   SetIndexBuffer(1,ColorBuffer,INDICATOR_COLOR_INDEX);
   
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtLineBuffer,true);
   ArraySetAsSeries(ColorBuffer,true);
   
//---- the number of the indicator 3 horizontal levels   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- values of the indicator horizontal levels   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,MiddleLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
//---- gray and magenta colors are used for horizontal levels lines  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,iColor);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,iColor);
//---- horizontal level line is a short dash-and-dot line  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,iStyle);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,iStyle);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,iStyle);
//---- width of level lines
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,0,int(iWidth));
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,1,int(iWidth));
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,2,int(iWidth));
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking for the sufficiency of the number of bars for the calculation
   if(BarsCalculated(RSI_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int to_copy,limit,bar,clr;

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-1-min_rates_total; // starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }

//---- calculation of the necessary amount of data to be copied
   to_copy=limit+1;
   
//---- copy newly appeared data into the arrays
   if(CopyBuffer(RSI_Handle,0,0,to_copy,ExtLineBuffer)<=0) return(RESET);

//---- main loop of indicator calculation
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      clr=1;
      double res=ExtLineBuffer[bar];
      
      if(res>HighLevel) clr=2;
      else if(res<LowLevel) clr=0;      
      
      ColorBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
