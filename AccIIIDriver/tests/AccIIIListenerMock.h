/*
 * AccIIIListenerMock.h
 * 
 * Inherits from AccIIIListener.
 * Mock class to access protected content for Unit Tests.
 * 
 *  Created on: Aug 25, 2020
 *      Author: Basil Duvernoy
 */

#ifndef ACCIIILISTENERMOCK_H_
#define ACCIIILISTENERMOCK_H_

#include "AccIIIDriver/AccIIIListener.h"

class AccIIIListenerMock : public AccIIIListener {
private:

protected:

public:

    /**------ RxBuffer Modifiers -------------------------**/
    int getRxBuffer_length();
    int getRxBuffer_nbElem();
    Byte* getRxBuffer();
};

#endif /* ACCIIILISTENERMOCK_H_ */
