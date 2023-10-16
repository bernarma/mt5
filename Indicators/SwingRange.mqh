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

enum SWING_TYPE {
   SWING_BEAR_SFT = -4,         // Bear Strong Follow-Through
   SWING_BEAR_FT = -3,          // Bear Follow-Through
   SWING_BEAR_NFT = -2,         // Bear No Follow-Through
   SWING_BEAR_UNCONFIRMED = -1, // Bear Unconfirmed

   SWING_NONE = 0,             // None

   SWING_BULL_UNCONFIRMED = 1, // Bull Unconfirmed
   SWING_BULL_NFT = 2,         // Bull No Follow-Through
   SWING_BULL_FT = 3,          // Bull Follow-Through
   SWING_BULL_SFT = 4,         // Bull Strong Follow-Through
};

class CSwingRange
{

private:
   datetime _timeHigh;
   datetime _timeLow;

   double _high;
   double _low;

   SWING_TYPE _type;
public:
   CSwingRange(datetime highTime, datetime lowTime, double high, double low)
   {
      _timeHigh = highTime;
      _timeLow = lowTime;
      _low = low;
      _high = high;
   }

   ~CSwingRange();

   datetime GetHighDate() { return _timeHigh; }
   datetime GetLowDate() { return _timeLow; }

   void SetHigh(datetime time, double high) { _timeHigh = time; _high = high; }
   void SetLow(datetime time, double low) { _timeLow = time; _low = low; }

   double GetHigh() { return _high; }
   double GetLow() { return _low; }

   void Update();

};

CSwingRange::~CSwingRange()
{
}

void CSwingRange::Update()
{
   // TODO: implement
}