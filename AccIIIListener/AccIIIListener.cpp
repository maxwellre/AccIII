#include <windows.h>

#include "AccIIIListener/AccIIIDriver.h"

using namespace std;

int main(int argc, char **argv) {

    int i;

    AccIIIDriver * accDriver = new AccIIIDriver();

    accDriver->ft_open()? cout << "Couldn't open the session." << endl : cout << "Opening the session..." << endl;
    
    for (i = 0; i < 1000; i++) {
        //std::cout << i << "," << std::flush;
        accDriver->read_once();
        //accDriver->recentData_to_print();
        Sleep(1);
    }
    std::cout << std::endl;
    std::cout << std::endl;

    accDriver->read_end();
    vector3D_int data = accDriver->getAccData();

    int nbsample = data.size();
    int nbsensor = data[0].size();
    int nbaxis = data[0][0].size();

    if (0) {
        std::cout << " ACCIII_NB_SENSORS: " << ACCIII_NB_SENSORS << std::endl;
        std::cout << " ACCIII_NB_SENSORSPERGROUP: " << ACCIII_NB_SENSORSPERGROUP << std::endl;
        std::cout << " ACCIII_NB_AXIS: " << ACCIII_NB_AXIS << std::endl;
        std::cout << " ACCIII_NB_BYTEPERVALUE: " << ACCIII_NB_BYTEPERVALUE << std::endl;
        std::cout << " ACCIII_NB_BYTEPERGROUP: " << ACCIII_NB_BYTEPERGROUP << std::endl;
        std::cout << " ACCIII_NB_BYTEPERSAMPLE: " << ACCIII_NB_BYTEPERSAMPLE << std::endl;
        std::cout << " ACCIII_OFFSET_HIGHBYTE: " << ACCIII_OFFSET_HIGHBYTE << std::endl;
        std::cout << " ACCIII_VALUE_MAX: " << ACCIII_VALUE_MAX << std::endl;
        std::cout << " ACCIII_VALUE_MID: " << ACCIII_VALUE_MID << std::endl;
    }
    else {
        for (int t = 0; t < nbsample; t++) {
            for (int s = 0; s < 3; s++) {
                std::cout << data[t][s][0] << "\t" << data[t][s][1] << "\t" << data[t][s][2] << " \t\t" << std::flush;
            }
            std::cout << std::endl;
        }

    }

    accDriver->ft_close()? cout << "Couldn't close the session." << endl : cout << "Closing the session..." << endl;

	return 0;
}
