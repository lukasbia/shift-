cmake_minimum_required(VERSION 3.25)

project(Shift
    VERSION 0.1.0
    LANGUAGES C CXX Swift
)

set(CMAKE_C_STANDARD 17)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(ShiftDriver)
