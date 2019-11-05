#include "stdafx.h"
#include "DataProc_2_boards.h"

DWORD EventDWord;
DWORD RxBytes_A;
DWORD RxBytes_B;
DWORD TxBytes;

long dwSum_A = 0;
long dwSum_B = 0;

unsigned char* fileBuffer_A = NULL;
unsigned char* fileBuffer_B = NULL;

std::queue<float> passTick_A, passTick_B;

int main(int argc, char* argv[])
{	
	int DataNum_A = (int)(40000 * 24); // Data Number of accelerometer array A
	int DataNum_B = (int)(40000 * 24); // Data Number, compensate with a factor if accelerometer array B mismatch with A

	if (argc == 2)
	{
		float samp_time = std::atof(argv[1]);
		printf("Sample time = %.4f secs\r\n", samp_time);
		DataNum_A = (int)(samp_time * ExpFs * AccBusNum * DataByteNum); // AccBusNum = 23 for a whole accelerometer array, reduce the number for special configurations
		DataNum_B = (int)(samp_time * ExpFs * AccBusNum * DataByteNum); // AccBusNum = 23 for a whole accelerometer array, reduce the number for special configurations
	}
	else if (argc == 1)
	{
		printf("Default sample time = 1 secs\r\n");
		DataNum_A = ExpFs * AccBusNum * DataByteNum; // AccBusNum = 23 for a whole accelerometer array, reduce the number for special configurations
		DataNum_B = ExpFs * AccBusNum * DataByteNum; // AccBusNum = 23 for a whole accelerometer array, reduce the number for special configurations	
	}
	else
	{
		printf("Only one input argument is allowed!\r\n");
		printf("Default sample time around 1 secs\r\n");
	}

	fileBuffer_A = new unsigned char[DataNum_A + 100000]; // Assign extra memery space (0.1 MB) to buffer A for safety
	fileBuffer_B = new unsigned char[DataNum_B + 100000]; // Assign extra memery space (0.1 MB) to buffer B for safety

	FT_HANDLE ftHandle_A;
	FT_HANDLE ftHandle_B;

	FT_STATUS ftStatus_A;
	FT_STATUS ftStatus_B;

	UCHAR Mask = 0xff;
	UCHAR Mode = 0x00; //reset mode 

	UCHAR LatencyTimer = 2; //our default setting is 16

	DWORD BytesWritten;
	char TxBuffer[1] = { 0x55 };

	ftStatus_A = FT_Open(0, &ftHandle_A);
	if (ftStatus_A != FT_OK)
	{
		printf("FT_Open forearm FAILED!\r\n");
	}
	else
	{
		printf("FT_Open forearm Succeeded!\r\n");
	}

	ftStatus_B = FT_Open(1, &ftHandle_B);
	if (ftStatus_B != FT_OK)
	{ 
		printf("FT_Open hand FAILED!\r\n");
	}
	else
	{
		printf("FT_Open hand Succeeded!\r\n");
	}

	ftStatus_A = FT_SetBitMode(ftHandle_A, Mask, Mode);
	ftStatus_B = FT_SetBitMode(ftHandle_B, Mask, Mode);

	if ( (ftStatus_A == FT_OK) && (ftStatus_B == FT_OK) )
	{
		bool setupCompleted_A = SetupConnect(ftHandle_A, LatencyTimer, TxBuffer, sizeof(TxBuffer), &BytesWritten);
		bool setupCompleted_B = SetupConnect(ftHandle_B, LatencyTimer, TxBuffer, sizeof(TxBuffer), &BytesWritten);
	
		// Track time using processor performance counter
		LARGE_INTEGER lPreTime, lPostTime, lFrequency;
		QueryPerformanceFrequency(&lFrequency);
		QueryPerformanceCounter(&lPreTime);

		dwSum_A = 0;
		dwSum_B = 0;

		// Initialize passed-time ticks recorder
		passTick_A.push(lPreTime.QuadPart);
		passTick_B.push(lPreTime.QuadPart);

		printf("Sampling...\n");
		while ( (dwSum_A < DataNum_A) || (dwSum_B < DataNum_B) )
		{
			if (dwSum_A < DataNum_A)
			{
				ftStatus_A = FT_GetStatus(ftHandle_A, &RxBytes_A, &TxBytes, &EventDWord);

				if ((ftStatus_A == FT_OK) && (RxBytes_A > 0))
				{
					if (RxBytes_A < 10000)
					{
						USBReadData(ftHandle_A, RxBytes_A, &dwSum_A, DataNum_A, fileBuffer_A);	
					}
					else
					{
						int iCount_A = RxBytes_A / 10000;
						for (int i = 0; i < iCount_A; i++)
						{
							USBReadData(ftHandle_A, 10000, &dwSum_A, DataNum_A, fileBuffer_A);
						}

						int iMod_A = RxBytes_A % 10000;
						if (iMod_A > 0)
						{
							USBReadData(ftHandle_A, iMod_A, &dwSum_A, DataNum_A, fileBuffer_A);
						}
					}
					QueryPerformanceCounter(&lPostTime);
					passTick_A.push(lPostTime.QuadPart);
				}
			}
			
			if (dwSum_B < DataNum_B)
			{
				ftStatus_B = FT_GetStatus(ftHandle_B, &RxBytes_B, &TxBytes, &EventDWord);

				if ((ftStatus_B == FT_OK) && (RxBytes_B > 0))
				{
					if (RxBytes_B < 10000)
					{
						USBReadData(ftHandle_B, RxBytes_B, &dwSum_B, DataNum_B, fileBuffer_B);
					}
					else
					{
						int iCount_B = RxBytes_B / 10000;
						for (int i = 0; i < iCount_B; i++)
						{
							USBReadData(ftHandle_B, 10000, &dwSum_B, DataNum_B, fileBuffer_B);
						}

						int iMod_B = RxBytes_B % 10000;
						if (iMod_B > 0)
						{
							USBReadData(ftHandle_B, iMod_B, &dwSum_B, DataNum_B, fileBuffer_B);
						}
					}
					QueryPerformanceCounter(&lPostTime);
					passTick_B.push(lPostTime.QuadPart);
				}
			}			
		}

		QueryPerformanceCounter(&lPostTime);
		float lPassTick = lPostTime.QuadPart - lPreTime.QuadPart;
		float lPassTime = lPassTick / (float)lFrequency.QuadPart;

		FT_Close(ftHandle_A);
		FT_Close(ftHandle_B);
		printf("Begin to save data into file!\r\n");

		//--------------------------------- Saving -------------------------------//

		// Save data
		SaveDataResult(dwSum_A, fileBuffer_A, "data_A.bin"); // Save data from board A
		SaveDataResult(dwSum_B, fileBuffer_B, "data_B.bin"); // Save data from board B

		printf("File Save Done!\r\n");

		// Save total measurement time
		SaveNum(lPassTime, "sample_time.txt");

		// Save time ticks to synchronize two boards (potional).
		SaveTickTime(passTick_A, (float)lFrequency.QuadPart, "sample_time.txt");
		SaveTickTime(passTick_B, (float)lFrequency.QuadPart, "sample_time.txt");

		// Save sampling rate of board A
		float idDataRate_A = dwSum_A / (lPassTime * 6 * 2 * AccBusNum);
		SaveNum(idDataRate_A, "data_rate_A.txt");

		// Save sampling rate of board B
		float idDataRate_B = dwSum_B / (lPassTime * 6 * 2 * AccBusNum);
		SaveNum(idDataRate_B, "data_rate_B.txt");
	}
	else
	{
		TRACE("FT_SetBitMode Failed!\r\n"); // FT_SetBitMode FAILED!
	}
	FT_Close(ftHandle_A);
	FT_Close(ftHandle_B);

	delete(fileBuffer_A);
	delete(fileBuffer_B);

	return 0;
}
