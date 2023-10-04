//+------------------------------------------------------------------+
//|                                        PropSense Book Levels.mq5 |
//|                                 Copyright 2023, Mark Bernardinis |
//|                                   https://www.mtnsconsulting.com |
//+------------------------------------------------------------------+

// TODO: Outstanding Items
// - update book level (possibly grey or user configurable color) if it will be closed based on current forming candle
// - show bias (use what has been done on the trading view one)
// - incorporate bullish/bearish output from IG data
// - adjust fixes when in daylight savings time (tokyo remains the same, london will change)
// - bug when timezone is 0 and defining a session starting at 2300 and finishing 0700 (nothing shows)

// https://www.mql5.com/en/docs/constants/objectconstants/enum_object/obj_bitmap
// https://www.mql5.com/en/docs/runtime/resources (embed resource into ex5)

#property version   "1.5"
#property indicator_chart_window

#property indicator_plots   0

#include <Generic\Stack.mqh>
#include <Generic\ArrayList.mqh>

#include "CalendarHelpers.mqh"
#include "DrawingHelpers.mqh"
#include "TimeHelpers.mqh"

#include "Books.mqh"
#include "Sessions.mqh"
#include "Fixes.mqh"

enum ENUM_INIT_STATE {
   INIT_STATE_NOT_INITIALIZED = 0,
   INIT_STATE_INITIALIZED = 1,
};

ENUM_INIT_STATE g_State = INIT_STATE_NOT_INITIALIZED;

const string INDICATOR_SHORT_NAME = "PS";

//--- input parameters
//input int InpMaxLevelsToShow     = 5;        // Max Levels to Show
input int InpLookbackBars        = 999;        // Max Lookback to Show

input ENUM_LINE_STYLE InpLineStyle = STYLE_SOLID; // Line Style
input int  InpLineWidth = 1;        // Line Width

input int InpOffset = 20; // Book and Fix Offset (how many bars?)

input color InpBookBullishColor = clrSkyBlue; // Book Level Color (Bullish)
input color InpBookBearishColor = clrLightCoral; // Book Level Color (Bearish)

input bool InpOnlyInSession = true; // Filter with Market Sessions

input bool InpDetectServerTimezone = false; // Detect the timezone of the Server Automatically
input double InpServerTimezone = 3.0; // Server Timezone (used if auto detection is disabled)

input int InpMaxHistoricalSessionsToShow     = 10;        // Max Historical Sessions to Show

input int InpSessionTimeZonesHour = 0; // Timezone (Hour)
input int InpSessionTimeZonesMin = 0; // Timezone (Min)

input bool InpShowSession1 = true; // Show Session 1
input bool InpShowNextSession1 = true; // Show Next Session 1
input string InpSession1Name = "Sydney"; // Session 1 Name
input SESSION_TZ InpSession1Type = SESSION_TZ_SYDNEY; // Session 1 Type
input color InpSession1Color = clrFuchsia; // Session 1 Color
input int InpSession1StartHour = 20; // Session 1 Time (Start Hour)
input int InpSession1StartMin = 00; // Session 1 Time (Start Min)
input int InpSession1EndHour = 5; // Session 1 Time (End Hour)
input int InpSession1EndMin = 0; // Session 1 Time (End Min)

input bool InpShowSession2 = true; // Show Session 2
input bool InpShowNextSession2 = true; // Show Next Session 2
input string InpSession2Name = "Asia"; // Session 2 Name
input SESSION_TZ InpSession2Type = SESSION_TZ_ASIA; // Session 2 Type
input color InpSession2Color = clrBlueViolet; // Session 2 Color
input int InpSession2StartHour = 0; // Session 2 Time (Start Hour)
input int InpSession2StartMin = 0; // Session 2 Time (Start Min)
input int InpSession2EndHour = 9; // Session 2 Time (End Hour)
input int InpSession2EndMin = 0; // Session 2 Time (End Min)

