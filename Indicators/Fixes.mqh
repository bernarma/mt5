//+------------------------------------------------------------------+
//|                                                        fixes.mqh |
//|                                 Copyright 2023, Mark Bernardinis |
//|                                   https://www.mtnsconsulting.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Mark Bernardinis"
#property link      "https://www.mtnsconsulting.com"
#property version   "1.00"

#include <Generic\ArrayList.mqh>
#include "Fix.mqh"

class CFixes
{

private:
   string _prefix;
   int _maxFixes;
   int _offset;
   
   CArrayList<CFix *> *_fixes;
      
public:
   CFixes(string prefix, int maxHistoricalFixesToShow, int offset);
   ~CFixes();
   
   void CreateFix(string name, double time, int tz, int serverOffset, color clr, ENUM_LINE_STYLE style);
   void Handle(datetime time, double open);
   
};

CFixes::CFixes(string prefix, int maxHistoricalFixesToShow, int offset)
{
   _prefix = prefix;
   _maxFixes = maxHistoricalFixesToShow;
   _offset = offset;
         
   _fixes = new CArrayList<CFix *>();
}

CFixes::~CFixes()
{
   CFix *fix;
   
   for (int i = _fixes.Count(); i > 0; i--)
   {
      if (_fixes.TryGetValue(i-1, fix))
         delete fix;
   }
   
   delete _fixes;
}

void CFixes::CreateFix(string name, double time, int tz, int serverOffset, color clr, ENUM_LINE_STYLE style)
{
   CFix *fix = new CFix(_prefix, name, _maxFixes, _offset, clr, style);
   fix.Initialize(time, tz, serverOffset);
   _fixes.Add(fix);
}

void CFixes::Handle(datetime time, double open)
{
   //PrintFormat("CFixes->Handle Period - Time [%s]", TimeToString(time));
   
   CFix *fix;
   for (int i = 0; i < _fixes.Count(); i++)
   {
      if (_fixes.TryGetValue(i, fix))
      {
         fix.Handle(time, open);
      }
   }
}
