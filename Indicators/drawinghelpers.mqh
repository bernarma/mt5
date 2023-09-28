//+------------------------------------------------------------------+
//|                                               drawinghelpers.mqh |
//|                                 Copyright 2023, Mark Bernardinis |
//|                                   https://www.mtnsconsulting.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Mark Bernardinis"
#property link      "https://www.mtnsconsulting.com"
#property version   "1.00"

class CDrawingHelpers
{

private:
   CDrawingHelpers();
   ~CDrawingHelpers();

public:
   static bool TrendCreate(const long      chart_ID=0,
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
           
   static bool TrendDelete(const long   chart_ID=0,
                    const string name="TrendLine");
           
   static void ChangeTrendEmptyPoints(datetime &time1,double &price1,
                               datetime &time2,double &price2);
                               
   static bool TextDelete(const long chart_ID=0,
                                   const string name="Text");
                                   
   static bool TextChange(const long   chart_ID=0,
                   const string name="Text",
                   const string text="Text");
                   
   static bool TextMove(const long   chart_ID=0,
                                 const string name="Text",
                                 datetime     time=0,
                                 double       price=0);
                                 
   static bool TextCreate(const long chart_ID=0,
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

        
   static void ChangeTextEmptyPoint(datetime &time,double &price);

   static bool RectangleCreate(const long            chart_ID=0,
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
                     
   static bool RectanglePointChange(const long   chart_ID=0,
                             const string name="Rectangle",
                             const int    point_index=0,
                             datetime     time=0,
                             double       price=0);
                          
   static bool RectangleDelete(const long   chart_ID=0,
                        const string name="Rectangle");
                        
   static void ChangeRectangleEmptyPoints(datetime &time1,double &price1,
                                   datetime &time2,double &price2);

   static bool VLineCreate(const long            chart_ID=0,
                    const string          name="VLine",
                    const string          text="VLine",
                    const int             sub_window=0,
                    datetime              time=0,
                    const color           clr=clrRed,
                    const ENUM_LINE_STYLE style=STYLE_SOLID,
                    const int             width=1,
                    const bool            back=false,
                    const bool            selection=true,
                    const bool            ray=true,
                    const bool            hidden=true,
                    const long            z_order=0);
   
   static bool VLineMove(const long   chart_ID=0,
                  const string name="VLine",
                  datetime     time=0);
                  
   static bool VLineDelete(const long   chart_ID=0,
                    const string name="VLine");

};

CDrawingHelpers::CDrawingHelpers()
{
}

CDrawingHelpers::~CDrawingHelpers()
{
}

//+------------------------------------------------------------------+
//| Create a trend line by the given coordinates                     |
//+------------------------------------------------------------------+
bool CDrawingHelpers::TrendCreate(const long            chart_ID=0,        // chart's ID
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
 
bool CDrawingHelpers::TrendDelete(const long   chart_ID=0,       // chart's ID
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
  
void CDrawingHelpers::ChangeTrendEmptyPoints(datetime &time1,double &price1,
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

bool CDrawingHelpers::TextCreate(const long chart_ID=0,
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

bool CDrawingHelpers::TextMove(const long   chart_ID=0,
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

bool CDrawingHelpers::TextChange(const long   chart_ID=0,
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

bool CDrawingHelpers::TextDelete(const long chart_ID=0,
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

void CDrawingHelpers::ChangeTextEmptyPoint(datetime &time,double &price)
{

   if(!time)
      time=TimeCurrent();

   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
}

bool CDrawingHelpers::RectangleCreate(const long            chart_ID=0,
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

bool CDrawingHelpers::RectanglePointChange(const long   chart_ID=0,       // chart's ID
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

bool CDrawingHelpers::RectangleDelete(const long   chart_ID=0,       // chart's ID
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

void CDrawingHelpers::ChangeRectangleEmptyPoints(datetime &time1,double &price1,
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


bool CDrawingHelpers::VLineCreate(const long            chart_ID=0,
                 const string          name="VLine",
                 const string          text="VLine",
                 const int             sub_window=0,
                 datetime              time=0,
                 const color           clr=clrRed,
                 const ENUM_LINE_STYLE style=STYLE_SOLID,
                 const int             width=1,
                 const bool            back=false,
                 const bool            selection=true,
                 const bool            ray=true,
                 const bool            hidden=true,
                 const long            z_order=0)
{
   if (!time)
      time = TimeCurrent();
   
   ResetLastError();
   
   if(!ObjectCreate(chart_ID,name,OBJ_VLINE,sub_window,time,0))
   {
      Print(__FUNCTION__,
            ": failed to create a vertical line! Error code = ",GetLastError());
      return(false);
   }
   
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY,ray);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true);
}

bool CDrawingHelpers::VLineMove(const long   chart_ID=0,
               const string name="VLine",
               datetime     time=0)
{
   if(!time)
      time=TimeCurrent();

   ResetLastError();

   if(!ObjectMove(chart_ID,name,0,time,0))
   {
      Print(__FUNCTION__,
            ": failed to move the vertical line! Error code = ",GetLastError());
      return(false);
   }

   return(true);
}

bool CDrawingHelpers::VLineDelete(const long   chart_ID=0,
                 const string name="VLine")
{
   ResetLastError();

   if(!ObjectDelete(chart_ID,name))
   {
      Print(__FUNCTION__,
            ": failed to delete the vertical line! Error code = ",GetLastError());
      return(false);
   }
   
   return(true);
}
