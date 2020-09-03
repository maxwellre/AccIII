/*
 * AccIIIDecoderMock.cpp
 *
 * Inherits from AccIIIDecoder.
 * Mock class to access protected content for Unit Tests.
 * 
 *  Created on: Aug 25, 2020
 *      Author: Basil Duvernoy
 */


#include "AccIIIDecoderMock.h"

void AccIIIDecoderMock::addtoAccData(std::deque<Byte> ByteQueue) {
	AccIIIDecoder::addtoAccData(ByteQueue);
}

int16_t AccIIIDecoderMock::uint16toint16(uint16_t i) {
	return AccIIIDecoder::uint16toint16(i);
}

uint16_t AccIIIDecoderMock::bytes2uint16(Byte h, Byte l) {
	return AccIIIDecoder::bytes2uint16(h,l);
}

uint8_t AccIIIDecoderMock::byte2uint8(Byte b) {
	return AccIIIDecoder::byte2uint8(b);
}

Byte AccIIIDecoderMock::uint2byte(uint8_t i) {
	return AccIIIDecoder::uint2byte(i);
}
