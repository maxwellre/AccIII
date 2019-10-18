// FT2232H56QTest.cpp : 

#include "stdafx.h"
#include "DataProc.h"

#include "window.h"
#include <QApplication>

DWORD EventDWord;
DWORD RxBytes;
DWORD TxBytes;

long dwSum = 0;
unsigned char* fileBuffer = NULL;

int main(int argc, char* argv[])
{
	int DataNum = 40000 * 24; // Old version default: 1.159 secs

	// QT program initialization
	//QApplication a(argc, argv);
	//Window w;
	//w.show();

	if (argc == 2)
	{
		float samp_time = std::atof(argv[1]);
		printf("Sample time = %.4f secs\r\n", samp_time);
		DataNum = (int)(samp_time * ExpFs * AccBusNum * DataByteNum);
	}
	else if (argc == 1)
	{
		printf("Default sample time = 1 secs\r\n");
		DataNum = ExpFs * AccBusNum * DataByteNum;
	}
	else
	{
		TRACE(_T("Only one input argument is allowed!\r\n"));
		printf("Only one input argument is allowed!\r\n");
		printf("Default sample time = 1.159 secs\r\n");
	}

	fileBuffer = new unsigned char[DataNum];

	//clock_t t; // checked

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
		//TRACE(_T("FT_Open FAILED!\r\n"));
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
			//TRACE(_T("FT_SetLatencyTimer OK!\r\n"));
			printf("FT_SetLatencyTimer Succeeded!\r\n");
		}
		else {
			//TRACE(_T("FT_SetLatencyTimer FAILED!\r\n"));
			printf("FT_SetLatencyTimer FAILED!\r\n");
		}

		ftStatus = FT_SetUSBParameters(ftHandle, 0x10000, 0x1);
		if (ftStatus == FT_OK) {
			//TRACE(_T("FT_SetUSBParameters OK!\r\n"));
			printf("FT_SetUSBParameters Succeeded!\r\n");
		}
		else {
			//TRACE(_T("FT_SetUSBParameters FAILED!\r\n"));
			printf("FT_SetUSBParameters FAILED!\r\n");
		}

		ftStatus = FT_SetFlowControl(ftHandle, FT_FLOW_RTS_CTS, 0, 0);
		if (ftStatus == FT_OK) {
			//TRACE(_T("FT_SetFlowControl OK!\r\n"));
			printf("FT_SetFlowControl Succeeded!\r\n");
		}
		else {
			//TRACE(_T("FT_SetFlowControl FAILED!\r\n"));
			printf("FT_SetFlowControl FAILED!\r\n");
		}

		ftStatus = FT_Purge(ftHandle, FT_PURGE_RX);
		if (ftStatus == FT_OK) {
			//TRACE(_T("FT_Purge OK!\r\n"));
			printf("FT_Purge Succeeded!\r\n");
		}
		else {
			//TRACE(_T("FT_Purge FAILED!\r\n"));
			printf("FT_Purge FAILED!\r\n");
		}

		ftStatus = FT_Write(ftHandle, TxBuffer, sizeof(TxBuffer), &BytesWritten);
		if (ftStatus == FT_OK) {
			//TRACE(_T("FT_Write OK!\r\n"));
			printf("FT_Write Succeeded!\r\n");
		}
		else {
			//TRACE(_T("FT_Write Failed\r\n"));
			printf("FT_Write Failed\r\n");
		}

		LARGE_INTEGER lPreTime, lPostTime, lFrequency;
		QueryPerformanceFrequency(&lFrequency);
		QueryPerformanceCounter(&lPreTime);

		dwSum = 0;

		DWORD BytesReceivedTest;
		DWORD readBytesTest = 0;

		unsigned char RxBuffer[10000];

		printf("Sampling...\n");
		while (dwSum < DataNum) 
		{
			ftStatus = FT_Read(ftHandle, RxBuffer, readBytesTest, &BytesReceivedTest);

			//int temp = (int)rxbuffer[0];

			//w.dataupdate(temp);

			//printf("ftstatus = %d, rxbytes = %d\n", ftstatus, rxbytes);

		//	if ((ftstatus == ft_ok) && (rxbytes > 0))
		//	{
		//		ftstatus = ft_read(fthandle, rxbuffer, &rxbytes, &bytesreceived);


		//		if (rxbytes < 10000)
		//		{
		//			usbreaddata(fthandle, rxbytes, &dwsum, datanum, filebuffer);
		//		}
		//		else
		//		{
		//			int icount = rxbytes / 10000;
		//			for (int i = 0; i < icount; i++)
		//			{
		//				usbreaddata(fthandle, 10000, &dwsum, datanum, filebuffer);
		//			}

		//			int imod = rxbytes % 10000;
		//			if (imod > 0)
		//			{
		//				usbreaddata(fthandle, imod, &dwsum, datanum, filebuffer);
		//			}
		//		}
		//	}
		}

		//QueryPerformanceCounter(&lPostTime);
		//float lPassTick = lPostTime.QuadPart - lPreTime.QuadPart;
		//float lPassTime = lPassTick / (float)lFrequency.QuadPart;

		////float USB_data_speed = dwSum / (lPassTime * 1024 * 1024);
		////TRACE(_T("USB_data_speed : %f \r\n"), USB_data_speed);

		//FT_Close(ftHandle);
		//printf("Begin to save data into file!\r\n");

		//SaveDataResult(dwSum, fileBuffer);
		//printf("File Save Done!\r\n");

		//SaveNum(lPassTime, "sample_time.txt");

		////TRACE(_T("Time passed : %f \r\n"), lPassTime);

		////TRACE(_T("Data Number = %d \r\n"), dwSum/(2*6*46));

		//float idDataRate = dwSum / (lPassTime * 6 * 46); // Count ID as data
		//SaveNum(idDataRate, "data_rate.txt");
	}
	else
	{
		// FT_SetBitMode FAILED!
		FT_Close(ftHandle);
	}
	
	free(fileBuffer); // Free buffer memory to avoid memory leak

	return 0;
	//return a.exec(); // Exit the QT program
}
