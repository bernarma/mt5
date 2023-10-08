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

#include "DrawingHelpers.mqh"

class CSessionRange
{

private:
   datetime _start;
   datetime _end;

   bool _isVisible;
   
   color _clr;

   double _high;
   double _low;
   
   string _prefix;
   string _name;

   string GetDrawingNameRange();
   string GetDrawingNameLabel();
   string ToString();
                     
public:
   CSessionRange(string prefix, string name, datetime start, datetime end, double high, double low, bool isVisible, color clr);
   ~CSessionRange();
   
   void Update(datetime dt, double high, double low);
};

string CSessionRange::GetDrawingNameRange(void)
{
   return StringFormat("[%s]Sess_%s_%s_RNG", _prefix, _name, TimeToString(_start, TIME_DATE));
}

string CSessionRange::GetDrawingNameLabel(void)
{
   return StringFormat("[%s]Sess_%s_%s_LBL", _prefix, _name, TimeToString(_start, TIME_DATE));
}

CSessionRange::CSessionRange(string prefix, string name, datetime start, datetime end, double high, double low, bool isVisible, color clr)
{
   _prefix = prefix;
   _name = name;
   _start = start;
   _end = end;
   _high = high;
   _low = low;
   _clr = clr;
   _isVisible = isVisible;

   if (_isVisible)
   {
      CDrawingHelpers::RectangleCreate(0, GetDrawingNameRange(), 0,
         _start, _low, _end, _high, _clr, STYLE_DOT, 1, false, true, false);
         
      CDrawingHelpers::TextCreate(0, GetDrawingNameLabel(), 0, _start, _low, _name,
         "Arial", 6, _clr, 0.000000, ANCHOR_LEFT_UPPER, false, false, true, 0);
   }
}
      
CSessionRange::~CSessionRange()
{
   if (_isVisible)
   {
      CDrawingHelpers::RectangleDelete(0, GetDrawingNameRange());
      CDrawingHelpers::TextDelete(0, GetDrawingNameLabel());
   }
}
  
void CSessionRange::Update(datetime dt, double high, double low)
{
   //_end = dt;
   _high = MathMax(high, _high);
   _low = MathMin(low, _low);

   if (_isVisible)
   {
      // Update the drawing - top left and bottom right
      CDrawingHelpers::RectanglePointChange(0, GetDrawingNameRange(), 0, _start, _low);
      CDrawingHelpers::RectanglePointChange(0, GetDrawingNameRange(), 1, _end, _high);
      
      // update the name of the session and location anchored to bottom left - start will always be the same
      CDrawingHelpers::TextMove(0, GetDrawingNameLabel(), _start, _low);
   }
}

string CSessionRange::ToString()
{
   return StringFormat("Session [%s], Range=[%s-%s] HL[%f,%f]",
         _name,
         TimeToString(_start),
         TimeToString(_end),
         _high, _low);
}
