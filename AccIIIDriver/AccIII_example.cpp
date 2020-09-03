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

#include "AccIIIDriver/FileManager.h"

#include "AccIIIDriver/AccIIIDriver2.h"

using namespace std;

bool advance_thread();
bool advance_thread_infinite();

int main(int argc, char **argv) {
    int errorRaised;

    errorRaised = false;

    //errorRaised = advance_thread();
    errorRaised = advance_thread_infinite();

    return errorRaised;
}

bool advance_thread_infinite() {

    AccIIIDriver2* accDriver;
    bool disp_data;

    accDriver = new AccIIIDriver2();
    disp_data = 1;

    if (AD_OK != accDriver->record(50000)) {
        // Must join both thread before leaving
        accDriver->close();
        return !AD_OK;
    }

    Sleep(100);
    if (accDriver->geterrorCommunication()) {
        // Must join both thread before leaving
        accDriver->close();
        return !AD_OK;
    }

    if (disp_data) {
        int curr_start_idx, s_start, s_end;
        vector3D_int data = vector3D_int();

        curr_start_idx = 0;
        s_start = 10;
        s_end = s_start + 4;

        while (1) {
            data = accDriver->getData();

            if (data.empty()) {
                Sleep(10);
                continue;
            }

            //std::cout << "[" << data.size() << "," << data[0].size() << "," << data[0][0].size() << "]" << std::endl;
            for (int t = curr_start_idx; t < data.size(); t+=5) {
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

            curr_start_idx = data.size();
        }
        
    }


    if (AD_OK != accDriver->close()) {
        // Must join both thread before leaving
        return !AD_OK;
    }

    return AD_OK;
}

bool advance_thread() {

    AccIIIDriver2* accDriver;
    bool disp_data;

    accDriver = new AccIIIDriver2();
    disp_data = 1;

    if (AD_OK != accDriver->record(1000)) {
        // Must join both thread before leaving
        accDriver->close();
        return !AD_OK;
    }

    if (AD_OK != accDriver->close()) {
        // Must join both thread before leaving
        return !AD_OK;
    }


    if (disp_data) {
        vector3D_int data = accDriver->getData();
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

    return AD_OK;
}
