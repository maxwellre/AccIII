/*
 * AccIIIDriver.h
 *
 *  Created on: Aug 16, 2020
 *      Author: Basil Duvernoy
 */

#ifndef ACCIIIDRIVER_H_
#define ACCIIIDRIVER_H_

#include <algorithm>    // std::copy
#include <atomic>
#include <chrono>
#include <cmath>
#include <errno.h>
#include <iostream>
#include <limits>       // std::numeric_limits
#include <queue>        // std::deque
#include <stdio.h>
#include <string>

#ifdef _WIN32
#include <condition_variable>
#include <mutex>                // std::mutex, std::unique_lock
#include <thread>
#include <windows.h>
#endif

#ifdef linux
#include <pthread.h>
#endif

#include "../../libs/ftd2xx.h"

#include "AccIIIDriver_defines.h"


class AccIIIDriver {
private:

    // communication variables
    FT_HANDLE ftHandle; // container for FT_open object
    FT_STATUS ftStatus; // status of ftHandle after calling functions

    // required variables for FT_read()
    DWORD EventDWord;
    DWORD TxBytes;
    DWORD RxBytes;
    DWORD RxBuffer_nbElem;

    // number of byte within the header
    int headerSize; // unit is Byte;

    // Short-term buffer for FT_read()
    Byte* RxBuffer;
    int RxBuffer_length;
    // Infinite resizable buffer of RxBuffer
    std::deque< Byte > receivedBytes;
    // Organized data
    std::vector<int> decode_idx;
    vector3D_int accData;

    // Thread related
    std::mutex m_mutex;
    std::condition_variable m_condVar;
    std::atomic<bool> workdone;
    std::thread readerThread;

    /**
     * @brief job that the reader thread will do.
     */
    bool readerThread_job();
    bool readerThread_job2();

    bool is_jobdone();

    /**
     * @brief main read called by other functions.
     * @param nbBytes number of byte to read; if Default value, RxBytes is used instead.
     * @return the value of RxBytes (number of bytes received).
     */
    long read_raw(DWORD nbBytes = -1);

    /**
     * @brief initialise RxBuffer array with l elem.
     * @param l length of the buffer; Default is 0.
     */
    bool initRxBuffer(int l = 1);

    /**
     * @brief clear receivedBytes.
     */
    bool initReceivedBytes();

    /**
     * @brief decode byteQueue by frame, sensors and axis in a 3D vector.
     * @param byteQueue The queue of byte that has to be converted.
     * @return the 3-D vector with X,Y,Z values of each sensor for each frame.
     */
    vector3D_int decode(std::deque<Byte> byteQueue);

    /**
     * @brief decode byteQueue for each axis of each accelerometer for one frame
     * based on the manner FTD2XX device communication protocol.
     * @param dataFrame Pointer to a 2-D vector to get the results;
     * @param byteQueue Queue of the size of a frame.
     */
    vector2D_int* decode_frame(vector2D_int* dataFrame, std::deque<Byte> byteQueue_frame);

    bool pop();
    bool pop_once(int offset = 0);

    /**
     * @brief store decoded ReceivedBytes values into acc_values queue.
     */
    bool storeDecodedBytes();

    /**
     * @brief get the header
     * @param headerSize number of Byte generated of the header.
     * @return vector of byte corresponding to the size of headerSize
     */
    std::vector<Byte> get_header(int headerSize);

    /**
     * @brief verify the header
     * @param hp unsigned char pointer to verify
     * @return true if the param is equal to the expected header
     */
    bool is_header(int headerSize);

    /*
    * Print the header with std::cout
    */
    void print_header(std::vector<Byte> vb);

protected:
    // Protected for Unit Test (Mock class) 

    /**------ RxBuffer Modifiers -------------------------**/
    int getRxBuffer_length(); 
    int getRxBuffer_nbElem();
    Byte* getRxBuffer();

    /**------ ReceivedBytes Modifiers --------------------**/
    void addtoReceivedBytes(Byte* bp, long length = -1);
    void addtoReceivedBytes(Byte b);
    bool removeFromReceivedBytes(long nbByte);
    void setReceivedBytes(std::deque<Byte> ByteQueue);

    /**------ AccData Modifiers --------------------------**/
    /*
    * @return the number of new values in accData
    */
    long addtoAccData(std::deque<Byte> ByteQueue);

    /**------ Type Converters ----------------------------**/
    int16_t uint16toint16(uint16_t i);
    uint16_t bytes2uint16(Byte h, Byte l);
    uint8_t byte2uint8(Byte b);
    Byte uint2byte(uint8_t i);


public:

	AccIIIDriver();
	virtual ~AccIIIDriver();

    /**
     * @brief Set communication with the ftd2xx device.
     * @param Mask Mask for FT_SetBitMode function. Default is 0xFF (output mode);
     * @param Mode Mode for FT_SetBitMode function. Default is 0x00 (reset mode);
     * @param LatencyTimer Latency in millisecond for FT_SetLatencyTimer function. Default is 2 (ms);
     * @param TxBuffer Input value for FT_Write function. Needed to say that the program is ready to listen. 
                Value is 0x55.
     */
    bool ft_open(UCHAR Mask = 0xff, UCHAR Mode = 0x00, UCHAR LatencyTimer = 2);

    /**
     * @brief Start communication with the ftd2xx device and check the header response.
     * @param TxBuffer Input value for FT_Write function. Needed to say that the program is ready to listen.
                Value is 0x55.
     */
    bool ft_startCommunication(const char TxBuffer = 0x55);

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
    bool read_for(int readTime);

    /**
     * @brief read the ftd2xx device once.
     * @return check if data has been read. If not, return NOT_OK
     */
    bool read_once();

    /*
    * @brief Subtance up to the threads
    */
    void end_read();

    /**------ PUBLIC --- GETTERS -------------------------**/
    std::deque<Byte> getReceivedBytes();
    vector3D_int getAccData();
};


#endif /* ACCIIIDRIVER_H_ */
