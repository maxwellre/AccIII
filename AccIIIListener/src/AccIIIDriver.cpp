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

    this->EventDWord = 0;
    this->TxBytes = 0;
    this->RxBytes = 0;
    this->BytesReceived = 0;

    this->RxBuffer_length = 50000;
    this->RxBuffer = new unsigned char[this->RxBuffer_length]();

    this->receivedBytes_maxLength = 10^6;
    clearReceivedBytes();
}

AccIIIDriver::~AccIIIDriver() {

    delete[] this->RxBuffer;
}

long AccIIIDriver::read_raw() {

    this->ftStatus = FT_GetStatus(this->ftHandle, &this->RxBytes, &this->TxBytes, &this->EventDWord);

    if ((FT_OK == this->ftStatus) && (0 < this->RxBytes)) {

        if (this->RxBuffer_length < (int)this->RxBytes) {
            // if buffer is too small, resize it
            this->RxBuffer_length = this->RxBytes;
            delete[] this->RxBuffer;
            this->RxBuffer = new unsigned char[this->RxBuffer_length]();
        }

        this->ftStatus = FT_Read(this->ftHandle, this->RxBuffer, this->RxBytes, &this->BytesReceived);

        if (FT_OK != this->ftStatus) {
            // FT_Read Failed
            errno = ENOMSG;
            perror("FT_Write Failed ");
        }
        else if (this->BytesReceived != this->RxBytes) {
            // FT_Read Incomplete 
            errno = ENOMSG;
            perror("FT_Write Incomplete ");
        }
    }

    return this->RxBytes;
}

bool AccIIIDriver::storeRxBuffer() {

    if (this->receivedBytes_maxLength < this->receivedBytes.size() + 1) {
        // if new element can't fit in the queue based on predefined max size
        //clearReceivedBytes();
    }

    long rxl = this->RxBytes;
    for (int itr = 0; itr < rxl; itr++) {
        this->receivedBytes.push_back(this->RxBuffer[itr]);
    }
    
    return false;
}

bool AccIIIDriver::clearReceivedBytes() {

    std::cout << "clearReceivedBytes..." << std::endl;
    std::deque< Byte > emptyQueue;
    std::swap(this->receivedBytes, emptyQueue);

    return false;
}

vector3D_int AccIIIDriver::decode() {
    vector2D_int vec2D_sample(ACCIII_NB_SENSORS, std::vector<int>(ACCIII_NB_AXIS));
    int s, nbCompletedSamples, nbbytesample;

    nbbytesample = ACCIII_NB_BYTEPERSAMPLE; // unexpected behavior when directly used in the operation
    nbCompletedSamples = (int)this->receivedBytes.size() / nbbytesample;
    if (this->receivedBytes.size() % nbbytesample) {
        // remove last sample if incomplete
        nbCompletedSamples--;
    }

    vector3D_int accData_all(nbCompletedSamples, vec2D_sample);

    for (s = 0; s < nbCompletedSamples; s++) {
        if (decode_once(&accData_all[s], s)) {
            perror("decode_once error\n");
            break;
        }
    }

    return accData_all;
}


bool AccIIIDriver::decode_once(vector2D_int *dataSample, int offset) {

    Byte highByte, lowByte;
    int a, s, incr, value;
    int sensor_ID, highByte_ID, lowByte_ID;
    int offset_group, offset_sample;

    offset_sample = offset * ACCIII_NB_BYTEPERSAMPLE;

    for (incr = 0; incr < ACCIII_NB_GROUP; incr++) {
        // care about odd ID sensors first, then even ID sensors
        offset_group = incr * ACCIII_NB_BYTEPERGROUP;

        for (s = 0; s < ACCIII_NB_SENSORSPERGROUP; s++) {
            // for each sensor of the current group (odd // even)
            sensor_ID = s*ACCIII_NB_GROUP + incr;

            for (a = 0; a < ACCIII_NB_AXIS; a++) {
                // Axis X, Y, Z
                // chosen sample + chosen group + chosen sensor + chosen axis
                lowByte_ID = offset_sample + offset_group + s + a*ACCIII_NB_SENSORSPERGROUP*ACCIII_NB_BYTEPERVALUE;

                // based on the lowByteID, get HighByteID with the offset of the group sensor size
                highByte_ID = lowByte_ID + ACCIII_OFFSET_HIGHBYTE;

                highByte = this->receivedBytes[highByte_ID];
                lowByte = this->receivedBytes[lowByte_ID];

                value = ((int)highByte << 8) | (int)lowByte; // [High,Low]
                if (value > ACCIII_VALUE_MID) {
                    // sensors give negative and positive values (unsigned -> signed values)
                    // if last bit if 1, then value is negative
                    value -= ACCIII_VALUE_MAX;
                }
                (*dataSample)[sensor_ID][a] = value;
            }
        }
    }
   
    return false;
}

bool AccIIIDriver::pop() {
    int s, nbSamples;

    nbSamples = (int)this->receivedBytes.size() / ACCIII_NB_BYTEPERSAMPLE;

    vector2D_int accData_sample(ACCIII_NB_SENSORS, std::vector<int>(ACCIII_NB_AXIS));
    vector3D_int accData(nbSamples, accData_sample);

    for (s = 0; s < nbSamples; s++) {
        if (pop_once()) {
            perror("decode_once error\n");
            break;
        }
        accData[s] = accData_sample;
    }

    return false;
}

bool AccIIIDriver::pop_once(int offset) {

    int first_elem = offset * ACCIII_NB_BYTEPERSAMPLE;
    int last_elem = first_elem + ACCIII_NB_BYTEPERSAMPLE;

    if ( this->receivedBytes.size() >= last_elem) {
        auto ptr = this->receivedBytes.begin() + first_elem;
        this->receivedBytes.erase(ptr, ptr + ACCIII_NB_BYTEPERSAMPLE);
        return false;
    }
    else {
        return true;
    }
}


bool AccIIIDriver::storeDecodedBytes() {

    vector3D_int data = decode();
    //pop();

    this->accData = data;

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

    if (read_raw())
    {
        //std::cout << "read success with nb bytes = " << this->RxBytes << std::endl;
        storeRxBuffer();
    }

    return false;
}


bool AccIIIDriver::read_end() {
    storeDecodedBytes();

    return false;
}




std::string  AccIIIDriver::recentData_to_print() {
    std::string res = "";

    /*
    unsigned char* curBytes;
    int i, curBytes_length;

    curBytes_length = 0;

    
    if (!this->receivedBytes.empty())
    {
        curBytes = this->receivedBytes.back();

        for (i = 0; curBytes[i]; i++) {
            std::cout << int((unsigned char)curBytes[i]) << " " << std::flush;
            curBytes_length++;
        }
        std::cout << ":: " << curBytes_length << std::flush;
        std::cout << std::endl;

        res.append(reinterpret_cast<char*>(curBytes), sizeof(curBytes));
    }
    */
    return res;
}


vector3D_int AccIIIDriver::getAccData() {

    return this->accData;
}