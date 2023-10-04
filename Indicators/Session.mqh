//+------------------------------------------------------------------+
//|                                                      session.mqh |
//|                                 Copyright 2023, Mark Bernardinis |
//|                                   https://www.mtnsconsulting.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Mark Bernardinis"
#property link      "https://www.mtnsconsulting.com"
#property version   "1.00"

#include "CalendarHelpers.mqh"
#include "DrawingHelpers.mqh"
#include "SessionRange.mqh"
#include <Generic\Queue.mqh>
#include <Tools\DateTime.mqh>

enum DUR {
   DUR_BEFORE = -1,
   DUR_DURING = 0,
   DUR_AFTER = 1
};

class CSession
{

private:
   SESSION_TZ _sessionTz;

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
   
   void GetSessionTimes(datetime date, datetime &start, datetime &end, bool &isDaylightSavingsTime);
   void GetNextSessionTimes(datetime date, datetime &start, datetime &end, bool &isDaylightSavingsTime);
   void MoveToNextSession(datetime now = NULL);

   string GetDrawingName(void);
      
public:
   CSession(string prefix, string name, color clr, int maxHistoricalSessions, bool showNextSession, SESSION_TZ session);
   
   ~CSession();
   
   void Initialize(int startHour, int startMin, int endHour, int endMin, int sessionSecondsOffsetTz, int serverSecondsOffsetTz);
   
   bool IsInSession(datetime dtCurrent, DUR &state);
   
   void Process(datetime dtCurrent, double open, double high, double low, double close);
};

CSession::CSession(string prefix, string name, color clr, int maxHistoricalSessions, bool showNextSession, SESSION_TZ sessionTz)
{
   _sessionTz = sessionTz;
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
void CSession::Process(datetime dtCurrent, double open, double high, double low, double close)
{
   if (_start == NULL)
   {
      MoveToNextSession(dtCurrent);

      // draw the start of the next session - this will be moved during the creation of a session as needed
      if (_showNextSession)
         CDrawingHelpers::VLineCreate(0, GetDrawingName(), _name, 0, _start, _clr, STYLE_DOT, 1, true, false, true, true);
   }

   // Ignore any time that isn't in current session
   DUR state;
   bool inSession = IsInSession(dtCurrent, state);
   
   //  If current session doesn't exist and we just detected a session start
   //  - Set current session to "NEW SESSION"   
   if (_currentSession == NULL && inSession)
   {
      _currentSession = new CSessionRange(_prefix, _name, _start, _end, high, low, _clr);
      
      // move to the next session (if enabled)
      if (_showNextSession)
      {
         datetime start, end;
         bool isDaylightSavingsTime;
         GetNextSessionTimes(_start, start, end, isDaylightSavingsTime);
         CDrawingHelpers::VLineMove(0, GetDrawingName(), start);
      }
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

   if (state == DUR_AFTER) MoveToNextSession();
}

void CSession::GetSessionTimes(datetime date, datetime &start, datetime &end, bool &isDaylightSavingsTime)
{
   MqlDateTime sDate;
   TimeToStruct(date, sDate);

   sDate.hour = 0;
   sDate.min = 0;
   sDate.sec = 0;

   isDaylightSavingsTime = CCalendarHelpers::IsInDaylightSavingsTime(_sessionTz, date);
   int daylightSavingsTimeOffset = ((isDaylightSavingsTime) ? 60*60 : 0);
   
   start = StructToTime(sDate) + _startHourInSeconds + daylightSavingsTimeOffset;
   end = start + (_endHourInSeconds - _startHourInSeconds);

   if (_startHourInSeconds > _endHourInSeconds)
      end = end + (24 * 60 * 60);
}

void CSession::GetNextSessionTimes(datetime date, datetime &start, datetime &end, bool &isDaylightSavingsTime)
{
   MqlDateTime sDate;
   TimeToStruct(date, sDate);
   int daysToIncrement = (sDate.day_of_week != 5) ? 1 : 3;

   CDateTime dt;
   dt.DateTime(date);
   dt.DayInc(daysToIncrement);

   GetSessionTimes(dt.DateTime(), start, end, isDaylightSavingsTime);
}

void CSession::MoveToNextSession(datetime now = NULL)
{
   bool isDaylightSavingsTime;
   GetNextSessionTimes((now != NULL) ? now : _start, _start, _end, isDaylightSavingsTime);

   PrintFormat("Moved to Next Session [%s] Created [%s - %s] based on Input Date [%s], Adjusted for Daylight Savings Time? %i",
      _name, TimeToString(_start), TimeToString(_end), TimeToString(now), isDaylightSavingsTime);
}

bool CSession::IsInSession(datetime date, DUR &state)
{
   state = DUR_DURING;

   if (date > _end) state = DUR_AFTER;
   if (_start > date) state = DUR_BEFORE;

   return (state == DUR_DURING);
}