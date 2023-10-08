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

#property copyright "Copyright 2023, Mark Bernardinis"
#property link      "https://github.com/bernarma/mt5"
#property version   "1.1"

#property indicator_chart_window

#property indicator_plots   0

#include "CalendarHelpers.mqh"
#include "TimeHelpers.mqh"
#include "DrawingHelpers.mqh"

#include "Sessions.mqh"

const string INDICATOR_SHORT_NAME = "MARKET_SESSIONS";

//--- input parameters
input bool InpDetectServerTimezone = false; // Detect the timezone of the Server Automatically
input datetime InpServerTimeZone = D'1970.01.01 03:00'; // Server Timezone (used if auto detection is disabled)

input int  InpMaxHistoricalSessionsToShow = 50;        // Max Historical Sessions to Show

input datetime InpSessionTimeZone = D'1970.01.01 00:00'; // Timezone (Hour)

input bool InpShowSession1 = true; // Show Session 1
input bool InpShowNextSession1 = true; // Show Next Session 1
input string InpSession1Name = "Sydney"; // Session 1 Name
input SESSION_TZ InpSession1Type = SESSION_TZ_SYDNEY; // Session 1 Type
input color InpSession1Color = clrBlueViolet; // Session 1 Color
input DAY_OF_WEEK InpSession1StartDay = DAY_OF_WEEK_SUNDAY; // Session 1 Start Day
input DAY_OF_WEEK InpSession1EndDay = DAY_OF_WEEK_THURSDAY; // Session 1 End Day
input datetime InpSession1Start = D'1970.01.01 20:00'; // Session 1 Start
input datetime InpSession1End = D'1970.01.01 05:00'; // Session 1 Start

input bool InpShowSession2 = true; // Show Session 2
input bool InpShowNextSession2 = true; // Show Next Session 2
input string InpSession2Name = "Asia"; // Session 2 Name
input SESSION_TZ InpSession2Type = SESSION_TZ_ASIA; // Session 2 Type
input color InpSession2Color = clrAntiqueWhite; // Session 2 Color
input DAY_OF_WEEK InpSession2StartDay = DAY_OF_WEEK_MONDAY; // Session 2 Start Day
input DAY_OF_WEEK InpSession2EndDay = DAY_OF_WEEK_FRIDAY; // Session 2 End Day
input datetime InpSession2Start = D'1970.01.01 00:00'; // Session 2 Start
input datetime InpSession2End = D'1970.01.01 09:00'; // Session 2 Start

input bool InpShowSession3 = true; // Show Session 3
input bool InpShowNextSession3 = true; // Show Next Session 3
input string InpSession3Name = "London"; // Session 3 Name
input SESSION_TZ InpSession3Type = SESSION_TZ_LONDON; // Session 3 Type
input DAY_OF_WEEK InpSession3StartDay = DAY_OF_WEEK_MONDAY; // Session 3 Start Day
input DAY_OF_WEEK InpSession3EndDay = DAY_OF_WEEK_FRIDAY; // Session 3 End Day
input color InpSession3Color = clrGold; // Session 3 Color
input datetime InpSession3Start = D'1970.01.01 07:00'; // Session 3 Start
input datetime InpSession3End = D'1970.01.01 16:00'; // Session 3 Start

input bool InpShowSession4 = true; // Show Session 4
input bool InpShowNextSession4 = true; // Show Next Session 4
input string InpSession4Name = "New York"; // Session 4 Name
input SESSION_TZ InpSession4Type = SESSION_TZ_NEWYORK; // Session 4 Type
input DAY_OF_WEEK InpSession4StartDay = DAY_OF_WEEK_MONDAY; // Session 4 Start Day
input DAY_OF_WEEK InpSession4EndDay = DAY_OF_WEEK_FRIDAY; // Session 4 End Day
input color InpSession4Color = clrLimeGreen; // Session 4 Color
input datetime InpSession4Start = D'1970.01.01 12:00'; // Session 4 Start
input datetime InpSession4End = D'1970.01.01 21:00'; // Session 4 Start

