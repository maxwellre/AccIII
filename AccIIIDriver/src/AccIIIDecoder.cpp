/*
 * AccIIIDecoder.cpp
 *
 *  Created on: Aug 16, 2020
 *      Author: Basil Duvernoy
 */

#include "AccIIIDriver/AccIIIDecoder.h"

AccIIIDecoder::AccIIIDecoder() {
    this->accData = vector3D_int();
}

AccIIIDecoder::~AccIIIDecoder() {

}


/**
   ------ PRIVATE ------------------------------------
**/

vector3D_int AccIIIDecoder::decode(std::deque<Byte> byteQueue) {

    std::deque<Byte> byteQueue_frame;
    std::deque<Byte>::iterator it_start, it_end;
    int s, frameOffset, nbCompletedFrames, nbbyteframe;

    // get the number of frames
    nbbyteframe = ACCIII_NB_BYTEPERFRAME; // unexpected behavior when directly used in the operation
    nbCompletedFrames = (int)byteQueue.size() / nbbyteframe;
    if ( (0 < nbCompletedFrames) && (byteQueue.size() % nbbyteframe) ) {
        // remove last frame if incomplete
        nbCompletedFrames--;
    }

    // init result variable
    vector3D_int accData_all(nbCompletedFrames, vector2D_int(ACCIII_NB_SENSORS, std::vector<int16_t>(ACCIII_NB_AXIS)));

    for (s = 0; s < nbCompletedFrames; s++) {
        // for each frame, get the decoded data

        frameOffset = s * nbbyteframe;

        it_start = byteQueue.begin() + frameOffset;
        it_end = it_start + nbbyteframe;

        byteQueue_frame.assign(it_start, it_end);

        decode_frame(&accData_all[s], byteQueue_frame);
    }

    return accData_all;
}

vector2D_int* AccIIIDecoder::decode_frame(vector2D_int* dataFrame, std::deque<Byte> byteQueue_frame) {

    Byte highByte, lowByte;
    int a, s, g;
    int sensor_ID, highByte_ID, lowByte_ID;
    int offsetGroup;

    // get position of the current frame
    for (g = 0; g < ACCIII_NB_GROUP; g++) {
        // care about odd ID sensors first, then even ID sensors
        offsetGroup = g * ACCIII_NB_BYTEPERGROUP;

        for (s = 0; s < ACCIII_NB_SENSORSPERGROUP; s++) {
            // for each sensor of the current group (odd // even)
            sensor_ID = s * ACCIII_NB_GROUP + g;

            for (a = 0; a < ACCIII_NB_AXIS; a++) {
                // Axis X, Y, Z
                // chosen frame + chosen group + chosen sensor + chosen axis
                lowByte_ID = s + a * ACCIII_OFFSET_AXIS + offsetGroup;

                // based on the lowByteID, get HighByteID with the offset of the group sensor size
                highByte_ID = lowByte_ID + ACCIII_OFFSET_HIGHBYTE;

                highByte = byteQueue_frame[highByte_ID];
                lowByte = byteQueue_frame[lowByte_ID];

                (*dataFrame)[sensor_ID][a] = uint16toint16(bytes2uint16(highByte, lowByte));
            }
        }
    }

    return dataFrame;
}


/**
   ------ PROTECTED ----------------------------------
**/

long AccIIIDecoder::addtoAccData(std::deque<Byte> ByteQueue) {

    vector3D_int data = decode(ByteQueue);
    this->accData.insert(std::end(this->accData), std::begin(data), std::end(data));

    return data.size() * data[0].size() * data[0][0].size();
}

int16_t AccIIIDecoder::uint16toint16(uint16_t i) {
    return (int16_t)i;
}

uint16_t AccIIIDecoder::bytes2uint16(Byte h, Byte l) {
    return (uint16_t)(byte2uint8(h) << 8 | byte2uint8(l));
}

uint8_t AccIIIDecoder::byte2uint8(Byte b) {
    return (uint8_t)b;
}

Byte AccIIIDecoder::uint2byte(uint8_t i) {
    return (Byte)i;
}


/**
   ------ PUBLIC -------------------------------------
**/

vector3D_int AccIIIDecoder::getAccData() {
    return this->accData;
}
