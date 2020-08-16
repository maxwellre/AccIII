cmake_minimum_required (VERSION 2.6)

project (AccIIIReader)

set(INCLUDE_DIR ${CMAKE_SOURCE_DIR}/include)
set(SOURCES_DIR ${CMAKE_SOURCE_DIR}/src)
set(EXT_LIB_DIR ${CMAKE_SOURCE_DIR}/libs)

# --- Include directory ---
include_directories(${INCLUDE_DIR})

# --- External libraries ---
find_package(Threads REQUIRED)

# --- External static libraries ---
add_library(ftd2xx STATIC IMPORTED)
set_target_properties(ftd2xx PROPERTIES IMPORTED_LOCATION ${EXT_LIB_DIR}/libftd2xx.a)

# --- AccIII libraries ---
add_library(AccIIIDriver ${SOURCES_DIR}/AccIIIDriver.cpp)
target_link_libraries (AccIIIDriver ftd2xx Threads::Threads)

# --- Main ---
set(CMAKE_BUILD_TYPE RelWithDebInfo)
add_executable(${PROJECT_NAME} AccIIIReader.cpp)
target_link_libraries (${PROJECT_NAME} LINK_PUBLIC AccIIIDriver)

