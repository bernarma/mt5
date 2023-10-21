//+-----------------------------------------------------------------------------+
//| This program is free software: you can redistribute it and/or modify        |
//| it under the terms of the GNU Affero General Public License as published by |
//| the Free Software Foundation, either version 3 of the License, or           |
//| (at your option) any later version.                                         |
//|                                                                             |
//| This program is distributed in the hope that it will be useful,             |
//| but WITHOUT ANY WARRANTY; without even the implied warranty of              |
//| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               |
//| GNU Affero General Public License for more details.                         |
//|                                                                             |
//| You should have received a copy of the GNU Affero General Public License    |
//| along with this program.  If not, see <http://www.gnu.org/licenses/>.       |
//+-----------------------------------------------------------------------------+

#property version   "1.8"
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
input int InpMaxLevelsToShow     = 5;        // Max Levels to Show
input int InpLookbackBars        = 999;        // Max Lookback to Show

input ENUM_LINE_STYLE InpLineStyle = STYLE_SOLID; // Line Style
input int  InpLineWidth = 1;        // Line Width

input int InpOffset = 20; // Book and Fix Offset (how many bars?)

input color InpBookBullishColor = clrSkyBlue; // Book Level Color (Bullish)
input color InpBookBearishColor = clrLightCoral; // Book Level Color (Bearish)

input bool InpOnlyInSession = true; // Filter with Market Sessions

input bool InpDetectServerTimezone = false; // Detect the timezone of the Server Automatically
input ENUM_UTC_TZ InpServerTimeZone = TZ_UTC3; // Server Timezone (used if auto detection is disabled)

input int InpMaxHistoricalSessionsToShow     = 10;        // Max Historical Sessions to Show

input ENUM_UTC_TZ InpSessionTimeZone = TZ_UTC; // Timezone

input bool InpShowSession1 = false; // Show Session 1
input bool InpShowNextSession1 = false; // Show Next Session 1
input string InpSession1Name = "Sydney"; // Session 1 Name
input SESSION_TZ InpSession1Type = SESSION_TZ_SYDNEY; // Session 1 Type
input DAY_OF_WEEK InpSession1StartDay = DAY_OF_WEEK_SUNDAY; // Session 1 Start Day
input DAY_OF_WEEK InpSession1EndDay = DAY_OF_WEEK_THURSDAY; // Session 1 End Day
input color InpSession1Color = clrFuchsia; // Session 1 Color
input datetime InpSession1Start = D'1970.01.01 20:00'; // Session 1 Start
input datetime InpSession1End = D'1970.01.01 05:00'; // Session 1 End

input bool InpShowSession2 = false; // Show Session 2
input bool InpShowNextSession2 = false; // Show Next Session 2
input string InpSession2Name = "Asia"; // Session 2 Name
input SESSION_TZ InpSession2Type = SESSION_TZ_ASIA; // Session 2 Type
input DAY_OF_WEEK InpSession2StartDay = DAY_OF_WEEK_MONDAY; // Session 2 Start Day
input DAY_OF_WEEK InpSession2EndDay = DAY_OF_WEEK_FRIDAY; // Session 2 End Day
input color InpSession2Color = clrBlueViolet; // Session 2 Color
input datetime InpSession2Start = D'1970.01.01 00:00'; // Session 2 Start
input datetime InpSession2End = D'1970.01.01 09:00'; // Session 2 End

input bool InpShowSession3 = false; // Show Session 3
input bool InpShowNextSession3 = false; // Show Next Session 3
input string InpSession3Name = "London"; // Session 3 Name
input SESSION_TZ InpSession3Type = SESSION_TZ_LONDON; // Session 3 Type
input DAY_OF_WEEK InpSession3StartDay = DAY_OF_WEEK_MONDAY; // Session 3 Start Day
input DAY_OF_WEEK InpSession3EndDay = DAY_OF_WEEK_FRIDAY; // Session 3 End Day
input color InpSession3Color = clrGold; // Session 3 Color
input datetime InpSession3Start = D'1970.01.01 07:00'; // Session 3 Start
input datetime InpSession3End = D'1970.01.01 16:00'; // Session 3 End

