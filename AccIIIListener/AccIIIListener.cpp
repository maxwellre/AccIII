
#include <fstream>
#include <windows.h>

#include "AccIIIListener/AccIIIDriver.h"

using namespace std;

void savedata(std::deque<Byte> byteQueue);
std::deque<Byte> loaddata(std::string fn);

int main(int argc, char **argv) {

    AccIIIDriver* accDriver;
    vector3D_int data;
    int i;

    accDriver  = new AccIIIDriver();

    accDriver->ft_open()? cout << "Couldn't open the session." << endl : cout << "Session opened..." << endl;
    
    for (i = 0; i < 1000; i++) {
        //std::cout << i << "," << std::flush;
        accDriver->read_once();
        //accDriver->recentData_to_print();
        Sleep(1);
    }
    data = accDriver->getAccData();
    std::cout << "...getAccData" << std::endl;
    
    int nbsample = data.size();
    int nbsensor = data[0].size();
    int nbaxis = data[0][0].size();

    if (1) {
        std::cout << " nbsample: " << nbsample << std::endl;
        std::cout << " nbsensor: " << nbsensor << std::endl;
        std::cout << " nbaxis: " << nbaxis << std::endl;
    }
    if (0) {
        std::cout << " ACCIII_NB_SENSORS: " << ACCIII_NB_SENSORS << std::endl;
        std::cout << " ACCIII_NB_SENSORSPERGROUP: " << ACCIII_NB_SENSORSPERGROUP << std::endl;
        std::cout << " ACCIII_NB_AXIS: " << ACCIII_NB_AXIS << std::endl;
        std::cout << " ACCIII_NB_BYTEPERVALUE: " << ACCIII_NB_BYTEPERVALUE << std::endl;
        std::cout << " ACCIII_NB_BYTEPERGROUP: " << ACCIII_NB_BYTEPERGROUP << std::endl;
        std::cout << " ACCIII_NB_BYTEPERSAMPLE: " << ACCIII_NB_BYTEPERFRAME << std::endl;
        std::cout << " ACCIII_OFFSET_HIGHBYTE: " << ACCIII_OFFSET_HIGHBYTE << std::endl;
        std::cout << " ACCIII_VALUE_MAX: " << ACCIII_VALUE_MAX << std::endl;
        std::cout << " ACCIII_VALUE_MID: " << ACCIII_VALUE_MID << std::endl;
    }
    if (1) {
        for (int t = 0; t < 200; t++) {
            for (int s = 0; s < 3; s++) {
                std::cout << data[t][s][0] << "\t" << data[t][s][1] << "\t" << data[t][s][2] << " \t\t" << std::flush;
            }
            std::cout << std::endl;
        }
    }
    if (1)
    {
        ofstream myfile;
        myfile.open("example.csv");
        for (int t = 0; t < nbsample; t++) {
            for (int s = 0; s < nbsensor; s++) {
                myfile << data[t][s][0] << "," << data[t][s][1] << "," << data[t][s][2] << "," << std::flush;
            }
            myfile << std::endl;
        }
        myfile.close();
    }
    if (0) {
        savedata(accDriver->getReceivedBytes());
    }

    accDriver->ft_close()? cout << "Couldn't close the session." << endl : cout << "Session closed..." << endl;

	return 0;
}



void savedata(std::deque<Byte> byteQueue) {

    FILE* fp;

    errno_t err;
    if ((err = fopen_s(&fp, "data.bin", "wb")) != 0) {
        perror("The file was not opened\n");
    }
    else {
        printf("The file was opened\n");
    }

    long dwSum = byteQueue.size();
    unsigned char* fileBuffer = NULL;
    fileBuffer = new unsigned char[dwSum];
    int cpt = 0;

    while (byteQueue.size()) {
        fileBuffer[cpt++] = byteQueue.front();
        byteQueue.pop_front();
    }

    fwrite(fileBuffer, sizeof(byte), dwSum, fp);
    fclose(fp);
}

std::deque<Byte> loaddata(std::string fn) {

    std::deque<Byte> byteQueue;

    FILE* file = fopen(fn.c_str(), "r+");
    if (file == NULL) return byteQueue;
    fseek(file, 0, SEEK_END);
    long int size = ftell(file);
    fclose(file);
    // Reading data to array of unsigned chars
    file = fopen(fn.c_str(), "r+");
    unsigned char* in = (unsigned char*)malloc(size);
    int bytes_read = fread(in, sizeof(unsigned char), size, file);
    fclose(file);


    for (int i = 0; i < size; i++) {
        byteQueue.push_back(in[i]);
    }

    return byteQueue;
}
