/*
 * AccIIIDriver.h
 *
 *  Created on: Aug 16, 2020
 *      Author: Basil Duvernoy
 */

#ifndef ACCIIIDRIVER_H_
#define ACCIIIDRIVER_H_

#include <errno.h>
#include <limits>
#include <pthread.h>
#include <stdio.h>

#include "../../libs/ftd2xx.h"

class AccIIIDriver {
private:

    FT_HANDLE ftHandle;
    FT_STATUS ftStatus;

public:
	AccIIIDriver();
	virtual ~AccIIIDriver();

    bool ft_open();
    bool ft_close();
};

#endif /* ACCIIIDRIVER_H_ */
