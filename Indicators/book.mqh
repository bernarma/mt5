//+------------------------------------------------------------------+
//|                                                         book.mqh |
//|                                 Copyright 2023, Mark Bernardinis |
//|                                   https://www.mtnsconsulting.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Mark Bernardinis"
#property link      "https://www.mtnsconsulting.com"
#property version   "1.00"

//#include <Generic\Interfaces\IComparer.mqh>
#include <Generic\Interfaces\IEqualityComparable.mqh>
  
class CBook : public IEqualityComparable<CBook *>
{

private:

   int _index;
   datetime _time;
   double _price;
   
public:
   CBook(int index, datetime time, double price);
   ~CBook();
   
   bool Hide();
   bool Update(datetime end);
   
   bool IsExpired(int minIndex);

   bool Equals(CBook *value);
   int  HashCode(void);
   
   string ToString();
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBook::CBook(int index, datetime time, double price)
{
   _index = index;
   _time = time;
   _price = price;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBook::~CBook()
{
}
//+------------------------------------------------------------------+

bool CBook::Hide()
{
   return false;
}

bool CBook::IsExpired(int minIndex)
{
   return (_index < minIndex);
}

bool CBook::Update(datetime end)
{
   return false;
}

string CBook::ToString()
{
   return StringFormat("BOOK[%s]", TimeToString(_time));
}

bool CBook::Equals(CBook *value)
{
   return value.ToString() == ToString();
}

int  CBook::HashCode(void)
{
   // TODO: return correct hashcode
   return 10;
}