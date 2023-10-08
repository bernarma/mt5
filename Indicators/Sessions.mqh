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

#include "Session.mqh"
#include "TimeHelpers.mqh"

#include <Generic\ArrayList.mqh>

class CSessions
{

private:

   CArrayList<CSession *> *_sessions;

   int _serverOffset;

public:
   CSessions(int serverOffset);
   ~CSessions();
   
   void CreateSession(
      string prefix, string name, color clr, int maxHistoricalSessions, bool isVisible, bool showNextSession, datetime start,
      int durationInMinutes, datetime sessionTz, SESSION_TZ session, int startDay, int endDay);

   void CreateSession(
      string prefix, string name, color clr, int maxHistoricalSessions, bool isVisible, bool showNextSession, datetime start,
      datetime end, datetime sessionTz, SESSION_TZ session, int startDay, int endDay);
      
   bool IsInSession(datetime time);
   
   void ProcessTime(datetime time, double open, double high, double low, double close);
};

CSessions::CSessions(int serverOffset)
{
   _sessions = new CArrayList<CSession *>();

   _serverOffset = serverOffset;
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
   string prefix, string name, color clr, int maxHistoricalSessions, bool isVisible, bool showNextSession, datetime start,
   int durationInMinutes, datetime sessionTz, SESSION_TZ session, int startDay, int endDay)
{
   // Convert startHour to local
   int sessionStartInSeconds = CTimeHelpers::ConvertToLocalTimeToServerTimeInSeconds(start, sessionTz, _serverOffset);

   CSession *s = new CSession(prefix, name, clr, maxHistoricalSessions, isVisible, showNextSession, session,
                              startDay, endDay, sessionStartInSeconds, durationInMinutes * 60);
   _sessions.Add(s);
}

void CSessions::CreateSession(
   string prefix, string name, color clr, int maxHistoricalSessions, bool isVisible, bool showNextSession, datetime start,
   datetime end, datetime sessionTz, SESSION_TZ session, int startDay, int endDay)
{
   int duration = CTimeHelpers::MinutesBetween(start, end);

   CreateSession(prefix, name, clr, maxHistoricalSessions, isVisible, showNextSession, start,
      duration, sessionTz, session, startDay, endDay);
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