//+------------------------------------------------------------------+
//|                                                 sessionrange.mqh |
//|                                 Copyright 2023, Mark Bernardinis |
//|                                   https://www.mtnsconsulting.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Mark Bernardinis"
#property link      "https://www.mtnsconsulting.com"
#property version   "1.00"

class CSessionRange
{

private:
   bool RectangleCreate(const long            chart_ID=0,
                        const string          name="Rectangle",
                        const int             sub_window=0,
                        datetime              time1=0,
                        double                price1=0,      
                        datetime              time2=0,    
                        double                price2=0,       
                        const color           clr=clrRed,       
                        const ENUM_LINE_STYLE style=STYLE_SOLID,
                        const int             width=1,         
                        const bool            fill=false,      
                        const bool            back=false,        
                        const bool            selection=true,   
                        const bool            hidden=true,       
                        const long            z_order=0);
                     
   bool RectanglePointChange(const long   chart_ID=0,
                             const string name="Rectangle",
                             const int    point_index=0,
                             datetime     time=0,
                             double       price=0);
                          
   bool RectangleDelete(const long   chart_ID=0,
                        const string name="Rectangle");
                        
   void ChangeRectangleEmptyPoints(datetime &time1,double &price1,
                                   datetime &time2,double &price2);
                                   
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

   RectangleCreate(0, GetDrawingName(), 0,
      _start, _low, _end, _high, _clr, STYLE_DOT, 1, false, true, false);
}
      
CSessionRange::~CSessionRange()
{
  RectangleDelete(0, GetDrawingName());
}
  
void CSessionRange::Update(datetime dt, double high, double low)
{
   _end = dt;
   _high = MathMax(high, _high);
   _low = MathMin(low, _low);

   // Update the drawing - top left and bottom right
   RectanglePointChange(0, GetDrawingName(), 0, _start, _low);
   RectanglePointChange(0, GetDrawingName(), 1, _end, _high);
   
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
      
bool CSessionRange::RectangleCreate(const long            chart_ID=0,
                                    const string          name="Rectangle",
                                    const int             sub_window=0,
                                    datetime              time1=0,
                                    double                price1=0,
                                    datetime              time2=0,
                                    double                price2=0,
                                    const color           clr=clrRed,
                                    const ENUM_LINE_STYLE style=STYLE_SOLID,
                                    const int             width=1,
                                    const bool            fill=false,
                                    const bool            back=false,
                                    const bool            selection=true,
                                    const bool            hidden=true,
                                    const long            z_order=0)
{
   ChangeRectangleEmptyPoints(time1,price1,time2,price2);
   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2))
   {
      Print(__FUNCTION__,
            ": failed to create a rectangle! Error code = ",GetLastError());
      return(false);
   }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,fill);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true);
}

bool CSessionRange::RectanglePointChange(const long   chart_ID=0,       // chart's ID
                          const string name="Rectangle", // rectangle name
                          const int    point_index=0,    // anchor point index
                          datetime     time=0,           // anchor point time coordinate
                          double       price=0)          // anchor point price coordinate
{
   if(!time)
      time=TimeCurrent();

   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);

   ResetLastError();

   if(!ObjectMove(chart_ID,name,point_index,time,price))
   {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ",GetLastError());
      return(false);
   }

   return(true);
}

bool CSessionRange::RectangleDelete(const long   chart_ID=0,       // chart's ID
                     const string name="Rectangle") // rectangle name
{
   ResetLastError();
   
   if(!ObjectDelete(chart_ID,name))
   {
      Print(__FUNCTION__,
            ": failed to delete rectangle! Error code = ",GetLastError());
      return(false);
   }
   
   return(true);
}

void CSessionRange::ChangeRectangleEmptyPoints(datetime &time1,double &price1,
                                datetime &time2,double &price2)
{
   if(!time1)
      time1=TimeCurrent();
      
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
      
   if(!time2)
   {
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      time2=temp[0];
   }
   
   if(!price2)
      price2=price1-300*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
}