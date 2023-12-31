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

class CDrawingHelpers
{

private:
   CDrawingHelpers();
   ~CDrawingHelpers();

public:
   static bool TrendCreate(const long      chart_ID=0,
              const string          name="TrendLine",
              const string          desc="",
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

   static int PeriodToVisibility(ENUM_TIMEFRAMES VisibilityPeriod);
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
                 const string          desc="",           // description
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
            ": failed to create a trend line! [%s] Error code = ", name, GetLastError());
      return(false);
   }

   //uchar alfa=0x55;  // 0x55 means 55/255=21.6 % of transparency
   //ColorToARGB(clr,alfa);

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

   ObjectSetString(chart_ID,name,OBJPROP_TEXT,desc);

   return(true);
}
 
bool CDrawingHelpers::TrendDelete(const long   chart_ID=0,       // chart's ID
                 const string name="TrendLine") // line name
{
   ResetLastError();

   if(!ObjectDelete(chart_ID,name))
   {
      Print(__FUNCTION__,
            ": failed to delete a trend line! [%s] Error code = ", name, GetLastError());
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

int CDrawingHelpers::PeriodToVisibility(ENUM_TIMEFRAMES VisibilityPeriod)
{
   int i;
   int periods[]    = { PERIOD_M1, PERIOD_M2, PERIOD_M3, PERIOD_M4, PERIOD_M5, PERIOD_M6, PERIOD_M10, PERIOD_M12, PERIOD_M15, PERIOD_M20, PERIOD_M30, PERIOD_H1, PERIOD_H2, PERIOD_H3, PERIOD_H4, PERIOD_H6, PERIOD_H8, PERIOD_H12, PERIOD_D1, PERIOD_W1, PERIOD_MN1};
   int visibility[] = { OBJ_PERIOD_M1, OBJ_PERIOD_M2, OBJ_PERIOD_M3, OBJ_PERIOD_M4, OBJ_PERIOD_M5, OBJ_PERIOD_M6, OBJ_PERIOD_M10, OBJ_PERIOD_M12, OBJ_PERIOD_M15, OBJ_PERIOD_M20, OBJ_PERIOD_M30, OBJ_PERIOD_H1, OBJ_PERIOD_H2, OBJ_PERIOD_H3, OBJ_PERIOD_H4, OBJ_PERIOD_H6, OBJ_PERIOD_H8, OBJ_PERIOD_H12, OBJ_PERIOD_D1, OBJ_PERIOD_W1, OBJ_PERIOD_MN1};
   if (VisibilityPeriod == PERIOD_CURRENT)
      VisibilityPeriod = Period();

   for (i = 0; i < 21; i++)
      if (VisibilityPeriod == periods[i])
         break;

   return(visibility[i]);
}