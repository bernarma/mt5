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
                     
   bool RectanglePointChange(const long   chart_ID=0,       // chart's ID
                          const string name="Rectangle", // rectangle name
                          const int    point_index=0,    // anchor point index
                          datetime     time=0,           // anchor point time coordinate
                          double       price=0);
                          
                          bool RectangleDelete(const long   chart_ID=0,       // chart's ID
                     const string name="Rectangle") ;// rectangle name
                     
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
                     //CSessionRange();
                     CSessionRange(string name, datetime start, double high, double low, color clr);
                    ~CSessionRange();
                    
                    void Update(datetime dt, double high, double low);
                    
  };
  
string CSessionRange::GetDrawingName(void)
{
         return StringFormat("SESSION[%s-%s]", _name, TimeToString(_start));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSessionRange::CSessionRange(string name, datetime start, double high, double low, color clr)
      {
         _name = name;
         _start = start;
         _end = start;
         _high = high;
         _low = low;
         _clr = clr;

         // Create the drawing
         RectangleCreate(0, GetDrawingName(), 0,
            _start, _low, _end, _high, _clr, STYLE_DOT, 1, false, true, false);
      }
      
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+

string CSessionRange::ToString()
      {
         return StringFormat("Session [%s], Range=[%s-%s] HL[%f,%f]",
               _name,
               TimeToString(_start),
               TimeToString(_end),
               _high, _low);
      }
      
//+------------------------------------------------------------------+
//| Create rectangle by the given coordinates                        |
//+------------------------------------------------------------------+
bool CSessionRange::RectangleCreate(const long            chart_ID=0,        // chart's ID
                     const string          name="Rectangle",  // rectangle name
                     const int             sub_window=0,      // subwindow index 
                     datetime              time1=0,           // first point time
                     double                price1=0,          // first point price
                     datetime              time2=0,           // second point time
                     double                price2=0,          // second point price
                     const color           clr=clrRed,        // rectangle color
                     const ENUM_LINE_STYLE style=STYLE_SOLID, // style of rectangle lines
                     const int             width=1,           // width of rectangle lines
                     const bool            fill=false,        // filling rectangle with color
                     const bool            back=false,        // in the background
                     const bool            selection=true,    // highlight to move
                     const bool            hidden=true,       // hidden in the object list
                     const long            z_order=0)         // priority for mouse click
  {
//--- set anchor points' coordinates if they are not set
   ChangeRectangleEmptyPoints(time1,price1,time2,price2);
//--- reset the error value
   ResetLastError();
//--- create a rectangle by the given coordinates
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create a rectangle! Error code = ",GetLastError());
      return(false);
     }
//--- set rectangle color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the style of rectangle lines
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set width of the rectangle lines
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- enable (true) or disable (false) the mode of filling the rectangle
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,fill);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of highlighting the rectangle for moving
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
  
//+------------------------------------------------------------------+
//| Move the rectangle anchor point                                  |
//+------------------------------------------------------------------+
bool CSessionRange::RectanglePointChange(const long   chart_ID=0,       // chart's ID
                          const string name="Rectangle", // rectangle name
                          const int    point_index=0,    // anchor point index
                          datetime     time=0,           // anchor point time coordinate
                          double       price=0)          // anchor point price coordinate
  {
//--- if point position is not set, move it to the current bar having Bid price
   if(!time)
      time=TimeCurrent();
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- move the anchor point
   if(!ObjectMove(chart_ID,name,point_index,time,price))
     {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
  
//+------------------------------------------------------------------+
//| Delete the rectangle                                             |
//+------------------------------------------------------------------+
bool CSessionRange::RectangleDelete(const long   chart_ID=0,       // chart's ID
                     const string name="Rectangle") // rectangle name
  {
//--- reset the error value
   ResetLastError();
//--- delete rectangle
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete rectangle! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the values of rectangle's anchor points and set default    |
//| values for empty ones                                            |
//+------------------------------------------------------------------+
void CSessionRange::ChangeRectangleEmptyPoints(datetime &time1,double &price1,
                                datetime &time2,double &price2)
  {
//--- if the first point's time is not set, it will be on the current bar
   if(!time1)
      time1=TimeCurrent();
//--- if the first point's price is not set, it will have Bid value
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the second point's time is not set, it is located 9 bars left from the second one
   if(!time2)
     {
      //--- array for receiving the open time of the last 10 bars
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      //--- set the second point 9 bars left from the first one
      time2=temp[0];
     }
//--- if the second point's price is not set, move it 300 points lower than the first one
   if(!price2)
      price2=price1-300*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
  }