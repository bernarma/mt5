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
   int _maxFixes;
   
   CArrayList<CFix *> *_fixes;
      
public:
   CFixes(int maxHistoricalFixesToShow);
   ~CFixes();
   
   void CreateFix(string name, double time, int tz, int serverOffset, color clr, ENUM_LINE_STYLE style);
   void Handle(datetime time, double open);
   
};

CFixes::CFixes(int maxHistoricalFixesToShow)
{
   _maxFixes = maxHistoricalFixesToShow;
         
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
   CFix *fix = new CFix(name, _maxFixes, clr, style);
   fix.Initialize(time, tz, serverOffset);
   _fixes.Add(fix);
}

void CFixes::Handle(datetime time, double open)
{
   CFix *fix;
   for (int i = 0; i < _fixes.Count(); i++)
   {
      if (_fixes.TryGetValue(i, fix))
      {
         fix.Handle(time, open);
      }
   }
}
