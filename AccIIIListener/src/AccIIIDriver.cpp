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

    this->receivedBytes_maxSize = 5000;
    this->receivedBytes_2DLength = 0;
}

AccIIIDriver::~AccIIIDriver() {

    delete[] this->RxBuffer;
}

long AccIIIDriver::read_raw() {

    this->ftStatus = FT_GetStatus(this->ftHandle, &this->RxBytes, &this->TxBytes, &this->EventDWord);

    if ((FT_OK == this->ftStatus) && (0 < this->RxBytes))
    {
        // if buffer is too small, resize it
        if (this->RxBuffer_length < (int)this->RxBytes)
        {
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
    // check if new element can fit in the queue based on predefined max size
    if (this->receivedBytes_maxSize < this->receivedBytes.size() + 1) {
        clearReceivedBytes();
    }

    std::vector<Byte> data(this->RxBuffer, this->RxBuffer + this->RxBytes);
    this->receivedBytes.push_back(data);
    this->receivedBytes_2DLength += data.size();

    return false;
}

bool AccIIIDriver::clearReceivedBytes() {

    std::deque< Byte > emptyQueue;
    std::swap(this->receivedBytes, emptyQueue);
    this->receivedBytes_2DLength = 0;

    return false;
}

vector2D_int AccIIIDriver::decode_once(int offset=0) {
    std::vector<int> res;
    int nbSensors, nbHalfSensor, nbAxis, nbSamples;
    int nbBytePerValue, offsetHighByte;
    int t, a, s, incr, offset_even;

    nbBytePerValue = 2;
    nbAxis = 3;
    nbSensors = 46;
    nbSamples = this->receivedBytes_2DLength / (nbSensors * nbBytePerValue);
    nbHalfSensor = nbSensors / 2;
    offsetHighByte = nbHalfSensor; // Odd ID sensors Bytes sent first, then Even ID sensors; Low bytes sent first, then High Bytes

    vector2D_int accData_sample(nbSensors, std::vector<int>(nbAxis));


    for (int incr = 0; incr < 2; incr++) {

        offset_even = incr * nbHalfSensor;

        for (s = 0; s < nbHalfSensor; s++) {
            for (a = 0; a < nbAxis; a++) { // Axis X, Y, Z
                
                accData_sample[s+offset_even][a] = (((int)this->receivedBytes[s + offsetHighByte] & 0xFF) << 8) | ((int)hex_data[] & 0xFF); //[High,Low]

            }
        }
    }
    

    hex_i = nbAxis * nbHalfSensor;

    for (int j = 0; j < 3; ++j) // Axis X, Y, Z
    {
        for (int k = 0; k < HALFREAD; ++k) // Even number Sensor 1,2,...,23
        {
            a_sample[6 * k + j + 3] = (((int)hex_data[hex_i + k + HALFREAD] & 0xFF) << 8) | ((int)hex_data[hex_i + k] & 0xFF); //[High,Low]

            if (a_sample[6 * k + j + 3] > 32767) 
                a_sample[6 * k + j + 3] -= 65536; // # Format correction
        }
        hex_i += READNUM;
    }
        decoded_data.push_back(a_sample); //  Append a complete sample

        dataSetNum = decoded_data.size();
        // decoded_data is a vector of size dataSetNum * 138

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

    if (read_raw())
    {
        std::cout << "read success with nb bytes = " << this->RxBytes << std::endl;
        storeRxBuffer();
    }

    return false;
}


std::string  AccIIIDriver::recentData_to_print() {
    std::string res = "";

    unsigned char* curBytes;
    int i, curBytes_length;

    curBytes_length = 0;

    /*
    
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