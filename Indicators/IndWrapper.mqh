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

class CIndWrapper
{

private:
   int _bufferIndex;

protected:
   static int AllocateBuffer() {
      static int currentBuffer;
      return currentBuffer++;
   }

   bool FillArrayFromBuffer(double &values[], 
                            int shift,
                            int handle,
                            int amount);   

   bool FillArraysFromBuffers(double &up_arrows[],        // indicator buffer for up arrows
                           double &down_arrows[],      // indicator buffer for down arrows
                           int ind_handle,             // handle of the iFractals indicator
                           int amount                  // number of copied values
                           );

public:
   CIndWrapper();
   ~CIndWrapper();

   virtual bool Initialize() { return false; }

   virtual string GetComment() { return ""; }

   virtual int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) { return rates_total; }

};

CIndWrapper::CIndWrapper()
{
}

CIndWrapper::~CIndWrapper()
{
}

bool CIndWrapper::FillArrayFromBuffer(double &values[],   // indicator buffer of Moving Average values
                                      int shift,          // shift
                                      int handle,         // handle of the iMA indicator
                                      int amount          // number of copied values
                                     )
{
   ResetLastError();

   if(CopyBuffer(handle, 0, -shift, amount, values) < 0)
   {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the indicator, error code %d", GetLastError());

      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
   }

   return(true);
}

bool CIndWrapper::FillArraysFromBuffers(double &up_arrows[],        // indicator buffer for up arrows
                           double &down_arrows[],      // indicator buffer for down arrows
                           int ind_handle,             // handle of the iFractals indicator
                           int amount                  // number of copied values
                           )
  {
   //--- reset error code
   ResetLastError();

   //--- fill a part of the FractalUpBuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,0,0,amount,up_arrows)<0)
   {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iFractals indicator to the FractalUpBuffer array, error code %d",
                  GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
   }

   //--- fill a part of the FractalDownBuffer array with values from the indicator buffer that has index 1
   if(CopyBuffer(ind_handle,1,0,amount,down_arrows)<0)
   {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iFractals indicator to the FractalDownBuffer array, error code %d",
                  GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
   }

   //--- everything is fine
   return(true);
  }