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
#include <functional>
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

enum class StateThread { isnull, initialised, ready, running, finished, stoped, errorComm };

class AccIIIDriver2 {
private:
    // configuration variables
    AccIIIDecoder* a3d;
    AccIIIListener* a3l;
    int readTime;
    bool errorCommunication;

    // variable of transition between Listener and Decoder
    std::deque< Byte > byteStack;

    // Thread related
    std::mutex m_mutex;
    std::atomic<bool> workdone;
    std::thread listenerThread;
    std::thread decoderThread;
    StateThread masterState;
    StateThread listenerState;
    StateThread decoderState;

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

    /**------ Getters/Setters ----------------------------**/
    void setreadTime(int _readTime_ms);
    int getreadTime();
    void seterrorCommunication(bool b);

    /**------ byteStack Modifiers/Getters/Setters --------**/
    bool initbyteStack();

    void addtobyteStack(Byte* bp, long length = -1);
    void addtobyteStack(Byte b);

    bool removeFrombyteStack(long nbByte);
    std::deque< Byte > getFrombyteStack(long nbByte);
    int getbyteStack_length();

    /**------ Threads State Modifiers --------------------**/
    void setmasterState(StateThread value);
    void setlistenerState(StateThread value);
    void setdecoderState(StateThread value);
    void setState(StateThread* state_var, StateThread value);

    /**------ Threads State Getters ----------------------**/
    StateThread getmasterState();
    StateThread getlistenerState();
    StateThread getdecoderState();
    StateThread getState(StateThread* state_var);

    /**------ Threads State Checkers ---------------------**/
    bool is_master(StateThread st);
    bool is_listener(StateThread st);
    bool is_decoder(StateThread st);
    bool are_slaves(StateThread st);
    bool is_listenerDone();

public:

	AccIIIDriver2();
	virtual ~AccIIIDriver2();

    /**
    * @brief start listener and decoder threads for a certain period of time
    * @param number of milliseconds that the listener has to listen
    * @return return if an error has been raised during the initialisation
    */
    bool record(int _readTime_ms = 0);


    /**
    * @brief Close the listener and decoder threads
    * @return return if an error has been raised during the process
    */
    bool close();

    /**
    * @brief Get data recorded in a 3D vector of int format
    * @return 3-D vector of int based on : nbFrame x nbSensors x nbAxis
    */
    vector3D_int getData();

    /**
    * @brief error communication getter
    * @return return true if an communication error has been detected
    */
    bool geterrorCommunication();
};


#endif /* ACCIIIDRIVER2_H_ */
