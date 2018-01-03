// FT2232H56QTest.cpp : 

#include "stdafx.h"
#include "DataProc.h"

DWORD EventDWord;
DWORD RxBytes;
DWORD TxBytes;

long dwSum = 0;

int main()
{
	clock_t t; // checked

	//HANDLE ftHandle;
	FT_HANDLE ftHandle;

	FT_STATUS ftStatus;
	UCHAR Mask = 0xff;
	UCHAR Mode;

	UCHAR LatencyTimer = 2; //our default setting is 16

	DWORD BytesWritten;
	char TxBuffer[1] = { 0x55 };

	ftStatus = FT_Open(0, &ftHandle);
	if (ftStatus != FT_OK)
	{
		// FT_Open failed return;  
		TRACE(_T("FT_Open FAILED!\r\n"));
		printf("FT_Open FAILED!\r\n");
	}
	else
	{
		printf("FT_Open Succeeded!\r\n");
	}

	Mode = 0x00; //reset mode 
	ftStatus = FT_SetBitMode(ftHandle, Mask, Mode);

	if (ftStatus == FT_OK)
	{
		ftStatus = FT_SetLatencyTimer(ftHandle, LatencyTimer); 
		if (ftStatus == FT_OK) {
			TRACE(_T("FT_SetLatencyTimer OK!\r\n"));
			printf("FT_SetLatencyTimer Succeeded!\r\n");
		}
		else {
			TRACE(_T("FT_SetLatencyTimer FAILED!\r\n"));
			printf("FT_SetLatencyTimer FAILED!\r\n");
		}

		ftStatus = FT_SetUSBParameters(ftHandle, 0x10000, 0x1);
		if (ftStatus == FT_OK) {
			TRACE(_T("FT_SetUSBParameters OK!\r\n"));
			printf("FT_SetUSBParameters Succeeded!\r\n");
		}
		else {
			TRACE(_T("FT_SetUSBParameters FAILED!\r\n"));
			printf("FT_SetUSBParameters FAILED!\r\n");
		}

		ftStatus = FT_SetFlowControl(ftHandle, FT_FLOW_RTS_CTS, 0, 0);
		if (ftStatus == FT_OK) {
			TRACE(_T("FT_SetFlowControl OK!\r\n"));
			printf("FT_SetFlowControl Succeeded!\r\n");
		}
		else {
			TRACE(_T("FT_SetFlowControl FAILED!\r\n"));
			printf("FT_SetFlowControl FAILED!\r\n");
		}

		ftStatus = FT_Purge(ftHandle, FT_PURGE_RX);
		if (ftStatus == FT_OK) {
			TRACE(_T("FT_Purge OK!\r\n"));
			printf("FT_Purge Succeeded!\r\n");
		}
		else {
			TRACE(_T("FT_Purge FAILED!\r\n"));
			printf("FT_Purge FAILED!\r\n");
		}

		//access data from here

		ftStatus = FT_Write(ftHandle, TxBuffer, sizeof(TxBuffer), &BytesWritten);
		if (ftStatus == FT_OK) {
			TRACE(_T("FT_Write OK!\r\n"));
			printf("FT_Write Succeeded!\r\n");
		}
		else {
			TRACE(_T("FT_Write Failed\r\n"));
			printf("FT_Write Failed\r\n");
		}

		LARGE_INTEGER lPreTime, lPostTime, lFrequency;
		QueryPerformanceFrequency(&lFrequency);
		QueryPerformanceCounter(&lPreTime);

		dwSum = 0;
		//t = clock();
		printf("Sampling...\n");
		while (dwSum < DataNum)   //DataNum
		{
			ftStatus = FT_GetStatus(ftHandle, &RxBytes, &TxBytes, &EventDWord);
			//printf("ftStatus = %d\n", ftStatus);

			if ((ftStatus == FT_OK) && (RxBytes > 0))
			{
				if (RxBytes < 10000)
				{
					USBReadData(ftHandle, RxBytes, &dwSum);
					//printf("dwSum = %d\n", dwSum);
				}
				else
				{
					int iCount = RxBytes / 10000;
					for (int i = 0; i < iCount; i++)
					{
						USBReadData(ftHandle, 10000, &dwSum);
					}

					int iMod = RxBytes % 10000;
					if (iMod > 0)
					{
						USBReadData(ftHandle, iMod, &dwSum);
					}
				}
			}
		}
		//t = clock() - t;

		QueryPerformanceCounter(&lPostTime);
		float lPassTick = lPostTime.QuadPart - lPreTime.QuadPart;
		float lPassTime = lPassTick / (float)lFrequency.QuadPart;

		float dataRate = dwSum / (lPassTime * 6 * 46);

		float USB_data_speed = dwSum / (lPassTime * 1024 * 1024);

		//TRACE(_T("Time passed : %f \r\n"), lPassTime);
		//TRACE(_T("dataRate : %f \r\n"), dataRate);
		//TRACE(_T("USB_data_speed : %f \r\n"), USB_data_speed);

		FT_Close(ftHandle);
		printf("Begin to save data into file!\r\n");

		SaveDataResult(dwSum);
		printf("File Save Done!\r\n");

		SaveNum(dataRate);
	}
	else
	{
		// FT_SetBitMode FAILED!
	}
	FT_Close(ftHandle);

	return 0;
}