CSessions *g_Sessions;

bool g_IsInitialised = false;

void OnDeinit(const int reason)
{
   PrintFormat("Shutting Down (Market Sessions)");

   EventKillTimer();

   if (g_Sessions != NULL) delete g_Sessions;
   
   g_IsInitialised = false;
}

void Initialize(datetime dt)
{
   g_Sessions = new CSessions((int)dt);

   g_Sessions.CreateSession(
      INDICATOR_SHORT_NAME, InpSession1Name, InpSession1Color, InpMaxHistoricalSessionsToShow, InpShowSession1, InpShowNextSession1,
      InpSession1Start, InpSession1End, InpSessionTimeZone, InpSession1Type, InpSession1StartDay, InpSession1EndDay);
   
   g_Sessions.CreateSession(
      INDICATOR_SHORT_NAME, InpSession2Name, InpSession2Color, InpMaxHistoricalSessionsToShow, InpShowSession2, InpShowNextSession2,
      InpSession2Start, InpSession2End, InpSessionTimeZone, InpSession2Type, InpSession2StartDay, InpSession2EndDay);

   g_Sessions.CreateSession(
      INDICATOR_SHORT_NAME, InpSession3Name, InpSession3Color, InpMaxHistoricalSessionsToShow, InpShowSession3, InpShowNextSession3,
      InpSession3Start, InpSession3End, InpSessionTimeZone, InpSession3Type, InpSession3StartDay, InpSession3EndDay);

   g_Sessions.CreateSession(
      INDICATOR_SHORT_NAME, InpSession4Name, InpSession4Color, InpMaxHistoricalSessionsToShow, InpShowSession4, InpShowNextSession4,
      InpSession4Start, InpSession4End, InpSessionTimeZone, InpSession4Type, InpSession4StartDay, InpSession4EndDay);

   PrintFormat("Initialised (Market Sessions)");
   
   g_IsInitialised = true;
}

void OnTimer()
{
   if (!g_IsInitialised)
   {
      datetime dt = TimeTradeServer() - TimeGMT();
      
      Initialize(dt);

      PrintFormat("Starting (Market Sessions) - delayed initialization successful");
   }
}

int OnInit()
{
   //--- Delay a second to give MT5 a chance to startup before attempting to query the server
   //--- for timezone information and other bits that can cause failures during startup of the platform
   if (InpDetectServerTimezone)
   {
      PrintFormat("Starting (Market Sessions) - initialization delayed");
   }
   else
   {
      Initialize(CTimeHelpers::TimeToSeconds(InpServerTimeZone));
   }
   
   EventSetTimer(5);

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
   if (!g_IsInitialised)
   {
      Print("Awaiting initialization...");
      return(0);
   }

   int secondsPerPeriod = PeriodSeconds(PERIOD_CURRENT); // 600 in a 5 minute candle
   const int secondsPerDay = 60 * 60 * 24;
   int candlesPerDay = secondsPerDay / secondsPerPeriod;
   
   //--- Only calculate a max number of historical sessions based on user input
   int start = MathMax(rates_total - (InpMaxHistoricalSessionsToShow * candlesPerDay), prev_calculated);
   if (start > 0) start--;

   //--- Loop through the periods in the window except the last candle (which is the active one)
   for(int i = start; i < rates_total && !IsStopped(); i++)
   {
      ProcessBar(i, rates_total, time, open, high, low, close);
   }

   //--- return value of prev_calculated for next call
   return(rates_total);
}

//+------------------------------------------------------------------+

void ProcessBar(const int current,
               const int prev_calculated,
               const datetime &time[],
               const double &open[],
               const double &high[],
               const double &low[],
               const double &close[])
{
   g_Sessions.ProcessTime(time[current], open[current], high[current], low[current], close[current]);
}