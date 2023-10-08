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

#include "TimeHelpers.mqh"
#include "Book.mqh"
#include "Sessions.mqh"

class CBooks
{

private:
   string _prefix;
   int _offset;
   color _clrBearLevel;
   color _clrBullLevel;

   //-- EXTERNAL
   CSessions *_sessions;
   
   //-- INTERNAL
   CArrayList<DIR> *_prevCandleArr;
   CArrayList<CBook *> *_bearLvArr;
   CArrayList<CBook *> *_bullLvArr;
   
   int _maxLevelsToShow;
   int _lookbackPeriod;
   int _maxBearCDLookback;
   datetime _lastHandledPeriod;
   datetime _maxBookAge;
   bool _filterInSession;
   DIR _bias;

   double _mostRecentBear;
   double _mostRecentBull;
   double _lastBearCdOpen;
   
   datetime _lastBearCdDate;
   bool _isLastBearCdBroken;
   
   void AddBearBook(datetime time, double price);
   void AddBullBook(datetime time, double price);

   void UpdateAllBooks(datetime time, double price);
   void CleanBooks(CArrayList<CBook *> *bookArr, datetime time, double price);

   void Initialize(datetime time);

public:
   CBooks(string prefix, int offset, int maxLevelsToShow, bool filterInSession, CSessions *sessions, int lookbackPeriod, color bearLvl, color bullLvl);
   ~CBooks();
   
   DIR CurrentBias();
   
   void ProcessTime(int current, int total, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[]);
};
  
CBooks::CBooks(string prefix, int offset, int maxLevelsToShow, bool filterInSession, CSessions *sessions, int lookbackPeriod, color bearLvl, color bullLvl)
{
   _offset = offset;
   _prefix = prefix;
   _lookbackPeriod = lookbackPeriod;
   _filterInSession = filterInSession;
   _maxBearCDLookback = 2;
   _lastHandledPeriod = 0;
   _bias = DIR_NONE;
   _clrBearLevel = bearLvl;
   _clrBullLevel = bullLvl;
   _maxLevelsToShow = maxLevelsToShow;
   
   _bearLvArr = new CArrayList<CBook*>();
   _bullLvArr = new CArrayList<CBook*>();
   
   _sessions = sessions;
}

CBooks::~CBooks()
{
   delete _prevCandleArr;
   
   CBook *book;
   
   for (int i = _bullLvArr.Count(); i > 0; i--)
   {
      if (_bullLvArr.TryGetValue(i-1, book))
         delete book;
   }
   
   for (int i = _bearLvArr.Count(); i > 0; i--)
   {
      if (_bearLvArr.TryGetValue(i-1, book))
         delete book;
   }

   delete _bearLvArr;
   delete _bullLvArr;
   
   _sessions = NULL;
}

void CBooks::Initialize(datetime time)
{
   if (_lastHandledPeriod == 0)
   {
      _prevCandleArr = new CArrayList<DIR>();
      _lastHandledPeriod = time;

      //PrintFormat("Initialized Books [%s]", TimeToString(_lastHandledPeriod));
   }
}

DIR CBooks::CurrentBias()
{
   return _bias;
}

