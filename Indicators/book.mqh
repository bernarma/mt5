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
   
   bool TrendCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="TrendLine",  // line name
                 const int             sub_window=0,      // subwindow index
                 datetime              time1=0,           // first point time
                 double                price1=0,          // first point price
                 datetime              time2=0,           // second point time
                 double                price2=0,          // second point price
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=true,    // highlight to move
                 const bool            ray_left=false,    // line's continuation to the left
                 const bool            ray_right=false,   // line's continuation to the right
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0);
   bool TrendDelete(const long   chart_ID=0, const string name="TrendLine");
   void ChangeTrendEmptyPoints(datetime &time1, double &price1, datetime &time2, double &price2);

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

//+------------------------------------------------------------------+
//| Create a trend line by the given coordinates                     |
//+------------------------------------------------------------------+
bool CBook::TrendCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="TrendLine",  // line name
                 const int             sub_window=0,      // subwindow index
                 datetime              time1=0,           // first point time
                 double                price1=0,          // first point price
                 datetime              time2=0,           // second point time
                 double                price2=0,          // second point price
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=true,    // highlight to move
                 const bool            ray_left=false,    // line's continuation to the left
                 const bool            ray_right=false,   // line's continuation to the right
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0)         // priority for mouse click
{
   ChangeTrendEmptyPoints(time1,price1,time2,price2);
   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create a trend line! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_LEFT,ray_left);
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true);
}
 
//+------------------------------------------------------------------+
//| The function deletes the trend line from the chart.              |
//+------------------------------------------------------------------+
bool CBook::TrendDelete(const long   chart_ID=0,       // chart's ID
                 const string name="TrendLine") // line name
  {
//--- reset the error value
   ResetLastError();
//--- delete a trend line
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a trend line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
  
//+------------------------------------------------------------------+
//| Check the values of trend line's anchor points and set default   |
//| values for empty ones                                            |
//+------------------------------------------------------------------+
void CBook::ChangeTrendEmptyPoints(datetime &time1,double &price1,
                            datetime &time2,double &price2)
{
   if(!time1)
      time1=TimeCurrent();
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   if(!time2)
     {
      //--- array for receiving the open time of the last 10 bars
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      //--- set the second point 9 bars left from the first one
      time2=temp[0];
     }
   if(!price2)
      price2=price1;
}
