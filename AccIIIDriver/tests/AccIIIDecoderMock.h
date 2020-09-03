/*
 * AccIIIDecoderMock.h
 * 
 * Inherits from AccIIIListener.
 * Mock class to access protected content for Unit Tests.
 * 
 *  Created on: Aug 25, 2020
 *      Author: Basil Duvernoy
 */

#ifndef ACCIIIDECODERMOCK_H_
#define ACCIIIDECODERMOCK_H_

#include "AccIIIDriver/AccIIIDecoder.h"

class AccIIIDecoderMock : public AccIIIDecoder {
private:

protected:

public:

    /**------ AccData Modifiers --------------------------**/
    void addtoAccData(std::deque<Byte> ByteQueue);

    /**------ Type Converters ----------------------------**/
    int16_t uint16toint16(uint16_t i);
    uint16_t bytes2uint16(Byte h, Byte l);
    uint8_t byte2uint8(Byte b);
    Byte uint2byte(uint8_t i);

};

#endif /* ACCIIIDECODERMOCK_H_ */
