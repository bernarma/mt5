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

public:
                     CSessions();
                    ~CSessions();
                    
                    void CreateSession(string name, color clr, int maxHistoricalSessions, double startHour, double endHour, int sessionSecondsOffsetTz, int serverSecondsOffsetTz);
                    bool IsInSession(datetime time, double open, double high, double low, double close);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSessions::CSessions()
  {
      _sessions = new CArrayList<CSession *>();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+

void CSessions::CreateSession(string name, color clr, int maxHistoricalSessions, double startHour, double endHour, int sessionSecondsOffsetTz, int serverSecondsOffsetTz)
{
         CSession *session = new CSession(name, clr, maxHistoricalSessions);
         session.Initialize(startHour, endHour, sessionSecondsOffsetTz, serverSecondsOffsetTz);
   _sessions.Add(session);
}

bool CSessions::IsInSession(datetime time, double open, double high, double low, double close)
{
   bool isInSession = false;
   CSession *session;
   
   for (int i = 0; i < _sessions.Count(); i++)
   {
      if (_sessions.TryGetValue(i, session))
         isInSession = isInSession || session.Process(time, open, high, low, close);
   }
   
   return isInSession;
}