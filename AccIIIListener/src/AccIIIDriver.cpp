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
    this->RxBuffer = new Byte[this->RxBuffer_length]();

    initRxBuffer();
    initReceivedBytes();
}

AccIIIDriver::~AccIIIDriver() {

    delete[] this->RxBuffer;
}


/**
   ------ PRIVATE ------------------------------------
**/

long AccIIIDriver::read_raw(DWORD nbBytes) {

    int nbTry, nbTryMax;

    nbTry = 0;
    nbTryMax = 1000;

    do {
        // try getting status
        this->ftStatus = FT_GetStatus(this->ftHandle, &this->RxBytes, &this->TxBytes, &this->EventDWord);
        nbTry++;
    } while (FT_OK != this->ftStatus);

    if (FT_OK != this->ftStatus) {
        // report error if FT_GetStatus is unreachable
        perror("FT_GetStatus failed 1000 times in a raw ");
    }

    if (nbBytes == -1) {
        // if no specific number of bytes has been chosen, use the number of available Bytes
        nbBytes = this->RxBytes;
    }

    if (0 < nbBytes) {
        // readable number of byte
        if (this->RxBuffer_length < (int)nbBytes) {
            // if buffer is too small, resize it
            initRxBuffer((int)nbBytes);
        }

        this->ftStatus = FT_Read(this->ftHandle, this->RxBuffer, nbBytes, &this->BytesReceived);
        this->RxBuffer_nbElem = this->BytesReceived;

        if (FT_OK != this->ftStatus) {
            // FT_Read Failed
            errno = ENOMSG;
            perror("FT_Write Failed ");
        }
        else if (this->BytesReceived != nbBytes) {
            // FT_Read Incomplete 
            errno = ENOMSG;
            perror("FT_Write Incomplete ");
        }
    }

    return this->RxBuffer_nbElem;
}

bool AccIIIDriver::storeRxBuffer() {

    addtoReceivedBytes(this->RxBuffer, this->RxBytes);

    return false;
}

bool AccIIIDriver::initRxBuffer(int l) {

    if (this->RxBuffer != NULL)
        delete[] this->RxBuffer;

    this->RxBuffer_nbElem = 0;
    this->RxBuffer_length = l;
    this->RxBuffer = new Byte[this->RxBuffer_length]();

    return false;
}

bool AccIIIDriver::initReceivedBytes() {

    std::deque< Byte > emptyQueue;
    std::swap(this->receivedBytes, emptyQueue);

    return false;
}

vector3D_int AccIIIDriver::decode(std::deque<Byte> byteQueue) {

    std::deque<Byte> byteQueue_frame;
    std::deque<Byte>::iterator it_start, it_end;
    int s, frameOffset, nbCompletedFrames, nbbyteframe;

    // get the number of frames
    nbbyteframe = ACCIII_NB_BYTEPERFRAME; // unexpected behavior when directly used in the operation
    nbCompletedFrames = (int)byteQueue.size() / nbbyteframe;
    if (this->receivedBytes.size() % nbbyteframe) {
        // remove last frame if incomplete
        nbCompletedFrames--;
    }

    // init result variable
    vector3D_int accData_all(nbCompletedFrames, vector2D_int(ACCIII_NB_SENSORS, std::vector<int16_t>(ACCIII_NB_AXIS)));

    for (s = 0; s < nbCompletedFrames; s++) {
        // for each frame, get the decoded data
        frameOffset = s * nbbyteframe;
        it_start = byteQueue.begin() + frameOffset;
        it_end = it_start + nbbyteframe;
        byteQueue_frame.assign(it_start, it_end);

        decode_once(&accData_all[s], byteQueue_frame);
    }

    return accData_all;
}


bool AccIIIDriver::decode_once(vector2D_int *dataFrame, std::deque<Byte> byteQueue_frame) {

    Byte highByte, lowByte;
    int a, s, g;
    int sensor_ID, highByte_ID, lowByte_ID;
    int offsetGroup;

    // get position of the current frame

    for (g = 0; g < ACCIII_NB_GROUP; g++) {
        // care about odd ID sensors first, then even ID sensors
        offsetGroup = g * ACCIII_NB_BYTEPERGROUP;

        for (s = 0; s < ACCIII_NB_SENSORSPERGROUP; s++) {
            // for each sensor of the current group (odd // even)
            sensor_ID = s*ACCIII_NB_GROUP + g;

            for (a = 0; a < ACCIII_NB_AXIS; a++) {
                // Axis X, Y, Z
                // chosen frame + chosen group + chosen sensor + chosen axis
                lowByte_ID = offsetGroup + s + a*ACCIII_NB_SENSORSPERGROUP*ACCIII_NB_BYTEPERVALUE;

                // based on the lowByteID, get HighByteID with the offset of the group sensor size
                highByte_ID = lowByte_ID + ACCIII_OFFSET_HIGHBYTE;

                highByte = byteQueue_frame[highByte_ID];
                lowByte = byteQueue_frame[lowByte_ID];
                
                (*dataFrame)[sensor_ID][a] = uint16toint16(bytes2uint16(highByte, lowByte));
            }
        }
    }
   
    return false;
}

