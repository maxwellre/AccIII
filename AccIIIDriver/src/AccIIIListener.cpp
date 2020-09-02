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

    this->decode_idx.reserve(ACCIII_NB_SENSORS);
    for (int i = 0; i < ACCIII_NB_SENSORSPERGROUP; i++) {
        this->decode_idx[i * 2] = i;
        this->decode_idx[i * 2 + 1] = i + ACCIII_NB_SENSORSPERGROUP;
    }

    this->RxBuffer = NULL;
    initRxBuffer(pow(2, 16));
    initReceivedBytes();

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

bool AccIIIListener::initReceivedBytes() {

    std::deque< Byte > emptyQueue;
    std::swap(this->receivedBytes, emptyQueue);

    return AD_OK;
}

bool AccIIIListener::pop() {

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

bool AccIIIListener::pop_once(int offset) {

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

int AccIIIListener::getRxBuffer_length() {
    return this->RxBuffer_length;
}

int AccIIIListener::getRxBuffer_nbElem() {
    return this->RxBuffer_nbElem;
}

Byte* AccIIIListener::getRxBuffer() {
    return this->RxBuffer;
}

void AccIIIListener::addtoReceivedBytes(Byte* bp, long length) {
    int i, stop;

    length ? stop = length : stop = bp[0];

    for (i = 0; i < stop; i++) {
        addtoReceivedBytes(bp[i]);
    }
}

void AccIIIListener::addtoReceivedBytes(Byte b) {
    this->receivedBytes.push_back(b);
}

bool AccIIIListener::removeFromReceivedBytes(long nbByte) {

    if (nbByte <= this->receivedBytes.size()) {
        this->receivedBytes.erase(this->receivedBytes.begin(), this->receivedBytes.begin() + nbByte);
        return AD_OK;
    }
    return !AD_OK;
}

void AccIIIListener::setReceivedBytes(std::deque<Byte> ByteQueue) {
    this->receivedBytes = ByteQueue;
}

/**
   ------ PUBLIC -------------------------------------
**/

bool AccIIIListener::ft_open(UCHAR Mask, UCHAR Mode, UCHAR LatencyTimer) {
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

    // notify reader thread that it can start to extract data
    //this->m_condVar.notify_one();

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

bool AccIIIListener::read_infinite() { return false;}

bool AccIIIListener::read_for(int readTime_ms) { 
    
    std::chrono::steady_clock::time_point begin;
    int i;
    bool noMoreData;

    noMoreData = !AD_OK;

    begin = std::chrono::steady_clock::now();
    auto int_ms = std::chrono::duration_cast<std::chrono::milliseconds>(begin - begin).count();

    do {
        read_once();
        Sleep(1);
        int_ms = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now() - begin).count();
        //std::cout << "Time difference = " << int_ms << "[ms]" << std::endl;
    } while (int_ms < readTime_ms);

    //std::cout << "time to flush the remaining data in USB" << std::endl;

    do {
        noMoreData = read_once();
    } while (AD_OK == noMoreData);

    return AD_OK;
}

bool AccIIIListener::read_once() {

    if (read_raw())
    {
        //std::cout << "read success with nb bytes = " << this->RxBytes << std::endl;
        addtoReceivedBytes(this->RxBuffer, this->RxBytes);
        return AD_OK;
    }
    else
        return !AD_OK;
}

std::deque<Byte> AccIIIListener::getReceivedBytes() {
    return this->receivedBytes;
}
