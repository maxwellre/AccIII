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
    this->RxBuffer_nbElem = 0;

    this->headerSize = ACCIII_NB_SENSORS + 1; // unit is Byte;

    this->decode_idx.reserve(ACCIII_NB_SENSORS);
    for (int i = 0; i < ACCIII_NB_SENSORSPERGROUP; i++) {
        this->decode_idx[i * 2] = i;
        this->decode_idx[i * 2 + 1] = i + ACCIII_NB_SENSORSPERGROUP;
    }

    this->RxBuffer = NULL;
    initRxBuffer(pow(2, 16));
    initReceivedBytes();
}

AccIIIDriver::~AccIIIDriver() {

    delete[] this->RxBuffer;
}


/**
   ------ PRIVATE ------------------------------------
**/

long AccIIIDriver::read_raw(DWORD nbBytes) {

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

bool AccIIIDriver::initRxBuffer(int l) {

    if (this->RxBuffer != NULL)
        delete[] this->RxBuffer;

    this->RxBuffer_nbElem = 0;
    this->RxBuffer_length = l;
    this->RxBuffer = new Byte[this->RxBuffer_length]();

    return AD_OK;
}

bool AccIIIDriver::initReceivedBytes() {

    std::deque< Byte > emptyQueue;
    std::swap(this->receivedBytes, emptyQueue);

    return AD_OK;
}

vector3D_int AccIIIDriver::decode(std::deque<Byte> byteQueue) {

    std::deque<Byte> byteQueue_frame;
    std::deque<Byte>::iterator it_start, it_end;
    int s, frameOffset, nbCompletedFrames, nbbyteframe;

    // get the number of frames
    nbbyteframe = ACCIII_NB_BYTEPERFRAME; // unexpected behavior when directly used in the operation
    nbCompletedFrames = (int)byteQueue.size() / nbbyteframe;
    if ( (0 < nbCompletedFrames) && (byteQueue.size() % nbbyteframe) ) {
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

        decode_frame(&accData_all[s], byteQueue_frame);
    }

    return accData_all;
}

vector2D_int* AccIIIDriver::decode_frame(vector2D_int* dataFrame, std::deque<Byte> byteQueue_frame) {

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
            sensor_ID = s * ACCIII_NB_GROUP + g;

            for (a = 0; a < ACCIII_NB_AXIS; a++) {
                // Axis X, Y, Z
                // chosen frame + chosen group + chosen sensor + chosen axis
                lowByte_ID = s + a * ACCIII_OFFSET_AXIS + offsetGroup;

                // based on the lowByteID, get HighByteID with the offset of the group sensor size
                highByte_ID = lowByte_ID + ACCIII_OFFSET_HIGHBYTE;

                highByte = byteQueue_frame[highByte_ID];
                lowByte = byteQueue_frame[lowByte_ID];

                (*dataFrame)[sensor_ID][a] = uint16toint16(bytes2uint16(highByte, lowByte));
            }
        }
    }

    return dataFrame;
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

    return AD_OK;
}

bool AccIIIDriver::pop_once(int offset) {

    int first_elem = offset * ACCIII_NB_BYTEPERFRAME;
    int last_elem = first_elem + ACCIII_NB_BYTEPERFRAME;

    if ( this->receivedBytes.size() >= last_elem) {
        auto ptr = this->receivedBytes.begin() + first_elem;
        this->receivedBytes.erase(ptr, ptr + ACCIII_NB_BYTEPERFRAME);
        return AD_OK;
    }
    else {
        return !AD_OK;
    }
}

bool AccIIIDriver::storeDecodedBytes() {

    this->accData = decode(this->receivedBytes);
    //pop();

    return AD_OK;
}

std::vector<Byte> AccIIIDriver::get_header(int headerSize) {

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

bool AccIIIDriver::is_header(int headerSize) {

    std::vector<Byte> vb = get_header(headerSize);
    bool isheader = (HEADERBYTES_VEC1 == vb || HEADERBYTES_VEC2 == vb);
    if (!isheader)
        print_header(vb);

    return isheader;
}

void AccIIIDriver::print_header(std::vector<Byte> vb) {
    auto vb_len = vb.size();

    std::cout << "Received header values are : " << std::flush;
    for (int i = 0; i < vb_len; i++) {
        std::cout << std::to_string(byte2uint8(vb[i])) << " " << std::flush;
    }
    std::cout << std::endl;
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

bool AccIIIDriver::ft_close() {

    if( NULL != ftHandle && FT_OK != FT_Close(ftHandle))
    {
        perror("FT_Close can't be closed\n");
        return !AD_OK;
    }

    return AD_OK;
}

bool AccIIIDriver::read_infinite() { return false;}
bool AccIIIDriver::read_for(int time_limit) { return false;}

bool AccIIIDriver::read_once() {

    if (read_raw())
    {
        //std::cout << "read success with nb bytes = " << this->RxBytes << std::endl;
        addtoReceivedBytes(this->RxBuffer, this->RxBytes);
        return AD_OK;
    }
    else
        return !AD_OK;
}

void AccIIIDriver::end_read() {
    addtoAccData(this->receivedBytes);
    initReceivedBytes();
}

std::deque<Byte> AccIIIDriver::getReceivedBytes() {
    return this->receivedBytes;
}

vector3D_int AccIIIDriver::getAccData() {
    return this->accData;
}
