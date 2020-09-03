/*
 * AccIIIListener.cpp
 *
 *  Created on: Aug 16, 2020
 *      Author: Basil Duvernoy
 */

#include "AccIIIDriver/AccIIIListener.h"

const std::vector<Byte> HEADERBYTES_VEC1 = {
     32, 63, 32, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 32, 63, 63, 63, 63, 63, 63, 63, 63, 63,
    117, 63, 32, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 32, 63, 63, 63, 63, 63, 63, 63, 63, 63, 117 };
const std::vector<Byte> HEADERBYTES_VEC2 = {
     32, 63, 32, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 32, 63, 63, 63, 63, 63, 63, 63, 63, 63,
    117, 63, 32, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 32, 63, 63, 63, 63, 63, 63, 63, 63, 63, 85 };

AccIIIListener::AccIIIListener() {

    this->ftHandle = NULL;
    this->ftStatus = ~FT_OK; // std::numeric_limits<unsigned int>::min();

    this->EventDWord = 0;
    this->TxBytes = 0;
    this->RxBytes = 0;
    this->RxBuffer_nbElem = 0;

    this->headerSize = ACCIII_NB_SENSORS + 1; // unit is Byte;

    this->RxBuffer = NULL;
    initRxBuffer(pow(2, 16));

}

AccIIIListener::~AccIIIListener() {

    delete[] this->RxBuffer;
}


/**
   ------ PRIVATE ------------------------------------
**/

long AccIIIListener::read_raw(DWORD nbBytes) {

    if (FT_OK != FT_GetStatus(this->ftHandle, &this->RxBytes, &this->TxBytes, &this->EventDWord)) {
        // report error if FT_GetStatus is unreachable
        perror("FT_GetStatus failed ");
        this->RxBuffer_nbElem = 0;
        return 0;
    }

    if (-1 == nbBytes || nbBytes > this->RxBytes) {
        // if no specific number of bytes has been chosen, use the number of available Bytes
        nbBytes = this->RxBytes;
    }

    if (0 >= nbBytes) {
        this->RxBuffer_nbElem = 0;
        return 0;
    }

    // readable number of byte
    if (this->RxBuffer_length < (int)nbBytes) {
        // if buffer is too small, resize it
        initRxBuffer((int)nbBytes);
    }

    if (FT_OK != FT_Read(this->ftHandle, this->RxBuffer, nbBytes, &this->RxBuffer_nbElem)) {
        // FT_Read Failed
        errno = ENOMSG;
        perror("FT_Read Failed ");
    }
    else if (this->RxBuffer_nbElem != nbBytes) {
        // FT_Read Incomplete 
        errno = ENOMSG;
        perror("FT_Read Incomplete ");
    }

    return this->RxBuffer_nbElem;
}

bool AccIIIListener::initRxBuffer(int l) {

    if (this->RxBuffer != NULL)
        delete[] this->RxBuffer;

    this->RxBuffer_nbElem = 0;
    this->RxBuffer_length = l;
    this->RxBuffer = new Byte[this->RxBuffer_length]();

    return AD_OK;
}



std::vector<Byte> AccIIIListener::get_header(int headerSize) {

    std::vector<Byte> vb;
    int i, headerSize_left, nbTry, nbTryMax;

    vb.reserve(headerSize);
    headerSize_left = headerSize;
    nbTryMax = 10000;
    nbTry = 0;

    do {
        // try until the header is entirely flushed
        headerSize_left -= read_raw(headerSize_left);

        for (i = 0; i < (int)this->RxBuffer_nbElem; i++) {
            vb.push_back(this->RxBuffer[i]);
        }

        nbTry++;
    } while ( (0<headerSize_left) && nbTryMax>nbTry);

    return vb;
}

bool AccIIIListener::is_header(int headerSize) {

    std::vector<Byte> vb = get_header(headerSize);
    bool isheader = (HEADERBYTES_VEC1 == vb || HEADERBYTES_VEC2 == vb);
    if (!isheader)
        print_header(vb);

    return isheader;
}

void AccIIIListener::print_header(std::vector<Byte> vb) {
    auto vb_len = vb.size();

    std::cout << "Received header values are : " << std::flush;
    for (int i = 0; i < vb_len; i++) {
        std::cout << std::to_string((int)(vb[i])) << " " << std::flush;
    }
    std::cout << std::endl;
}

/**
   ------ PROTECTED ----------------------------------
**/

/**
   ------ PUBLIC -------------------------------------
**/

bool AccIIIListener::ft_open(UCHAR Mask, UCHAR Mode, UCHAR LatencyTimer) {

    if (FT_OK != FT_Open(0, &this->ftHandle)) {
        errno = ENODEV;
        perror("FT_Open FAILED! ");
        return !AD_OK;
    }

    if (FT_OK != FT_SetBitMode(this->ftHandle, Mask, Mode)) {
        errno = ENOMSG;
        perror("FT_SetBitMode FAILED! ");
        return !AD_OK;
    }

    if (FT_OK != FT_SetLatencyTimer(this->ftHandle, LatencyTimer)) {
        errno = ENOMSG;
        perror("FT_SetLatencyTimer FAILED! ");
        return !AD_OK;
    }

    if (FT_OK != FT_SetUSBParameters(this->ftHandle, 0x10000, 0x1)) {
        errno = ENOMSG;
        perror("FT_SetUSBParameters FAILED! ");
        return !AD_OK;
    }

    if (FT_OK != FT_SetFlowControl(this->ftHandle, FT_FLOW_RTS_CTS, 0, 0)) {
        errno = ENOMSG;
        perror("FT_SetFlowControl FAILED! ");
        return !AD_OK;
    }

    if (FT_OK != FT_Purge(this->ftHandle, FT_PURGE_RX)) {
        errno = ENOMSG;
        perror("FT_Purge FAILED! ");
        return !AD_OK;
    }

    return AD_OK;
}

bool AccIIIListener::ft_startCommunication(char TxBuffer) {

    DWORD BytesWritten;

    if (FT_OK != FT_Write(this->ftHandle, &TxBuffer, sizeof(&TxBuffer), &BytesWritten)) {
        errno = ENOMSG;
        perror("FT_Write Failed ");
        return !AD_OK;
    }

    if (sizeof(&TxBuffer) != BytesWritten) {
        errno = ENOMSG;
        perror("FT_Write Failed: did not correctly wrote the Ready Signal ");
        return !AD_OK;
    }

    if (!is_header(this->headerSize)) {
        perror("is_header failed : The current header doesn't match the good ones. ");
        return !AD_OK;
    }

    return AD_OK;
}

bool AccIIIListener::ft_close() {

    if( NULL != ftHandle && FT_OK != FT_Close(ftHandle))
    {
        perror("FT_Close can't be closed\n");
        return !AD_OK;
    }

    return AD_OK;
}

bool AccIIIListener::read_once() {

    if (!read_raw()) {
        return !AD_OK;
    }

    return AD_OK;
}

Byte* AccIIIListener::getRxBuffer() {
    return this->RxBuffer;
}

int AccIIIListener::getRxBuffer_length() {
    return this->RxBuffer_length;
}

DWORD AccIIIListener::getRxBuffer_nbElem() {
    return this->RxBuffer_nbElem;
}



