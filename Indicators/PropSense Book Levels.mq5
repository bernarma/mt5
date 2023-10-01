//+------------------------------------------------------------------+
//|                                        PropSense Book Levels.mq5 |
//+------------------------------------------------------------------+

// based on https://wddbbddb.notion.site/Prop-Firm-Passed-5m-Scalping-bab5baa1da3744109c108f95012a281a

// TODO: Outstanding Items
// - update book level (possibly grey or user configurable color) if it will be closed based on current forming candle
// - show bias (use what has been done on the trading view one)
// - fix input to fixes (hard coded)

// https://www.mql5.com/en/docs/constants/objectconstants/enum_object/obj_bitmap
// https://www.mql5.com/en/docs/runtime/resources (embed resource into ex5)

#property version   "1.4"
#property indicator_chart_window

#property indicator_plots   0

#include <Generic\Stack.mqh>
#include <Generic\ArrayList.mqh>

#include "TimeHelpers.mqh"
#include "Books.mqh"
#include "Sessions.mqh"
#include "Fixes.mqh"
#include "DrawingHelpers.mqh"

const string INDICATOR_SHORT_NAME = "PS";

//--- input parameters
input int            InpMaxLevelsToShow     = 5;        // Max Levels to Show - IGNORED
input int            InpLookbackBars        = 999;        // Max Lookback to Show

input ENUM_LINE_STYLE InpLineStyle = STYLE_SOLID; // Line Style
input int            InpLineWidth = 1;        // Line Width

input color          InpBullishColor = clrSkyBlue; // Level Color (Bullish)
input color          InpBearishColor = clrLightCoral; // Level Color (Bearish)

input bool InpOnlyInSession = true; // Filter with Market Sessions

input bool InpDetectServerTimezone = false; // Detect the timezone of the Server Automatically
input double InpServerTimezone = 3.0; // Server Timezone (used if auto detection is disabled)

input bool InpShowBooks = true; // Show Book Levels

input int  InpMaxHistoricalSessionsToShow     = 10;        // Max Historical Sessions to Show

input int InpSessionTimeZonesHour = 8; // Timezone (Hour)
input int InpSessionTimeZonesMin = 0; // Timezone (Min)

input bool InpShowSession1 = true; // Show Session 1
input bool InpShowNextSession1 = true; // Show Next Session 1
input string InpSession1Name = "Asia"; // Session 1 Name
input color InpSession1Color = clrBlueViolet; // Session 1 Color
input int InpSession1StartHour = 07; // Session 1 Time (Start Hour)
input int InpSession1StartMin = 00; // Session 1 Time (Start Min)
input int InpSession1EndHour = 16; // Session 1 Time (End Hour)
input int InpSession1EndMin = 00; // Session 1 Time (End Min)

input bool InpShowSession2 = true; // Show Session 2
input bool InpShowNextSession2 = true; // Show Next Session 2
input string InpSession2Name = "London"; // Session 2 Name
input color InpSession2Color = clrGold; // Session 2 Color
input int InpSession2StartHour = 15; // Session 2 Time (Start Hour)
input int InpSession2StartMin = 00; // Session 2 Time (Start Min)
input int InpSession2EndHour = 00; // Session 2 Time (End Hour)
input int InpSession2EndMin = 00; // Session 2 Time (End Min)

input bool InpShowSession3 = true; // Show Session 3
input bool InpShowNextSession3 = true; // Show Next Session 3
input string InpSession3Name = "New York"; // Session 3 Name
input color InpSession3Color = clrLimeGreen; // Session 3 Color
input int InpSession3StartHour = 20; // Session 3 Time (Start Hour)
input int InpSession3StartMin = 00; // Session 3 Time (Start Min)
input int InpSession3EndHour = 05.00; // Session 3 Time (End Hour)
input int InpSession3EndMin = 00; // Session 3 Time (End Min)

input bool InpShowTokyoFix = true; // Show the Tokyo Fix
input color InpTokyoFixColor = clrDarkGoldenrod; // Tokyo Fix Color
input ENUM_LINE_STYLE InpTokyoFixStyle = STYLE_DOT; // Tokyo Fix Style
input double InpTokyoFixTz = 9.00; // Tokyo Fix Timezone
input double InpTokyoFix = 9.55; // Tokyo Fix
//TOKYO_FIX = '0055-0100' // 9:55am Tokyo time(GMT+9)

