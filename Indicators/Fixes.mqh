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

#include <Generic\ArrayList.mqh>

#include "TimeHelpers.mqh"
#include "Fix.mqh"

class CFixes
{

private:
   string _prefix;
   int _maxFixes;
   int _drawingOffset;
   int _serverOffset;
   
   CArrayList<CFix *> *_fixes;
      
public:
   CFixes(string prefix, int maxHistoricalFixesToShow, int offset, int serverOffset);
   ~CFixes();
   
   void CreateFix(string name, int hourUTC, int minUTC, SESSION_TZ session, color clr, ENUM_LINE_STYLE style);
   void Handle(datetime time, double open);
   
};

CFixes::CFixes(string prefix, int maxHistoricalFixesToShow, int drawingOffset, int serverOffset)
{
   _prefix = prefix;
   _maxFixes = maxHistoricalFixesToShow;
   _drawingOffset = drawingOffset;
   _serverOffset = serverOffset;
         
   _fixes = new CArrayList<CFix *>();
}

CFixes::~CFixes()
{
   CFix *fix;
   
   for (int i = _fixes.Count(); i > 0; i--)
   {
      if (_fixes.TryGetValue(i-1, fix))
         delete fix;
   }
   
   delete _fixes;
}

void CFixes::CreateFix(string name, int hourUTC, int minUTC, SESSION_TZ session, color clr, ENUM_LINE_STYLE style)
{
   int fixInSeconds = CTimeHelpers::ConvertToLocalTimeToServerTimeInSeconds(hourUTC, minUTC, 0, 0, _serverOffset);

   CFix *fix = new CFix(_prefix, name, fixInSeconds, _maxFixes, _drawingOffset, session, clr, style);
   _fixes.Add(fix);

   //PrintFormat("Fix Created [%s]", fix.ToString());
}

void CFixes::Handle(datetime time, double open)
{
   //PrintFormat("CFixes->Handle Period - Time [%s]", TimeToString(time));
   
   CFix *fix;
   for (int i = 0; i < _fixes.Count(); i++)
   {
      if (_fixes.TryGetValue(i, fix))
      {
         fix.Handle(time, open);
      }
   }
}
