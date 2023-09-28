//+------------------------------------------------------------------+
//|                                                      session.mqh |
//|                                 Copyright 2023, Mark Bernardinis |
//|                                   https://www.mtnsconsulting.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Mark Bernardinis"
#property link      "https://www.mtnsconsulting.com"
#property version   "1.00"

#include "DrawingHelpers.mqh"
#include "SessionRange.mqh"
#include <Generic\Queue.mqh>
#include <Tools\DateTime.mqh>

class CSession
{

private:
   string _prefix;
   string _name;
   color  _clr;
   bool _showNextSession;
   int _startHourInSeconds;
   int _endHourInSeconds;
   int _maxHistoricalSessions;
   datetime _start, _end;
   
   CQueue<CSessionRange *> *_sessions;
   CSessionRange *_currentSession;
   
   static void CalculateNextSession(datetime currentStart, datetime currentEnd, datetime &nextStart, datetime &nextEnd);
   bool MoveNextSession(datetime dtCurrent);
   string GetDrawingName(void);
      
public:
   CSession(string prefix, string name, color clr, int maxHistoricalSessions, bool showNextSession);
   
   ~CSession();
   
   void Initialize(int startHour, int startMin, int endHour, int endMin, int sessionSecondsOffsetTz, int serverSecondsOffsetTz);
   
   bool IsInSession(datetime dtCurrent);
   
   void Process(datetime dtCurrent, double open, double high, double low, double close, bool &inSession);
};

CSession::CSession(string prefix, string name, color clr, int maxHistoricalSessions, bool showNextSession)
{
   _maxHistoricalSessions = maxHistoricalSessions;
   _prefix = prefix;
   _name = name;
   _clr = clr;
   _showNextSession = showNextSession;
   
   _sessions = new CQueue<CSessionRange*>();
}

CSession::~CSession()
{
   for (int i = _sessions.Count(); i > 0; i--)
   {
      CSessionRange *range = _sessions.Dequeue();
      delete range;
   }
   
   if (_showNextSession)
      CDrawingHelpers::VLineDelete(0, GetDrawingName());
      
   if (_currentSession != NULL)
      delete _currentSession;
   
   delete _sessions;
}

string CSession::GetDrawingName(void)
{
   return StringFormat("[%s]Sess_%s_NXT", _prefix, _name);
}

void CSession::Initialize(int startHour, int startMin, int endHour, int endMin, int sessionSecondsOffsetTz, int serverSecondsOffsetTz)
{
   int adjustment = (sessionSecondsOffsetTz - serverSecondsOffsetTz);
   
   // Convert start to hours and minutes (it is not truly a fractional but a representation of the minutes)
   _startHourInSeconds = ((int)startHour * 60 * 60) + startMin * 60;
   _startHourInSeconds -= adjustment;
   
   _endHourInSeconds = ((int)endHour * 60 * 60) + endMin * 60;
   _endHourInSeconds -= adjustment;
   
   if (_endHourInSeconds < 0) _endHourInSeconds = _endHourInSeconds + (24*60*60);
   
   PrintFormat("Initializing Session %f-%f Resulting Server Times From %f to %f, Offsets [Sess=%i, Server=%i], Resulting Adjustment [%i]",
      startHour, endHour, _startHourInSeconds, _endHourInSeconds, sessionSecondsOffsetTz, serverSecondsOffsetTz, adjustment);
   
   _start = NULL;
}

//--- Must be called in sequential order
void CSession::Process(datetime dtCurrent, double open, double high, double low, double close, bool &inSession)
{
   // Ignore any time that isn't in current session
   inSession = IsInSession(dtCurrent);
   
   //  If current session doesn't exist and we just detected a session start
   //  - Set current session to "NEW SESSION"   
   if (_currentSession == NULL && inSession)
   {
      _currentSession = new CSessionRange(_prefix, _name, dtCurrent, high, low, _clr);
      
      // move to the next session (if enabled)
      if (_showNextSession)
         CDrawingHelpers::VLineMove(0, GetDrawingName(), _start + 24*60*60);

   }
   else if (_currentSession != NULL && !inSession)
   {
      // If current session and we just detected end of session (i.e. it has finished)
      // - add to historical sessions
      _sessions.Enqueue(_currentSession);
      _currentSession = NULL;
      
      if (_sessions.Count() > _maxHistoricalSessions)
      {
         // If historical sessions greater than max historical
         // - Remove oldest historical sessions
         delete _sessions.Dequeue();
      }
   }
   else if (inSession)
   {
      // Set high and low values of current session based on current bar
      _currentSession.Update(dtCurrent, high, low);
   }
}

void CSession::CalculateNextSession(datetime currentStart, datetime currentEnd, datetime &nextStart, datetime &nextEnd)
{
   MqlDateTime mqCurrentStart;
   TimeToStruct(currentStart, mqCurrentStart);
   int daysToIncrement = (mqCurrentStart.day_of_week != 5) ? 1 : 3;

   CDateTime dtCurrentStart, dtCurrentEnd;
   dtCurrentStart.DateTime(currentStart);
   dtCurrentEnd.DateTime(currentEnd);
   
   dtCurrentStart.DayInc(daysToIncrement);
   dtCurrentEnd.DayInc(daysToIncrement);
   
   nextStart = dtCurrentStart.DateTime();
   nextEnd = dtCurrentEnd.DateTime();
}

bool CSession::MoveNextSession(datetime dtCurrent)
{
   if (_start == NULL) return false;
   
   datetime start, end;
   while (dtCurrent > _end)
   {
      CalculateNextSession(_start, _end, start, end);
      
      _start = start;
      _end = end;
   }
   
   return true;
}

//--- Check if date provided is contained within this session
bool CSession::IsInSession(datetime dtCurrent)
{
   if (_start == NULL)
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
      
      // TODO: implement the rules
      // London Session: clocks go forward 1 hour at 1am on the last Sunday in March, and back 1 hour at 2am on the last Sunday in October
      // New York Session: (from 2007) daylight saving time begins on the second Sunday of March and ends on the first Sunday of November
      // New York Session: (before 2007) daylight saving time started on the last Sunday of April and ended on the last Sunday of October
      //CDateTime _s;
      //_s.DateTime(sToday);
      //_s.SecInc(_startHourInSeconds);
      //_s.DayDec();
      
      _start = StructToTime(sToday) + _startHourInSeconds;
      
      // we roll back a day then add the start time
      if (_startHourInSeconds > _endHourInSeconds)
         _start = _start - (24 * 60 * 60);

      _end = StructToTime(sToday);
      _end = _end + _endHourInSeconds;
      
      // draw the start of the next session - this will be moved during the creation of a session as needed
      if (_showNextSession)
         CDrawingHelpers::VLineCreate(0, GetDrawingName(), _name, 0, _start, _clr, STYLE_DOT, 1, true, false, true, true);
      
      PrintFormat("Session [%s] Created [%s - %s] Adjusted Start/End [%f - %f]",
         _name, TimeToString(_start), TimeToString(_end), _startHourInSeconds, _endHourInSeconds);
   }

   if (dtCurrent > _end)
   {
      MoveNextSession(dtCurrent);
   }
   
   return (_start <= dtCurrent && dtCurrent <= _end);
}