/*
 * AccIIIDecoder.h
 *
 *  Created on: Aug 16, 2020
 *      Author: Basil Duvernoy
 */

#ifndef ACCIIIDECODER_H_
#define ACCIIIDECODER_H_

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

#include "AccIIIDriver_defines.h"

class AccIIIDecoder {
private:

    // Infinite resizable buffer of RxBuffer
    std::deque< Byte > receivedBytes;

    // Organized data
    std::vector<int> decode_idx;
    vector3D_int accData;

    /**
     * @brief decode byteQueue by frame, sensors and axis in a 3D vector.
     * @param byteQueue The queue of byte that has to be converted.
     * @return the 3-D vector with X,Y,Z values of each sensor for each frame.
     */
    vector3D_int decode(std::deque<Byte> byteQueue);

    /**
     * @brief decode byteQueue for each axis of each accelerometer for one frame
     * based on the manner FTD2XX device communication protocol.
     * @param dataFrame Pointer to a 2-D vector to get the results;
     * @param byteQueue Queue of the size of a frame.
     */
    vector2D_int* decode_frame(vector2D_int* dataFrame, std::deque<Byte> byteQueue_frame);

    bool pop();
    bool pop_once(int offset = 0);

protected:
    // Protected for Unit Test (Mock class) 

    /**------ AccData Modifiers --------------------------**/
    /*
    * @return the number of new values in accData
    */
    long addtoAccData(std::deque<Byte> ByteQueue);

    /**------ Type Converters ----------------------------**/
    int16_t uint16toint16(uint16_t i);
    uint16_t bytes2uint16(Byte h, Byte l);
    uint8_t byte2uint8(Byte b);
    Byte uint2byte(uint8_t i);


public:

	AccIIIDecoder();
	virtual ~AccIIIDecoder();

    vector3D_int getAccData();
};


#endif /* ACCIIIDECODER_H_ */
