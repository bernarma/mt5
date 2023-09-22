//+------------------------------------------------------------------+
//|                                                historicalfix.mqh |
//|                                 Copyright 2023, Mark Bernardinis |
//|                                   https://www.mtnsconsulting.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Mark Bernardinis"
#property link      "https://www.mtnsconsulting.com"
#property version   "1.00"

class CHistoricalFix
{
private:
   int _offset;
   
   string _name;
   datetime _date;
   double _price;
   color _clr;
   ENUM_LINE_STYLE _style;
   
   bool TrendCreate(const long      chart_ID=0,
              const string          name="TrendLine",
              const int             sub_window=0,
              datetime              time1=0,
              double                price1=0,
              datetime              time2=0,
              double                price2=0,
              const color           clr=clrRed,
              const ENUM_LINE_STYLE style=STYLE_SOLID,
              const int             width=1,
              const bool            back=false,
              const bool            selection=true,
              const bool            ray_left=false,
              const bool            ray_right=false,
              const bool            hidden=true,
              const long            z_order=0);
           
   bool TrendDelete(const long   chart_ID=0,
                    const string name="TrendLine");
           
   void ChangeTrendEmptyPoints(datetime &time1,double &price1,
                               datetime &time2,double &price2);
                               
   bool TextDelete(const long chart_ID=0,
                                   const string name="Text");
                                   
   bool TextChange(const long   chart_ID=0,
                   const string name="Text",
                   const string text="Text");
                   
   bool TextMove(const long   chart_ID=0,
                                 const string name="Text",
                                 datetime     time=0,
                                 double       price=0);
                                 
   bool TextCreate(const long chart_ID=0,
                                   const string            name="Text",
                                   const int               sub_window=0,
                                   datetime                time=0,
                                   double                  price=0,
                                   const string            text="Text",
                                   const string            font="Arial",
                                   const int               font_size=10,
                                   const color             clr=clrRed,
                                   const double            angle=0.0,
                                   const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER,
                                   const bool              back=false,
                                   const bool              selection=false,
                                   const bool              hidden=true,
                                   const long              z_order=0);
                                   
   void ChangeTextEmptyPoint(datetime &time,double &price);

   string LineName();
   string TextName();

public:
   CHistoricalFix(string name, datetime date, double price, int offset, color clr, ENUM_LINE_STYLE style);
   ~CHistoricalFix();
   
   string GetName();
   
   void Initialize();
   void Update(datetime current);
};

CHistoricalFix::CHistoricalFix(string name, datetime date, double price, int offset, color clr, ENUM_LINE_STYLE style)
{
   _name = name;
   _date = date;
   _price = price;
   _clr = clr;
   _style = style;
   _offset = offset; //6000;
}

CHistoricalFix::~CHistoricalFix()
{
   TrendDelete(0, LineName());
   TextDelete(0, TextName());
}

string CHistoricalFix::GetName()
{
   return StringFormat("HISTORICAL_FIX [%s %s]", _name, TimeToString(_date));
}

string CHistoricalFix::LineName()
{
   return StringFormat("HISTORICAL_FIX-LINE [%s %s]", _name, TimeToString(_date));
}

string CHistoricalFix::TextName()
{
   return StringFormat("HISTORICAL_FIX-TEXT [%s %s]", _name, TimeToString(_date));
}

void CHistoricalFix::Update(datetime current)
{
   // Move end of line
   ObjectMove(0, LineName(), 1, current + _offset, _price);
   
   // Move text position
   TextMove(0, TextName(), current + _offset, _price);
}

void CHistoricalFix::Initialize()
{
   // Create line
   TrendCreate(0, LineName(), 0, _date, _price, _date+_offset, _price, _clr, _style, 1, true, false, false, false);
   
   // Create text
   TextCreate(0, TextName(), 0, _date+_offset, _price, _name, "Arial", 6, _clr, 0, ANCHOR_LEFT, false, false, true);
}

//+------------------------------------------------------------------+
//| Create a trend line by the given coordinates                     |
//+------------------------------------------------------------------+
bool CHistoricalFix::TrendCreate(const long            chart_ID=0,        // chart's ID
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
 
bool CHistoricalFix::TrendDelete(const long   chart_ID=0,       // chart's ID
                 const string name="TrendLine") // line name
{
   ResetLastError();

   if(!ObjectDelete(chart_ID,name))
   {
      Print(__FUNCTION__,
            ": failed to delete a trend line! Error code = ",GetLastError());
      return(false);
   }

   return(true);
  }
  
void CHistoricalFix::ChangeTrendEmptyPoints(datetime &time1,double &price1,
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
      price2=price1;
}

bool CHistoricalFix::TextCreate(const long chart_ID=0,
                                const string            name="Text",
                                const int               sub_window=0,
                                datetime                time=0,
                                double                  price=0,
                                const string            text="Text",
                                const string            font="Arial",
                                const int               font_size=10,
                                const color             clr=clrRed,
                                const double            angle=0.0,
                                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER,
                                const bool              back=false,
                                const bool              selection=false,
                                const bool              hidden=true,
                                const long              z_order=0)
{
   ChangeTextEmptyPoint(time,price);
   ResetLastError();

   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price))
   {
      Print(__FUNCTION__,
            ": failed to create \"Text\" object! Error code = ",GetLastError());
      return(false);
   }

   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   
   return(true);
}

bool CHistoricalFix::TextMove(const long   chart_ID=0,
                              const string name="Text",
                              datetime     time=0,
                              double       price=0)
{
   if(!time)
      time=TimeCurrent();

   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);

   ResetLastError();

   if(!ObjectMove(chart_ID,name,0,time,price))
   {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ",GetLastError());
      return(false);
   }

   return(true);
}

bool CHistoricalFix::TextChange(const long   chart_ID=0,
                                const string name="Text",
                                const string text="Text")
{
   ResetLastError();

   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
   {
      Print(__FUNCTION__,
            ": failed to change the text! Error code = ",GetLastError());
      return(false);
   }

   return(true);
  }

bool CHistoricalFix::TextDelete(const long chart_ID=0,
                                const string name="Text")
{
   ResetLastError();

   if(!ObjectDelete(chart_ID,name))
   {
      Print(__FUNCTION__,
            ": failed to delete \"Text\" object! Error code = ",GetLastError());
      return(false);
   }

   return(true);
}

void CHistoricalFix::ChangeTextEmptyPoint(datetime &time,double &price)
{

   if(!time)
      time=TimeCurrent();

   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
}