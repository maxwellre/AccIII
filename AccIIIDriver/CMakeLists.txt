cmake_minimum_required (VERSION 2.6)

project (AccIIIDriver_project)

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

add_library(AccIIIListener ${SOURCES_DIR}/AccIIIListener.cpp)
target_link_libraries (AccIIIListener ftd2xx)

add_library(AccIIIDecoder ${SOURCES_DIR}/AccIIIDecoder.cpp)

add_library(AccIIIDriver ${SOURCES_DIR}/AccIIIDriver.cpp)
target_link_libraries (AccIIIDriver ftd2xx)

add_library(AccIIIDriver2 ${SOURCES_DIR}/AccIIIDriver2.cpp)
target_link_libraries (AccIIIDriver2 ftd2xx AccIIIListener AccIIIDecoder)

add_library(FileManager ${SOURCES_DIR}/FileManager.cpp)

# --- Main ---
set(CMAKE_BUILD_TYPE RelWithDebInfo)
add_executable(${PROJECT_NAME} AccIII_example.cpp)
target_link_libraries (${PROJECT_NAME} LINK_PUBLIC AccIIIDriver AccIIIDriver2 FileManager)


# --- AccIII Tests libraries ---
#add_library(AccIIIDriverMock ${SOURCES_DIR}/AccIIIDriverMock.cpp)
#target_link_libraries (AccIIIDriverMock ftd2xx AccIIIDriver)
#target_link_libraries (AccIIIDriverMock ftd2xx AccIIIDriver)

#add_executable(${PROJECT_NAME}_test tests/AccIIIDriver_test.cpp)
#target_link_libraries (${PROJECT_NAME}_test LINK_PUBLIC AccIIIDriverMock FileManager)