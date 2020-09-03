/*
 * AccIIIDriverMock.cpp
 *
 * Inherits from AccIIIDriver.
 * Mock class to access protected content during Unit Tests.
 * 
 *  Created on: Aug 25, 2020
 *      Author: Basil Duvernoy
 */


#include "AccIIIDriverMock.h"


void AccIIIDriverMock::setreadTime(int _readTime_ms) {
	AccIIIDriver::setreadTime(_readTime_ms);
}
int AccIIIDriverMock::getreadTime() {
	return AccIIIDriver::getreadTime();
}

void AccIIIDriverMock::seterrorCommunication(bool b) {
	AccIIIDriver::seterrorCommunication(b);
}

/**------ byteStack Modifiers/Getters/Setters --------**/
bool AccIIIDriverMock::initbyteStack() {
	return AccIIIDriver::initbyteStack();
}


void AccIIIDriverMock::addtobyteStack(Byte* bp, long length) {
	AccIIIDriver::addtobyteStack(bp, length);
}
void AccIIIDriverMock::addtobyteStack(Byte b) {
	AccIIIDriver:addtobyteStack(b);
}

bool AccIIIDriverMock::removeFrombyteStack(long nbByte) {
	return AccIIIDriver::removeFrombyteStack(nbByte);
}

std::deque< Byte > AccIIIDriverMock::getFrombyteStack(long nbByte) {
	return AccIIIDriver::getFrombyteStack(nbByte);
}

int AccIIIDriverMock::getbyteStack_length() {
	return AccIIIDriver::getbyteStack_length();
}

/**------ Threads State Modifiers --------------------**/
void AccIIIDriverMock::setmasterState(StateThread value) {
	AccIIIDriver::setmasterState(value);
}
void AccIIIDriverMock::setlistenerState(StateThread value) {
	AccIIIDriver::setlistenerState(value);
}
void AccIIIDriverMock::setdecoderState(StateThread value) {
	AccIIIDriver::setdecoderState(value);
}
void AccIIIDriverMock::setState(StateThread* state_var, StateThread value) {
	AccIIIDriver::setState(state_var, value);
}

/**------ Threads State Getters ----------------------**/
StateThread AccIIIDriverMock::getmasterState() {
	return AccIIIDriver::getmasterState();
}

StateThread AccIIIDriverMock::getlistenerState() {
	return AccIIIDriver::getlistenerState();
}

StateThread AccIIIDriverMock::getdecoderState() {
	return AccIIIDriver::getdecoderState();
}

StateThread AccIIIDriverMock::getState(StateThread* state_var) {
	return AccIIIDriver::getState(state_var);
}

/**------ Threads State Checkers ---------------------**/
bool AccIIIDriverMock::is_master(StateThread st) {
	return AccIIIDriver::is_master(st);
}

bool AccIIIDriverMock::is_listener(StateThread st) {
	return AccIIIDriver::is_listener(st);
}

bool AccIIIDriverMock::is_decoder(StateThread st) {
	return AccIIIDriver::is_decoder(st);
}

bool AccIIIDriverMock::are_slaves(StateThread st) {
	return AccIIIDriver::are_slaves(st);
}

bool AccIIIDriverMock::areAfter_slaves(StateThread st) {
	return AccIIIDriver::areAfter_slaves(st);
}

bool AccIIIDriverMock::is_listenerDone() {
	return AccIIIDriver::is_listenerDone();
}

