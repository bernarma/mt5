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
   bool _isVisible;
   bool _showNextSession;

   int _startDay;
   int _endDay;
   int _startHourInSeconds;
   int _durationInSeconds;

   int _maxHistoricalSessions;
   datetime _start;
   
   CQueue<CSessionRange *> *_sessions;
   CSessionRange *_currentSession;
   
   static datetime GetSessionStart(datetime date, int startTimeInSeconds);
   datetime GetNextSessionStart(datetime date);
   void MoveToNextSession(datetime now = NULL);

   datetime GetNextStart();
   datetime GetStart();
   datetime GetEnd();

   string GetDrawingName(void);
      
public:
   CSession(string prefix, string name, color clr, int maxHistoricalSessions, bool isVisible, bool showNextSession, SESSION_TZ session, int startDay, int endDay);
   
   ~CSession();
   
   void Initialize(int startHour, int startMin, int endHour, int endMin, int sessionSecondsOffsetTz, int serverSecondsOffsetTz);
   
   bool IsInSession(datetime dtCurrent, DUR &state);
   
   void Process(datetime dtCurrent, double open, double high, double low, double close);
};

CSession::CSession(string prefix, string name, color clr, int maxHistoricalSessions, bool isVisible, bool showNextSession, SESSION_TZ sessionTz, int startDay, int endDay)
{
   _sessionTz = sessionTz;
   _maxHistoricalSessions = maxHistoricalSessions;
   _prefix = prefix;
   _name = name;
   _clr = clr;
   _showNextSession = showNextSession;
   _isVisible = isVisible;
   _startDay = startDay;
   _endDay = endDay;
   
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

   // handle when time crosses midnight, i.e. 2300 - 0700
   if (endHour < startHour)
   {
      _durationInSeconds = (((24 - startHour) + endHour) * 60 - startMin + endMin) * 60;
   }
   else
   {
      _durationInSeconds = ((endHour - startHour) * 60 - startMin + endMin) * 60;
   }
   
   PrintFormat("Initializing Session %f-%f Resulting Server Times Starting %i, Duration %i, Offsets [Sess=%i, Server=%i], Resulting Adjustment [%i]",
      startHour, endHour, _startHourInSeconds, _durationInSeconds, sessionSecondsOffsetTz, serverSecondsOffsetTz, adjustment);
   
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
         CDrawingHelpers::VLineCreate(0, GetDrawingName(), _name, 0, GetStart(), _clr, STYLE_DOT, 1, true, false, true, true);
   }

   // Ignore any time that isn't in current session
   DUR state;
   bool inSession = IsInSession(dtCurrent, state);
   
   //  If current session doesn't exist and we just detected a session start
   //  - Set current session to "NEW SESSION"   
   if (_currentSession == NULL && inSession)
   {
      _currentSession = new CSessionRange(_prefix, _name, GetStart(), GetEnd(), high, low, _isVisible, _clr);
      
      if (_showNextSession) CDrawingHelpers::VLineMove(0, GetDrawingName(), GetNextStart());
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

datetime CSession::GetSessionStart(datetime date, int startTimeInSeconds)
{
   MqlDateTime sDate;
   TimeToStruct(date, sDate);

   sDate.hour = 0;
   sDate.min = 0;
   sDate.sec = 0;

   return StructToTime(sDate) + startTimeInSeconds;
}

datetime CSession::GetNextSessionStart(datetime date)
{
   MqlDateTime sDate;
   TimeToStruct(date, sDate);
   
   CDateTime dt;
   dt.DateTime(date);

   // failsafe to ensure we don't loop forever
   int count = 7;

   do
   {
      dt.DayInc(1);
   } while ((dt.day_of_week < _startDay || dt.day_of_week > _endDay) && (count-- > 0));

   return GetSessionStart(dt.DateTime(), _startHourInSeconds);
}

void CSession::MoveToNextSession(datetime now = NULL)
{
   datetime originalStart = _start;

   _start = GetNextSessionStart((now != NULL) ? now : _start);

   PrintFormat("Moved to Next Session [%s] from [%s] Created [%s - %s] based on Input Date [%s]",
      _name, TimeToString(originalStart), TimeToString(GetStart()), TimeToString(GetEnd()), TimeToString(now));
}

bool CSession::IsInSession(datetime date, DUR &state)
{
   state = DUR_DURING;

   if (date > GetEnd()) state = DUR_AFTER;
   if (GetStart() > date) state = DUR_BEFORE;

   return (state == DUR_DURING);
}

datetime CSession::GetNextStart()
{
   datetime start = GetNextSessionStart(_start);

   // adjust for daylight savings
   bool isDaylightSavingsTime = CCalendarHelpers::IsInDaylightSavingsTime(_sessionTz, start);
   int daylightSavingsTimeOffset = ((isDaylightSavingsTime) ? 60*60 : 0);

   return start + daylightSavingsTimeOffset;
}

datetime CSession::GetStart()
{
   // adjust for daylight savings
   bool isDaylightSavingsTime = CCalendarHelpers::IsInDaylightSavingsTime(_sessionTz, _start);
   int daylightSavingsTimeOffset = ((isDaylightSavingsTime) ? 60*60 : 0);

   return _start + daylightSavingsTimeOffset;
}

datetime CSession::GetEnd()
{
   return GetStart() + _durationInSeconds;
}