input bool InpShowSession4 = false; // Show Session 4
input bool InpShowNextSession4 = false; // Show Next Session 4
input string InpSession4Name = "New York"; // Session 4 Name
input SESSION_TZ InpSession4Type = SESSION_TZ_NEWYORK; // Session 4 Type
input DAY_OF_WEEK InpSession4StartDay = DAY_OF_WEEK_MONDAY; // Session 4 Start Day
input DAY_OF_WEEK InpSession4EndDay = DAY_OF_WEEK_FRIDAY; // Session 4 End Day
input color InpSession4Color = clrLimeGreen; // Session 4 Color
input datetime InpSession4Start = D'1970.01.01 12:00'; // Session 4 Start
input datetime InpSession4End = D'1970.01.01 21:00'; // Session 4 End

input int InpFixesToShow = 2; // The number of fixes to show (including current)

input bool InpShowTokyoFix = true; // Show the Tokyo Fix
input color InpTokyoFixColor = clrDarkGoldenrod; // Tokyo Fix Color
input ENUM_LINE_STYLE InpTokyoFixStyle = STYLE_DOT; // Tokyo Fix Style
input datetime InpTokyoFixUTC = D'1970.01.01 00:55'; // Tokyo Fix
input SESSION_TZ InpTokyoFixType = SESSION_TZ_ASIA; // Asian Session Fix Type
//TOKYO_FIX = '0055-0100' // 9:55am Tokyo time(GMT+9)

input bool InpShowLondonFix = true; // Show the London Fix
input color InpLondonFixColor = clrPaleGoldenrod; // London Fix Color
input ENUM_LINE_STYLE InpLondonFixStyle = STYLE_DOT; // London Fix Style
input datetime InpLondonFixUTC = D'1970.01.01 16:00'; // London Fix
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
   g_Fixes = new CFixes(INDICATOR_SHORT_NAME, InpFixesToShow, secondsOffset, (int)dt);
   g_Books = new CBooks(INDICATOR_SHORT_NAME, secondsOffset, InpMaxLevelsToShow, InpOnlyInSession, g_Sessions, InpLookbackBars, InpBookBearishColor, InpBookBullishColor);
   
   if (InpShowTokyoFix)
   {
      g_Fixes.CreateFix("Tokyo", InpTokyoFixUTC, InpTokyoFixType, InpTokyoFixColor, InpTokyoFixStyle);
   }
   if (InpShowLondonFix)
   {
      g_Fixes.CreateFix("London", InpLondonFixUTC, InpLondonFixType, InpLondonFixColor, InpLondonFixStyle);
   }
   
   g_Sessions.CreateSession(
      INDICATOR_SHORT_NAME, InpSession1Name, InpSession1Color, InpMaxHistoricalSessionsToShow, InpShowSession1, InpShowNextSession1, InpSession1Start, InpSession1End,
      InpSessionTimeZone, InpSession1Type, InpSession1StartDay, InpSession1EndDay);
   
   g_Sessions.CreateSession(
      INDICATOR_SHORT_NAME, InpSession2Name, InpSession2Color, InpMaxHistoricalSessionsToShow, InpShowSession2, InpShowNextSession2, InpSession2Start, InpSession2End,
      InpSessionTimeZone, InpSession2Type, InpSession2StartDay, InpSession2EndDay);

   g_Sessions.CreateSession(
      INDICATOR_SHORT_NAME, InpSession3Name, InpSession3Color, InpMaxHistoricalSessionsToShow, InpShowSession3, InpShowNextSession3, InpSession3Start, InpSession3End,
      InpSessionTimeZone, InpSession3Type, InpSession3StartDay, InpSession3EndDay);

   g_Sessions.CreateSession(
      INDICATOR_SHORT_NAME, InpSession4Name, InpSession4Color, InpMaxHistoricalSessionsToShow, InpShowSession4, InpShowNextSession4, InpSession4Start, InpSession4End,
      InpSessionTimeZone, InpSession4Type, InpSession4StartDay, InpSession4EndDay);

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
      Initialize(InpServerTimeZone*60*60);
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

   // TODO: Go back as far as required based on the number of sessions to show

   //--- Only calculate historically from InpLookbackBars
   int start = MathMax(rates_total - InpLookbackBars, prev_calculated);
   if (start > 0) start--;

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
