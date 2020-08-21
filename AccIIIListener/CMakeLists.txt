cmake_minimum_required (VERSION 2.6)

project (AccIIIListener)

set(INCLUDE_DIR ${CMAKE_SOURCE_DIR}/include)
set(SOURCES_DIR ${CMAKE_SOURCE_DIR}/src)
set(EXT_LIB_DIR ${CMAKE_SOURCE_DIR}/libs)

# --- Include directory ---
include_directories(${INCLUDE_DIR})

# --- External libraries ---
link_directories("${PROJECT_SOURCE_DIR}/libs")
add_subdirectory(${EXT_LIB_DIR})

# --- AccIII libraries ---
add_library(AccIIIDriver ${SOURCES_DIR}/AccIIIDriver.cpp)
if (WIN32)
	target_link_libraries (AccIIIDriver ftd2xx)
endif (WIN32)
if (UNIX)
	target_link_libraries (AccIIIDriver ftd2xx Threads::Threads)
endif (UNIX)

# --- Main ---
set(CMAKE_BUILD_TYPE RelWithDebInfo)
add_executable(${PROJECT_NAME} AccIIIListener.cpp)
target_link_libraries (${PROJECT_NAME} LINK_PUBLIC AccIIIDriver)

