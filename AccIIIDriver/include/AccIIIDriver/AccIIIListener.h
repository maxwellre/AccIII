/*
 * AccIIIListener.h
 *
 *  Created on: Aug 16, 2020
 *      Author: Basil Duvernoy
 */

#ifndef ACCIIILISTENER_H_
#define ACCIIILISTENER_H_

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

#include "../../libs/ftd2xx.h"

#include "AccIIIDriver_defines.h"

class AccIIIListener {
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

    bool pop();
    bool pop_once(int offset = 0);

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

    /**
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

public:

	AccIIIListener();
	virtual ~AccIIIListener();

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

    /**------ PUBLIC --- GETTERS -------------------------**/
    std::deque<Byte> getReceivedBytes();
};


#endif /* ACCIIILISTENER_H_ */
