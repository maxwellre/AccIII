/*
 * AccIIIListener.cpp
 *
 *  Created on: Aug 16, 2020
 *      Author: Basil Duvernoy
 */

#include <chrono>
#include <iomanip>
#include <time.h>
#include <windows.h>

#include "AccIIIListener/AccIIIDriver.h"
#include "AccIIIListener/FileManager.h"

using namespace std;

bool basic();
bool basic_period();

int main(int argc, char **argv) {


    FileManager* fm = new FileManager();
    std::cout << fm->getFileName() << std::endl;

    std::chrono::steady_clock::time_point begin = std::chrono::steady_clock::now();
    Sleep(1000);
    std::chrono::steady_clock::time_point end = std::chrono::steady_clock::now();

    std::cout << "Time difference = " << std::chrono::duration_cast<std::chrono::seconds>(end - begin).count() << "[s]" << std::endl;
    std::cout << "Time difference = " << std::chrono::duration_cast<std::chrono::milliseconds>(end - begin).count() << "[ms]" << std::endl;
    std::cout << "Time difference = " << std::chrono::duration_cast<std::chrono::microseconds>(end - begin).count() << "[us]" << std::endl;
    std::cout << "Time difference = " << std::chrono::duration_cast<std::chrono::nanoseconds> (end - begin).count() << "[ns]" << std::endl;

    //basic();
	basic_period();

	return 0;
}

bool basic_period() {

    AccIIIDriver* accDriver; 
    std::chrono::steady_clock::time_point begin, end;
    int i, readTime_ms;
    bool disp_data, save_data, noMoreData;

    noMoreData = !AD_OK;
    readTime_ms = 1 * 1000;

    disp_data = 1;
    save_data = 1;

    accDriver = new AccIIIDriver();

    if (AD_OK != accDriver->ft_open()) {
        std::cerr << "Couldn't open the session." << std::endl;
        return 1;
    }
    else
        std::cout << "Session opened..." << std::endl;


    begin = std::chrono::steady_clock::now();
    auto int_ms = std::chrono::duration_cast<std::chrono::milliseconds>(begin-begin).count();

    do {
        accDriver->read_once();
        Sleep(1);
        int_ms = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now() - begin).count();
        std::cout << "Time difference = " << int_ms << "[ms]" << std::endl;
    } while (int_ms < readTime_ms);
    
    std::cout << "time to flush the remaining data in USB" << std::endl;

    do {
        noMoreData = accDriver->read_once();
    } while (AD_OK == noMoreData);

    std::cout << "time to decode the data" << std::endl;
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
        int cpt = 0;

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
