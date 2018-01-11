#pragma once
//------------------------------------------------------------------------------
#include<string>
#define ExpFs 1560 // Expected sampling frequency
#define AccBusNum 23 // Totally 23 buses each connecting two accelerometers
#define DataByteNum 24 //Each bus connects two accelerometer each with 3 axies [High + Low] bytes

void USBReadData(FT_HANDLE ftHandle, DWORD readBytes, long* dwSum, int dataNum, unsigned char fileBuffer[]);

void SaveDataResult(long dwSum, unsigned char fileBuffer[]);

void SaveNum(float inputValue, std::string fileName);