/*
 * AccIIIDriver.cpp
 *
 *  Created on: Sep 02, 2020
 *      Author: Basil Duvernoy
 */

#include "AccIIIDriver/AccIIIDriver2.h"


AccIIIDriver2::AccIIIDriver2() {

    initbyteStack();

    this->a3d = new AccIIIDecoder();
    this->a3l = new AccIIIListener();

    setmasterState(StateThread::initialised);
    setlistenerState(StateThread::initialised);
    setdecoderState(StateThread::initialised);

    this->listenerThread = std::thread(&AccIIIDriver2::listenerThread_job, this);
    this->decoderThread = std::thread(&AccIIIDriver2::decoderThread_job, this);
}

AccIIIDriver2::~AccIIIDriver2() {
    if (this->listenerThread.joinable()) {
        this->listenerThread.join();
    }
}



/**
   ------ PRIVATE ------------------------------------
**/

bool AccIIIDriver2::listenerThread_job() {

    std::chrono::steady_clock::time_point begin;
    int i, nbElem;
    bool noMoreData;

    noMoreData = !AD_OK;

    setlistenerState(StateThread::ready);

    while (!this->is_master(StateThread::running)) {
        // wait for master to ask for job
        Sleep(1);
    }

    setlistenerState(StateThread::running);

    if (AD_OK != this->a3l->ft_open()) {
        std::cerr << "Couldn't open the session." << std::endl;
        seterrorCommunication(true);
        setlistenerState(StateThread::errorComm);
        return !AD_OK;
    }
    else
        std::cout << "Session opened..." << std::endl;

    if (AD_OK != this->a3l->ft_startCommunication()) {
        std::cerr << "Couldn't start the communication." << std::endl;
        seterrorCommunication(true);
        setlistenerState(StateThread::errorComm);
        return !AD_OK;
    }
    else
        std::cout << "Communication started..." << std::endl;

    begin = std::chrono::steady_clock::now();
    auto int_ms = std::chrono::duration_cast<std::chrono::milliseconds>(begin - begin).count();

    do {
        Sleep(1);
        // read USB channel, if nothing has been received go to next iteration
        if (AD_OK != this->a3l->read_once())
            continue;
        // get the number of received bytes
        nbElem = (int)this->a3l->getRxBuffer_nbElem();
        // add the buffer to the byteStack value
        addtobyteStack(this->a3l->getRxBuffer(), nbElem);

        int_ms = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now() - begin).count();
        //std::cout << "Time difference = " << int_ms << "[ms]" << std::endl;
    } while (int_ms < this->readTime);


    do {
        noMoreData = this->a3l->read_once();
    } while (AD_OK == noMoreData);

    if (AD_OK != this->a3l->ft_close()) {
        std::cerr << "Couldn't close the session." << std::endl;
        seterrorCommunication(true);
        setlistenerState(StateThread::errorComm);
        return !AD_OK;
    }
    else
        std::cout << "Session closed..." << std::endl;

    setlistenerState(StateThread::finished);
	return AD_OK;
}

bool AccIIIDriver2::decoderThread_job() {
    
    std::deque< Byte > byteStack_local;
    int byteStack_len, nbFullFrameInStack, nbbyteframe;

    byteStack_len = 0;
    nbFullFrameInStack = 0;
    nbbyteframe = ACCIII_NB_BYTEPERFRAME; // unexpected behavior when directly used in the operation
    setdecoderState(StateThread::ready);

    while (!this->is_master(StateThread::running)) {
        // wait for master to ask for job
        Sleep(1);
    }
    setdecoderState(StateThread::running);

    while (!this->is_listenerDone() || (1 <= nbFullFrameInStack) ) {
        // listener is still running and/or at least a frame is inside the stack

        byteStack_len = getbyteStack_length();
        nbFullFrameInStack = byteStack_len / nbbyteframe;

        if (nbFullFrameInStack) {

            byteStack_local = getFrombyteStack(nbFullFrameInStack * nbbyteframe);
            removeFrombyteStack(nbFullFrameInStack * nbbyteframe);

            this->a3d->addtoAccData(byteStack_local);
        }

    }

    setlistenerState(StateThread::finished);
    
	return AD_OK;
}

bool AccIIIDriver2::is_jobdone() {

	return AD_OK;
}

/**
   ------ PROTECTED ----------------------------------
**/



void AccIIIDriver2::setreadTime(int _readTime_ms) {

    if (_readTime_ms < 0) {
        perror("readTime can't be below 0 millisecond. ");
    }
    else {
        this->readTime = _readTime_ms;
    }
}

