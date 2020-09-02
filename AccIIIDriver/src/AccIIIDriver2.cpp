/*
 * AccIIIDriver.cpp
 *
 *  Created on: Sep 02, 2020
 *      Author: Basil Duvernoy
 */

#include "AccIIIDriver/AccIIIDriver2.h"


AccIIIDriver2::AccIIIDriver2(int readTime_ms) {
	this->readTime = readTime_ms;

    this->a3d = new AccIIIDecoder();
    this->a3l = new AccIIIListener();

    this->listenerThread_ready = false;
    this->decoderThread_ready = false;

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
    int i;
    bool noMoreData;

    noMoreData = !AD_OK;

    this->listenerThread_ready = true;

    std::cout << "ready" << std::endl;

    std::unique_lock<std::mutex> ulock(this->m_mutex);
    this->m_condVar.wait(ulock);

    std::cout << "run" << std::endl;

    if (AD_OK != this->a3l->ft_open()) {
        std::cerr << "Couldn't open the session." << std::endl;
        return !AD_OK;
    }
    else
        std::cout << "Session opened..." << std::endl;


    if (AD_OK != this->a3l->ft_startCommunication()) {
        std::cerr << "Couldn't start the communication." << std::endl;
        return !AD_OK;
    }
    else
        std::cout << "Communication started..." << std::endl;


    begin = std::chrono::steady_clock::now();
    auto int_ms = std::chrono::duration_cast<std::chrono::milliseconds>(begin - begin).count();

    do {
        this->a3l->read_once();
        Sleep(1);
        int_ms = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now() - begin).count();
        //std::cout << "Time difference = " << int_ms << "[ms]" << std::endl;
    } while (int_ms < this->readTime);

    //std::cout << "time to flush the remaining data in USB" << std::endl;

    do {
        noMoreData = this->a3l->read_once();
    } while (AD_OK == noMoreData);


    if (AD_OK != this->a3l->ft_close()) {
        std::cerr << "Couldn't close the session." << std::endl;
        return 3;
    }
    else
        std::cout << "Session closed..." << std::endl;

	return AD_OK;
}

bool AccIIIDriver2::decoderThread_job() {

    this->decoderThread_ready = true;

	return AD_OK;
}

bool AccIIIDriver2::is_jobdone() {

	return AD_OK;
}

/**
   ------ PROTECTED ----------------------------------
**/


/**
   ------ PUBLIC -------------------------------------
**/

void AccIIIDriver2::initialise() {

    this->listenerThread = std::thread(&AccIIIDriver2::listenerThread_job, this);
    this->decoderThread = std::thread(&AccIIIDriver2::decoderThread_job, this);

    std::cout << "yolo." << std::endl;
}

void AccIIIDriver2::startRecording() {

    if (this->listenerThread_ready && this->decoderThread_ready) {
        std::cout << "bonjour" << std::endl;
        this->m_condVar.notify_one();
    }
    std::cout << "bonsoir" << std::endl;
    
}













