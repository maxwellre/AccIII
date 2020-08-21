if (WIN32)
	add_library(ftd2xx STATIC IMPORTED)
	set_target_properties(ftd2xx PROPERTIES IMPORTED_LOCATION libftd2xx.dll)
endif (WIN32)
if (UNIX)
	find_package(Threads REQUIRED)
    add_library(ftd2xx STATIC IMPORTED)
    set_target_properties(ftd2xx PROPERTIES IMPORTED_LOCATION libftd2xx.a)
endif (UNIX)


