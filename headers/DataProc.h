#pragma once
//------------------------------------------------------------------------------
#include<string>
#define DataNum 40000*24

void USBReadData(FT_HANDLE ftHandle, DWORD readBytes, long* dwSum);

void SaveDataResult(long dwSum);

void SaveNum(float inputValue, std::string fileName);