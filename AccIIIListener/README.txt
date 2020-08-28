# Driver for the AccIII array
## Author: Basil Duvernoy
##
## Sensor Array developed by Yitian Shao, Yon Visell. RE TOUCH LAB, UC Santa Barbara. ([for more](http://re-touch-lab.com))
## Code based on the previously made driver by Yitian Shao ([GitHub](https://github.com/maxwellre/AccIII))

---

Project organization:
* include: headers developed for the driver
* libs: headers, dynamic and static libraries of third-party sources
* src: code developed for the driver
* tests: Unit Tests to ensure code quality

. Include/AccIIIListener folder:
.. AccIIIDriver.h: header of the Driver class;
.. AccIIIDriver_defines.h: constant definition and new types (included in accIIIDriver.h);
.. AccIIIDriverMock.h: header of a class inherited from AccIIIDriver; access to protected variables and methods for Unit Tests;
.. FileManager.h: header of the FileManager class.

. src folder:
.. AccIIIDriver.cpp: content of the Driver class;
.. AccIIIDriverMock.cpp: content of a class inherited from AccIIIDriver; access to protected variables and methods for Unit Tests;
.. FileManager.cpp: content of the FileManager class.

. libs folder:
.. ftd2xx.h: header of the FTDI USB driver;
.. libftd2xx.a and ftd2xx\win32\ftd2xx.lib and ftd2xx\win64\ftd2xx.lib: static libraries for Linux, Windows 32bits, Windows 64bits respectively
.. catch.hpp: header and content of the Catch2 library (Unit Tests)

. tests folder:
.. AccIIIDriver_test.cpp: content of the Unit tests for AccIIIDriver and FileManager

---

Software architecture:


---

Minimum requirements on Linux:
* CMake V 2.6
* C++11

Minimum requirements on Windows:
* CMake V 2.6
* C++11
* Install FTDI chip driver using the setup.exe ([FTDI drivers list](https://www.ftdichip.com/Drivers/D2XX.htm))







