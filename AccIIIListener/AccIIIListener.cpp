#include <windows.h>

#include "AccIIIListener/AccIIIDriver.h"

using namespace std;

int main(int argc, char **argv) {

    int i;

    AccIIIDriver * accDriver = new AccIIIDriver();

    accDriver->ft_open()? cout << "Couldn't open the session." << endl : cout << "Opening the session..." << endl;
    
    for (i = 0; i < 100; i++) {
        accDriver->read_once();
        //std::cout << accDriver->lastData_to_print() << std::flush;
        accDriver->lastData_to_print();
        std::cout << std::endl;
        Sleep(10);
    }
    std::cout << std::endl;

    accDriver->ft_close()? cout << "Couldn't close the session." << endl : cout << "Closing the session..." << endl;

	return 0;
}
