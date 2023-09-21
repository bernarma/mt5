//+------------------------------------------------------------------+
//|                                                    propsense.mq5 |
//+------------------------------------------------------------------+

// based on https://wddbbddb.notion.site/Prop-Firm-Passed-5m-Scalping-bab5baa1da3744109c108f95012a281a

// TODO: Outstanding Items
// - Sometimes the historical book lines are not removed (assuming this is when "out of session" but still need to clean up)
// - Add label to fixes
// - add buy/sell to candle with price level extended
// - update book level (possibly grey or user configurable color) if it will be closed based on current forming candle
// - add book levels (use what has been done on the trading view one)
// - show bias (use what has been done on the trading view one)

#property version   "1.02"
#property indicator_chart_window

#property indicator_plots   0

#include <Generic\Stack.mqh>
#include <Generic\Queue.mqh>
#include <Generic\ArrayList.mqh>
#include "CisNewBar.mqh"
#include "Sessions.mqh"
#include "Fixes.mqh"

class CPointOfInterest {
   public:
      int index;
      datetime period;
      double price;
      string name;
};

enum CANDLE_DIR {
   BULL_DIR = 1,
   NONE_DIR = 0,
   BEAR_DIR = -1
};

CisNewBar current_chart; // instance of the CisNewBar class: current chart

//--- input parameters
input int            InpMaxLevelsToShow     = 5;        // Max Levels to Show
input int            InpLookbackBars        = 999;        // Max Lookback to Show

input color          InpBullish = clrBlue; // Level Color (Bullish)
input color          InpBearish = clrRed; // Level Color (Bearish)

input ENUM_LINE_STYLE InpLineStyle = STYLE_SOLID; // Line Style
input int            InpLineWidth = 1;        // Line Width

input bool InpOnlyInSession = true; // Filter with Market Sessions

///--- NEW
input int  InpMaxHistoricalSessionsToShow     = 10;        // Max Historical Sessions to Show

input double InpSessionTimeZones = 8.00; // Timezone

input bool InpShowSession1 = true; // Show Session 1
input bool InpShowNextSession1 = true; // Show Session 1
input string InpSession1Name = "Asia"; // Session 1 Name
input color InpSession1Color = clrBlueViolet; // Session 1 Color
input double InpSession1Start = 07.00; // Session 1 Time (Start)
input double InpSession1End = 16.00; // Session 1 Time (End)

input bool InpShowSession2 = true; // Show Session 2
input bool InpShowNextSession2 = true; // Show Session 2
input string InpSession2Name = "London"; // Session 2 Name
input color InpSession2Color = clrGold; // Session 2 Color
input double InpSession2Start = 15.00; // Session 2 Time (Start)
input double InpSession2End = 00.00; // Session 2 Time (End)

input bool InpShowSession3 = true; // Show Session 3
input bool InpShowNextSession3 = true; // Show Session 3
input string InpSession3Name = "New York"; // Session 3 Name
input color InpSession3Color = clrLimeGreen; // Session 3 Color
input double InpSession3Start = 20.00; // Session 3 Time (Start)
input double InpSession3End = 05.00; // Session 3 Time (End)

//input bool InpShowCurrentBias =  true; // Show Current Bias
//input ENUM_ANCHOR_POINT InpLocation; // Location
//input ENUM_TEST InpSize = ENUM_AUTO; // Size

////// Constants //////
//const int LINE_OFFSET = 15
const int MAX_LINE = 250; // 250 on each side = 500 lines in total
const int MAX_BEAR_CD_LOOKBACK = 2;
//const string GMT = "GMT+0";

input bool InpShowTokyoFix = true; // Show the Tokyo Fix
input color InpTokyoFixColor = clrDarkGoldenrod; // Tokyo Fix Color
input ENUM_LINE_STYLE InpTokyoFixStyle = STYLE_DOT; // Tokyo Fix Style
double TokyoFixTz = 9.00;
double TokyoFix = 9.55;
//TOKYO_FIX = '0055-0100' // 9:55am Tokyo time(GMT+9)

input bool InpShowLondonFix = true; // Show the London Fix
input color InpLondonFixColor = clrPaleGoldenrod; // London Fix Color
input ENUM_LINE_STYLE InpLondonFixStyle = STYLE_DOT; // London Fix Style
double LondonFixTz = 1.00;
double LondonFix = 15.00;
//LONDON_FIX = '1500-1501' // 4pm London time(GMT+1)

CANDLE_DIR gBias = NONE_DIR;

CArrayList<CANDLE_DIR> prevCandleArr();
CArrayList<CPointOfInterest *> bearLvArr();
CArrayList<CPointOfInterest *> bullLvArr();

CFixes *g_Fixes;
CSessions *g_Sessions;

