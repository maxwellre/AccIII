// Functions for Data Processing

#include "stdafx.h"
#include <fstream> 
#include <iostream>
#include "DataProc_2_boards.h"

DWORD BytesReceived;
unsigned char RxBuffer[10000];

bool SetupConnect(FT_HANDLE ftHandle, UCHAR LatencyTimer, LPVOID lpBuffer, DWORD dwBytesToWrite, LPDWORD lpBytesWritten)
{
	bool setupCompleted = false;
	FT_STATUS ftStatus;

	ftStatus = FT_SetLatencyTimer(ftHandle, LatencyTimer);
	if (ftStatus == FT_OK) {
		setupCompleted = true;
		printf("FT_SetLatencyTimer Succeeded!\r\n");
	}
	else {
		setupCompleted = false;
		printf("FT_SetLatencyTimer FAILED!\r\n");
	}

	ftStatus = FT_SetUSBParameters(ftHandle, 0x10000, 0x1); // DO NOT Change the parameters!
	if (ftStatus == FT_OK) {
		printf("FT_SetUSBParameters Succeeded!\r\n");
	}
	else {
		setupCompleted = false;
		printf("FT_SetUSBParameters FAILED!\r\n");
	}

	ftStatus = FT_SetFlowControl(ftHandle, FT_FLOW_RTS_CTS, 0, 0);
	if (ftStatus == FT_OK) {
		printf("FT_SetFlowControl Succeeded!\r\n");
	}
	else {
		setupCompleted = false;
		printf("FT_SetFlowControl FAILED!\r\n");
	}

	ftStatus = FT_Purge(ftHandle, FT_PURGE_RX);
	if (ftStatus == FT_OK) {
		printf("FT_Purge Succeeded!\r\n");
	}
	else {
		setupCompleted = false;
		printf("FT_Purge FAILED!\r\n");
	}

	ftStatus = FT_Write(ftHandle, lpBuffer, dwBytesToWrite, lpBytesWritten);
	if (ftStatus == FT_OK) {
		printf("FT_Write Succeeded!\r\n");
	}
	else {
		setupCompleted = false;
		printf("FT_Write Failed\r\n");
	}

	return setupCompleted;
}

void USBReadData(FT_HANDLE ftHandle, DWORD readBytes, long* dwSum, int dataNum, unsigned char fileBuffer[])
{
	FT_STATUS ftStatus;
	ftStatus = FT_Read(ftHandle, RxBuffer, readBytes, &BytesReceived);
	if (ftStatus == FT_OK)
	{
		long dwSum_org = *dwSum;
		*dwSum = *dwSum + BytesReceived;

		if (*dwSum <= dataNum)
		{
			memcpy(fileBuffer + dwSum_org, RxBuffer, BytesReceived);
		}
	}
	else
	{
		// FT_Read Failed  
		TRACE(_T("FT_Read Failed! ftStatus = %d\r\n"), ftStatus);
	}
}

void SaveDataResult(long dwSum, unsigned char fileBuffer[], std::string fileName)
{
	FILE* fp;
	errno_t err;

	if ((err = fopen_s(&fp, fileName.c_str(), "wb")) != 0)
	{
		TRACE("The hand file was not opened\r\n");
	}		
	else
	{
		TRACE("The hand file was opened\r\n");
	}

	fwrite(fileBuffer, sizeof(byte), dwSum, fp);
	fclose(fp);
}

void SaveNum(float inputValue, std::string fileName)
{
	std::ofstream ofs;
	ofs.open(fileName);
	ofs << inputValue << std::endl;
	ofs.close();
}