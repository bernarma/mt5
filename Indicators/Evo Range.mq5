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

#property strict

#property copyright "Copyright 2023, Mark Bernardinis"
#property link      "https://github.com/bernarma/mt5"
#property version   "1.00"

#property indicator_chart_window

#property indicator_plots   3
#property indicator_buffers 3

#property indicator_label1 "Range Low"
#property indicator_type1 DRAW_LINE

#property indicator_label2 "Range High"
#property indicator_type2 DRAW_LINE

#property indicator_label3 "Range Type"
//#property indicator_type3 DRAW_LINE

#include "TimeHelpers.mqh"
#include "SwingRange.mqh"

const int BUFFER_UP_INDEX = 0;
const int BUFFER_DOWN_INDEX = 1;

double _lowRange[];
double _highRange[];
double _rangeType[];

//input bool InpShowRange = true; // Show the Time Frame Range
//input InpDefault = ;

int g_HTFFractalHandle;
int _fractalBarsCalculated = 0;
double _fractalUpBuffer[], _fractalDownBuffer[];

int OnInit()
{
   SetIndexBuffer(0, _lowRange, INDICATOR_DATA);
   SetIndexBuffer(1, _highRange, INDICATOR_DATA);
   SetIndexBuffer(2, _rangeType, INDICATOR_DATA);

   ArraySetAsSeries(_fractalDownBuffer, true);
   ArraySetAsSeries(_fractalUpBuffer, true);

   g_HTFFractalHandle = iFractals(NULL, NULL);

   if (g_HTFFractalHandle == INVALID_HANDLE)
   {
      PrintFormat("Failed to create handle of the iFractals indicator for the symbol %s, error code %d",
                  _Symbol, GetLastError());

      return (INIT_FAILED);
   }

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   if (g_HTFFractalHandle != INVALID_HANDLE)
      IndicatorRelease(g_HTFFractalHandle);

   //--- clear the chart after deleting the indicator
   Comment("");
}

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
   const int OFFSET = 2;

   if (rates_total == 0) return 0;

   // determine if we have the fractals generated, if not return and we'll try again later
   _fractalBarsCalculated = BarsCalculated(g_HTFFractalHandle);
   if (_fractalBarsCalculated <= 0) return prev_calculated;

   //--- Only calculate historically from InpLookbackBars
   int start = prev_calculated;
   if (start > 0) start--;

   // The maximum number of historical bars to retrieve
   int requiredToBeProcessed = _fractalBarsCalculated; //MathMin(_fractalBarsCalculated == 0 ? rates_total : OFFSET, _fractalBarsCalculated);

   // Get all Fractals (up to lookback) - shift all fractals
   int copiedUpCount = CopyBuffer(g_HTFFractalHandle, BUFFER_UP_INDEX, 0, requiredToBeProcessed, _fractalUpBuffer);
   int copiedDownCount = CopyBuffer(g_HTFFractalHandle, BUFFER_DOWN_INDEX, 0, requiredToBeProcessed, _fractalDownBuffer);

   //--- Loop through the periods in the window except the last candle (which is the active one)
   for (int i = start; i < rates_total && !IsStopped(); i++)
   {
      ProcessBar(i, rates_total, time, open, high, low, close);
   }

   //--- return value of prev_calculated for next call
   return(rates_total);
}

double _lastSwingLow = DBL_MAX;
double _lastSwingHigh = DBL_MAX;
double _high = DBL_MIN;
double _low = DBL_MAX;
datetime g_CurrentTime = NULL;

