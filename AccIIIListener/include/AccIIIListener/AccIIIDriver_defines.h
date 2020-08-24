#define ACCIII_NB_SENSORS 46
#define ACCIII_NB_GROUP 2
#define ACCIII_NB_AXIS 3
#define ACCIII_NB_BYTEPERVALUE 2

// number of bytes for one sample for all odd-or-even group sensors
#define ACCIII_NB_SENSORSPERGROUP ACCIII_NB_SENSORS/ACCIII_NB_GROUP
#define ACCIII_NB_BYTEPERGROUP ACCIII_NB_AXIS*ACCIII_NB_BYTEPERVALUE*ACCIII_NB_SENSORSPERGROUP
#define ACCIII_NB_BYTEPERSAMPLE ACCIII_NB_AXIS*ACCIII_NB_BYTEPERVALUE*ACCIII_NB_SENSORS

// Odd ID sensors Bytes sent first, then Even ID sensors; Low bytes sent first for the entire group, then High Bytes
#define ACCIII_OFFSET_HIGHBYTE ACCIII_NB_SENSORSPERGROUP

// 1 value = 2 Bytes = 0xFFFF = 65536 = 32768 * 2
#define ACCIII_VALUE_MAX 65536
#define ACCIII_VALUE_MID ACCIII_VALUE_MAX/2


