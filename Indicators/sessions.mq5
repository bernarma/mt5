//+------------------------------------------------------------------+
//|                                                     sessions.mq5 |
//|                                 Copyright 2023, Mark Bernardinis |
//|                                   https://www.mtnsconsulting.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Mark Bernardinis"
#property link      "https://www.mtnsconsulting.com"
#property version   "1.00"
#property indicator_chart_window

#property indicator_plots   0

#include <Generic\ArrayList.mqh>
#include <Generic\Queue.mqh>

#include "CisNewBar.mqh"

CisNewBar current_chart; // instance of the CisNewBar class: current chart

input int  InpMaxHistoricalSessionsToShow     = 10;        // Max Historical Sessions to Show

input double InpSessionTimeZones = 8.00; // Timezone

input bool InpShowSession1 = true; // Show Session 1
input string InpSession1Name = "Asia"; // Session 1 Name
input color InpSession1Color = clrBlueViolet; // Session 1 Color
input double InpSession1Start = 07.00; // Session 1 Time (Start)
input double InpSession1End = 16.00; // Session 1 Time (End)

input bool InpShowSession2 = true; // Show Session 2
input string InpSession2Name = "London"; // Session 1 Name
input color InpSession2Color = clrGold; // Session 2 Color
input double InpSession2Start = 15.00; // Session 2 Time (Start)
input double InpSession2End = 00.00; // Session 2 Time (End)

input bool InpShowSession3 = true; // Show Session 3
input string InpSession3Name = "New York"; // Session 1 Name
input color InpSession3Color = clrLimeGreen; // Session 3 Color
input double InpSession3Start = 20.00; // Session 3 Time (Start)
input double InpSession3End = 05.00; // Session 3 Time (End)

bool g_IsInitialised = false;

class CSessionRange {
   public:
      CSessionRange(string name, datetime start, double high, double low, color clr)
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
      
      ~CSessionRange()
      {
         RectangleDelete(0, GetDrawingName());
      }
      
      void Update(datetime dt, double high, double low)
      {
         _end = dt;
         _high = MathMax(high, _high);
         _low = MathMin(low, _low);

         // Update the drawing - top left and bottom right
         RectanglePointChange(0, GetDrawingName(), 0, _start, _low);
         RectanglePointChange(0, GetDrawingName(), 1, _end, _high);
         
         // TODO: draw the name of the session
      }
      
      string ToString()
      {
         return StringFormat("Session [%s], Range=[%s-%s] HL[%f,%f]",
               _name,
               TimeToString(_start),
               TimeToString(_end),
               _high, _low);
      }
      
   private:
      datetime _start;
      datetime _end;
      
      color _clr;

      double _high;
      double _low;
      
      string _name;

      string GetDrawingName()
      {
         return StringFormat("SESSION[%s-%s]", _name, TimeToString(_start));
      }
};

class CSession {
   public:
      CSession(string name, color clr)
      {
         _name = name;
         _clr = clr;
         
         _sessions = new CQueue<CSessionRange*>();
      }
      
      ~CSession()
      {
         for (int i = _sessions.Count(); i > 0; i--)
         {
            CSessionRange *range = _sessions.Dequeue();
            delete range;
         }
         
         if (_currentSession != NULL)
            delete _currentSession;
         
         delete _sessions;
      }
      
      void Initialize(double startHour, double endHour, int sessionSecondsOffsetTz, int serverSecondsOffsetTz)
      {
         int adjustment = (sessionSecondsOffsetTz + serverSecondsOffsetTz);
         if (adjustment > 0) adjustment = (int)(adjustment / 60.0 / 60.0);
      
         _startHour = startHour - adjustment;
         _endHour = endHour - adjustment;
         
         if (_endHour < 0) _endHour = _endHour + 24;
         
         //PrintFormat("Initializing Session %f-%f, Resulting Server Times From %f to %f", startHour, endHour, _startHour, _endHour);
         
         _start = NULL;
      }
      
      //--- Must be called in sequential order
      void Process(datetime dtCurrent, double open, double high, double low, double close, bool isFullyFormed)
      {
         // Ignore any time that isn't in current session
         bool inSession = IsInSession(dtCurrent);
         
         //  If current session doesn't exist and we just detected a session start
         //  - Set current session to "NEW SESSION"   
         if (_currentSession == NULL && inSession)
         {
            _currentSession = new CSessionRange(_name, dtCurrent, high, low, _clr);
         }
         else if (_currentSession != NULL && !inSession)
         {
            // If current session and we just detected end of session (i.e. it has finished)
            // - add to historical sessions
            _sessions.Enqueue(_currentSession);
            _currentSession = NULL;
            
            if (_sessions.Count() > InpMaxHistoricalSessionsToShow)
            {
               // If historical sessions greater than max historical
               // - Remove oldest historical sessions
               delete _sessions.Dequeue();
            }
         }
         else if (inSession)
         {
            // Set high and low values of current session based on current bar
            _currentSession.Update(dtCurrent, high, low);
         }
      }
      
   private:
      string _name;
      color  _clr;

      double _startHour;
      double _endHour;
      
      datetime _start, _end;
      
      CQueue<CSessionRange *> *_sessions;
      
      CSessionRange *_currentSession;