void CBooks::ProcessTime(int current, int total, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[])
{
   if (_lastHandledPeriod == 0) Initialize(time[current]);
   if ((current+1) == total) return;

   //PrintFormat("[Books] Processing Period %s", TimeToString(time[current]));
   
   _lastHandledPeriod = time[current];
   _maxBookAge = _lastHandledPeriod + (3 * 24 * 60 * 60); // TODO: extend to accomodate for weekends
   
   DIR currentBias = DIR_NONE;
   
   // don't do anything if we don't have at least 2 times to work with
   if (current < 1)
      return;
   
   bool inSession = (!_filterInSession) || _sessions.IsInSession(time[current]);
   
   if (!CTimeHelpers::IsNeutralCandle(open[current-1], high[current-1], low[current-1], close[current-1]))
   {
      _prevCandleArr.Add(CTimeHelpers::CandleDir(open[current-1], high[current-1], low[current-1], close[current-1]));
      if (_prevCandleArr.Count() > _maxBearCDLookback)
         _prevCandleArr.RemoveAt(0); // RemoveAt(0) = shift
   }

   bool isBearLv = false;
   if (_prevCandleArr.Count() == _maxBearCDLookback)
   {
      DIR dir1, dir2;
      _prevCandleArr.TryGetValue(0, dir1);
      _prevCandleArr.TryGetValue(1, dir2);
      
      isBearLv =
         CTimeHelpers::IsBullDir(dir1) &&
         CTimeHelpers::IsBearDir(dir2) &&
         CTimeHelpers::IsBearCandle(open[current], high[current], low[current], close[current]);
   }

   if (isBearLv)
      currentBias = DIR_BEAR;
   
   if (inSession && isBearLv)
   {
      AddBearBook(time[current-1], close[current-1]);
   }

   if (CTimeHelpers::IsBearCandle(open[current], high[current], low[current], close[current]))
   {
       _lastBearCdOpen = open[current];
       _lastBearCdDate = time[current];
       _isLastBearCdBroken = false;
   }
       
   bool isBullLv =
      CTimeHelpers::IsBullCandle(open[current], high[current], low[current], close[current]) &&
      close[current] > _lastBearCdOpen &&
      !_isLastBearCdBroken;

   if (isBullLv)
   {
       _isLastBearCdBroken = true;
   }
   
   if (inSession && isBullLv)
   {
      AddBullBook(_lastBearCdDate, _lastBearCdOpen);
   }

   UpdateAllBooks(time[current], close[current]);
}

void CBooks::UpdateAllBooks(datetime time, double price)
{
   CleanBooks(_bearLvArr, time, price);
   CleanBooks(_bullLvArr, time, price);
}

void CBooks::CleanBooks(CArrayList<CBook *> *bookArr, datetime time, double price)
{
   CBook *book;
   for (int i = bookArr.Count(); i > 0; i--)
   {
      if (bookArr.TryGetValue(i-1, book))
      {
         BOOK_STATE state;
         if (book.IsComplete(time, price, state))
         {
            //PrintFormat("Closing Book - %s, State=%i", book.ToString(), state);
            bookArr.Remove(book);
            delete book;
         }
      }
   }

   // we are now left with all active books after we removed expired and used
   int threshold = bookArr.Count() - _maxLevelsToShow;
   for (int i = bookArr.Count(); i > 0; i--)
   {
      if (bookArr.TryGetValue(i-1, book))
      {
         // PrintFormat("Updating Book - %s, State=%i", book.ToString(), state);
         book.Update(time, price, i);
         book.Show(i > threshold);
      }
   }
}

void CBooks::AddBearBook(datetime time, double price)
{
   _mostRecentBear = price;

   CBook *book = new CBook(_prefix, _offset, BOOK_TYPE_BEAR, time, price, _maxBookAge, _clrBearLevel);

   if (_bearLvArr.IndexOf(book) < 0)
   {
      //PrintFormat("Creating Book - %s", book.ToString());
      _bearLvArr.Add(book);
   }
   else
   {
      //PrintFormat("Updating Book - %s", book.ToString());
      
      // TODO: need to remove book when updating when candle is still forming
   }

   //PrintFormat("Bear Book Stats [Count=%i]", _bearLvArr.Count());
}

void CBooks::AddBullBook(datetime time, double price)
{
   CBook *book = new CBook(_prefix, _offset, BOOK_TYPE_BULL, time, price, _maxBookAge, _clrBullLevel);

   if (_bullLvArr.IndexOf(book) < 0)
   {
      //PrintFormat("Creating Book - %s", book.ToString());
      _bullLvArr.Add(book);
   }
   else
   {
      //PrintFormat("Updating Book - %s", book.ToString());

      // TODO: need to remove book when updating when candle is still forming
   }

   //PrintFormat("Bull Book Stats [Count=%i]", _bullLvArr.Count());
}
