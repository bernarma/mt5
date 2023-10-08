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

#include <Generic\ArrayList.mqh>

#include "SwingRange.mqh"
#include "IndWrapper.mqh"

class CFractalInd : public CIndWrapper
{

private:
   //--- indicator buffers
   double  _fractalUpBuffer[];
   double  _fractalDownBuffer[];

   CArrayList<CSwingRange *> *_ranges;

   ENUM_TIMEFRAMES _period;
   
   //--- name of the indicator on a chart
   string _short_name;

   int _maxHistory;
   
   string _symbol;
   string _name;
   string _comm;
      
   int _handle;
   int _lookback;

   int _bars_calculated;

public:
   CFractalInd(string symbol, ENUM_TIMEFRAMES period, int maxHistory, int lookback);
   ~CFractalInd();

   bool Initialize();

   string GetComment();

   int OnCalculate(const int rates_total,
                   const int prev_calculated,
                   const datetime &time[],
                   const double &open[],
                   const double &high[],
                   const double &low[],
                   const double &close[],
                   const long &tick_volume[],
                   const long &volume[],
                   const int &spread[]);
};

CFractalInd::CFractalInd(string symbol, ENUM_TIMEFRAMES period, int maxHistory, int lookback)
   : CIndWrapper()
{
   _symbol = symbol;
   _period = period;
   _maxHistory = maxHistory;
   _lookback = lookback;

   _ranges = new CArrayList<CSwingRange *>(maxHistory);
}

CFractalInd::~CFractalInd()
{
   if (_handle != INVALID_HANDLE)
      IndicatorRelease(_handle);

   delete _ranges;
}

string CFractalInd::GetComment()
{
   return _comm;
}

bool CFractalInd::Initialize()
{
   //--- assignment of arrays to indicator buffers
   SetIndexBuffer(AllocateBuffer(), _fractalUpBuffer, INDICATOR_DATA);
   SetIndexBuffer(AllocateBuffer(), _fractalDownBuffer, INDICATOR_DATA);
   
   //--- determine the symbol the indicator is drawn for
   _name = _symbol;

   //--- delete spaces to the right and to the left
   StringTrimRight(_name);
   StringTrimLeft(_name);

   _handle = iFractals(_name, _period);

   if (_handle == INVALID_HANDLE)
   {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iFractals indicator for the symbol %s/%s, error code %d",
                  _name,
                  EnumToString(_period),
                  GetLastError());

      //--- the indicator is stopped early
      return false;
   }

   //--- show the symbol/timeframe the Fractals indicator is calculated for
   _short_name = StringFormat("iFractals(%s/%s)", _name, EnumToString(_period));

   return true;
}

int CFractalInd::OnCalculate(const int rates_total,
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
   //--- number of values copied from the iFractals indicator
   int values_to_copy;

   //--- determine the number of values calculated in the indicator
   int calculated = BarsCalculated(_handle);
   if (calculated <= 0)
   {
      PrintFormat("BarsCalculated() returned %d, error code %d", calculated, GetLastError());
      return(0);
   }

   //--- if it is the first start of calculation of the indicator or if the number of values in the iFractals indicator changed
   //---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history)
   if (prev_calculated == 0 || calculated != _bars_calculated || rates_total > prev_calculated + 1)
   {
      //--- if the FractalUpBuffer array is greater than the number of values in the iFractals indicator for symbol/period, then we don't copy everything 
      //--- otherwise, we copy less than the size of indicator buffers
      if (calculated > rates_total) values_to_copy = rates_total;
      else                          values_to_copy = calculated;
   }
   else
   {
      //--- it means that it's not the first time of the indicator calculation, and since the last call of OnCalculate()
      //--- for calculation not more than one bar is added
      values_to_copy = (rates_total-prev_calculated) + 1;
   }
   
   //--- fill the FractalUpBuffer and FractalDownBuffer arrays with values from the Fractals indicator
   //--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if (!FillArraysFromBuffers(_fractalUpBuffer, _fractalDownBuffer, _handle, values_to_copy)) return(0);

   // the most recent
   string first = (_fractalUpBuffer[rates_total-3] != DBL_MAX) ? "U": (_fractalDownBuffer[rates_total-3] != DBL_MAX) ? "D": "-";
   string second = (_fractalUpBuffer[rates_total-4] != DBL_MAX) ? "U": (_fractalDownBuffer[rates_total-4] != DBL_MAX) ? "D": "-";
   string third = (_fractalUpBuffer[rates_total-5] != DBL_MAX) ? "U": (_fractalDownBuffer[rates_total-5] != DBL_MAX) ? "D": "-";
   string fourth = (_fractalUpBuffer[rates_total-6] != DBL_MAX) ? "U": (_fractalDownBuffer[rates_total-6] != DBL_MAX) ? "D": "-";

   // TODO: implement (create / update high-low and remove ranges)

   //--- Only calculate historically from InpLookbackBars
   int start = MathMax(rates_total - _lookback, _bars_calculated);
   if (start > 0) start--;

   //--- Loop through the periods in the window except the last candle (which is the active one)
   for(int i = start; i < rates_total && !IsStopped(); i++)
   {
      //ProcessBar(i, rates_total, time, open, high, low, close);
      PrintFormat("Processing Fractal [%s] %i", _short_name, i);
   }

   //--- form the message
   _comm = StringFormat("%s ==>  Updated value in the indicator %s: %d [1: %s, 2: %s, 3: %s, 4: %s]",
                            TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),
                            _short_name,
                            values_to_copy, first, second, third, fourth);

   //--- memorize the number of values in the Fractals indicator
   _bars_calculated = calculated;

   //--- return the prev_calculated value for the next call
   return(rates_total);
}