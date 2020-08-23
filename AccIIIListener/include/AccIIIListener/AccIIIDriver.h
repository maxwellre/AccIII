/*
 * AccIIIDriver.h
 *
 *  Created on: Aug 16, 2020
 *      Author: Basil Duvernoy
 */

#ifndef ACCIIIDRIVER_H_
#define ACCIIIDRIVER_H_

#include <algorithm>    // std::copy
#include <errno.h>
#include <iostream>
#include <limits>
#include <queue>          // std::queue
#include <stdio.h>
#include <string>

#ifdef _WIN32
#include <windows.h>
#endif

#ifdef linux
#include <pthread.h>
#endif

#include "../../libs/ftd2xx.h"

// To clarify the reading
typedef unsigned char Byte;
typedef std::vector< std::vector<int> > vector2D_int;
typedef std::vector< vector2D_int > vector3D_int;


class AccIIIDriver {
private:

    // communication variables
    FT_HANDLE ftHandle; // container for FT_open object
    FT_STATUS ftStatus; // status of ftHandle after calling functions

    // required variables for FT_read()
    DWORD EventDWord;
    DWORD TxBytes;
    DWORD RxBytes;
    DWORD BytesReceived;
    unsigned char* RxBuffer;
    int RxBuffer_length;

    // variables of control for receivedBytes
    int receivedBytes_maxSize; // maximum number of vectors in the queue
    int receivedBytes_2DLength; // total number of elements in receivedBytes

    /**
     * @brief main read called by other functions
     * @return the value of RxBytes (number of bytes received)
     */
    long read_raw();

    /**
     * @brief store RxBuffer values into receivedBytes queue
     */
    bool storeRxBuffer();

    /**
     * @brief clear receivedBytes is size if bigger than receivedBytes_maxSize
     */
    bool clearReceivedBytes();

    /**
     * @brief decode ReceivedBytes for one value of each accelerometer 
     * based on the manner FTD2XX device communication protocol.
     * @param offset Offset defines the targeted sample 
     * @return the 2-D vector with X,Y,Z values of each sensor for one sample 
     */
    vector2D_int decode_once(int offset = 0);

    /**
     * @brief store decoded ReceivedBytes values into acc_values queue
     */
    bool storeDecodedBytes(std::vector<int> * val);


public:
    std::deque< Byte > receivedBytes;
    vector3D_int accData;

	AccIIIDriver();
	virtual ~AccIIIDriver();

    /**
     * @brief Opening communication with the ftd2xx device.
     * @param Mask Mask for FT_SetBitMode function. Default is 0xFF (output mode)
     * @param Mode Mode for FT_SetBitMode function. Default is 0x00 (reset mode)
     * @param LatencyTimer Latency in millisecond for FT_SetLatencyTimer function. Default is 2 (ms)
     * @param TxBuffer Input value for FT_Write function. Needed to test one time to write into the device. Default value is 0x55
     */
    bool ft_open(UCHAR Mask = 0xff, UCHAR Mode = 0x00, UCHAR LatencyTimer = 2, const char TxBuffer = 0x55 );

    /**
     * @brief close communication with the ftd2xx device.
     */
    bool ft_close();

    /**
     * @brief read until receiving a stop signal.
     */
    bool read_infinite();

    /**
     * @brief close communication with the ftd2xx device.
     * @param time_limit value in millisecond that the program reads the ftd2xx device.
     */
    bool read_for(int time_limit);

    /**
     * @brief read the ftd2xx device once.
     */
    bool read_once();

    /**
     * @brief convert last data to be print
     */
    std::string recentData_to_print();

};

#endif /* ACCIIIDRIVER_H_ */