double mostRecentBear = NULL;
double mostRecentBull = NULL;
double lastBearCdOpen = NULL;

int lastBearCdIndex = NULL;
bool isLastBearCdBroken = false;

CStack<CPointOfInterest *> invalidLvIndexArr();

bool isInitialised = false;
bool inAs, inLdn, inNy;

void Clean(CArrayList<CPointOfInterest *> &book)
{
   while (book.Count() > 0)
   {   
      CPointOfInterest *poi;
      if (book.TryGetValue(0, poi))
      {
         TrendDelete(0, poi.name);
         book.Remove(poi);
         delete poi;
      }
   }
}

void OnDeinit(const int reason)
{
   PrintFormat("Shutting Down (propsense)");

   Clean(bearLvArr);
   Clean(bullLvArr);
   
   delete g_Fixes;

   delete g_Sessions;
   
   isInitialised = false;
}

void OnTimer()
{
   if (!isInitialised)
   {
      datetime dt = TimeTradeServer() - TimeGMT();
      
      PrintFormat("Server Initialised with Date/Time %s, Calculated using TimeTradeServer=%s\nTimeGMT=%s, TimeGMTOffset=%i, TimeLocal=%s, %i",
         TimeToString(dt),
         TimeToString(TimeTradeServer()),
         TimeToString(TimeGMT()),
         TimeGMTOffset(),
         TimeToString(TimeLocal()),
         (int)dt);
         
      g_Sessions = new CSessions();
            
      g_Fixes = new CFixes(2);
      
      // Initialise Fixes
      if (InpShowTokyoFix)
      {
         g_Fixes.CreateFix("Tokyo", TokyoFix, (int)(TokyoFixTz*60*60), (int)dt, InpTokyoFixColor, InpTokyoFixStyle);
      }
      if (InpShowLondonFix)
      {
         g_Fixes.CreateFix("London", LondonFix, (int)(LondonFixTz*60*60), (int)dt, InpLondonFixColor, InpLondonFixStyle);
      }
      
      if (InpShowSession1)
      {
         g_Sessions.CreateSession(InpSession1Name, InpSession1Color, InpMaxHistoricalSessionsToShow, InpSession1Start, InpSession1End, (int)InpSessionTimeZones*60*60, (int)dt);
      }
      
      if (InpShowSession2)
      {
         g_Sessions.CreateSession(InpSession2Name, InpSession2Color, InpMaxHistoricalSessionsToShow, InpSession2Start, InpSession2End, (int)InpSessionTimeZones*60*60, (int)dt);
      }      
      
      if (InpShowSession3)
      {
         g_Sessions.CreateSession(InpSession3Name, InpSession3Color, InpMaxHistoricalSessionsToShow, InpSession3Start, InpSession3End, (int)InpSessionTimeZones*60*60, (int)dt);
      }
            
      PrintFormat("Initialised (propsense)");
      isInitialised = true;
   }
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   gBias = NONE_DIR;
   
   //--- Delay a second to give MT5 a chance to startup before attempting to query the server
   //--- for timezone information and other bits that can cause failures during startup of the platform
   EventSetTimer(1);
   
   PrintFormat("Started (propsense)");
   
   //---
   return(INIT_SUCCEEDED);
}
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   //---
   if (rates_total == 0)
      return (rates_total);

   if (!isInitialised) return(0);

   //--- Only calculate historically from InpLookbackBars
   int start = MathMax(rates_total - InpLookbackBars, prev_calculated);

   //--- Loop through the periods in the window except the last candle (which is the active one)
   for(int i = start; i < rates_total && !IsStopped(); i++)
   {
      ProcessBar(i, time, open, high, low, close);
   }
   
   // Process the active one (this will affect the high/low and start/end
   ProcessBar(rates_total - 1, time, open, high, low, close, true);
   
   // Number of seconds in current chart period
   int period_seconds=PeriodSeconds(_Period);
   
   // Time of bar opening on current chart
   datetime new_time = TimeCurrent() / period_seconds * period_seconds;
   
   // When new bar appears - launch the NewBar event handler
   if(current_chart.isNewBar(new_time)) OnNewBar(rates_total, time, open, high, low, close);

   //--- return value of prev_calculated for next call
   return(rates_total);
}

//+------------------------------------------------------------------+

