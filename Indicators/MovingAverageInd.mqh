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

#include "IndWrapper.mqh"

class CMovingAverageInd : public CIndWrapper
{

private:
   int _ma_period;
   ENUM_TIMEFRAMES _period;
   int _ma_shift;
   
   //--- name of the indicator on a chart
   string _short_name;
   
   string _symbol;
   string _name;
   
   ENUM_MA_METHOD _ma_method;
   ENUM_APPLIED_PRICE _applied_price;
   
   string _comm;
   double _iMABuffer[];
   int _handle;

   int _bars_calculated;

public:
   CMovingAverageInd(string symbol, ENUM_TIMEFRAMES period, int maPeriod);
   ~CMovingAverageInd();

   int RequiredBuffers();

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

CMovingAverageInd::CMovingAverageInd(string symbol, ENUM_TIMEFRAMES period, int maPeriod) : CIndWrapper()
{
   _bars_calculated = 0;
   _ma_period = maPeriod;
   _period = period;
   _ma_shift = 0;
   
   _symbol = symbol;
   _name = symbol;
   
   _ma_method = MODE_EMA;
   _applied_price = PRICE_CLOSE;

   //--- delete spaces to the right and to the left
   StringTrimRight(_name);
   StringTrimLeft(_name);

   //--- show the symbol/timeframe the Moving Average indicator is calculated for
   _short_name = StringFormat("iMA(%s/%s, %d, %d, %s, %s)", _name, EnumToString(_period),
                           _ma_period, _ma_shift, EnumToString(_ma_method), EnumToString(_applied_price));

}

bool CMovingAverageInd::Initialize()
{
   //--- assignment of array to indicator buffer
   SetIndexBuffer(AllocateBuffer(), _iMABuffer, INDICATOR_DATA);

   //--- set shift
   //PlotIndexSetInteger(0, PLOT_SHIFT, _ma_shift);   

   //--- create handle of the indicator
   _handle = iMA(_name, _period, _ma_period, _ma_shift, _ma_method, _applied_price);

   //IndicatorSetString(INDICATOR_SHORTNAME, _short_name);

   return true;
}

CMovingAverageInd::~CMovingAverageInd()
{
   if(_handle != INVALID_HANDLE)
      IndicatorRelease(_handle);
}

string CMovingAverageInd::GetComment()
{
   return _comm;
}

int CMovingAverageInd::OnCalculate(const int rates_total,
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
   //--- number of values copied from the iMA indicator
   int values_to_copy;

   //--- determine the number of values calculated in the indicator
   int calculated = BarsCalculated(_handle);
   if (calculated<=0)
   {
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated,GetLastError());
      return(0);
   }

   //--- if it is the first start of calculation of the indicator or if the number of values in the iMA indicator changed
   //---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history)
   if (prev_calculated == 0 || calculated != _bars_calculated || rates_total > prev_calculated + 1)
   {
      //--- if the iMABuffer array is greater than the number of values in the iMA indicator for symbol/period, then we don't copy everything 
      //--- otherwise, we copy less than the size of indicator buffers
      if(calculated > rates_total) values_to_copy = rates_total;
      else                         values_to_copy = calculated;
   }
   else
   {
      //--- it means that it's not the first time of the indicator calculation, and since the last call of OnCalculate()
      //--- for calculation not more than one bar is added
      values_to_copy= (rates_total - prev_calculated) + 1;
   }

   //--- fill the iMABuffer array with values of the Moving Average indicator
   //--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if (!FillArrayFromBuffer(_iMABuffer, _ma_shift, _handle, values_to_copy)) return(0);

   //--- form the message
   _comm = StringFormat("%s ==>  Updated value in the indicator %s: %d, Val=%f",
                            TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),
                            _short_name,
                            values_to_copy, _iMABuffer[rates_total-1]);

   //--- memorize the number of values in the Moving Average indicator
   _bars_calculated = calculated;

   //--- return the prev_calculated value for the next call
   return(rates_total);
}