input bool InpShowLondonFix = true; // Show the London Fix
input color InpLondonFixColor = clrPaleGoldenrod; // London Fix Color
input ENUM_LINE_STYLE InpLondonFixStyle = STYLE_DOT; // London Fix Style
input double InpLondonFixTz = 0.00; // London Fix Timezone
input double InpLondonFix = 15.00; // London Fix
//LONDON_FIX = '1500-1501' // 4pm London time(GMT+1)

CFixes *g_Fixes;
CSessions *g_Sessions;
CBooks *g_Books;

bool isInitialised = false;

void OnDeinit(const int reason)
{
   PrintFormat("Shutting Down (propsense)");

   delete g_Books;
   delete g_Fixes;
   delete g_Sessions;
   
   isInitialised = false;
}

void Initialize(datetime dt)
{
   g_Sessions = new CSessions();
         
   // TODO: convert bars to seconds for offset
   g_Fixes = new CFixes(INDICATOR_SHORT_NAME, 2, 6000);
   
   g_Books = new CBooks(INDICATOR_SHORT_NAME, 6000, InpOnlyInSession, g_Sessions, InpLookbackBars, InpBearishColor, InpBullishColor);
   
   // Initialise Fixes
   if (InpShowTokyoFix)
   {
      g_Fixes.CreateFix("Tokyo", InpTokyoFix, (int)(InpTokyoFixTz*60*60), (int)dt, InpTokyoFixColor, InpTokyoFixStyle);
   }
   if (InpShowLondonFix)
   {
      g_Fixes.CreateFix("London", InpLondonFix, (int)(InpLondonFixTz*60*60), (int)dt, InpLondonFixColor, InpLondonFixStyle);
   }
   
   if (InpShowSession1)
   {
      g_Sessions.CreateSession(
         INDICATOR_SHORT_NAME, InpSession1Name, InpSession1Color, InpMaxHistoricalSessionsToShow, InpShowNextSession1, InpSession1StartHour,
         InpSession1StartMin, InpSession1EndHour, InpSession1EndMin, (InpSessionTimeZonesHour*60*60 + InpSessionTimeZonesMin*60), (int)dt);
   }
   
   if (InpShowSession2)
   {
      g_Sessions.CreateSession(
         INDICATOR_SHORT_NAME, InpSession2Name, InpSession2Color, InpMaxHistoricalSessionsToShow, InpShowNextSession2, InpSession2StartHour,
         InpSession2StartMin, InpSession2EndHour, InpSession2EndMin, (InpSessionTimeZonesHour*60*60 + InpSessionTimeZonesMin*60), (int)dt);
   }      
   
   if (InpShowSession3)
   {
      g_Sessions.CreateSession(
         INDICATOR_SHORT_NAME, InpSession3Name, InpSession3Color, InpMaxHistoricalSessionsToShow, InpShowNextSession3, InpSession3StartHour,
         InpSession3StartMin, InpSession3EndHour, InpSession3EndMin, (InpSessionTimeZonesHour*60*60 + InpSessionTimeZonesMin*60), (int)dt);
   }

   PrintFormat("Initialised (propsense)");
   
   isInitialised = true;
}

void OnTimer()
{
   if (!isInitialised)
   {
      datetime dt = TimeTradeServer() - TimeGMT();
      
      Initialize(dt);

      PrintFormat("Starting (propsense) - delayed initialization successful");
   }
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Delay a second to give MT5 a chance to startup before attempting to query the server
   //--- for timezone information and other bits that can cause failures during startup of the platform
   if (InpDetectServerTimezone)
   {
      EventSetTimer(1);
      PrintFormat("Starting (propsense) - initialization delayed");
   }
   else
   {
      Initialize((int)InpServerTimezone * 60 * 60);
   }
   
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
   if (!isInitialised)
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
   bool inSess; // TODO: remove this in the future as this is only used for the legacy code

   // update the sessions (including highs/lows and bounding box)
   g_Sessions.ProcessTime(time[current], open[current], high[current], low[current], close[current], inSess);

   // update the books
   g_Books.ProcessTime(current, ratesTotal, time, open, high, low, close);

   // update the fixes - if a new candle just formed
   g_Fixes.Handle(time[current], open[current]);
}
