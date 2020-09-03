/*
 * AccIIIDriverMock.h
 * 
 * Inherits from AccIIIDriver.
 * Mock class to access protected content during Unit Tests.
 * 
 *  Created on: Aug 25, 2020
 *      Author: Basil Duvernoy
 */

#ifndef ACCIIIDRIVERMOCK_H_
#define ACCIIIDRIVERMOCK_H_

#include "AccIIIDriver/AccIIIDriver.h"

class AccIIIDriverMock : public AccIIIDriver {
private:

protected:

public:

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
    bool areAfter_slaves(StateThread st);
    bool is_listenerDone();
};

#endif /* ACCIIIDRIVERMOCK_H_ */
