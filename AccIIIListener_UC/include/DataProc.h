#pragma once
//------------------------------------------------------------------------------
#include<string>

#include "../libs/ftd2xx.h"

#define ExpFs 1310 // Expected sampling frequency
#define AccBusNum 10 // Totally 23 buses each connecting two accelerometers
#define DataByteNum 24 //Each bus connects two accelerometer each with 3 axies [High + Low] bytes

#pragma comment (lib, "ftd2xx.lib")

#include <stdint.h>

typedef uint8_t BYTE;
//typedef int32_t LONG;
typedef int64_t LONGLONG;


void USBReadData(FT_HANDLE ftHandle, DWORD readBytes, long* dwSum, int dataNum, unsigned char fileBuffer[]);

void SaveDataResult(long dwSum, unsigned char fileBuffer[]);

void SaveNum(float inputValue, std::string fileName);
