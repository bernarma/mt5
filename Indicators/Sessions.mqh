//+------------------------------------------------------------------+
//|                                                     sessions.mqh |
//|                                 Copyright 2023, Mark Bernardinis |
//|                                   https://www.mtnsconsulting.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Mark Bernardinis"
#property link      "https://www.mtnsconsulting.com"
#property version   "1.00"

#include "session.mqh"
#include <Generic\ArrayList.mqh>

class CSessions
{

private:

   CArrayList<CSession *> *_sessions;

   int _serverSecondsOffsetTz;

public:
   CSessions(int serverSecondsOffsetTz);
   ~CSessions();
   
   void CreateSession(
      string prefix, string name, color clr, int maxHistoricalSessions, bool showNextSession,
      int startHour, int startMin, int endHour, int endMin, int sessionSecondsOffsetTz, SESSION_TZ session);
      
   bool IsInSession(datetime time);
   
   void ProcessTime(datetime time, double open, double high, double low, double close);
};

CSessions::CSessions(int serverSecondsOffsetTz)
{
   _sessions = new CArrayList<CSession *>();

   _serverSecondsOffsetTz = serverSecondsOffsetTz;
}

CSessions::~CSessions()
{
   CSession *session;
   
   for (int i = 0; i < _sessions.Count(); i++)
   {
      if (_sessions.TryGetValue(i, session))
         delete session;
   }
   
   delete _sessions;
}

void CSessions::CreateSession(
   string prefix, string name, color clr, int maxHistoricalSessions, bool showNextSession, int startHour, int startMin,
   int endHour, int endMin, int sessionSecondsOffsetTz, SESSION_TZ session)
{
   CSession *s = new CSession(prefix, name, clr, maxHistoricalSessions, showNextSession, session);
   s.Initialize(startHour, startMin, endHour, endMin, sessionSecondsOffsetTz, _serverSecondsOffsetTz);
   _sessions.Add(s);
}

bool CSessions::IsInSession(datetime time)
{
   CSession *session;
   
   for (int i = 0; i < _sessions.Count(); i++)
   {
      if (_sessions.TryGetValue(i, session))
      {
         DUR state;
         if (session.IsInSession(time, state)) return true;
      }
   }
   
   return false;
}

void CSessions::ProcessTime(datetime time, double open, double high, double low, double close)
{
   CSession *session;
   
   for (int i = 0; i < _sessions.Count(); i++)
   {
      if (_sessions.TryGetValue(i, session))
      {
         session.Process(time, open, high, low, close);
      }
   }
}