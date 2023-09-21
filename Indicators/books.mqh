//+------------------------------------------------------------------+
//|                                                        books.mqh |
//|                                 Copyright 2023, Mark Bernardinis |
//|                                   https://www.mtnsconsulting.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Mark Bernardinis"
#property link      "https://www.mtnsconsulting.com"
#property version   "1.00"

#include <Generic\ArrayList.mqh>

#include "book.mqh"
#include "sessions.mqh"

enum DIR {
   DIR_BULL = 1,
   DIR_NONE = 0,
   DIR_BEAR = -1
};

class CBooks
{

private:
   bool _isInitialized;

   //-- EXTERNAL
   CSessions *_sessions;
   
   //-- INTERNAL
   CArrayList<DIR> *_prevCandleArr;
   CArrayList<CBook *> *_bearLvArr;
   CArrayList<CBook *> *_bullLvArr;
   
   double _mostRecentBear;
   int _lookbackPeriod;
   int _maxBearCDLookback;
   int _lastHandledPeriod;
   bool _filterInSession;
   DIR _bias;
   
   DIR CandleDir(const double open, const double high, const double low, const double close);
   bool IsBullDir(DIR dir);
   bool IsBearDir(DIR dir);
   bool IsNeutralDir(DIR dir);
   bool IsBullCandle(const double open, const double high, const double low, const double close);
   bool IsBearCandle(const double open, const double high, const double low, const double close);
   bool IsNeutralCandle(const double open, const double high, const double low, const double close);
   
   void AddBearBook(int index, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[]);
   
   //void UpdateBearBooks();

public:
   CBooks(bool filterInSession, CSessions *sessions, int lookbackPeriod);
   ~CBooks();
   
   void Initialize(datetime time);
   bool IsInitialized();
   
   DIR CurrentBias();
   