input bool InpShowSession3 = true; // Show Session 3
input bool InpShowNextSession3 = true; // Show Next Session 3
input string InpSession3Name = "London"; // Session 3 Name
input SESSION_TZ InpSession3Type = SESSION_TZ_LONDON; // Session 3 Type
input color InpSession3Color = clrGold; // Session 3 Color
input int InpSession3StartHour = 7; // Session 3 Time (Start Hour)
input int InpSession3StartMin = 0; // Session 3 Time (Start Min)
input int InpSession3EndHour = 16; // Session 3 Time (End Hour)
input int InpSession3EndMin = 0; // Session 3 Time (End Min)

input bool InpShowSession4 = true; // Show Session 4
input bool InpShowNextSession4 = true; // Show Next Session 4
input string InpSession4Name = "New York"; // Session 4 Name
input SESSION_TZ InpSession4Type = SESSION_TZ_NEWYORK; // Session 4 Type
input color InpSession4Color = clrLimeGreen; // Session 4 Color
input int InpSession4StartHour = 12; // Session 4 Time (Start Hour)
input int InpSession4StartMin = 0; // Session 4 Time (Start Min)
input int InpSession4EndHour = 21; // Session 4 Time (End Hour)
input int InpSession4EndMin = 0; // Session 4 Time (End Min)

input bool InpShowTokyoFix = true; // Show the Tokyo Fix
input color InpTokyoFixColor = clrDarkGoldenrod; // Tokyo Fix Color
input ENUM_LINE_STYLE InpTokyoFixStyle = STYLE_DOT; // Tokyo Fix Style
input int InpTokyoFixUTCHour = 0; // Tokyo Fix (Hour)
input int InpTokyoFixUTCMin = 55; // Tokyo Fix (Min)
input SESSION_TZ InpTokyoFixType = SESSION_TZ_ASIA; // Asian Session Fix Type
//TOKYO_FIX = '0055-0100' // 9:55am Tokyo time(GMT+9)

input bool InpShowLondonFix = true; // Show the London Fix
input color InpLondonFixColor = clrPaleGoldenrod; // London Fix Color
input ENUM_LINE_STYLE InpLondonFixStyle = STYLE_DOT; // London Fix Style
input int InpLondonFixUTCHour = 16; // London Fix (Hour)
input int InpLondonFixUTCMin = 0; // London Fix (Min)
input SESSION_TZ InpLondonFixType = SESSION_TZ_LONDON; // London Session Fix Type
//LONDON_FIX = '1500-1501' // 4pm London time(GMT+1)

CFixes *g_Fixes;
CSessions *g_Sessions;
CBooks *g_Books;

void OnDeinit(const int reason)
{
   PrintFormat("Shutting Down (PropSense Book Levels)");

   EventKillTimer();

   delete g_Books;
   delete g_Fixes;
   delete g_Sessions;

   Comment("");
   
   g_State = INIT_STATE_NOT_INITIALIZED;
}

