# importing ftd2xx library for FPGA control communication
if (WIN32)
	add_library(ftd2xx STATIC IMPORTED)
	# the dll must be placed in the C:/Windows/system32 directory by runing the FTD Setup.exe driver installer
	set_target_properties(ftd2xx PROPERTIES IMPORTED_LOCATION libftd2xx.dll)
endif (WIN32)
if (UNIX)
	find_package(Threads REQUIRED)
    add_library(ftd2xx STATIC IMPORTED)
    set_target_properties(ftd2xx PROPERTIES IMPORTED_LOCATION libftd2xx.a)
endif (UNIX)


