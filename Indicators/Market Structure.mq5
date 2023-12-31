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

#property indicator_buffers 6

#property indicator_plots 0

#include <Generic\ArrayList.mqh>
#include "DrawingHelpers.mqh"

struct Fractal
{
    double Value;
    datetime Loc;
    bool IsCrossed;
};

//--- indicator buffers
double    Buffer_dh[];
double    Buffer_dl[];
double    Buffer_bullf[];
double    Buffer_bearf[];
double    Buffer_bullf_count[];
double    Buffer_bearf_count[];

input int InpLength = 5; // Length

input bool InpBullishStructures = true; // Bullish Structures
input color InpBullishStructuresColor = clrGreen; // Bullish Structures Color

input bool InpBearishStructures = true; // Bearish Structures
input color InpBearishStructuresColor = clrRed; // Bearish Structures Color

input bool InpShowSupport = true; // Support
input color InpSupportColor = clrGreen; // Support Color

input bool InpShowResistance = true; // Resistance
input color InpResistanceColor = clrRed; // Resistance Color

CArrayList<string> lines;
CArrayList<string> labels;

int Length;
int P;
Fractal Upper, Lower;
double Os = 0;
int Bull_ms_count = 0;
int Bear_ms_count = 0;
bool Broken_sup = false;
bool Broken_res = false;

