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
#property version   "1.0"
#property indicator_chart_window

#property indicator_plots   0

int OnInit()
{
   return(INIT_SUCCEEDED);
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
   

   //--- return value of prev_calculated for next call
   return(rates_total);
}

void OnTimer()
{

}