void Initialize(datetime dt)
{
   int secondsOffset = InpOffset * CTimeHelpers::GetTimeframeMinutes(Period()) * 60;

   g_Sessions = new CSessions((int)dt);
   g_Fixes = new CFixes(INDICATOR_SHORT_NAME, 2, secondsOffset, (int)dt);
   g_Books = new CBooks(INDICATOR_SHORT_NAME, secondsOffset, InpOnlyInSession, g_Sessions, InpLookbackBars, InpBookBearishColor, InpBookBullishColor);
   
   if (InpShowTokyoFix)
   {
      g_Fixes.CreateFix("Tokyo", InpTokyoFixUTCHour, InpTokyoFixUTCMin, InpTokyoFixType, InpTokyoFixColor, InpTokyoFixStyle);
   }
   if (InpShowLondonFix)
   {
      g_Fixes.CreateFix("London", InpLondonFixUTCHour, InpLondonFixUTCMin, InpLondonFixType, InpLondonFixColor, InpLondonFixStyle);
   }
   
   if (InpShowSession1)
   {
      g_Sessions.CreateSession(
         INDICATOR_SHORT_NAME, InpSession1Name, InpSession1Color, InpMaxHistoricalSessionsToShow, InpShowNextSession1, InpSession1StartHour,
         InpSession1StartMin, InpSession1EndHour, InpSession1EndMin, (InpSessionTimeZonesHour*60*60 + InpSessionTimeZonesMin*60), InpSession1Type);
   }
   
   if (InpShowSession2)
   {
      g_Sessions.CreateSession(
         INDICATOR_SHORT_NAME, InpSession2Name, InpSession2Color, InpMaxHistoricalSessionsToShow, InpShowNextSession2, InpSession2StartHour,
         InpSession2StartMin, InpSession2EndHour, InpSession2EndMin, (InpSessionTimeZonesHour*60*60 + InpSessionTimeZonesMin*60), InpSession2Type);
   }      
   
   if (InpShowSession3)
   {
      g_Sessions.CreateSession(
         INDICATOR_SHORT_NAME, InpSession3Name, InpSession3Color, InpMaxHistoricalSessionsToShow, InpShowNextSession3, InpSession3StartHour,
         InpSession3StartMin, InpSession3EndHour, InpSession3EndMin, (InpSessionTimeZonesHour*60*60 + InpSessionTimeZonesMin*60), InpSession3Type);
   }

   if (InpShowSession4)
   {
      g_Sessions.CreateSession(
         INDICATOR_SHORT_NAME, InpSession4Name, InpSession4Color, InpMaxHistoricalSessionsToShow, InpShowNextSession4, InpSession4StartHour,
         InpSession4StartMin, InpSession4EndHour, InpSession4EndMin, (InpSessionTimeZonesHour*60*60 + InpSessionTimeZonesMin*60), InpSession4Type);
   }

   PrintFormat("Initialised (PropSense Book Levels)");
   
   g_State = INIT_STATE_INITIALIZED;
}

void OnTimer()
{
   switch (g_State)
   {
      case INIT_STATE_NOT_INITIALIZED:
         ServerInitialize();
         break;
      case INIT_STATE_INITIALIZED:
         StatsUpdate();
         break;
   }
}

void ServerInitialize()
{
   datetime dt = TimeTradeServer() - TimeGMT();
   
   Initialize(dt);

   PrintFormat("Starting (PropSense Book Levels) - delayed initialization successful");
}

void StatsUpdate()
{
   //Print("Running External Code");

   //PrintFormat("", i);
}

int OnInit()
{
   //--- Delay a second to give MT5 a chance to startup before attempting to query the server
   //--- for timezone information and other bits that can cause failures during startup of the platform
   if (InpDetectServerTimezone)
   {
      PrintFormat("Starting (PropSense Book Levels) - initialization delayed");
   }
   else
   {
      Initialize((int)InpServerTimezone * 60 * 60);
   }
   
   EventSetTimer(5);

   //---
   return(INIT_SUCCEEDED);
}
  
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
   if (g_State == INIT_STATE_NOT_INITIALIZED)
   {
      Print("Awaiting initialization...");
      return(0);
   }

   //--- Only calculate historically from InpLookbackBars
   int start = MathMax(rates_total - InpLookbackBars - 1, prev_calculated - 1);

   //--- Loop through the periods in the window except the last candle (which is the active one)
   for(int i = start; i < rates_total && !IsStopped(); i++)
   {
      ProcessBar(i, rates_total, time, open, high, low, close);
   }
   
   //--- return value of prev_calculated for next call
   return(rates_total);
}

void ProcessBar(const int current,
                const int ratesTotal,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[])
{
   // update the sessions (including highs/lows and bounding box)
   g_Sessions.ProcessTime(time[current], open[current], high[current], low[current], close[current]);

   // update the books
   g_Books.ProcessTime(current, ratesTotal, time, open, high, low, close);

   // update the fixes - if a new candle just formed
   g_Fixes.Handle(time[current], open[current]);
}
