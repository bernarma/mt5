//+------------------------------------------------------------------+
//|                                                      session.mqh |
//|                                 Copyright 2023, Mark Bernardinis |
//|                                   https://www.mtnsconsulting.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Mark Bernardinis"
#property link      "https://www.mtnsconsulting.com"
#property version   "1.00"

#include "SessionRange.mqh"
#include <Generic\Queue.mqh>

class CSession
{

private:
   string _name;
   color  _clr;
   int _startHourInSeconds;
   int _endHourInSeconds;
   int _maxHistoricalSessions;
   datetime _start, _end;
   
   CQueue<CSessionRange *> *_sessions;
   CSessionRange *_currentSession;
   
   bool MoveNextSession(datetime dtCurrent);
   int GetMinutesFromTime(double time);
      
public:
   CSession(string name, color clr, int maxHistoricalSessions);
   
   ~CSession();
   
   void Initialize(double startHour, double endHour, int sessionSecondsOffsetTz, int serverSecondsOffsetTz);
   
   bool IsInSession(datetime dtCurrent);
   
   void Process(datetime dtCurrent, double open, double high, double low, double close, bool &inSession);
};

CSession::CSession(string name, color clr, int maxHistoricalSessions)
{
   _maxHistoricalSessions = maxHistoricalSessions;
   _name = name;
   _clr = clr;
   
   _sessions = new CQueue<CSessionRange*>();
}

CSession::~CSession()
{
   for (int i = _sessions.Count(); i > 0; i--)
   {
      CSessionRange *range = _sessions.Dequeue();
      delete range;
   }
   
   if (_currentSession != NULL)
      delete _currentSession;
   
   delete _sessions;
}

int CSession::GetMinutesFromTime(double time)
{
   return (int)((time - (int)time) * 100);
}

void CSession::Initialize(double startHour, double endHour, int sessionSecondsOffsetTz, int serverSecondsOffsetTz)
{
   int adjustment = (sessionSecondsOffsetTz - serverSecondsOffsetTz);
   
   // Convert start to hours and minutes (it is not truly a fractional but a representation of the minutes)
   _startHourInSeconds = ((int)startHour * 60 * 60) + GetMinutesFromTime(startHour) * 60;
   _startHourInSeconds -= adjustment;
   
   _endHourInSeconds = ((int)endHour * 60 * 60) + GetMinutesFromTime(endHour) * 60;
   _endHourInSeconds -= adjustment;
   
   if (_endHourInSeconds < 0) _endHourInSeconds = _endHourInSeconds + (24*60*60);
   
   //PrintFormat("Initializing Session %f-%f, Resulting Server Times From %f to %f, Offsets [Sess=%i, Server=%i], Resulting Adjustment [%i]",
      //startHour, endHour, _startHourInSeconds, _endHourInSeconds,
      //sessionSecondsOffsetTz, serverSecondsOffsetTz, adjustment);
   
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
      _currentSession = new CSessionRange(_name, dtCurrent, high, low, _clr);
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

bool CSession::MoveNextSession(datetime dtCurrent)
{
   if (_start == NULL) return false;
   const int dayIncrement = 24*60*60;
   
   while (dtCurrent > _end)
   {
      _start = _start + dayIncrement;
      _end = _end + dayIncrement;
   }
   
   return true;
}

//--- Check if date provided is contained within this session
bool CSession::IsInSession(datetime dtCurrent)
{
   // TODO: handle daylight saving based on the first/last Sunday of month - see rules
   // and then adjust the dtCandle.hour statement accordingly

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
      
      _start = StructToTime(sToday) + _startHourInSeconds;
      
      // we roll back a day then add the start time
      if (_startHourInSeconds > _endHourInSeconds)
         _start = _start - (24 * 60 * 60);

      _end = StructToTime(sToday);
      _end = _end + _endHourInSeconds;
      
      //PrintFormat("Session [%s] Created [%s - %s] Adjusted Start/End [%f - %f]",
         //_name, TimeToString(_start), TimeToString(_end), _startHourInSeconds, _endHourInSeconds);
   }

   // skip weekends
   if (dtCurrent > _end)
   {
      MoveNextSession(dtCurrent);
   }
   
   return (_start <= dtCurrent && dtCurrent <= _end);
}