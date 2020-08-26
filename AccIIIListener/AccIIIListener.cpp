
#include <fstream>
#include <windows.h>

#include "AccIIIListener/AccIIIDriver.h"

using namespace std;

int main(int argc, char **argv) {

    AccIIIDriver* accDriver;
    vector3D_int data;
    int i;
    bool nok, disp, disp_data, save_data;

    disp = 0;
    disp_data = 0;
    save_data = 0;

    accDriver  = new AccIIIDriver();

    nok = accDriver->ft_open();
    nok ? cout << "Couldn't open the session." << endl : cout << "Session opened..." << endl;
    
    for (i = 0; i < 1000; i++) {
        if (disp) std::cout << i << "," << std::flush;
        accDriver->read_once();
        Sleep(1);
    }
    if (disp) std::cout << std::endl;

    nok = accDriver->ft_close();
    nok ? cout << "Couldn't close the session." << endl : cout << "Session closed..." << endl;
    
    data = accDriver->getAccData();

    if (disp_data) {
        for (int t = 0; t < 200; t++) {
            for (int s = 0; s < 3; s++) {
                std::cout << data[t][s][0] << "\t" << data[t][s][1] << "\t" << data[t][s][2] << " \t\t" << std::flush;
            }
            std::cout << std::endl;
        }
    }

    if (save_data) {
        ofstream myfile;
        myfile.open("example.csv");
        for (int t = 0; t < data[0].size(); t++) {
            for (int s = 0; s < data[0][0].size(); s++) {
                myfile << data[t][s][0] << "," << data[t][s][1] << "," << data[t][s][2] << "," << std::flush;
            }
            myfile << std::endl;
        }
        myfile.close();
    }

	return 0;
}