void ProcessBar(const int current,
                const int ratesTotal,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[])
{
   datetime currentTime = time[current];
   if (currentTime != g_CurrentTime)
   {
      // Previous time is complete
      if (g_CurrentTime != NULL)
      {
         const int OFFSET = 2;

         int indexPrevious = current-2;
         int indexCurrent = current-1;

         // we need at least 2 times before we do anything
         if (current <= 2) return;

         // fractal high and low for 2 candles back
         if (current > OFFSET)
         {
            int fractalIndex = iBarShift(NULL, NULL, time[indexCurrent - OFFSET]);
            if (fractalIndex >= 0)
            {
               _lastSwingLow = (_fractalDownBuffer[fractalIndex] != DBL_MAX) ? _fractalDownBuffer[fractalIndex]: _lastSwingLow;
               _lastSwingHigh = (_fractalUpBuffer[fractalIndex] != DBL_MAX) ? _fractalUpBuffer[fractalIndex]: _lastSwingHigh;
            }
         }

         _high = MathMax(_high, high[indexCurrent]);
         _low = MathMax(_low, low[indexCurrent]);

         double rHigh = (indexPrevious < 0) ? _highRange[0]: _highRange[indexPrevious];
         double rLow = (indexPrevious < 0) ? _lowRange[0]: _lowRange[indexPrevious];
         double rType = (indexPrevious < 0) ? _rangeType[0]: _rangeType[indexPrevious];

         // set to previous (will be overridden if necessary)
         _rangeType[indexCurrent] = rType;
         _highRange[indexCurrent] = rHigh;
         _lowRange[indexCurrent] = rLow;

         // do work
         if (high[indexCurrent] > rHigh || rType == SWING_BULL_UNCONFIRMED)
         {
            bool change = false;

            if (rType == SWING_BULL_UNCONFIRMED)
            {
               change = true;
               _high = MathMax(_high, high[indexCurrent]);

               // this is the second candle we are processing as part of the "break"
               if (close[indexCurrent] > rHigh)
               {
                  if (CTimeHelpers::IsBullCandle(open[indexCurrent], close[indexCurrent]))
                  {
                     // 2nd close outside of range and bearish as well as previous, strong follow-through
                     _rangeType[indexCurrent] = SWING_BULL_SFT;
                  }
                  else
                  {
                     // pull back, bullish - follow-through
                     _rangeType[indexCurrent] = SWING_BULL_FT;
                  }
               }
               else
               {
                  _rangeType[indexCurrent] = SWING_BULL_NFT;
               }
            }
            else
            {
               _high = high[indexCurrent];

               if (close[indexCurrent] <= rHigh)
               {
                  // close back in range - no follow-through
                  _rangeType[indexCurrent] = SWING_BULL_NFT;
                  change = true;
               }
               else
               {
                  // first close outside of range, unconfirmed
                  _rangeType[indexCurrent] = SWING_BULL_UNCONFIRMED;
               }
            }

            if (change)
            {
               _lowRange[indexCurrent] = (_lastSwingLow != DBL_MAX) ? _lastSwingLow: _low;
               _highRange[indexCurrent] = _high;
               _high = DBL_MIN;
            }
         }
         else if (low[indexCurrent] < rLow || rType == SWING_BEAR_UNCONFIRMED)
         {
            bool change = false;

            if (rType == SWING_BEAR_UNCONFIRMED)
            {
               // this is the second candle we are processing as part of the "break"
               if (close[indexCurrent] < rLow)
               {
                  if (CTimeHelpers::IsBullCandle(open[indexCurrent], close[indexCurrent]))
                  {
                     // 2nd close outside of range and bearish as well as previous, strong follow-through
                     _rangeType[indexCurrent] = SWING_BEAR_SFT;
                  }
                  else
                  {
                     // TODO: Update logic of FT based on https://www.youtube.com/watch?v=RRtr0u_UI_Y - 00:10:00 (rules for FT)

                     // pull back, bullish - follow-through
                     _rangeType[indexCurrent] = SWING_BEAR_FT;
                  }
               }
               else
               {
                  _rangeType[indexCurrent] = SWING_BEAR_NFT;
               }

               _low = MathMin(low[indexCurrent], _low);
               change = true;
            }
            else
            {
               _low = low[indexCurrent];

               if (close[indexCurrent] >= rLow)
               {
                  // close back in range - no follow-through
                  _rangeType[indexCurrent] = SWING_BEAR_NFT;
                  change = true;
               }
               else
               {
                  // first close outside of range, unconfirmed
                  _rangeType[indexCurrent] = SWING_BEAR_UNCONFIRMED;
               }
            }

            if (change)
            {
               _highRange[indexCurrent] = (_lastSwingHigh != DBL_MAX) ? _lastSwingHigh: _high;
               _lowRange[indexCurrent] = _low;
               _low = _lastSwingLow;
            }
         }

         Comment(StringFormat("Time: %s, Active Range[high=%0.4f, low=%.4f - type=%s]",
                     TimeToString(time[indexCurrent]),
                     _highRange[indexCurrent], _lowRange[indexCurrent], EnumToString((SWING_TYPE)_rangeType[indexCurrent])));

         _rangeType[current] = _rangeType[indexCurrent];
         _lowRange[current] = _lowRange[indexCurrent];
         _highRange[current] = _highRange[indexCurrent];
      }
      else
      {
         // only called once but sets the initial high/low and type of range
         _rangeType[current] = SWING_NONE;
         _lowRange[current] = low[current];
         _highRange[current] = high[current];
      }
   
      g_CurrentTime = currentTime;
   }
}

// TODO: Update logic of FT based on https://www.youtube.com/watch?v=RRtr0u_UI_Y - 00:10:00 (rules for FT)
/*
FT - continuation (2 bullish candles above fractal)
NFT - reversal (bullish then bearish or a wick)
SFT - FT but not expecting to pullback (2 consecutive body close candles above fractal with no prior wick close and no bearish candle in-between)
*/
