/*
 * AccIIIDriverMock.cpp
 *
 * Inherits from AccIIIDriver.
 * Mock class to access protected content during Unit Tests.
 * 
 *  Created on: Aug 25, 2020
 *      Author: Basil Duvernoy
 */


#include "AccIIIListener/AccIIIDriverMock.h"

int AccIIIDriverMock::getRxBuffer_length() {
	return AccIIIDriver::getRxBuffer_length();
}

int AccIIIDriverMock::getRxBuffer_nbElem() {
	return AccIIIDriver::getRxBuffer_nbElem();
}

Byte* AccIIIDriverMock::getRxBuffer() {
	return AccIIIDriver::getRxBuffer();
}

void AccIIIDriverMock::addtoReceivedBytes(Byte* bp, long l = -1) {
	AccIIIDriver::addtoReceivedBytes(bp, l);
}

void AccIIIDriverMock::addtoReceivedBytes(Byte b) {
	AccIIIDriver::addtoReceivedBytes(b);
}

void AccIIIDriverMock::setReceivedBytes(std::deque<Byte> byteQueue) {
	AccIIIDriver::setReceivedBytes(byteQueue);
}

void AccIIIDriverMock::addtoAccData(std::deque<Byte> ByteQueue) {
	AccIIIDriver::addtoAccData(ByteQueue);
}

int16_t AccIIIDriverMock::uint16toint16(uint16_t i) {
	return AccIIIDriver::uint16toint16(i);
}

uint16_t AccIIIDriverMock::bytes2uint16(Byte h, Byte l) {
	return AccIIIDriver::bytes2uint16(h,l);
}

uint8_t AccIIIDriverMock::byte2uint8(Byte b) {
	return AccIIIDriver::byte2uint8(b);
}

Byte AccIIIDriverMock::uint2byte(uint8_t i) {
	return AccIIIDriver::uint2byte(i);
}
