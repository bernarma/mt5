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
   double _startHour;
   double _endHour;
   int _maxHistoricalSessions;
   datetime _start, _end;
   
   CQueue<CSessionRange *> *_sessions;
   CSessionRange *_currentSession;
   
   bool IsInSession(datetime dtCurrent);
   bool MoveNextSession(datetime dtCurrent);
      
public:
   CSession(string name, color clr, int maxHistoricalSessions);
   
   ~CSession();
   
   void Initialize(double startHour, double endHour, int sessionSecondsOffsetTz, int serverSecondsOffsetTz);
   
   bool Process(datetime dtCurrent, double open, double high, double low, double close);
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

void CSession::Initialize(double startHour, double endHour, int sessionSecondsOffsetTz, int serverSecondsOffsetTz)
{
   int adjustment = (sessionSecondsOffsetTz - serverSecondsOffsetTz);
   if (adjustment > 0) adjustment = (int)(adjustment / 60.0 / 60.0);
   
   _startHour = startHour - adjustment;
   _endHour = endHour - adjustment;
   
   if (_endHour < 0) _endHour = _endHour + 24;
   
   PrintFormat("Initializing Session %f-%f, Resulting Server Times From %f to %f, Adjustments [%i, %i]",
      startHour, endHour, _startHour, _endHour,
      sessionSecondsOffsetTz, serverSecondsOffsetTz);
   
   _start = NULL;
}

//--- Must be called in sequential order
bool CSession::Process(datetime dtCurrent, double open, double high, double low, double close)
{
   // Ignore any time that isn't in current session
   bool inSession = IsInSession(dtCurrent);
   
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
   
   return inSession;
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
      
      _start = StructToTime(sToday) + (int)(_startHour * 60 * 60);
      
      // we roll back a day then add the start time
      if (_startHour > _endHour)
         _start = _start - (24 * 60 * 60);

      _end = StructToTime(sToday);
      _end = _end + (int)(_endHour * 60 * 60);
      
      PrintFormat("Session [%s] Created [%s - %s] Adjusted Start/End [%f - %f]",
         _name, TimeToString(_start), TimeToString(_end), _startHour, _endHour);
   }

   // skip weekends
   if (dtCurrent > _end)
   {
      MoveNextSession(dtCurrent);
   }
   
   return (_start <= dtCurrent && dtCurrent <= _end);
}