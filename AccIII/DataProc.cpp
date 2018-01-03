// Functions for Data Processing

#include "stdafx.h"
#include <fstream> 
#include <iostream>
#include "DataProc.h"

DWORD BytesReceived;
unsigned char RxBuffer[10000];
unsigned char fileBuffer[40000 * 24];

void USBReadData(FT_HANDLE ftHandle, DWORD readBytes, long* dwSum)
{
	FT_STATUS ftStatus;
	ftStatus = FT_Read(ftHandle, RxBuffer, readBytes, &BytesReceived);
	if (ftStatus == FT_OK)
	{
		long dwSum_org = *dwSum;
		*dwSum = *dwSum + BytesReceived;

		if (*dwSum <= DataNum)
		{
			memcpy(fileBuffer + dwSum_org, RxBuffer, BytesReceived);
			//printf("BytesReceived = %d, dwSum =%d\r\n", BytesReceived, *dwSum);	
			//printf(".\n");
		}
	}
	else
	{
		// FT_Read Failed  
		TRACE(_T("FT_Read Failed! ftStatus = %d\r\n"), ftStatus);
	}
}

///*Save data as text file (Obsolete)*/
//void SaveDataResult()
//{
//	CStdioFile DataFile(_T("Data.txt"), CStdioFile::modeCreate | CStdioFile::modeWrite);
//
//	for (long long i = 0; i < DataNum; i++)
//	{
//		CString strTmp;
//		strTmp.Format(_T("%02x "), fileBuffer[i]);
//		DataFile.SeekToEnd();
//		DataFile.WriteString(strTmp.GetString());
//	}
//}

void SaveDataResult(long dwSum)
{
	FILE* fp;
	errno_t err;
	if ((err = fopen_s(&fp, "data.bin", "wb")) != 0)
		TRACE("The file was not opened\n");
	else
		TRACE("The file was opened\n");

	fwrite(fileBuffer, sizeof(byte), dwSum, fp);
	fclose(fp);
}

void SaveNum(float data_rate)
{
	std::ofstream ofs;
	ofs.open("data_rate.txt");
	ofs << data_rate << std::endl;
	ofs.close();
}