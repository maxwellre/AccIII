/*
 * AccIIIDriver.cpp
 *
 *  Created on: Aug 16, 2020
 *      Author: Basil Duvernoy
 */

#include "AccIIIListener/AccIIIDriver.h"


AccIIIDriver::AccIIIDriver() {

    this->ftHandle = NULL;
    this->ftStatus = ~FT_OK;// std::numeric_limits<unsigned int>::min();

    this->RxBytes = 0;
    this->RxBuffer_length = 10000;
    this->RxBuffer = new unsigned char[this->RxBuffer_length]();
    this->receivedBytes_maxSize = 5000;
}

AccIIIDriver::~AccIIIDriver() {

    delete[] RxBuffer;
}

bool AccIIIDriver::read_raw() {

    DWORD EventDWord;
    DWORD TxBytes;
    DWORD BytesReceived;

    this->ftStatus = FT_GetStatus(this->ftHandle, &this->RxBytes, &TxBytes, &EventDWord);

    if ((FT_OK == this->ftStatus) && (0 < RxBytes))
    {
        // if current buffer is too small, resize it
        if (this->RxBuffer_length < (int)this->RxBytes)
        {
            this->RxBuffer_length = this->RxBytes;
            delete[] this->RxBuffer;
            this->RxBuffer = new unsigned char[this->RxBuffer_length]();
        }

        this->ftStatus = FT_Read(this->ftHandle, RxBuffer, RxBytes, &BytesReceived);
    }

    return false;
}


bool AccIIIDriver::storeRxBuffer() {
    // check if new element can fit in the queue based on predefined max size
    if (this->receivedBytes_maxSize < this->receivedBytes.size() + 1) {
        clearReceivedBytes();
    }
    this->receivedBytes.push(this->RxBuffer);

    return false;
}

bool AccIIIDriver::clearReceivedBytes() {

    std::queue<unsigned char *> empty;
    std::swap(this->receivedBytes, empty);

    return false;
}

std::vector<int> AccIIIDriver::decode_once() {
    std::vector<int> res;

    return res;
}
bool AccIIIDriver::storeDecodedBytes(std::vector<int> * val) {

    this->acc_values.push(*val);

    return false;
}


bool AccIIIDriver::ft_open(UCHAR Mask, UCHAR Mode, UCHAR LatencyTimer, char TxBuffer) {
   
    DWORD BytesWritten;

    if (FT_OK != FT_Open(0, &this->ftHandle)) {
        errno = ENODEV;
        perror("FT_Open FAILED! ");
        return true;
    }

    if (FT_OK != FT_SetBitMode(this->ftHandle, Mask, Mode)) {
        errno = ENOMSG;
        perror("FT_SetBitMode FAILED! ");
        return true;
    }

    if (FT_OK != FT_SetLatencyTimer(this->ftHandle, LatencyTimer)) {
        errno = ENOMSG;
        perror("FT_SetLatencyTimer FAILED! ");
        return true;
    }

    if (FT_OK != FT_SetUSBParameters(this->ftHandle, 0x10000, 0x1)) {
        errno = ENOMSG;
        perror("FT_SetUSBParameters FAILED! ");
        return true;
    }

    if (FT_OK != FT_SetFlowControl(this->ftHandle, FT_FLOW_RTS_CTS, 0, 0)) {
        errno = ENOMSG;
        perror("FT_SetFlowControl FAILED! ");
        return true;
    }

    if (FT_OK != FT_Purge(this->ftHandle, FT_PURGE_RX)) {
        errno = ENOMSG;
        perror("FT_Purge FAILED! ");
        return true;
    }

    if (FT_OK != FT_Write(this->ftHandle, &TxBuffer, sizeof(&TxBuffer), &BytesWritten)) {
        errno = ENOMSG;
        perror("FT_Write Failed ");
        return true;
    }

    return false;
}

bool AccIIIDriver::ft_close() {

    if( NULL != ftHandle && FT_OK != FT_Close(ftHandle))
    {
        perror("FT_Close can't be closed\n");
        return true;
    }

    return false;
}


bool AccIIIDriver::read_infinite() {


    return false;
}


bool AccIIIDriver::read_for(int time_limit) {


    return false;
}


bool AccIIIDriver::read_once() {

    read_raw();
    storeRxBuffer();

    return false;
}


std::string  AccIIIDriver::lastData_to_print() {
    std::string res = "";

    unsigned char* curBytes;
    unsigned char* p;
    int i;
    int elements_in_curBytes;

    while(!this->receivedBytes.empty())
    {
        curBytes = this->receivedBytes.front();
        this->receivedBytes.pop();
        p = curBytes;
        elements_in_curBytes = 0;

        for (i = 0; p[i]; i++) {
            std::cout << int((unsigned char)p[i]) << " " << std::flush;
            elements_in_curBytes++;
        }
        std::cout << ":: " << elements_in_curBytes << std::flush;
        std::cout << std::endl;

        res.append(reinterpret_cast<char*>(curBytes), sizeof(curBytes));
    }

    return res;
}