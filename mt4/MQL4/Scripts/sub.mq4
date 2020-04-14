//+------------------------------------------------------------------+
//|                                                       hello1.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Mt4Redis/RedisPubSub.mqh>
#include <JAson.mqh>
#include <hash.mqh>

RedisPubSub *subscriber=NULL;
RedisPubSub *publisher=NULL;
Hash *config = new Hash();
string REDIS_HOST = "127.0.0.1";
int REDIS_PORT = 6379;

int OnInit()
  {
   readConfig();
   REDIS_HOST = config.hGetString("REDIS_HOST");
   REDIS_PORT = StrToInteger(config.hGetString("REDIS_POST"));
   
   RedisContext *c=RedisContext::connect(REDIS_HOST,REDIS_PORT);
   RedisContext *p=RedisContext::connect(REDIS_HOST,REDIS_PORT);
   if(c==NULL)
     {
      return INIT_FAILED;
     }
   subscriber=new RedisPubSub(c);
   publisher = new RedisPubSub(p);
   return(INIT_SUCCEEDED);
  }
  
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   int n=subscriber.subscribe("get-symbol-infor");

   if(subscriber.hasError())
     {
      Print("Error occured when subscribing to get-symbol-infor. Prepare to quit");
      return;
     }

   Print("Successfully subscribed to ",n," channel(s).");
   
   string m="";
   do
     {
      m=subscriber.getMessage();
      Print("Receiving: [", m, "]");
      string out = GetInforSymbol(m);
      printf("send");
      publisher.publish("Symbol-info", out);
     }
   while(!subscriber.hasError() && m!="quit");
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(CheckPointer(subscriber)!=POINTER_INVALID )
     {
      delete subscriber;
     }
    if(CheckPointer(publisher)!=POINTER_INVALID )
     {
      delete publisher;
     }
  }
  
string GetInforSymbol(string symbol)
{
  
   StringToUpper(symbol);
   CJAVal js(NULL,jtUNDEF);
   js["Symbol"] = symbol;
   js["MODE_DIGITS"] = MarketInfo(symbol,MODE_DIGITS);
   js["MODE_LOTSIZE"] = MarketInfo(symbol,MODE_LOTSIZE);
   js["MODE_SWAPLONG"] = MarketInfo(symbol,MODE_SWAPLONG);
   js["MODE_SWAPSHORT"] = MarketInfo(symbol,MODE_SWAPSHORT);
   js["MODE_MINLOT"] = MarketInfo(symbol,MODE_MINLOT);
   js["MODE_MAXLOT"] = MarketInfo(symbol,MODE_MAXLOT);
   js["MODE_LOTSTEP"] = MarketInfo(symbol,MODE_LOTSTEP);
   string out="";
   js.Serialize(out);
   return out;
}


void readConfig(){
   ResetLastError();
   string InpFileName = "config.ini";
   int file_handle=FileOpen(InpFileName,FILE_READ);
   if(file_handle!=INVALID_HANDLE)
     {
      PrintFormat("%s file is available for reading",InpFileName);
      PrintFormat("File path: %s\\Files\\",TerminalInfoString(TERMINAL_DATA_PATH));
      //--- additional variables
      
      string str;
      //--- read data from the file
      while(!FileIsEnding(file_handle))
        {
         //--- find out how many symbols are used for writing the time
         
         //--- read the string
         str=FileReadString(file_handle);         
         
         string pair[];
         int pairSize = StringSplit(str, StringGetCharacter("=",0), pair);
         if(pairSize !=2){            
            continue;
         }
         config.hPutString(pair[0], pair[1]);
         //--- print the string
         Print(str," - key: ", pair[0], ", value: ", pair[1]);
         
        }
      //--- close the file
      FileClose(file_handle);
      PrintFormat("Data is read, %s file is closed",InpFileName);
     }
   else
      PrintFormat("Failed to open %s file, Error code = %d",InpFileName,GetLastError());
}
