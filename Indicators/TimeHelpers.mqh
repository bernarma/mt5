//+------------------------------------------------------------------+
//|                                                  TimeHelpers.mqh |
//|                                 Copyright 2023, Mark Bernardinis |
//|                                   https://www.mtnsconsulting.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Mark Bernardinis"
#property link      "https://www.mtnsconsulting.com"
#property version   "1.00"

enum DIR {
   DIR_BULL = 1,
   DIR_NONE = 0,
   DIR_BEAR = -1
};

class CTimeHelpers
{
private:

public:
   CTimeHelpers();
   ~CTimeHelpers();

   static DIR CandleDir(const double open, const double high, const double low, const double close);
   static bool IsBullDir(DIR dir);
   static bool IsBearDir(DIR dir);
   static bool IsNeutralDir(DIR dir);
   static bool IsBullCandle(const double open, const double high, const double low, const double close);
   static bool IsBearCandle(const double open, const double high, const double low, const double close);
   static bool IsNeutralCandle(const double open, const double high, const double low, const double close);

   static int ConvertToLocalTimeToServerTimeInSeconds(int hour, int min, int tzHour, int tzMin, int serverOffsetSeconds);

   static int GetTimeframeMinutes(ENUM_TIMEFRAMES timeframe);
};

CTimeHelpers::CTimeHelpers()
{
}

CTimeHelpers::~CTimeHelpers()
{
}

int CTimeHelpers::ConvertToLocalTimeToServerTimeInSeconds(int hour, int min, int tzHour, int tzMin, int serverOffsetSeconds)
{
   int localHour = hour - tzHour;
   int localMin = min - tzMin;

   return ((localHour * 60) + localMin) * 60 + serverOffsetSeconds;
}

DIR CTimeHelpers::CandleDir(const double open, const double high, const double low, const double close)
{
   return close > open ? DIR_BULL : (close < open ? DIR_BEAR : DIR_NONE);
}

bool CTimeHelpers::IsBullDir(DIR dir)
{
   return dir == DIR_BULL;
}

bool CTimeHelpers::IsBearDir(DIR dir)
{
   return dir == DIR_BEAR;
}

bool CTimeHelpers::IsNeutralDir(DIR dir)
{
   return dir == DIR_NONE;
}

bool CTimeHelpers::IsBullCandle(const double open, const double high, const double low, const double close)
{
   return IsBullDir(CandleDir(open, high, low, close));
}

bool CTimeHelpers::IsBearCandle(const double open, const double high, const double low, const double close)
{
   return IsBearDir(CandleDir(open, high, low, close));
}

bool CTimeHelpers::IsNeutralCandle(const double open, const double high, const double low, const double close)
{
   return IsNeutralDir(CandleDir(open, high, low, close));
}

int CTimeHelpers::GetTimeframeMinutes(ENUM_TIMEFRAMES timeframe)
{
   switch(timeframe)
   {
      case PERIOD_M1:
         return(1);
      case PERIOD_M2:
         return(2);
      case PERIOD_M3:
         return(3);
      case PERIOD_M4:
         return(4);
      case PERIOD_M5:
         return(5);
      case PERIOD_M6:
         return(6);
      case PERIOD_M10:
         return(10);
      case PERIOD_M12:
         return(12);
      case PERIOD_M15:
         return(15);
      case PERIOD_M20:
         return(20);
      case PERIOD_M30:
         return(30);
      case PERIOD_H1:
         return(60);
      case PERIOD_H2:
         return(2*60);
      case PERIOD_H3:
         return(3*60);
      case PERIOD_H4:
         return(4*60);
      case PERIOD_H6:
         return(6*60);
      case PERIOD_H8:
         return(8*60);
      case PERIOD_H12:
         return(12*60);
      case PERIOD_D1:
         return(24*60);
      case PERIOD_W1:
         return(7*24*60);
      default:
         return(0);
   }

   return(0);
};
