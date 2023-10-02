//+------------------------------------------------------------------+
//|                                              Market Sessions.mq5 |
//|                                 Copyright 2023, Mark Bernardinis |
//|                                   https://www.mtnsconsulting.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Mark Bernardinis"
#property link      "https://www.mtnsconsulting.com"
#property version   "1.00"
#property indicator_chart_window

#property indicator_plots   0

#include "CalendarHelpers.mqh"
#include "DrawingHelpers.mqh"

#include "Sessions.mqh"

const string INDICATOR_SHORT_NAME = "MARKET_SESSIONS";

//--- input parameters
input bool InpDetectServerTimezone = false; // Detect the timezone of the Server Automatically
input double InpServerTimezone = 3.0; // Server Timezone (used if auto detection is disabled)

input int  InpMaxHistoricalSessionsToShow = 50;        // Max Historical Sessions to Show

input int InpSessionTimeZonesHour = 0; // Timezone (Hour)
input int InpSessionTimeZonesMin = 0; // Timezone (Minute) - usually 0

input bool InpShowSession1 = true; // Show Session 1
input bool InpShowNextSession1 = true; // Show Next Session 1
input string InpSession1Name = "Asia"; // Session 1 Name
input SESSION_TZ InpSession1Type = SESSION_TZ_ASIA; // Session 1 Type
input color InpSession1Color = clrBlueViolet; // Session 1 Color
input int InpSession1StartHour = 23; // Session 1 Time (Start Hour)
input int InpSession1StartMin = 30; // Session 1 Time (Start Min)
input int InpSession1EndHour = 2; // Session 1 Time (End Hour)
input int InpSession1EndMin = 0; // Session 1 Time (End Min)

input bool InpShowSession2 = true; // Show Session 2
input bool InpShowNextSession2 = true; // Show Next Session 2
input string InpSession2Name = "London"; // Session 2 Name
input SESSION_TZ InpSession2Type = SESSION_TZ_LONDON; // Session 2 Type
input color InpSession2Color = clrGold; // Session 2 Color
input int InpSession2StartHour = 5; // Session 2 Time (Start Hour)
input int InpSession2StartMin = 30; // Session 2 Time (Start Min)
input int InpSession2EndHour = 8; // Session 2 Time (End Hour)
input int InpSession2EndMin = 0; // Session 2 Time (End Min)

input bool InpShowSession3 = true; // Show Session 3
input bool InpShowNextSession3 = true; // Show Next Session 3
input string InpSession3Name = "New York"; // Session 3 Name
input SESSION_TZ InpSession3Type = SESSION_TZ_NEWYORK; // Session 3 Type
input color InpSession3Color = clrLimeGreen; // Session 3 Color
input int InpSession3StartHour = 11; // Session 3 Time (Start Hour)
input int InpSession3StartMin = 0; // Session 3 Time (Start Min)
input int InpSession3EndHour = 13; // Session 3 Time (End Hour)
input int InpSession3EndMin = 30; // Session 3 Time (End Min)

CSessions *g_Sessions;

bool g_IsInitialised = false;

void OnDeinit(const int reason)
{
   PrintFormat("Shutting Down (Market Sessions)");

   if (g_Sessions != NULL) delete g_Sessions;
   
   g_IsInitialised = false;
}

void Initialize(datetime dt)
{
   g_Sessions = new CSessions();

   if (InpShowSession1)
   {
      g_Sessions.CreateSession(
         INDICATOR_SHORT_NAME, InpSession1Name, InpSession1Color, InpMaxHistoricalSessionsToShow, InpShowNextSession1, InpSession1StartHour,
         InpSession1StartMin, InpSession1EndHour, InpSession1EndMin, (InpSessionTimeZonesHour*60*60 + InpSessionTimeZonesMin*60), (int)dt, InpSession1Type);
   }
   
   if (InpShowSession2)
   {
      g_Sessions.CreateSession(
         INDICATOR_SHORT_NAME, InpSession2Name, InpSession2Color, InpMaxHistoricalSessionsToShow, InpShowNextSession2, InpSession2StartHour,
         InpSession2StartMin, InpSession2EndHour, InpSession2EndMin, (InpSessionTimeZonesHour*60*60 + InpSessionTimeZonesMin*60), (int)dt, InpSession2Type);
   }      
   
   if (InpShowSession3)
   {
      g_Sessions.CreateSession(
         INDICATOR_SHORT_NAME, InpSession3Name, InpSession3Color, InpMaxHistoricalSessionsToShow, InpShowNextSession3, InpSession3StartHour,
         InpSession3StartMin, InpSession3EndHour, InpSession3EndMin, (InpSessionTimeZonesHour*60*60 + InpSessionTimeZonesMin*60), (int)dt, InpSession3Type);
   }

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
      EventSetTimer(1);
      PrintFormat("Starting (Market Sessions) - initialization delayed");
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
   if (!g_IsInitialised)
   {
      Print("Awaiting initialization...");
      return(0);
   }

   int secondsPerPeriod = PeriodSeconds(PERIOD_CURRENT); // 600 in a 5 minute candle
   const int secondsPerDay = 60 * 60 * 24;
   int candlesPerDay = secondsPerDay / secondsPerPeriod;
   
   //--- Only calculate a max number of historical sessions based on user input
   int start = MathMax(rates_total - (InpMaxHistoricalSessionsToShow * candlesPerDay) - 1, prev_calculated - 1);

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