#ifndef ACCIII_H
#define ACCIII_H

#include "DataProc.h"

#include <assert.h>
#include <vector>

class Acciii
{
private:
    DWORD EventDWord;
    DWORD RxBytes;
    DWORD TxBytes;

    long dwSum;
    unsigned char* fileBuffer;

    //Number of data set acquired -----------------------------------------------
    int dataSetNum;     // data buffer has size dataSetNum*138
    int DataNum;        // Old version default: 1.159 secs
    float idDataRate;    // sampling rate;
    float sampleTime;

    //Decoding configuration parameters and variables
    const double GSCALE; // Unit coversion (0.73 mg/digit)
    const unsigned int READNUM; // For a single branch
    const unsigned int HALFREAD; // Half of readnum

    FT_HANDLE ftHandle;
    FT_STATUS ftStatus;


public:
    explicit Acciii();
    ~Acciii();

    void setSampleTime(float time);
    void sampleData();
    std::vector<std::vector<double>> decodeHeader(int headerSize);
    std::vector<std::vector<double>> decodeData();

    int returnDataSetNum();
    float returnIdDataRate();

};

#endif // ACCIII_H
