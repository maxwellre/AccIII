/*
 * AccIII_example.cpp
 *
 *  Created on: Aug 16, 2020
 *      Author: Basil Duvernoy
 */

#include <iomanip>
#include <time.h>

#ifdef _WIN32
#include <windows.h>
#endif

#ifdef linux
#include <pthread.h>
#endif

#include "AccIIIDriver/AccIIIDriver.h"
#include "AccIIIDriver/FileManager.h"

#include "AccIIIDriver/AccIIIDriver2.h"

using namespace std;

bool basic();
bool basic_period();
bool basic_thread();
bool advance_thread();

int main(int argc, char **argv) {

    //basic();
    //basic_period();
    //basic_thread();
    advance_thread();

    return 0;
}

bool advance_thread() {

    AccIIIDriver2* accDriver;
    
    accDriver = new AccIIIDriver2();

    accDriver->initialise();

    Sleep(1000);

    accDriver->startRecording();

    Sleep(1000);

    return AD_OK;
}

bool basic_thread() {

    AccIIIDriver* accDriver;
    accDriver = new AccIIIDriver();

    /*
    if (AD_OK != accDriver->ft_open()) {
        std::cerr << "Couldn't open the session." << std::endl;
        return 1;
    }
    else
        std::cout << "Session opened..." << std::endl;

    if (AD_OK != accDriver->ft_startCommunication()) {
        std::cerr << "Couldn't start the communication." << std::endl;
        return 1;
    }
    else
        std::cout << "Communication started..." << std::endl;

        */
    if (AD_OK != accDriver->ft_close()) {
        std::cerr << "Couldn't close the session." << std::endl;
        return 3;
    }
    else
        std::cout << "Session closed..." << std::endl;
}


bool basic_period() {

    AccIIIDriver* accDriver; 
    int i, readTime_ms;
    bool disp_data, save_data;

    readTime_ms = 1 * 1000;

    disp_data = 1;
    save_data = 0;

    accDriver = new AccIIIDriver();

    if (AD_OK != accDriver->ft_open()) {
        std::cerr << "Couldn't open the session." << std::endl;
        return 1;
    }
    else
        std::cout << "Session opened..." << std::endl;

    if (AD_OK != accDriver->ft_startCommunication()) {
        std::cerr << "Couldn't start the session." << std::endl;
        return 1;
    }
    else
        std::cout << "Session started..." << std::endl;

    if (AD_OK != accDriver->read_for(readTime_ms)) {
        std::cout << "read_for failed..." << std::endl;
        return 2;
    }
    
    if (AD_OK != accDriver->ft_close()) {
        std::cerr << "Couldn't close the session." << std::endl;
        return 3;
    }
    else
        std::cout << "Session closed..." << std::endl;

    if (disp_data) {
        vector3D_int data = accDriver->getAccData();
        int s_start, s_end;

        s_start = 10;
        s_end = s_start + 4;

        std::cout << "[" << data.size() << "," << data[0].size() << "," << data[0][0].size() << "]" << std::endl;
        for (int t = 0; t < data.size(); t++) {
            std::cout << setw(4) << t << "::" << std::flush;

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
        vector3D_int data = accDriver->getAccData();
        FileManager* fm = new FileManager();

        fm->createFile();
        fm->addToFile(data);
    }
}



bool basic() {

    AccIIIDriver* accDriver;
    int i;
    bool disp_data, save_data;

    disp_data = 1;
    save_data = 0;

    accDriver = new AccIIIDriver();

    if (AD_OK != accDriver->ft_open()) {
        std::cerr << "Couldn't open the session." << std::endl;
        return 1;
    }
    else
        std::cout << "Session opened..." << std::endl;

    if (AD_OK != accDriver->ft_startCommunication()) {
        std::cerr << "Couldn't start the session." << std::endl;
        return 1;
    }
    else
        std::cout << "Session started..." << std::endl;


    for (i = 0; i < 100; i++) {
        accDriver->read_once();
        Sleep(1);
    }
    accDriver->end_read();

    if (AD_OK != accDriver->ft_close()) {
        std::cerr << "Couldn't close the session." << std::endl;
        return 2;
    }
    else
        std::cout << "Session closed..." << std::endl;


    if (disp_data) {
        vector3D_int data = accDriver->getAccData();
        int s_start, s_end;

        s_start = 10;
        s_end = s_start + 4;

        std::cout << "[" << data.size() << "," << data[0].size() << "," << data[0][0].size() << "]" << std::endl;
        for (int t = 500; t < 1000; t++) {
            std::cout << setw(4) << t << "::" << std::flush;

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
        vector3D_int data = accDriver->getAccData();
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

        fm->addToFile(data, fname);
    }
}
