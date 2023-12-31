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

#include <Tools\DateTime.mqh>

enum DAY_OF_WEEK {
   DAY_OF_WEEK_SUNDAY = 0, // Sunday
   DAY_OF_WEEK_MONDAY = 1, // Monday
   DAY_OF_WEEK_TUESDAY = 2, // Tuesday
   DAY_OF_WEEK_WEDNESDAY = 3, // Wednesday
   DAY_OF_WEEK_THURSDAY = 4, // Thursday
   DAY_OF_WEEK_FRIDAY = 5, // Friday
   DAY_OF_WEEK_SATURDAY = 6, // Saturday
};

enum SESSION_TZ {
   SESSION_TZ_SYDNEY = 0, // Sydney
   SESSION_TZ_ASIA = 1, // Asia
   SESSION_TZ_LONDON = 2, // London
   SESSION_TZ_NEWYORK = 3, // New York
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

   if (tz == SESSION_TZ_SYDNEY)
   {
      // Sydney Session: clocks go forward 1 hour at 3am on the first Sunday in April, and back 1 hour at 3am on the first Sunday in October
      d.mon = 4;  datetime firstSundayInApril = GetNDayOfWeekOfMonth(d.DateTime(), 0, 1);
      d.mon = 10; datetime firstSundayInOctober = GetNDayOfWeekOfMonth(d.DateTime(), 0, 1);

      return (date < firstSundayInApril || date >= firstSundayInOctober);
   }
   else if (tz == SESSION_TZ_LONDON)
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
