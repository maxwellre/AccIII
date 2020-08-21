/*
 * AccIIIDriver.cpp
 *
 *  Created on: Aug 16, 2020
 *      Author: Basil Duvernoy
 */

#include "AccIIIListener/AccIIIDriver.h"

#include <iostream>
AccIIIDriver::AccIIIDriver() {
    this->ftHandle = NULL;
    this->ftStatus = 1;// std::numeric_limits<unsigned int>::min();
}

AccIIIDriver::~AccIIIDriver() {
    // TODO Auto-generated destructor stub
}

bool AccIIIDriver::ft_open() {

    DWORD BytesWritten;
    UCHAR Mask;
    UCHAR Mode;
    UCHAR LatencyTimer; //our default setting is 16
    char TxBuffer[1] = { 0x55 };

    Mask = 0xff;
    Mode = 0x00; //reset mode
    LatencyTimer = 2;

    if (FT_OK != FT_Open(0, &ftHandle)) {
        errno = ENODEV;
        perror("FT_Open FAILED! ");
        return true;
    }

    if (FT_OK == FT_SetBitMode(ftHandle, Mask, Mode)) {
        errno = ENOMSG;
        perror("FT_SetBitMode FAILED! ");
        return true;
    }

    if (FT_OK == FT_SetLatencyTimer(ftHandle, LatencyTimer)) {
        errno = ENOMSG;
        perror("FT_SetLatencyTimer FAILED! ");
        return true;
    }

    if (FT_OK == FT_SetUSBParameters(ftHandle, 0x10000, 0x1)) {
        errno = ENOMSG;
        perror("FT_SetUSBParameters FAILED! ");
        return true;
    }

    if (FT_OK == FT_SetFlowControl(ftHandle, FT_FLOW_RTS_CTS, 0, 0)) {
        errno = ENOMSG;
        perror("FT_SetFlowControl FAILED! ");
        return true;
    }

    if (FT_OK == FT_Purge(ftHandle, FT_PURGE_RX)) {
        errno = ENOMSG;
        perror("FT_Purge FAILED! ");
        return true;
    }

    if (FT_OK != FT_Write(ftHandle, TxBuffer, sizeof(TxBuffer), &BytesWritten)) {
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