void ProcessBar(const int current,
               const datetime &time[],
               const double &open[],
               const double &high[],
               const double &low[],
               const double &close[],
               bool stillForming = false)
{
   // initialise to value of first bar - does this get hit if we start somewhere in the middle of the range due to optimisation?
   if (current == 0)
   {
      mostRecentBull = NULL;
      lastBearCdIndex = 0;
      lastBearCdOpen = open[0];
      isLastBearCdBroken = false;
   }
   
   // update the sessions (including highs/lows and bounding box)
   bool inSess;
   g_Sessions.ProcessTime(time[current], open[current], high[current], low[current], close[current], inSess);

   // update the fixes
   g_Fixes.Handle(time[current], open[current]);
      
   if (stillForming) return;

   // if previous candle is not neutral
   if (current > 0 && !IsNeutralCandle(open[current-1], high[current-1], low[current-1], close[current-1]))
   {
      prevCandleArr.Add(CandleDir(open[current-1], high[current-1], low[current-1], close[current-1]));
      if (prevCandleArr.Count() > MAX_BEAR_CD_LOOKBACK)
         prevCandleArr.RemoveAt(0); // RemoveAt(0) = shift
   }

   CANDLE_DIR lBias = gBias;

   bool isBearLv = false;
   if (prevCandleArr.Count() == MAX_BEAR_CD_LOOKBACK)
   {
      CANDLE_DIR dir1, dir2;
      prevCandleArr.TryGetValue(0, dir1);
      prevCandleArr.TryGetValue(1, dir2);
      
      isBearLv = IsBullDir(dir1) && IsBearDir(dir2) && IsBearCandle(open[current], high[current], low[current], close[current]);
   }
   
   if (isBearLv)
      lBias = BEAR_DIR;

   if (inSess && isBearLv)
   {
      mostRecentBear = close[current - 1];
      
      CPointOfInterest *poi = new CPointOfInterest();
      poi.name = StringFormat("BEAR_LVL[%s]", TimeToString(time[current - 1]));
      poi.period = time[current - 1];
      poi.price = mostRecentBear;
      poi.index = current - 1;
            
      bearLvArr.Add(poi);
      TrendCreate(0, poi.name, 0, poi.period, mostRecentBear, poi.period+600, mostRecentBear, InpBearish, InpLineStyle, InpLineWidth, false, false, false, true);
      
      TrimLineArr(bearLvArr, MAX_LINE);
   }
   
   for (int i = 0; i < bearLvArr.Count(); i++)
   {
      CPointOfInterest *poi;
      if (bearLvArr.TryGetValue(i, poi))
      {
         if (close[current] > poi.price || IsLineExpired(current, poi))
         {
            invalidLvIndexArr.Push(poi);
         }
      }
   }
   
   while (invalidLvIndexArr.Count() > 0)
   {
      CPointOfInterest *l = invalidLvIndexArr.Pop();
      bool bSuccess = bearLvArr.Remove(l);
      TrendDelete(0, l.name);
      delete l;
   }
   
   ColorizeLevels(bearLvArr, InpBearish);

   // Bullish Levels : bull & close > last bear open
   
   if (IsBearCandle(open[current], high[current], low[current], close[current]))
   {
       lastBearCdOpen = open[current];
       lastBearCdIndex = current;
       isLastBearCdBroken = false;
   }
       
   bool isBullLv = IsBullCandle(open[current], high[current], low[current], close[current]) && close[current] > lastBearCdOpen && !isLastBearCdBroken;
   if (isBullLv)
   {
       isLastBearCdBroken = true;
       lBias = BULL_DIR;
   }
   
   if (inSess && isBullLv)
   {
       mostRecentBull = lastBearCdOpen;
       
       CPointOfInterest *poi = new CPointOfInterest();
       poi.name = StringFormat("BULL_LVL[%s]", TimeToString(time[current]));
       poi.period = time[current] - (PeriodSeconds() * (current - lastBearCdIndex));
       poi.price = mostRecentBull; // Set to "Previous" Candles Open (the high of the last bull)
       poi.index = lastBearCdIndex;

       bullLvArr.Add(poi);
       
       TrendCreate(0, poi.name, 0, poi.period, mostRecentBull, poi.period+600, mostRecentBull, InpBullish, InpLineStyle, InpLineWidth, false, false, false, true);

       TrimLineArr(bullLvArr, MAX_LINE);
   }
   
   for (int i = 0; i < bullLvArr.Count(); i++)
   {
      CPointOfInterest *poi;
      if (bullLvArr.TryGetValue(i, poi))
      {
         if (close[current] < poi.price || IsLineExpired(current, poi))
         {
            invalidLvIndexArr.Push(poi);
         }
      }
   }
           
   while (invalidLvIndexArr.Count() > 0)
   {
      CPointOfInterest *l = invalidLvIndexArr.Pop();
      bool bSuccess = bullLvArr.Remove(l);
      TrendDelete(0, l.name);
      delete l;
   }
   
   ColorizeLevels(bullLvArr, InpBullish);
   
   bool biasChanged = (lBias != gBias);
   
   if (biasChanged)
   {
      gBias = lBias;
   }

   // TODO: need to implement Rebalancing
}

