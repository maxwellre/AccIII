#include <iostream>
#include <pthread.h>
#include <stdio.h>

#include "AccIIIListener/AccIIIDriver.h"

using namespace std;


int main(int argc, char **argv) {

    AccIIIDriver * accDriver = new AccIIIDriver();

    if (accDriver->ft_open())
        cout << "Couldn't open the session." << endl;
    else
        cout << "Hello world, opening the session..." << endl;

    #ifdef _WIN32
        cout << "Windows" << endl;
    #elif unix
        cout << "Unix" << endl;
    #else
        cout << "Other" << endl;
    #endif


    if (accDriver->ft_close())
        cout << "Couldn't close the session." << endl;
    else
        cout << "Goodbye world, closing the session..." << endl;

	return 0;
}
