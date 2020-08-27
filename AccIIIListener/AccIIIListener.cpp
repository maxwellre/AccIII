/*
 * AccIIIListener.cpp
 *
 *  Created on: Aug 16, 2020
 *      Author: Basil Duvernoy
 */

#include <windows.h>
#include <iomanip>

#include "AccIIIListener/AccIIIDriver.h"
#include "AccIIIListener/FileManager.h"

using namespace std;

int main(int argc, char **argv) {

    AccIIIDriver* accDriver;
    //vector3D_int data;
    int i;
    bool nok, disp, disp_data, save_data;

    disp = 0;
    disp_data = 1;
    save_data = 0;

    accDriver  = new AccIIIDriver();

    nok = accDriver->ft_open();
    if (nok) {
        std::cerr << "Couldn't open the session." << std::endl;
        return 1;
    }
    else
        std::cout << "Session opened..." << std::endl;
    
    for (i = 0; i < 100; i++) {
        if (disp) std::cout << i << "," << std::flush;
        accDriver->read_once();
        Sleep(1);
    }
    if (disp) std::cout << std::endl;

    accDriver->end_read();

    nok = accDriver->ft_close();
    if (nok) {
        std::cerr << "Couldn't close the session." << std::endl;
        return 2;
    }
    else
        std::cout << "Session closed..." << std::endl;
    
    vector3D_int data = accDriver->getAccData();
    
    if (disp_data) {
        int s_start, s_end;

        s_start = 20;
        s_end = s_start + 4;
        std::cout << "[" << data.size() << "," << data[0].size() << "," << data[0][0].size() << "]" << std::endl;
        for (int t = 500; t < 1000; t++) {
            std::cout << setw(4) << t << "::" << std::flush;
           // int s = 10;

            for (int s = s_start; s < s_end; s++) {
                std::cout << "[" << setw(2) << s << "](" << std::flush;
                std::cout << setw(8) << data[t][s][0] << std::flush;
                std::cout << setw(8) << data[t][s][1] << std::flush;
                std::cout << setw(8) << data[t][s][2] << std::flush;
                std::cout << ")\t" << std::flush;
            }
            std::cout << std::endl;
        }
    }

    if (save_data) {
        FileManager* fm = new FileManager();
        int cpt = 0;
        std::string fbase = "test";
        std::string fext = ".csv";
        std::string fname = fbase + fext;

        if (fm->existFile(fname) == false) {
            fm->createFile(fname);
        }
        else {
            do {
                fname = fbase + to_string(cpt) + fext;
                cpt++;
            } while (fm->existFile(fname) != false);
            fm->createFile(fname);
        }

        fm->addToFile(fname, data);
    }

    

	return 0;
}


