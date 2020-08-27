cmake_minimum_required (VERSION 2.6)

project (AccIIIListener)

set(INCLUDE_DIR ${CMAKE_SOURCE_DIR}/include)
set(SOURCES_DIR ${CMAKE_SOURCE_DIR}/src)
set(EXT_LIB_DIR ${CMAKE_SOURCE_DIR}/libs)

# --- Include directory ---
include_directories(${INCLUDE_DIR})

# --- External libraries ---
# add link to the library in the main cmakeLists file
if (WIN32)
	if (CMAKE_CL_64)
		set(FTD2XX_LIB_PATH ${EXT_LIB_DIR}/ftd2xx/win64)
	else ()
		set(FTD2XX_LIB_PATH ${EXT_LIB_DIR}/ftd2xx/win32)
	endif ()
endif (WIN32)
if (UNIX)
		set(FTD2XX_LIB_PATH ${EXT_LIB_DIR}/ftd2xx/unix)
endif (UNIX)
link_directories("${FTD2XX_LIB_PATH}")
add_subdirectory(${EXT_LIB_DIR})

# --- AccIII libraries ---
message("AccIII libraries")
add_library(DataProc ${SOURCES_DIR}/DataProc.cpp)
add_library(acciii ${SOURCES_DIR}/acciii.cpp)
if (WIN32)
	target_link_libraries (DataProc ftd2xx)
endif (WIN32)
if (UNIX)
	target_link_libraries (DataProc ftd2xx Threads::Threads)
endif (UNIX)

target_link_libraries (acciii ftd2xx DataProc)

# --- Main ---
set(CMAKE_BUILD_TYPE RelWithDebInfo)
add_executable(${PROJECT_NAME} AccIII_reformatUC.cpp)
target_link_libraries (${PROJECT_NAME} LINK_PUBLIC acciii)


