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

#include "AccIIIDriver.h"

class AccIIIDriverMock : public AccIIIDriver {
private:

protected:

public:

    /**------ ReceivedBytes Modifiers --------------------**/
    void addtoReceivedBytes(Byte* bp, long l);
    void addtoReceivedBytes(Byte b);
    void setReceivedBytes(std::deque<Byte> byteQueue);

    /**------ AccData Modifiers --------------------------**/
    void addtoAccData(std::deque<Byte> ByteQueue);

    /**------ Type Converters ----------------------------**/
    int16_t uint16toint16(uint16_t i);
    uint16_t bytes2uint16(Byte h, Byte l);
    uint8_t byte2uint8(Byte b);
    Byte uint2byte(uint8_t i);

};

#endif /* ACCIIIDRIVERMOCK_H_ */