      bool NextSession()
      {
         if (_start == NULL) return false;
         
         int inc = 24*60*60;
         _start = _start + inc;
         _end = _end + inc;
         
         return true;
      }

      //--- Check if date provided is contained within this session
      bool IsInSession(datetime dtCurrent)
      {
         // TODO: handle daylight saving based on the first/last Sunday of month - see rules
         // and then adjust the dtCandle.hour statement accordingly
      
         if (_start == NULL)
         {
            // Initialise using the current date as the start of the session window
            MqlDateTime dtS;
            TimeToStruct(dtCurrent, dtS);
            
            MqlDateTime sToday;
            sToday.year = dtS.year;
            sToday.mon = dtS.mon;
            sToday.day = dtS.day;
            sToday.hour = 0;
            sToday.min = 0;
            sToday.sec = 0;
            
            _start = StructToTime(sToday) + (int)(_startHour * 60 * 60);
            
            // we roll back a day then add the start time
            if (_startHour > _endHour)
               _start = _start - (24 * 60 * 60);

            _end = StructToTime(sToday);
            _end = _end + (int)(_endHour * 60 * 60);
         }

         // skip weekends
         while (dtCurrent > _end)
         {
            NextSession();
         }
         
         return (_start <= dtCurrent && dtCurrent <= _end);
      }
};

CArrayList<CSession *> *g_Sessions;

void OnDeinit(const int reason)
{
   if (g_Sessions != NULL)
   {
      CSession *session;
   
      for (int i = 0; i < g_Sessions.Count(); i++)
      {
         if (g_Sessions.TryGetValue(i, session))
            delete session;
      }
      
      delete g_Sessions;
   }
   
   g_IsInitialised = false;
   
   PrintFormat("[Sessions] Deactivated");
}

void OnTimer()
{
   if (!g_IsInitialised)
   {
      datetime dt = TimeTradeServer() - TimeGMT();
      
      PrintFormat("Server Initialised with Date/Time %s, Calculated using TimeTradeServer=%s\nTimeGMT=%s, TimeGMTOffset=%i, TimeLocal=%s, %i",
         TimeToString(dt),
         TimeToString(TimeTradeServer()),
         TimeToString(TimeGMT()),
         TimeGMTOffset(),
         TimeToString(TimeLocal()),
         (int)dt);
         
      g_Sessions = new CArrayList<CSession *>();
         
      if (InpShowSession1)
      {
         CSession *session = new CSession(InpSession1Name, InpSession1Color);
         session.Initialize(InpSession1Start, InpSession1End, (int)InpSessionTimeZones*60*60, (int)dt);
         g_Sessions.Add(session);
      }
      
      if (InpShowSession2)
      {
         CSession *session = new CSession(InpSession2Name, InpSession2Color);
         session.Initialize(InpSession2Start, InpSession2End, (int)InpSessionTimeZones*60*60, (int)dt);
         g_Sessions.Add(session);
      }      
      
      if (InpShowSession3)
      {
         CSession *session = new CSession(InpSession3Name, InpSession3Color);
         session.Initialize(InpSession3Start, InpSession3End, (int)InpSessionTimeZones*60*60, (int)dt);
         g_Sessions.Add(session);
      }
   
      g_IsInitialised = true;
      
      PrintFormat("[Sessions] Initialised");
   }
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   EventSetTimer(1);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   //PrintFormat("Calculating rates_total=%i, prev_calculated=%i", rates_total, prev_calculated);
   
   if (rates_total == 0 || !g_IsInitialised)
      return (prev_calculated);

   //--- TODO: need to be smarter as to where we start processing candles from
   int start = prev_calculated;

   for(int i = start; i < rates_total && !IsStopped(); i++)
   {
      ProcessBar(i, time, open, high, low, close, i == rates_total-1);
   }

   // Number of seconds in current chart period
   int period_seconds = PeriodSeconds(_Period);
   
   // Time of bar opening on current chart
   datetime new_time = TimeCurrent() / period_seconds * period_seconds;
   
   // When new bar appears - launch the NewBar event handler
   if (current_chart.isNewBar(new_time)) OnNewBar(rates_total, time, open, high, low, close);

   return(rates_total);
}

void ProcessBar(const int current,
               const datetime &time[],
               const double &open[],
               const double &high[],
               const double &low[],
               const double &close[],
               bool forming)
{
   CSession *session;
   
   for (int i = 0; i < g_Sessions.Count(); i++)
   {
      if (g_Sessions.TryGetValue(i, session))
         session.Process(time[current], open[current], high[current], low[current], close[current], !forming);
   }
}

//+------------------------------------------------------------------+
//| New bar event handler function                                   |
//+------------------------------------------------------------------+
void OnNewBar(const int rates_total,
              const datetime &time[],
              const double &open[],
              const double &high[],
              const double &low[],
              const double &close[])
{
   if (rates_total - 1 == 0) return;
   
   ProcessBar(rates_total - 2, time, open, high, low, close, false);
}

//+------------------------------------------------------------------+
//| Create rectangle by the given coordinates                        |
//+------------------------------------------------------------------+
bool RectangleCreate(const long            chart_ID=0,        // chart's ID
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
bool RectanglePointChange(const long   chart_ID=0,       // chart's ID
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
bool RectangleDelete(const long   chart_ID=0,       // chart's ID
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
void ChangeRectangleEmptyPoints(datetime &time1,double &price1,
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