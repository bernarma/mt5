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
};

CTimeHelpers::CTimeHelpers()
{
}

CTimeHelpers::~CTimeHelpers()
{
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
