//+------------------------------------------------------------------+
//|                                                         Book.mqh |
//|                                 Copyright 2023, Mark Bernardinis |
//|                                   https://www.mtnsconsulting.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Mark Bernardinis"
#property link      "https://www.mtnsconsulting.com"
#property version   "1.00"

#include <Generic\Interfaces\IEqualityComparable.mqh>

#include "DrawingHelpers.mqh"

enum BOOK_TYPE {
   BOOK_TYPE_BULL = 1,
   BOOK_TYPE_BEAR = -1
};

enum BOOK_STATE {
   BOOK_STATE_OPEN = 0,
   BOOK_STATE_CLOSED = 1,
   BOOK_STATE_EXPIRED = 2
};

class CBook : public IEqualityComparable<CBook *>
{

protected:
   string _prefix;
   datetime _time;
   datetime _expiration;
   double _price;
   BOOK_TYPE _type;
   color _clr;
   int _offset;
   
   string GetDrawingNameLevel(void);
   string GetDrawingNameLabel(void);
   string GetDrawingNameText(void);

public:
   CBook(string prefix, int offset, BOOK_TYPE type, datetime time, double price, datetime expiration, color clr);
   ~CBook();
   
   void Show(bool isVisible);
   
   bool IsComplete(datetime current, double price, BOOK_STATE &state);

   void Update(datetime now, double price, int level);

   bool Equals(CBook *value);
   int  HashCode(void);
   
   string ToString();
};

CBook::CBook(string prefix, int offset, BOOK_TYPE type, datetime time, double price, datetime expiration, color clr)
{
   _prefix = prefix;
   _expiration = expiration;
   _type = type;
   _time = time;
   _price = price;
   _clr = clr;
   _offset = offset;

   // Draw Level (with offset)
   CDrawingHelpers::TrendCreate(0, GetDrawingNameLevel(), GetDrawingNameText(), 0, _time, _price, _time + _offset, _price, _clr, STYLE_SOLID, 1, false, false, false, false, 1);

   // Draw Label (with offset)
   CDrawingHelpers::TextCreate(0, GetDrawingNameLabel(), 0, _time + _offset, _price, "0", "Arial", 6, _clr, 0, ANCHOR_LEFT, false, false, true, 1);
}

CBook::~CBook()
{
   // Delete Level
   CDrawingHelpers::TrendDelete(0, GetDrawingNameLevel());

   // Delete Label
   CDrawingHelpers::TextDelete(0, GetDrawingNameLabel());
}

void CBook::Update(datetime now, double price, int level)
{
   if(!ObjectMove(0, GetDrawingNameLevel(), 1, now + _offset, _price))
   {
       Print(__FUNCTION__, ": failed to move the BOOK LEVEL! Error code = ",GetLastError());
   }

   if (!ObjectSetString(0, GetDrawingNameLabel(), OBJPROP_TEXT, StringFormat("%i", level)))
   {
       Print(__FUNCTION__, ": failed to update the text for a BOOK LEVEL! Error code = ",GetLastError());
   }

   if(!ObjectMove(0, GetDrawingNameLabel(), 0, now + _offset + 50, _price))
   {
       Print(__FUNCTION__, ": failed to move the BOOK LEVEL LABEL! Error code = ",GetLastError());
   }
}

void CBook::Show(bool isVisible)
{
   int visibility = CDrawingHelpers::PeriodToVisibility(Period());
   int objTimeframes = (isVisible) ? visibility: OBJ_NO_PERIODS;

   ObjectSetInteger(0, GetDrawingNameLevel(), OBJPROP_TIMEFRAMES, objTimeframes);
   ObjectSetInteger(0, GetDrawingNameLabel(), OBJPROP_TIMEFRAMES, objTimeframes);
}

bool CBook::IsComplete(datetime current, double price, BOOK_STATE &state)
{
   if (current > _expiration)
   {
   state = BOOK_STATE_EXPIRED;
      return true;
   }
   
   if ( (_type == BOOK_TYPE_BEAR && _price < price) || (_type == BOOK_TYPE_BULL && _price > price))
   {
      state = BOOK_STATE_CLOSED;
      return true;
   }

   state = BOOK_STATE_OPEN;
   return false;
}

string CBook::ToString()
{
   return StringFormat("BOOK[Time=%s Price=%f Type=%i]", TimeToString(_time), _price, _type);
}

bool CBook::Equals(CBook *value)
{
   return (value._time == _time && value._type == _type);
}

string CBook::GetDrawingNameLevel(void)
{
   return StringFormat("[%s]Book_%s_%s_LVL", _prefix, _type == BOOK_TYPE_BULL ? "BULL": "BEAR", TimeToString(_time));
}

string CBook::GetDrawingNameLabel(void)
{
   return StringFormat("[%s]Book_%s_%s_LBL", _prefix, _type == BOOK_TYPE_BULL ? "BULL": "BEAR", TimeToString(_time));
}

string CBook::GetDrawingNameText(void)
{
   return "";
   //return StringFormat("%s Book", _type == BOOK_TYPE_BULL ? "Bull": "Bear");
}