int AccIIIDriver2::getreadTime() {
    return this->readTime;
}



void AccIIIDriver2::seterrorCommunication(bool b) {
    std::unique_lock<std::mutex> mlock(this->m_mutex);
    this->errorCommunication = b;
}

bool AccIIIDriver2::geterrorCommunication() {
    return this->errorCommunication;
}


bool AccIIIDriver2::initbyteStack() {

    std::deque< Byte > emptyQueue;
    std::swap(this->byteStack, emptyQueue);

    return AD_OK;
}

void AccIIIDriver2::addtobyteStack(Byte* bp, long length) {

    std::unique_lock<std::mutex> mlock(this->m_mutex);

    int i, stop;

    length ? stop = length : stop = bp[0];

    for (i = 0; i < stop; i++) {
        addtobyteStack(bp[i]);
    }
}

void AccIIIDriver2::addtobyteStack(Byte b) {
    this->byteStack.push_back(b);
}

bool AccIIIDriver2::removeFrombyteStack(long nbByte) {
    std::unique_lock<std::mutex> mlock(this->m_mutex);

    if (nbByte <= this->byteStack.size()) {
        this->byteStack.erase(this->byteStack.begin(), this->byteStack.begin() + nbByte);
        return AD_OK;
    }
    return !AD_OK;
}

std::deque< Byte > AccIIIDriver2::getFrombyteStack(long nbByte) {
    std::unique_lock<std::mutex> mlock(this->m_mutex);

    std::deque< Byte > subStack(this->byteStack.begin() , this->byteStack.begin()+nbByte);

    return subStack;
}

int  AccIIIDriver2::getbyteStack_length() {
    std::unique_lock<std::mutex> mlock(this->m_mutex);
    return this->byteStack.size();
}

void AccIIIDriver2::setmasterState(StateThread value) {
    setState(&(this->masterState), value);
}

void AccIIIDriver2::setlistenerState(StateThread value) {
    setState(&(this->listenerState), value);
}

void AccIIIDriver2::setdecoderState(StateThread value) {
    setState(&(this->decoderState), value);
}

void AccIIIDriver2::setState(StateThread* state_var, StateThread value) {
    std::lock_guard<std::mutex> lk(this->m_mutex); // locker to access shared variables
    *state_var = value;
}

bool AccIIIDriver2::is_master(StateThread st) {
    return st == getmasterState();
}

bool AccIIIDriver2::is_listener(StateThread st) {
    return st == getlistenerState();
}

bool AccIIIDriver2::is_decoder(StateThread st) {
    return st == getdecoderState();
}

bool AccIIIDriver2::are_slaves(StateThread st) {
    return (is_listener(st) && is_decoder(st));
}


bool AccIIIDriver2::is_listenerDone() {
    return (is_listener(StateThread::finished) 
        || is_listener(StateThread::stoped) 
        || is_listener(StateThread::errorComm) );
}

StateThread AccIIIDriver2::getmasterState() {
    return getState(&(this->masterState));
}

StateThread AccIIIDriver2::getlistenerState() {
    return getState(&(this->listenerState));
}

StateThread AccIIIDriver2::getdecoderState() {
    return getState(&(this->decoderState));
}

StateThread AccIIIDriver2::getState(StateThread* state_var) {
    //std::unique_lock<std::mutex> mlock(this->m_mutex);
    return *state_var;
}



/**
   ------ PUBLIC -------------------------------------
**/

bool AccIIIDriver2::record(int _readTime_ms) {

    setreadTime(_readTime_ms);

    while (!this->are_slaves(StateThread::ready)) {
        // wait for slaves being ready
        Sleep(1);
    }

    setmasterState(StateThread::running);

    if (geterrorCommunication()) {
        return !AD_OK;
    }
    return AD_OK;
}



bool AccIIIDriver2::close() {

    // waiting for threads to finish their jobs.
    this->listenerThread.join();
    this->decoderThread.join();

    /*
    for (int i = 0; i < this->byteStack.size(); i++) {
        std::cout << std::to_string((int)this->byteStack[i]) << std::flush;
    }
    std::cout << std::endl;
    */

    if (geterrorCommunication()) {
        return !AD_OK;
    }
    return AD_OK;
}


vector3D_int AccIIIDriver2::getData() {

    vector3D_int vData;


    vData = this->a3d->getAccData();



    return vData;
}