   void Handle(int current, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[]);
                       
};
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBooks::CBooks(bool filterInSession, CSessions *sessions, int lookbackPeriod)
{
   _isInitialized = false;
   _lookbackPeriod = lookbackPeriod;
   _filterInSession = filterInSession;
   _maxBearCDLookback = 2;
   _lastHandledPeriod = -1;
   _bias = DIR_NONE;
   
   _bearLvArr = new CArrayList<CBook*>();
   _bullLvArr = new CArrayList<CBook*>();
   
   _sessions = sessions;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+

void CBooks::Initialize(datetime time)
{
   if (!_isInitialized)
   {
      //
      _prevCandleArr = new CArrayList<DIR>();
      _isInitialized = true;
   }
}

bool CBooks::IsInitialized()
{
   return _isInitialized;
}

DIR CBooks::CurrentBias()
{
   return DIR_NONE;
}

void CBooks::Handle(int current, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[])
{
   if (current == _lastHandledPeriod)
   {
      //PrintFormat("Processing Period %i - %s that was already processed", current, TimeToString(time[current]));
   }
   
   _lastHandledPeriod = current;
   
   DIR currentBias = DIR_NONE;
   
   // don't do anything if we don't have at least 2 times to work with
   if (current < 2)
      return;
   
   bool inSession = (!_filterInSession) || _sessions.IsInSession(time[current]);
   
   //PrintFormat("Processing Period %i - %s", current, TimeToString(time[current]));
   
   // the previous candle
   if (!IsNeutralCandle(open[current-1], high[current-1], low[current-1], close[current-1]))
   {
      _prevCandleArr.Add(CandleDir(open[current-1], high[current-1], low[current-1], close[current-1]));
      if (_prevCandleArr.Count() > _maxBearCDLookback)
         _prevCandleArr.RemoveAt(0); // RemoveAt(0) = shift
   }

   bool isBearLv = false;
   if (_prevCandleArr.Count() == _maxBearCDLookback)
   {
      DIR dir1, dir2;
      _prevCandleArr.TryGetValue(0, dir1);
      _prevCandleArr.TryGetValue(1, dir2);
      
      isBearLv = IsBullDir(dir1) && IsBearDir(dir2) && IsBearCandle(open[current], high[current], low[current], close[current]);
   }

   if (isBearLv)
      currentBias = DIR_BEAR;
   
   if (inSession && isBearLv)
   {
      AddBearBook(current - 1, time, open, high, low, close);
   }
   
   CBook *book;
   for (int i = _bearLvArr.Count(); i > 0; i--)
   {
      if (_bullLvArr.TryGetValue(i-1, book))
      {
         if (close[current] > book.IsExpired(current - _lookbackPeriod))
         {
            PrintFormat("Removing Book - %s", book.ToString());
            _bearLvArr.Remove(book);
            delete book;
         }
      }
   }
   
   //UpdateBearBooks(current, close[current - 1], close[current]);
   
   
   /*
   // TODO:

   if (inSess && isBearLv)
   {
      mostRecentBear = close[current - 1];
      
      CPointOfInterest *poi = new CPointOfInterest();
      poi.name = StringFormat("BEAR_LVL[%i]", current - 1);
      poi.period = time[current - 1];
      poi.price = mostRecentBear;
      poi.index = current - 1;
            
      bearLvArr.Add(poi);
      TrendCreate(0, poi.name, 0, poi.period, mostRecentBear, poi.period+600, mostRecentBear, InpBearish, InpLineStyle, InpLineWidth, false, false, false, true);
      
      TrimLineArr(bearLvArr, MAX_LINE);
   }
   
   for (int i = 0; i < bearLvArr.Count(); i++)
   {
      CPointOfInterest *poi;
      if (bearLvArr.TryGetValue(i, poi))
      {
         if (close[current] > poi.price || IsLineExpired(current, poi))
         {
            invalidLvIndexArr.Push(poi);
         }
      }
   }
   
   while (invalidLvIndexArr.Count() > 0)
   {
      CPointOfInterest *l = invalidLvIndexArr.Pop();
      bool bSuccess = bearLvArr.Remove(l);
      if (!TrendDelete(0, l.name))
      {
         PrintFormat("Failed to Delete [%s]", l.name);
      }
      delete l;
   }
   
   ColorizeLevels(bearLvArr, InpBearish);

   // Bullish Levels : bull & close > last bear open
   
   if (IsBearCandle(open[current], high[current], low[current], close[current]))
   {
       lastBearCdOpen = open[current];
       lastBearCdIndex = current;
       isLastBearCdBroken = false;
   }
       
   bool isBullLv = IsBullCandle(open[current], high[current], low[current], close[current]) && close[current] > lastBearCdOpen && !isLastBearCdBroken;
   if (isBullLv)
   {
       isLastBearCdBroken = true;
       lBias = BULL_DIR;
   }
   
   if (inSess && isBullLv)
   {
       mostRecentBull = lastBearCdOpen;
       
       CPointOfInterest *poi = new CPointOfInterest();
       poi.name = StringFormat("BULL_LVL[%i]", current);
       poi.period = time[current] - (PeriodSeconds() * (current - lastBearCdIndex));
       poi.price = mostRecentBull; // Set to "Previous" Candles Open (the high of the last bull)
       poi.index = lastBearCdIndex;

       bullLvArr.Add(poi);
       
       TrendCreate(0, poi.name, 0, poi.period, mostRecentBull, poi.period+600, mostRecentBull, InpBullish, InpLineStyle, InpLineWidth, false, false, false, true);

       TrimLineArr(bullLvArr, MAX_LINE);
   }
   
   for (int i = 0; i < bullLvArr.Count(); i++)
   {
      CPointOfInterest *poi;
      if (bullLvArr.TryGetValue(i, poi))
      {
         if (close[current] < poi.price || IsLineExpired(current, poi))
         {
            invalidLvIndexArr.Push(poi);
         }
      }
   }
           
   while (invalidLvIndexArr.Count() > 0)
   {
      CPointOfInterest *l = invalidLvIndexArr.Pop();
      bool bSuccess = bullLvArr.Remove(l);
      if (!TrendDelete(0, l.name))
      {
         PrintFormat("Failed to Delete [%s]", l.name);
      }
      delete l;
   }
   
   ColorizeLevels(bullLvArr, InpBullish);
   
   bool biasChanged = (lBias != gBias);
   
   if (biasChanged)
   {
      gBias = lBias;
   }

   */
}

void CBooks::AddBearBook(int index, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[])
{
   _mostRecentBear = close[index];

   CBook *book = new CBook(index, time[index], close[index]);

   if (_bearLvArr.IndexOf(book) < 0)
   {
      PrintFormat("Book Not Found [%s]", book.ToString());
      _bearLvArr.Add(book);
   }
   else
   {
      PrintFormat("Found Book [%s]", book.ToString());
   }
   
   // TODO: trim if needed
}

DIR CBooks::CandleDir(const double open, const double high, const double low, const double close)
{
   return close > open ? DIR_BULL : (close < open ? DIR_BEAR : DIR_NONE);
}

bool CBooks::IsBullDir(DIR dir)
{
   return dir == DIR_BULL;
}

bool CBooks::IsBearDir(DIR dir)
{
   return dir == DIR_BEAR;
}

bool CBooks::IsNeutralDir(DIR dir)
{
   return dir == DIR_NONE;
}

bool CBooks::IsBullCandle(const double open, const double high, const double low, const double close)
{
   return IsBullDir(CandleDir(open, high, low, close));
}

bool CBooks::IsBearCandle(const double open, const double high, const double low, const double close)
{
   return IsBearDir(CandleDir(open, high, low, close));
}

bool CBooks::IsNeutralCandle(const double open, const double high, const double low, const double close)
{
   return IsNeutralDir(CandleDir(open, high, low, close));
}
