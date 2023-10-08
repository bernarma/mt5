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

#property copyright "Copyright 2023, Mark Bernardinis"
#property link      "https://github.com/bernarma/mt5"
#property version   "1.00"

#property indicator_chart_window

#property indicator_plots   0

#property indicator_buffers 8

#include "FractalInd.mqh"
#include "MovingAverageInd.mqh"

input int InpLookback = 1000; // How many bars to lookback

input bool InpShowLTFRange = true; // Show the Lower Time Frame Range
input bool InpShowMTFRange = true; // Show the Medium Time Frame Range
input bool InpShowHTFRange = true; // Show the Higher Time Frame Range

input int MaxHistoricalLTFRange = 3;
input int MaxHistoricalMTFRange = 3;
input int MaxHistoricalHTFRange = 3;

input ENUM_TIMEFRAMES InpLTF = PERIOD_M1; // Lower Timeframe
input ENUM_TIMEFRAMES InpMTF = PERIOD_M5; // Medium Timeframe
input ENUM_TIMEFRAMES InpHTF = PERIOD_M15; // Higher Timeframe

CIndWrapper *_wrapper1;
CIndWrapper *_wrapper2;
CIndWrapper *_fractalShort;
CIndWrapper *_fractalMedium;
CIndWrapper *_fractalLong;

int OnInit()
{
   _wrapper1 = new CMovingAverageInd(_Symbol, PERIOD_CURRENT, 10);
   if (!_wrapper1.Initialize())
      return (INIT_FAILED);

   _wrapper2 = new CMovingAverageInd(_Symbol, PERIOD_CURRENT, 100);
   if (!_wrapper2.Initialize())
      return (INIT_FAILED);

   _fractalShort = new CFractalInd(_Symbol, InpLTF, MaxHistoricalLTFRange, InpLookback);
   if (!_fractalShort.Initialize())
      return (INIT_FAILED);

   _fractalMedium = new CFractalInd(_Symbol, InpMTF, MaxHistoricalMTFRange, InpLookback);
   if (!_fractalMedium.Initialize())
      return (INIT_FAILED);

   _fractalLong = new CFractalInd(_Symbol, InpHTF, MaxHistoricalHTFRange, InpLookback);
   if (!_fractalLong.Initialize())
      return (INIT_FAILED);

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   if (_wrapper1 != NULL) delete _wrapper1;
   if (_wrapper2 != NULL) delete _wrapper2;
   if (_fractalShort != NULL) delete _fractalShort;
   if (_fractalMedium != NULL) delete _fractalMedium;
   if (_fractalLong != NULL) delete _fractalLong;

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
   int w1 = _wrapper1.OnCalculate(rates_total, prev_calculated, time, open, high, low, close, tick_volume, volume, spread);
   int w2 = _wrapper2.OnCalculate(rates_total, prev_calculated, time, open, high, low, close, tick_volume, volume, spread);
   int w3 = _fractalShort.OnCalculate(rates_total, prev_calculated, time, open, high, low, close, tick_volume, volume, spread);
   int w4 = _fractalMedium.OnCalculate(rates_total, prev_calculated, time, open, high, low, close, tick_volume, volume, spread);
   int w5 = _fractalLong.OnCalculate(rates_total, prev_calculated, time, open, high, low, close, tick_volume, volume, spread);
   
   Comment(StringFormat("%s\n%s\n%s\n%s\n%s", _wrapper1.GetComment(), _wrapper2.GetComment(), _fractalShort.GetComment(), _fractalMedium.GetComment(), _fractalLong.GetComment()));

   return MathMin(MathMin(MathMin(MathMin(w1, w2), w3), w4), w5);
}
