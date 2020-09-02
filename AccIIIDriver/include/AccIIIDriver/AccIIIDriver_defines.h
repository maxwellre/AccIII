#include <vector>

typedef unsigned char Byte;
typedef std::vector< std::vector<int16_t> > vector2D_int;
typedef std::vector< vector2D_int > vector3D_int; 

#define ACCIII_NB_SENSORS 48
#define ACCIII_NB_GROUP 2
#define ACCIII_NB_AXIS 3
#define ACCIII_NB_BYTEPERSAMPLE 2

// number of bytes for one frame for all odd-or-even group sensors
#define ACCIII_NB_SENSORSPERGROUP ACCIII_NB_SENSORS/ACCIII_NB_GROUP
#define ACCIII_NB_BYTEPERGROUP ACCIII_NB_AXIS*ACCIII_NB_BYTEPERSAMPLE*ACCIII_NB_SENSORSPERGROUP
#define ACCIII_NB_BYTEPERFRAME ACCIII_NB_AXIS*ACCIII_NB_BYTEPERSAMPLE*ACCIII_NB_SENSORS

// Odd ID sensors Bytes sent first, then Even ID sensors; Low bytes sent first for the entire group, then High Bytes
#define ACCIII_OFFSET_HIGHBYTE ACCIII_NB_SENSORSPERGROUP
#define ACCIII_OFFSET_AXIS ACCIII_NB_SENSORSPERGROUP * ACCIII_NB_BYTEPERSAMPLE

// 1 value = 2 Bytes = 0xFFFF = 65535
#define ACCIII_UINT16_MAX 65535 //std::numeric_limits<uint16_t>::max()
// 1 value = 2 Bytes = 0x8000 = 32767
#define ACCIII_INT16_MAX 32767

#define AD_OK false



