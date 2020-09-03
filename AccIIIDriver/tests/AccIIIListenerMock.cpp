/*
 * AccIIIListenerMock.cpp
 *
 * Inherits from AccIIIListener.
 * Mock class to access protected content for Unit Tests.
 * 
 *  Created on: Aug 25, 2020
 *      Author: Basil Duvernoy
 */


#include "AccIIIListenerMock.h"

int AccIIIListenerMock::getRxBuffer_length() {
	return AccIIIListener::getRxBuffer_length();
}

int AccIIIListenerMock::getRxBuffer_nbElem() {
	return AccIIIListener::getRxBuffer_nbElem();
}

Byte* AccIIIListenerMock::getRxBuffer() {
	return AccIIIListener::getRxBuffer();
}
