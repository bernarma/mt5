//+------------------------------------------------------------------+
//|                                                historicalfix.mqh |
//|                                 Copyright 2023, Mark Bernardinis |
//|                                   https://www.mtnsconsulting.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Mark Bernardinis"
#property link      "https://www.mtnsconsulting.com"
#property version   "1.00"

#include "DrawingHelpers.mqh"

class CHistoricalFix
{
private:
   int _offset;
   
   string _prefix;
   string _name;
   datetime _date;
   double _price;
   color _clr;
   ENUM_LINE_STYLE _style;

   string LineName();
   string TextName();

public:
   CHistoricalFix(string prefix, string name, datetime date, double price, int offset, color clr, ENUM_LINE_STYLE style);
   ~CHistoricalFix();
   
   string GetName();
   
   void Initialize();
   void Update(datetime current);
};

CHistoricalFix::CHistoricalFix(string prefix, string name, datetime date, double price, int offset, color clr, ENUM_LINE_STYLE style)
{
   _prefix = prefix;
   _name = name;
   _date = date;
   _price = price;
   _clr = clr;
   _style = style;
   _offset = offset; //6000;
}

CHistoricalFix::~CHistoricalFix()
{
   CDrawingHelpers::TrendDelete(0, LineName());
   CDrawingHelpers::TextDelete(0, TextName());
}

string CHistoricalFix::GetName()
{
   return StringFormat("[%s]Fix_%s_%s", _prefix, _name, TimeToString(_date));
}

string CHistoricalFix::LineName()
{
   return StringFormat("[%s]Fix_%s_%s_LVL", _prefix, _name, TimeToString(_date));
}

string CHistoricalFix::TextName()
{
   return StringFormat("[%s]Fix_%s_%s_LBL", _prefix, _name, TimeToString(_date));
}

void CHistoricalFix::Update(datetime current)
{
   // Move end of line
   ObjectMove(0, LineName(), 1, current + _offset, _price);
   
   // Move text position
   CDrawingHelpers::TextMove(0, TextName(), current + _offset, _price);
}

void CHistoricalFix::Initialize()
{
   // Create line
   CDrawingHelpers::TrendCreate(0, LineName(), 0, _date, _price, _date+_offset, _price, _clr, _style, 1, true, false, false, false);
   
   // Create text
   CDrawingHelpers::TextCreate(0, TextName(), 0, _date+_offset, _price, StringFormat("%s Fix", _name), "Arial", 6, _clr, 0, ANCHOR_LEFT, false, false, true);
}
