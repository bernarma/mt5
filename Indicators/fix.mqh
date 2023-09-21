//+------------------------------------------------------------------+
//|                                                          fix.mqh |
//|                                 Copyright 2023, Mark Bernardinis |
//|                                   https://www.mtnsconsulting.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Mark Bernardinis"
#property link      "https://www.mtnsconsulting.com"
#property version   "1.00"

#include <Generic\LinkedList.mqh>
#include "HistoricalFix.mqh"

class CFix
{

private:
   string _name;
   
   int _secondsFromMidnight;
   
   int _maxHistoricalFixesToShow;
   
   bool _initialised;
   
   MqlDateTime _startTime;
   
   CLinkedList<CHistoricalFix *> *_historicalFixes;
   
   color _clr;
   
   ENUM_LINE_STYLE _style;
   
   int GetMinutesFromTime(double time);
      
public:
   CFix(string name, int maxHistoricalFixesToShow, color clr, ENUM_LINE_STYLE style);
   ~CFix();
   
   void Handle(datetime time, double price);

   bool IsInRange(datetime dtCurrent);

   void Initialize(double start, int sessionSecondsOffsetTz, int serverSecondsOffsetTz);

};

CFix::CFix(string name, int maxHistoricalFixesToShow, color clr, ENUM_LINE_STYLE style)
{
   _name = name;
   _initialised = false;
   _clr = clr;
   _style = style;
   
   _maxHistoricalFixesToShow = maxHistoricalFixesToShow;
   
   _historicalFixes = new CLinkedList<CHistoricalFix *>();
}

CFix::~CFix()
{
   Print("~CFix");
   
   for (int i = _historicalFixes.Count(); i > 0; i--)
   {
      CLinkedListNode<CHistoricalFix *> *historicalFixNode = _historicalFixes.First();
      delete historicalFixNode.Value();
      _historicalFixes.Remove(historicalFixNode);
   }
   
   delete _historicalFixes;
}

int CFix::GetMinutesFromTime(double time)
{
   return (int)((time - (int)time) * 100);
}

void CFix::Initialize(double start, int sessionSecondsOffsetTz, int serverSecondsOffsetTz)
{
   int adjustment = (sessionSecondsOffsetTz - serverSecondsOffsetTz);
   
   // Convert start to hours and minutes (it is not truly a fractional but a representation of the minutes)
   _secondsFromMidnight = ((int)start * 60 * 60) + GetMinutesFromTime(start) * 60;
   _secondsFromMidnight -= adjustment;

   //PrintFormat("Adjusting [%s - %f] Fix based on Server Timezone and Fix Timezone [Session=%i, ServerOffset=%i]",
      //_name, start, sessionSecondsOffsetTz, serverSecondsOffsetTz);
}

bool CFix::IsInRange(datetime dtCurrent)
{
   // Initialise using the current date as the start of the session window
   MqlDateTime dtS;
   TimeToStruct(dtCurrent, dtS);

   if (!_initialised)
   {
      MqlDateTime sToday;
      sToday.year = dtS.year;
      sToday.mon = dtS.mon;
      sToday.day = dtS.day;
      sToday.hour = 0;
      sToday.min = 0;
      sToday.sec = 0;
      
      TimeToStruct(StructToTime(sToday) + _secondsFromMidnight, _startTime);
      
      //PrintFormat("Initialized [%s] Fix %s",
         //_name, TimeToString(StructToTime(_startTime)));
         
      _initialised = true;
   }
   
   return (dtS.hour == _startTime.hour && dtS.min == _startTime.min);
}

void CFix::Handle(datetime time, double price)
{
   if (IsInRange(time))
   {
      // Add Fix
      CHistoricalFix *historicalFix = new CHistoricalFix(_name, time, price, _clr, _style);
      historicalFix.Initialize();
      _historicalFixes.Add(historicalFix);
      
      if (_historicalFixes.Count() > _maxHistoricalFixesToShow)
      {
         CLinkedListNode<CHistoricalFix *> *historicalFixNode = _historicalFixes.First();
         delete historicalFixNode.Value();
         _historicalFixes.Remove(historicalFixNode);
      }
   }
   else
   {
      // TODO: update the offset of the fix
      CLinkedListNode<CHistoricalFix *> *node = _historicalFixes.Head();
      if (node != NULL)
      {
         do
         {
            //PrintFormat("Iterating over Historical Fix LL %s %i", node.Value().GetName(), failsafe);
            node.Value().Update(time);
            node = node.Next();
         } while (node != _historicalFixes.Last());
      }
   }
   
}
