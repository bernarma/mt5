//+------------------------------------------------------------------+
//|                                              CalendarHelpers.mqh |
//|                                 Copyright 2023, Mark Bernardinis |
//|                                   https://www.mtnsconsulting.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Mark Bernardinis"
#property link      "https://www.mtnsconsulting.com"
#property version   "1.00"

#include <Tools\DateTime.mqh>

enum SESSION_TZ {
   SESSION_TZ_ASIA = 0, // Asia
   SESSION_TZ_LONDON = 1, // London
   SESSION_TZ_NEWYORK = 2, // New York
};

class CCalendarHelpers
{
private:
   CCalendarHelpers();
   ~CCalendarHelpers();

public:
   // Day of week (0-Sunday, 1-Monday, ... ,6-Saturday)
   static datetime GetNDayOfWeekOfMonth(datetime date, int dayOfWeek, int count);

   static bool IsInDaylightSavingsTime(SESSION_TZ tz, datetime date);
};

CCalendarHelpers::CCalendarHelpers()
{
}

CCalendarHelpers::~CCalendarHelpers()
{
}

bool CCalendarHelpers::IsInDaylightSavingsTime(SESSION_TZ tz, datetime date)
{
   if (tz == SESSION_TZ_ASIA) return false;

   CDateTime d();
   d.DateTime(date);

   if (tz == SESSION_TZ_LONDON)
   {
      // London Session: clocks go forward 1 hour at 1am on the last Sunday in March, and back 1 hour at 2am on the last Sunday in October
      d.mon = 3;  datetime lastSundayOfMarch = GetNDayOfWeekOfMonth(d.DateTime(), 0, -1);
      d.mon = 10; datetime lastSundayOfOctober = GetNDayOfWeekOfMonth(d.DateTime(), 0, -1);

      return (date >= lastSundayOfMarch && date < lastSundayOfOctober);
   }
   else if (tz == SESSION_TZ_NEWYORK)
   {
      // New York Session: (from 2007) daylight saving time begins on the second Sunday of March and ends on the first Sunday of November
      if (d.year >= 2007)
      {
         d.mon = 3;  datetime secondSundaySundayOfMarch = GetNDayOfWeekOfMonth(d.DateTime(), 0, 2);
         d.mon = 11; datetime firstSundayOfNovember = GetNDayOfWeekOfMonth(d.DateTime(), 0, 1);

         return (date >= secondSundaySundayOfMarch && date < firstSundayOfNovember);
      }
      else
      {
         // New York Session: (before 2007) daylight saving time started on the last Sunday of April and ended on the last Sunday of October
         d.mon = 4;  datetime lastSundayOfApril = GetNDayOfWeekOfMonth(d.DateTime(), 0, 1);
         d.mon = 10; datetime lastSundayOfOctober = GetNDayOfWeekOfMonth(d.DateTime(), 0, -1);

         return (date >= lastSundayOfApril && date < lastSundayOfOctober);
      }
   }

   return false;
}

datetime CCalendarHelpers::GetNDayOfWeekOfMonth(datetime date, int dayOfWeek, int count)
{
   CDateTime d();
   d.DateTime(date);
   d.Day(1);

   int inc = 1;

   if (count < 0)
   {
      d.MonInc();
      inc = -1;
   }

   while (count != 0)
   {
      if (d.day_of_week == dayOfWeek)
         count += (count < 0) ? 1 : -1;

      if (count != 0)
         d.DayInc(inc);
   }
   
   return d.DateTime();
}
