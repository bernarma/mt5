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

#include <Generic\LinkedList.mqh>

#include "HistoricalFix.mqh"
#include "CalendarHelpers.mqh"

class CFix
{

private:
   string _prefix;
   string _name;
   
   int _drawingOffset;
   int _maxHistoricalFixesToShow;
   int _fixInSeconds;
   
   CLinkedList<CHistoricalFix *> *_historicalFixes;
   
   color _clr;
   
   ENUM_LINE_STYLE _style;

   SESSION_TZ _session;
      
public:
   CFix(string prefix, string name, int fixInSeconds, int maxHistoricalFixesToShow,
           int drawingOffset, SESSION_TZ session, color clr, ENUM_LINE_STYLE style);

   ~CFix();
   
   string ToString();

   void Handle(datetime time, double price);

   bool IsInRange(datetime dtCurrent);

};

CFix::CFix(string prefix, string name, int fixInSeconds, int maxHistoricalFixesToShow,
           int drawingOffset, SESSION_TZ session, color clr, ENUM_LINE_STYLE style)
{
   _prefix = prefix;
   _name = name;
   _clr = clr;
   _style = style;
   _drawingOffset = drawingOffset;
   _session = session;

   _fixInSeconds = fixInSeconds;
   //_secondsFromMidnight = (((hourUTC * 60) + minUTC) * 60) + serverOffset;
   
   _maxHistoricalFixesToShow = maxHistoricalFixesToShow;
   
   _historicalFixes = new CLinkedList<CHistoricalFix *>();
}

CFix::~CFix()
{
   for (int i = _historicalFixes.Count(); i > 0; i--)
   {
      CLinkedListNode<CHistoricalFix *> *historicalFixNode = _historicalFixes.First();
      delete historicalFixNode.Value();
      _historicalFixes.Remove(historicalFixNode);
   }
   
   delete _historicalFixes;
}

string CFix::ToString()
{
   datetime d = _fixInSeconds;
   return StringFormat("%s - %s", _name, TimeToString(d));
}

bool CFix::IsInRange(datetime dtCurrent)
{
   // Initialise using the current date as the start of the session window
   MqlDateTime dtS;
   TimeToStruct(dtCurrent, dtS);

   MqlDateTime sToday;
   sToday.year = dtS.year;
   sToday.mon = dtS.mon;
   sToday.day = dtS.day;
   sToday.hour = 0;
   sToday.min = 0;
   sToday.sec = 0;

   bool isDaylightSavingsTime = CCalendarHelpers::IsInDaylightSavingsTime(_session, dtCurrent);
   int daylightSavingsTimeOffset = ((isDaylightSavingsTime) ? 60*60 : 0);

   datetime dtFix = StructToTime(sToday) + _fixInSeconds - daylightSavingsTimeOffset;

   //PrintFormat("Initialized [%s] Fix %s",
      //_name, TimeToString(StructToTime(_startTime)));

   return dtFix == dtCurrent;
}

void CFix::Handle(datetime time, double price)
{
   if (IsInRange(time))
   {
      // Add Fix
      CHistoricalFix *historicalFix = new CHistoricalFix(_prefix, _name, time, price, _drawingOffset, _clr, _style);
      historicalFix.Initialize();
      _historicalFixes.Add(historicalFix);
      //PrintFormat("Creating Historical Fix %s based off Fix %s", historicalFix.GetName(), ToString());
      
      if (_historicalFixes.Count() > _maxHistoricalFixesToShow)
      {
         CLinkedListNode<CHistoricalFix *> *historicalFixNode = _historicalFixes.First();
         //PrintFormat("Removing Historical Fix %s", historicalFixNode.Value().GetName());
         delete historicalFixNode.Value();
         _historicalFixes.Remove(historicalFixNode);
      }
   }
   else
   {
      //PrintFormat("Updating Fix %s [%i] Historical Fixes with Time %s", _name, _historicalFixes.Count(), TimeToString(time));
   
      CLinkedListNode<CHistoricalFix *> *node = _historicalFixes.Head();
      int count = 0;
      if (node != NULL)
      {
         do
         {
            //PrintFormat("Updating Historical Fix LL %s", node.Value().GetName());
            node.Value().Update(time);
            node = node.Next();
         } while (node != _historicalFixes.Head() && count++ < 10);
      }
   }
}
