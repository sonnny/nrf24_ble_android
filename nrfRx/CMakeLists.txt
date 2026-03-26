cmake_minimum_required(VERSION 3.12)
set(PICO_SDK_PATH "/home/sonny/pico/pico-sdk")
include("${PICO_SDK_PATH}/external/pico_sdk_import.cmake")
set(CMAKE_CXX_STANDARD 17)
project(nrf_receive)  
pico_sdk_init()
add_executable(nrf_receive main.c) 

target_link_libraries(nrf_receive
pico_stdlib
hardware_spi)

pico_enable_stdio_usb(nrf_receive 1)

pico_add_extra_outputs(nrf_receive)
