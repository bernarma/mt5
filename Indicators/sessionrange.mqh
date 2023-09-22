//+------------------------------------------------------------------+
//|                                                 sessionrange.mqh |
//|                                 Copyright 2023, Mark Bernardinis |
//|                                   https://www.mtnsconsulting.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Mark Bernardinis"
#property link      "https://www.mtnsconsulting.com"
#property version   "1.00"

#include "DrawingHelpers.mqh"

class CSessionRange
{

private:
   datetime _start;
   datetime _end;
   
   color _clr;

   double _high;
   double _low;
   
   string _name;

   string GetDrawingName();
   string ToString();
                     
public:
   CSessionRange(string name, datetime start, double high, double low, color clr);
   ~CSessionRange();
   
   void Update(datetime dt, double high, double low);
};
  
string CSessionRange::GetDrawingName(void)
{
   return StringFormat("SESSION[%s-%s]", _name, TimeToString(_start));
}

CSessionRange::CSessionRange(string name, datetime start, double high, double low, color clr)
{
   _name = name;
   _start = start;
   _end = start;
   _high = high;
   _low = low;
   _clr = clr;

   CDrawingHelpers::RectangleCreate(0, GetDrawingName(), 0,
      _start, _low, _end, _high, _clr, STYLE_DOT, 1, false, true, false);
}
      
CSessionRange::~CSessionRange()
{
  CDrawingHelpers::RectangleDelete(0, GetDrawingName());
}
  
void CSessionRange::Update(datetime dt, double high, double low)
{
   _end = dt;
   _high = MathMax(high, _high);
   _low = MathMin(low, _low);

   // Update the drawing - top left and bottom right
   CDrawingHelpers::RectanglePointChange(0, GetDrawingName(), 0, _start, _low);
   CDrawingHelpers::RectanglePointChange(0, GetDrawingName(), 1, _end, _high);
   
   // TODO: draw the name of the session
}

string CSessionRange::ToString()
{
   return StringFormat("Session [%s], Range=[%s-%s] HL[%f,%f]",
         _name,
         TimeToString(_start),
         TimeToString(_end),
         _high, _low);
}