CANDLE_DIR CandleDir(const double open, const double high, const double low, const double close)
{
   return close > open ? BULL_DIR : (close < open ? BEAR_DIR : NONE_DIR);
}

bool IsBullDir(CANDLE_DIR dir)
{
   return dir == BULL_DIR;
}

bool IsBearDir(CANDLE_DIR dir)
{
   return dir == BEAR_DIR;
}

bool IsNeutralDir(CANDLE_DIR dir)
{
   return dir == NONE_DIR;
}

bool IsBullCandle(const double open, const double high, const double low, const double close)
{
   return IsBullDir(CandleDir(open, high, low, close));
}

bool IsBearCandle(const double open, const double high, const double low, const double close)
{
   return IsBearDir(CandleDir(open, high, low, close));
}

bool IsNeutralCandle(const double open, const double high, const double low, const double close)
{
   return IsNeutralDir(CandleDir(open, high, low, close));
}

bool IsLineExpired(int current, CPointOfInterest* poi)
{
   return current - poi.index > InpLookbackBars;
}

void TrimLineArr(CArrayList<CPointOfInterest *> &arr, int max)
{
    if (arr.Count() > max)
    {
      CPointOfInterest *value;
      if (arr.TryGetValue(0, value))
      {
         arr.RemoveAt(0);
         TrendDelete(0, value.name);
         delete value;
      }
    }
}

void ColorizeLevels(CArrayList<CPointOfInterest *> &arr, int clr)
{
   CPointOfInterest *value;
   for (int i = 0; i < arr.Count(); i++)
   {
      if (arr.TryGetValue(i, value))
      {
         int visibleOnPeriods = (arr.Count() - i > InpMaxLevelsToShow) ? OBJ_NO_PERIODS: OBJ_ALL_PERIODS;
         ObjectSetInteger(0, value.name, OBJPROP_TIMEFRAMES, visibleOnPeriods);
      }
   }
}

void OnNewBar(const int rates_total,
              const datetime &time[],
              const double &open[],
              const double &high[],
              const double &low[],
              const double &close[])
{
   if (rates_total < 2) return;

   // The rates_total will include the currently forming candle
   // we only want the fully-formed candle therefore go back 1
   // since 0 index based, take 1 from that which equates to 2
   ProcessBar(rates_total - 2, time, open, high, low, close);
}

bool TrendCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="TrendLine",  // line name
                 const int             sub_window=0,      // subwindow index
                 datetime              time1=0,           // first point time
                 double                price1=0,          // first point price
                 datetime              time2=0,           // second point time
                 double                price2=0,          // second point price
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=true,    // highlight to move
                 const bool            ray_left=false,    // line's continuation to the left
                 const bool            ray_right=false,   // line's continuation to the right
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0)         // priority for mouse click
{
   ChangeTrendEmptyPoints(time1,price1,time2,price2);
   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create a trend line! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_LEFT,ray_left);
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true);
}
 
bool TrendDelete(const long   chart_ID=0,       // chart's ID
                 const string name="TrendLine") // line name
{
   ResetLastError();
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a trend line! Error code = ",GetLastError());
      return(false);
     }
   return(true);
}
  
void ChangeTrendEmptyPoints(datetime &time1,double &price1,
                            datetime &time2,double &price2)
{
   if(!time1)
      time1=TimeCurrent();
      
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
      
   if(!time2)
   {
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      time2=temp[0];
   }

   if(!price2)
      price2=price1;
}

bool VLineCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="VLine",      // line name
                 const int             sub_window=0,      // subwindow index
                 datetime              time=0,            // line time
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=true,    // highlight to move
                 const bool            ray=true,          // line's continuation down
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0)         // priority for mouse click
{
   if (!time)
      time = TimeCurrent();
   
   ResetLastError();
   
   if(!ObjectCreate(chart_ID,name,OBJ_VLINE,sub_window,time,0))
   {
      Print(__FUNCTION__,
            ": failed to create a vertical line! Error code = ",GetLastError());
      return(false);
   }
   
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY,ray);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true);
}

bool VLineMove(const long   chart_ID=0,   // chart's ID
               const string name="VLine", // line name
               datetime     time=0)       // line time
{
   if(!time)
      time=TimeCurrent();

   ResetLastError();

   if(!ObjectMove(chart_ID,name,0,time,0))
   {
      Print(__FUNCTION__,
            ": failed to move the vertical line! Error code = ",GetLastError());
      return(false);
   }

   return(true);
}

bool VLineDelete(const long   chart_ID=0,   // chart's ID
                 const string name="VLine") // line name
{
   ResetLastError();

   if(!ObjectDelete(chart_ID,name))
   {
      Print(__FUNCTION__,
            ": failed to delete the vertical line! Error code = ",GetLastError());
      return(false);
   }
   
   return(true);
}