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

enum DIR {
   DIR_BULL = 1,
   DIR_NONE = 0,
   DIR_BEAR = -1
};

enum ENUM_UTC_TZ {
   TZ_UTCM12 = -12, // UTC-12
   TZ_UTCM11 = -11, // UTC-11
   TZ_UTCM10 = -10, // UTC-10
   TZ_UTCM9 = -9, // UTC-9
   TZ_UTCM8 = -8, // UTC-8
   TZ_UTCM7 = -7, // UTC-7
   TZ_UTCM6 = -6, // UTC-6
   TZ_UTCM5 = -5, // UTC-5
   TZ_UTCM4 = -4, // UTC-4
   TZ_UTCM3 = -3, // UTC-3
   TZ_UTCM2 = -2, // UTC-2
   TZ_UTCM1 = -1, // UTC-1
   TZ_UTC = 0, // UTC
   TZ_UTC1 = 1, // UTC+1
   TZ_UTC2 = 2, // UTC+2
   TZ_UTC3 = 3, // UTC+3
   TZ_UTC4 = 4, // UTC+4
   TZ_UTC5 = 5, // UTC+5
   TZ_UTC6 = 6, // UTC+6
   TZ_UTC7 = 7, // UTC+7
   TZ_UTC8 = 8, // UTC+8
   TZ_UTC9 = 9, // UTC+9
   TZ_UTC10 = 10, // UTC+10
   TZ_UTC11 = 11, // UTC+11
   TZ_UTC12 = 12, // UTC+12
   TZ_UTC13 = 13, // UTC+13
   TZ_UTC14 = 14 // UTC+14
};

class CTimeHelpers
{
private:
   static int ConvertToLocalTimeToServerTimeInSeconds(int hour, int min, ENUM_UTC_TZ tz, int serverOffsetSeconds, bool &next);

public:
   CTimeHelpers();
   ~CTimeHelpers();

   static DIR CandleDir(const double open, const double close);
   static bool IsBullDir(DIR dir);
   static bool IsBearDir(DIR dir);
   static bool IsNeutralDir(DIR dir);
   static bool IsBullCandle(const double open, const double close);
   static bool IsBearCandle(const double open, const double close);
   static bool IsNeutralCandle(const double open, const double close);

   static int ConvertToLocalTimeToServerTimeInSeconds(datetime time, ENUM_UTC_TZ tz, int serverOffsetSeconds, bool &next);

   static int TimeToSeconds(datetime date);

   static int MinutesBetween(datetime start, datetime end);

   static int GetTimeframeMinutes(ENUM_TIMEFRAMES timeframe);
};

CTimeHelpers::CTimeHelpers()
{
}

CTimeHelpers::~CTimeHelpers()
{
}

int CTimeHelpers::MinutesBetween(datetime start, datetime end)
{
   MqlDateTime dStart, dEnd;
   TimeToStruct(start, dStart);
   TimeToStruct(end, dEnd);

   int duration = 0;

   // handle when time crosses midnight, i.e. 2300 - 0700
   if (dEnd.hour < dStart.hour)
   {
      duration = (((24 - dStart.hour) + dEnd.hour) * 60 - dStart.min + dEnd.min);
   }
   else
   {
      duration = ((dEnd.hour - dStart.hour) * 60 - dStart.min + dEnd.min);
   }

   return duration;
}

int CTimeHelpers::TimeToSeconds(datetime date)
{
   MqlDateTime d;
   TimeToStruct(date, d);

   return ((d.hour * 60) + d.min) * 60;
}

int CTimeHelpers::ConvertToLocalTimeToServerTimeInSeconds(datetime time, ENUM_UTC_TZ tz, int serverOffsetSeconds, bool &next)
{
   MqlDateTime dTime;
   TimeToStruct(time, dTime);
   
   return ConvertToLocalTimeToServerTimeInSeconds(dTime.hour, dTime.min, tz, serverOffsetSeconds, next);
}

int CTimeHelpers::ConvertToLocalTimeToServerTimeInSeconds(int hour, int min, ENUM_UTC_TZ tz, int serverOffsetSeconds, bool &next)
{
   next = false;
   int i = (((hour - tz) * 60) + min) * 60 + serverOffsetSeconds;

   if (i > 86400)
   {
      i -= 86400;
      next = true;
   }

   return i;
}

DIR CTimeHelpers::CandleDir(const double open, const double close)
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

bool CTimeHelpers::IsBullCandle(const double open, const double close)
{
   return IsBullDir(CandleDir(open, close));
}

bool CTimeHelpers::IsBearCandle(const double open, const double close)
{
   return IsBearDir(CandleDir(open, close));
}

bool CTimeHelpers::IsNeutralCandle(const double open, const double close)
{
   return IsNeutralDir(CandleDir(open, close));
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
