//+------------------------------------------------------------------+
//|                                                    propsense.mq5 |
//+------------------------------------------------------------------+

#property copyright "Copyright 2023, Mark Bernardinis"
#property version   "1.00"
#property indicator_chart_window

class CPointOfInterest {
   public:
      int index;
      datetime period;
      double price;
      string name;
};

// TODO: define a structure for DST adjustments to London and New York based on the DST rules

enum CANDLE_DIR {
   BULL_DIR = 1,
   NONE_DIR = 0,
   BEAR_DIR = -1
};

#property indicator_plots   0

#include <Generic\Stack.mqh>
#include <Generic\ArrayList.mqh>
#include <Lib CisNewBar.mqh>

CisNewBar current_chart; // instance of the CisNewBar class: current chart

//--- input parameters
input int            InpMaxLevelsToShow     = 5;        // Max Levels to Show
input int            InpLookbackBars        = 999;        // Max Lookback to Show

input color          InpBullish = clrBlue; // Level Color (Bullish)
input color          InpBearish = clrRed; // Level Color (Bearish)

input ENUM_LINE_STYLE InpLineStyle = STYLE_SOLID; // Line Style
input int            InpLineWidth = 1;        // Line Width

input bool InpOnlyInSession = true; // Filter with Market Sessions

input bool InpAsianSession = true; // Asian Session
input double InpAsianSessionStart = 07.00; // Asian Session Time (Start)
input double InpAsianSessionEnd = 16.00; // Asian Session Time (End)
input bool InpLondonSession = true; // Asian Session
input double InpLondonSessionStart = 15.00; // London Session Time (Start)
input double InpLondonSessionEnd = 00.00; // London Session Time (End)
input bool InpNewYorkSession = true; // Asian Session
input double InpNewYorkSessionStart = 20.00; // New York Session Time (Start)
input double InpNewYorkSessionEnd = 05.00; // New York Session Time (End)
input double InpSessionTimeZones = 8.00; // Timezone

//input bool InpShowCurrentBias =  true; // Show Current Bias
//input ENUM_ANCHOR_POINT InpLocation; // Location
//input ENUM_TEST InpSize = ENUM_AUTO; // Size

////// Constants //////
//NONE_COLOR = color.new(color.white, 100)
//const int LINE_OFFSET = 15
const int MAX_LINE = 250; // 250 on each side = 500 lines in total
const int MAX_BEAR_CD_LOOKBACK = 2;
const string GMT = "GMT+0";
const string TOKYO_FIX = "0055-0100";
const string LONDON_FIX = "1600-1601";

CANDLE_DIR gBias = NONE_DIR;

CArrayList<CANDLE_DIR> prevCandleArr();
CArrayList<CPointOfInterest *> bearLvArr();
CArrayList<CPointOfInterest *> bullLvArr();

double mostRecentBear = NULL;
double mostRecentBull = NULL;
double lastBearCdOpen = NULL;

double serverTimeZoneOffset = 0;

int lastBearCdIndex = NULL;
bool isLastBearCdBroken = false;

CStack<CPointOfInterest *> invalidLvIndexArr();

bool isInitialised = false;

void OnTick()
{
   //
}

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
   
   isInitialised = false;
}

void OnTimer()
{
   //
   if (!isInitialised)
   {
      //int daylightSavingsCorrection = TimeDaylightSavings();
      serverTimeZoneOffset = (double)((int)(TimeTradeServer() - TimeGMT()));
   
      // TimeGMTOffset(), TimeToString(TimeTradeServer()), TimeToString(TimeGMT()), 
      
      PrintFormat("Initialised (propsense)");
      isInitialised = true;
      
      EventKillTimer();
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
   //for(int i = prev_calculated; i < rates_total - 1; i++)
   for(int i = start; i < rates_total - 1 && !IsStopped(); i++)
   {
      ProcessBar(i, time, open, high, low, close);
   }
   
   int period_seconds=PeriodSeconds(_Period);                     // Number of seconds in current chart period
   datetime new_time=TimeCurrent()/period_seconds*period_seconds; // Time of bar opening on current chart
   if(current_chart.isNewBar(new_time)) OnNewBar(rates_total, time, open, high, low, close); // When new bar appears - launch the NewBar event handler

   //--- return value of prev_calculated for next call
   return(rates_total);
}

//+------------------------------------------------------------------+

bool InSession(datetime dtCurrent, double sessStart, double sessEnd, double sessTz)
{
   MqlDateTime dtCandle;
   TimeToStruct(dtCurrent, dtCandle);
   
   double Servertime = dtCandle.hour - (serverTimeZoneOffset/60/60) + (dtCandle.min * 0.01) + sessTz;
   
   if ((sessEnd-sessStart) < 0 && (Servertime<sessEnd || Servertime >= sessStart))
      return (true);
      
   if ((sessEnd-sessStart) > 0 && Servertime < sessEnd && Servertime >= sessStart)
      return (true);
      
   if (sessStart + sessEnd == 0)
      return (true);
      
   return (false);
}

void ProcessBar(const int current,
               const datetime &time[],
               const double &open[],
               const double &high[],
               const double &low[],
               const double &close[])
{
   // initialise to value of first bar
   if (current == 0)
   {
      mostRecentBull = NULL;
      lastBearCdIndex = 0;
      lastBearCdOpen = open[0];
      isLastBearCdBroken = false;
   }

   bool inAs = InpOnlyInSession && InpAsianSession && InSession(time[current], InpAsianSessionStart, InpAsianSessionEnd, InpSessionTimeZones);
   bool inLdn = InpOnlyInSession && InpLondonSession && InSession(time[current], InpLondonSessionStart, InpLondonSessionEnd, InpSessionTimeZones);
   bool inNy = InpOnlyInSession && InpNewYorkSession && InSession(time[current], InpNewYorkSessionStart, InpNewYorkSessionEnd, InpSessionTimeZones);
      
   bool inSess = InpOnlyInSession ? (inAs || inLdn || inNy) : true;
      
   //if (!inSess)
   //{
      //PrintFormat("Not in session detected for CANDLE %s for TZ %f, %f SERVER OFFSET %f", TimeToString(time[current]), InpSessionTimeZones, 8.0, serverTimeZoneOffset);
   //}
   
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
      poi.name = StringFormat("BEAR_LVL[%i]", current - 1);
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
       poi.name = StringFormat("BULL_LVL[%i]", current);
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

//+------------------------------------------------------------------+
//| New bar event handler function                                   |
//+------------------------------------------------------------------+
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

//+------------------------------------------------------------------+
//| Create a trend line by the given coordinates                     |
//+------------------------------------------------------------------+
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
 
//+------------------------------------------------------------------+
//| The function deletes the trend line from the chart.              |
//+------------------------------------------------------------------+
bool TrendDelete(const long   chart_ID=0,       // chart's ID
                 const string name="TrendLine") // line name
  {
//--- reset the error value
   ResetLastError();
//--- delete a trend line
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a trend line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
  
//+------------------------------------------------------------------+
//| Check the values of trend line's anchor points and set default   |
//| values for empty ones                                            |
//+------------------------------------------------------------------+
void ChangeTrendEmptyPoints(datetime &time1,double &price1,
                            datetime &time2,double &price2)
{
   if(!time1)
      time1=TimeCurrent();
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   if(!time2)
     {
      //--- array for receiving the open time of the last 10 bars
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      //--- set the second point 9 bars left from the first one
      time2=temp[0];
     }
   if(!price2)
      price2=price1;
}