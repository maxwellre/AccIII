/*
 * AccIIIDriver2.h
 *
 *  Created on: Sep 02, 2020
 *      Author: Basil Duvernoy
 */

#ifndef ACCIIIDRIVER2_H_
#define ACCIIIDRIVER2_H_

#include <algorithm>    // std::copy
#include <atomic>
#include <chrono>
#include <cmath>
#include <errno.h>
#include <iostream>
#include <limits>       // std::numeric_limits
#include <queue>        // std::deque
#include <stdio.h>
#include <string>

#ifdef _WIN32
#include <condition_variable>
#include <mutex>                // std::mutex, std::unique_lock
#include <thread>
#include <windows.h>
#endif

#ifdef linux
#include <pthread.h>
#endif

#include "AccIIIDriver_defines.h"

#include "AccIIIDecoder.h"
#include "AccIIIListener.h"


class AccIIIDriver2 {
private:
    // configuration variables
    AccIIIDecoder* a3d;
    AccIIIListener* a3l;
    int readTime;

    // Thread related
    std::mutex m_mutex;
    std::condition_variable m_condVar;
    std::atomic<bool> workdone;

    bool listenerThread_ready;
    bool decoderThread_ready;

    std::thread listenerThread;
    std::thread decoderThread;

    /**
     * @brief job that the reader thread will do.
     */
    bool listenerThread_job();

    /**
     * @brief job that the decoder thread will do.
     */
    bool decoderThread_job();

    bool is_jobdone();

    
protected:
    // Protected for Unit Test (Mock class) 


public:

	AccIIIDriver2(int readTime_ms = -1);
	virtual ~AccIIIDriver2();

    void initialise();
    void startRecording();

};


#endif /* ACCIIIDRIVER2_H_ */