int OnInit()
{
   //--- indicator buffers mapping
   SetIndexBuffer(0, Buffer_dh, INDICATOR_DATA);
   SetIndexBuffer(1, Buffer_dl, INDICATOR_DATA);
   SetIndexBuffer(2, Buffer_bullf, INDICATOR_DATA);
   SetIndexBuffer(3, Buffer_bearf, INDICATOR_DATA);
   SetIndexBuffer(4, Buffer_bullf_count, INDICATOR_DATA);
   SetIndexBuffer(5, Buffer_bearf_count, INDICATOR_DATA);

   Length = MathMax(InpLength, 3);
   P  = (int)(Length / 2);

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   string name;
   for (int i = lines.Count(); i > 0; i--)
   {
      if (lines.TryGetValue(i-1, name))
      {
         if (CDrawingHelpers::TrendDelete(0, name))
            lines.Remove(name);
      }
   }
   for (int i = labels.Count(); i > 0; i--)
   {
      if (labels.TryGetValue(i-1, name))
      {
         if (CDrawingHelpers::TrendDelete(0, name))
            labels.Remove(name);
      }
   }
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
   int i, start;
   
   //--- check for bars count
   if(rates_total <= Length)
      return(0);

   //--- initialize
   start = Length - 1;
   if (start + 1 < prev_calculated)
   {
      start = prev_calculated - 2;
   }
   else
   {
      for (i = 0; i < start; i++)
      {
         Buffer_dh[i] = 0;
         Buffer_dl[i] = 0;
         
         Buffer_bullf[i] = 0;
         Buffer_bearf[i] = 0;
         
         Buffer_bullf_count[i] = 0;
         Buffer_bearf_count[i] = 0;
      }
   }
   
   //--- main cycle
   for (i = start; i < rates_total && !IsStopped(); i++)
   {
      //-----------------------------------------------------------------------------}
      //Fractal Detection
      //-----------------------------------------------------------------------------{
      Buffer_dh[i] = SumOfSign(high, i, P);
      Buffer_dl[i] = SumOfSign(low, i, P);
      
      Buffer_bullf[i] = (Buffer_dh[i] == -P && Buffer_dh[i-P] == P && high[i-P] == Highest(high, i, Length)) ? 1 : 0;
      Buffer_bearf[i] = (Buffer_dl[i] == P && Buffer_dl[i-P] == -P && low[i-P] == Lowest(low, i, Length)) ? 1: 0;

      Buffer_bullf_count[i] = Buffer_bullf_count[i-1] + Buffer_bullf[i];
      Buffer_bearf_count[i] = Buffer_bearf_count[i-1] + Buffer_bearf[i];

      //-----------------------------------------------------------------------------}
      //Bullish market structure
      //-----------------------------------------------------------------------------{

      if (Buffer_bullf[i])
      {
         Upper.Value = high[i-P];
         Upper.IsCrossed = false;
         Upper.Loc = time[i-P];
      }
      
      if (Crossover(close, i, Upper.Value) && !Upper.IsCrossed)
      {
         //PrintFormat("Create BULL %s - %s %s [%.4f]", TimeToString(Upper.Loc), TimeToString(time[i]), (Os == -1) ? "ChoCH": "BOS", Upper.Value);

         string nameLine = StringFormat("MS_Bull_NAME_%s", TimeToString(Upper.Loc));
         string nameLabel = StringFormat("MS_Bull_LBL_%s", TimeToString(Upper.Loc));
         
         lines.Add(nameLine);
         CDrawingHelpers::TrendCreate(
            0, nameLine, NULL, 0, Upper.Loc, Upper.Value, time[i], Upper.Value,
            InpBullishStructuresColor, STYLE_SOLID, 1, true, false, false, false, true, 0);
            
         labels.Add(nameLabel);
         CDrawingHelpers::TextCreate(0, nameLabel, 0, Upper.Loc + (time[i] - Upper.Loc)/2, Upper.Value, (Os == -1) ? "ChoCH": "BOS",
            "Roboto", 7, InpBullishStructuresColor, 0.000000, ANCHOR_LOWER, false, false, true, 0);
         
         //Set support
         int k = 2;
         //min = low[i-1];
         //for i = 2 to (n - Upper.loc)-1
             //min := math.min(low[i], min)
             //k := low[i] == min ? i : k

         if (InpShowSupport)
         {
            //lower_lvl := line.new(n-k, min, n, min, color = bullCss, style = line.style_dashed)
            Broken_sup = false;
         }

         Upper.IsCrossed = true;
         Bull_ms_count += 1;
         Os = 1;
      }
      else if (InpShowSupport && !Broken_sup)
      {
          //lower_lvl.set_x2(n)
      
          //if (close < lower_lvl.get_y2())
              //Bbroken_sup := true
      }
      
      //-----------------------------------------------------------------------------}
      //Bearish market structure
      //-----------------------------------------------------------------------------{

      if (Buffer_bearf[i])
      {
         Lower.Value = low[i-P];
         Lower.IsCrossed = false;
         Lower.Loc = time[i-P];
      }
      
      if (Crossunder(close, i, Lower.Value) && !Lower.IsCrossed)
      {
         //PrintFormat("Create BEAR %s - %s %s [%.4f]", TimeToString(Lower.Loc), TimeToString(time[i]), (Os == 1) ? "ChoCH": "BOS", Lower.Value);

         string nameLine = StringFormat("MS_Bear_NAME_%s", TimeToString(Lower.Loc));
         string nameLabel = StringFormat("MS_Bear_LBL_%s", TimeToString(Lower.Loc));
         
         lines.Add(nameLine);
         CDrawingHelpers::TrendCreate(
            0, nameLine, NULL, 0, Lower.Loc, Lower.Value, time[i], Lower.Value,
            InpBearishStructuresColor, STYLE_SOLID, 1, true, false, false, false, true, 0);
            
         labels.Add(nameLabel);
         CDrawingHelpers::TextCreate(0, nameLabel, 0, Lower.Loc + (time[i] - Lower.Loc)/2, Lower.Value, (Os == 1) ? "ChoCH": "BOS",
            "Roboto", 7, InpBearishStructuresColor, 0.000000, ANCHOR_UPPER, false, false, true, 0);
         
         Lower.IsCrossed = true;
         Bear_ms_count += 1;
         Os = -1;
      }
      else if (InpShowResistance && !Broken_res)
      {
          //upper_lvl.set_x2(n)
      
          //if close > upper_lvl.get_y2()
              //Broken_res := true
      }
   }
   
   //--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
}

bool Crossunder(const double &values[], int index, double value)
{
   return values[index] < value && values[index-1] > value;
}

bool Crossover(const double &values[], int index, double value)
{
   return values[index] > value && values[index-1] < value;
}

double SumOfSign(const double &values[], int index, int length)
{
   double sum = 0;
   
   do
   {
      sum += Sign(values[index-length+1] - values[index-length]);
   } while (--length > 0);
   
   return sum;
}

double Sign(double value)
{
   return (value > 0) ? 1: (value < 0) ? -1 : 0;
}

double Highest(const double &values[], int index, int length)
{
   double highest = DBL_MIN;
   
   do
   {
      if (values[index-length] > highest) highest = values[index-length];
   }
   while (--length > 0);
   
   return highest;
}

double Lowest(const double &values[], int index, int length)
{
   double lowest = DBL_MAX;

   do
   {
      if (values[index-length] < lowest) lowest = values[index-length];
   }
   while (--length > 0);

   return lowest;
}