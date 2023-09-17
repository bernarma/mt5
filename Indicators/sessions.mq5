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

#include <Generic\Queue.mqh>

#include "CisNewBar.mqh"

CisNewBar current_chart; // instance of the CisNewBar class: current chart

input int  InpMaxHistoricalSessionsToShow     = 10;        // Max Historical Sessions to Show

input double InpSessionTimeZones = 8.00; // Timezone

input bool InpShowAsiaSession = true; // Asia Session
input color InpAsiaSessionColor = clrBlueViolet; // Asia Session Color
input double InpAsiaSessionStart = 07.00; // Asia Session Time (Start)
input double InpAsiaSessionEnd = 16.00; // Asia Session Time (End)

input bool InpShowLondonSession = true; // Show London Session
input color InpLondonSessionColor = clrGold; // London Session Color
input double InpLondonSessionStart = 15.00; // London Session Time (Start)
input double InpLondonSessionEnd = 00.00; // London Session Time (End)

input bool InpShowNewYorkSession = true; // Show New York  Session
input color InpNewYorkSessionColor = clrLimeGreen; // New York Session Color
input double InpNewYorkSessionStart = 20.00; // New York Session Time (Start)
input double InpNewYorkSessionEnd = 05.00; // New York Session Time (End)

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
      }
      
      string ToString()
      {
         return StringFormat("%s Session Complete, Range=[%s - %s] Low=%f, High=%f",
               _name,
               TimeToString(_start),
               TimeToString(_end),
               _low, _high);
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
         CSessionRange *range;
         while ((range = _sessions.Dequeue()) != NULL)
         {
            delete range;
         }
      }
      
      void Initialize(double startHour, double endHour, double sessionTz, double serverTz)
      {
         _startHour = startHour - sessionTz - serverTz;
         _endHour = endHour - sessionTz - serverTz;
         
         if (_endHour < 0) _endHour = _endHour + 24;
         
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
            
            //NextSession();
            PrintFormat("Incrementing to Next Session %s - %s", TimeToString(_start), TimeToString(_end));
            
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
            
            int hour = (int)MathFloor(_startHour);
            if (hour < 0)
            {
               dtS.hour = hour + 24;
            }
            else
            {
               dtS.hour = hour;
            }
            
            _start = StructToTime(dtS);
            
            if (hour < 0)
            {
               _start = _start - (24 * 60 * 60);
            }
            
            _end = _start + (int)(_endHour - _startHour) * 60 * 60;
         }

         // Weekends - 
         while (dtCurrent > _end)
         {
            PrintFormat("Moving to Next Session - %s in %s-%s", TimeToString(dtCurrent), TimeToString(_start), TimeToString(_end));
            NextSession();
         }
         
         return (_start <= dtCurrent && dtCurrent <= _end);
      }
};



CSession *g_AsiaSession;
CSession *g_LondonSession;
CSession *g_NewYorkSession;

double g_ServerTimeZoneOffset = 0;
bool g_IsInitialised = false;

void OnTimer()
{
   EventKillTimer();

   if (!g_IsInitialised)
   {
      PrintFormat("GMT: %f", TimeGMT());
      
      // TODO: int daylightSavingsCorrection = TimeDaylightSavings();
      g_ServerTimeZoneOffset = (double)((int)(TimeTradeServer() - TimeGMT())) / 60 / 60;
      
      g_AsiaSession = new CSession("Asia", InpAsiaSessionColor);
      g_AsiaSession.Initialize(InpAsiaSessionStart, InpAsiaSessionEnd, InpSessionTimeZones, g_ServerTimeZoneOffset);
      
      g_LondonSession = new CSession("London", InpLondonSessionColor);
      g_LondonSession.Initialize(InpLondonSessionStart, InpLondonSessionEnd, InpSessionTimeZones, g_ServerTimeZoneOffset);
      
      g_NewYorkSession = new CSession("New York", InpNewYorkSessionColor);
      g_NewYorkSession.Initialize(InpNewYorkSessionStart, InpNewYorkSessionEnd, InpSessionTimeZones, g_ServerTimeZoneOffset);

      g_IsInitialised = true;
   }
}

void OnDeinit(const int reason)
{
   if (g_AsiaSession) delete g_AsiaSession;
   if (g_LondonSession) delete g_LondonSession;
   if (g_NewYorkSession) delete g_NewYorkSession;
   
   g_IsInitialised = false;
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Delay a second to give MT5 a chance to startup before attempting to query the server
   //--- for timezone information and other bits that can cause failures during startup of the platform
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
   if (rates_total == 0)
      return (rates_total);
      
   if (!g_IsInitialised) return(0);

   //--- Only calculate historically from InpLookbackBars
   //int InpLookbackBars = 10000;
   //int start = MathMax(rates_total - InpLookbackBars, prev_calculated);
   
   int start = prev_calculated;

   for(int i = start; i < rates_total && !IsStopped(); i++)
   {
      ProcessBar(i, time, open, high, low, close, i == rates_total-1);
   }

   int period_seconds=PeriodSeconds(_Period);                     // Number of seconds in current chart period
   datetime new_time=TimeCurrent()/period_seconds*period_seconds; // Time of bar opening on current chart
   if(current_chart.isNewBar(new_time)) OnNewBar(rates_total, time, open, high, low, close); // When new bar appears - launch the NewBar event handler
   
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
   g_AsiaSession.Process(time[current], open[current], high[current], low[current], close[current], !forming);
   g_LondonSession.Process(time[current], open[current], high[current], low[current], close[current], !forming);
   g_NewYorkSession.Process(time[current], open[current], high[current], low[current], close[current], !forming);
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