bool AccIIIDriver::pop() {

    int s, nbFrames;

    nbFrames = (int)this->receivedBytes.size() / ACCIII_NB_BYTEPERFRAME;

    vector2D_int accData_frame(ACCIII_NB_SENSORS, std::vector<int16_t>(ACCIII_NB_AXIS));
    vector3D_int accData(nbFrames, accData_frame);

    for (s = 0; s < nbFrames; s++) {
        if (pop_once()) {
            perror("decode_once error\n");
            break;
        }
        accData[s] = accData_frame;
    }

    return false;
}

bool AccIIIDriver::pop_once(int offset) {

    int first_elem = offset * ACCIII_NB_BYTEPERFRAME;
    int last_elem = first_elem + ACCIII_NB_BYTEPERFRAME;

    if ( this->receivedBytes.size() >= last_elem) {
        auto ptr = this->receivedBytes.begin() + first_elem;
        this->receivedBytes.erase(ptr, ptr + ACCIII_NB_BYTEPERFRAME);
        return false;
    }
    else {
        return true;
    }
}

bool AccIIIDriver::storeDecodedBytes() {

    this->accData = decode(this->receivedBytes);
    //pop();

    return false;
}

bool AccIIIDriver::remove_header(int headerSize) {

    int nbTry, nbTryMax, headerSize_left;

    headerSize_left = headerSize;
    nbTry = 0;
    nbTryMax = 100;

    // try until the entire header is flush
    do {
        // read without storing the values
        headerSize_left -= read_raw(headerSize_left);
        nbTry++;
    } while ((0 != headerSize_left) && nbTry < nbTryMax);

    return ((nbTry < nbTryMax) ? false : true);
}


/**
   ------ PROTECTED ----------------------------------
**/

int AccIIIDriver::getRxBuffer_length() {
    return this->RxBuffer_length;
}

int AccIIIDriver::getRxBuffer_nbElem() {
    return this->RxBuffer_nbElem;
}

Byte* AccIIIDriver::getRxBuffer() {
    return this->RxBuffer;
}

void AccIIIDriver::addtoReceivedBytes(Byte* bp, long length) {
    int i, stop;

    length ? stop = length : stop = bp[0];

    for (i = 0; i < stop; i++) {
        addtoReceivedBytes(bp[i]);
    }
}

void AccIIIDriver::addtoReceivedBytes(Byte b) {
    this->receivedBytes.push_back(b);
}

void AccIIIDriver::setReceivedBytes(std::deque<Byte> ByteQueue) {
    this->receivedBytes = ByteQueue;
}

void AccIIIDriver::addtoAccData(std::deque<Byte> ByteQueue) {

    vector3D_int data = decode(ByteQueue);
    this->accData.insert(std::end(this->accData), std::begin(data), std::end(data));
}

int16_t AccIIIDriver::uint16toint16(uint16_t i) {
    return (int16_t)i;
}

uint16_t AccIIIDriver::bytes2uint16(Byte h, Byte l) {
    return (uint16_t)(byte2uint8(h) << 8 | byte2uint8(l));
}

uint8_t AccIIIDriver::byte2uint8(Byte b) {
    return (uint8_t)b;
}

Byte AccIIIDriver::uint2byte(uint8_t i) {
    return (Byte)i;
}


/**
   ------ PUBLIC -------------------------------------
**/

bool AccIIIDriver::ft_open(UCHAR Mask, UCHAR Mode, UCHAR LatencyTimer, char TxBuffer) {
    DWORD BytesWritten;
    int headerSize = 46 + 1; // unit is Byte;

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

    if (remove_header(headerSize)) {
        errno = ENOMSG;
        perror("Remove_header failed");
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

std::deque<Byte> AccIIIDriver::getReceivedBytes() {
    return this->receivedBytes;
}

vector3D_int AccIIIDriver::getAccData() {
    return this->accData;
}


