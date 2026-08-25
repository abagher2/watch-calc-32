cmake_minimum_required(VERSION 3.29)
include($ENV{PICO_SDK_PATH}/external/pico_sdk_import.cmake)

set(CMAKE_Swift_COMPILATION_MODE wholemodule)
set(CMAKE_Swift_COMPILER_WORKS YES)

project(WatchCalcFirmware)
if(NOT DEFINED PICO_BOARD)
    set(PICO_BOARD pico)
endif()
pico_sdk_init()
enable_language(Swift)

if(PICO_BOARD STREQUAL "pico2")
    # The Swift 6.0 toolchain snapshot does not have the armv8m.main-none-none-eabihf stdlib precompiled.
    # We compile the Swift code as armv6m (Cortex-M0+) and soft-float, which the Cortex-M33 (RP2350) 
    # can run natively due to backwards compatibility.
    set(SWIFT_TARGET "armv6m-none-none-eabi") 
    list(APPEND CLANG_ARCH_ABI_FLAGS "-Xcc -mfloat-abi=soft")
else()
    set(SWIFT_TARGET "armv6m-none-none-eabi") # rp2040 (Cortex-M0+)
    list(APPEND CLANG_ARCH_ABI_FLAGS "-Xcc -mfloat-abi=soft")
endif()

file(GLOB RPN_CORE_SOURCES "../RPNCore/Sources/RPNCore/*.swift" "../RPNCore/Sources/RPNCore/Display/*.swift")
file(GLOB RATIONAL_SOURCES "../RPNCore/.build/checkouts/swift-rational/Sources/RationalModule/*.swift")
list(FILTER RATIONAL_SOURCES EXCLUDE REGEX "Rational\\+AlgebraicField\\.swift$")
file(GLOB FIRMWARE_SOURCES "*.swift" "core/*.swift" "display/*.swift")

add_executable(WatchCalcFirmware
    hardware_wrapper.c
    font_bitmaps.c
    missing_stubs.c
    ${FIRMWARE_SOURCES}
    ${RPN_CORE_SOURCES}
    ${RATIONAL_SOURCES}
)

target_compile_definitions(WatchCalcFirmware PRIVATE EMULATOR=1)
target_compile_options(WatchCalcFirmware PRIVATE $<$<COMPILE_LANGUAGE:Swift>:-DEMULATOR>)

set_target_properties(WatchCalcFirmware PROPERTIES LINKER_LANGUAGE CXX)
target_link_options(WatchCalcFirmware PRIVATE -Wl,--defsym=PICO_HEAP_SIZE=220000)

target_link_libraries(WatchCalcFirmware
    pico_stdlib hardware_spi hardware_gpio hardware_timer
)
pico_enable_stdio_uart(WatchCalcFirmware 1)
pico_enable_stdio_usb(WatchCalcFirmware 0)

set_target_properties(pico_standard_link PROPERTIES INTERFACE_COMPILE_OPTIONS "")
target_compile_options(pico_standard_link INTERFACE "$<$<COMPILE_LANGUAGE:C>:SHELL: -ffunction-sections -fdata-sections>")

set_property(GLOBAL PROPERTY visited_targets "")
set_property(GLOBAL PROPERTY compilerdefs_list "")

function(gather_compile_definitions_recursive target)
    get_property(visited_targets GLOBAL PROPERTY visited_targets)
    if (${target} MATCHES "\\\$<" OR ${target} MATCHES "::@" OR ${target} IN_LIST visited_targets)
        return()
    endif()

    list(APPEND visited_targets ${target})
    set_property(GLOBAL PROPERTY visited_targets "${visited_targets}")

    get_target_property(target_definitions ${target} INTERFACE_COMPILE_DEFINITIONS)
    if (target_definitions)
        get_property(compilerdefs_list GLOBAL PROPERTY compilerdefs_list)
        list(APPEND compilerdefs_list ${target_definitions})
        set_property(GLOBAL PROPERTY compilerdefs_list "${compilerdefs_list}")
    endif()

    get_target_property(target_linked_libs ${target} INTERFACE_LINK_LIBRARIES)
    if (target_linked_libs)
        foreach(linked_target ${target_linked_libs})
            gather_compile_definitions_recursive(${linked_target})
        endforeach()
    endif()
endfunction()

gather_compile_definitions_recursive(WatchCalcFirmware)
get_property(COMPILE_DEFINITIONS GLOBAL PROPERTY compilerdefs_list)

list(REMOVE_DUPLICATES COMPILE_DEFINITIONS)
list(PREPEND COMPILE_DEFINITIONS "")
string(REPLACE "$<TARGET_PROPERTY:PICO_TARGET_BINARY_TYPE>" "$<TARGET_PROPERTY:WatchCalcFirmware,PICO_TARGET_BINARY_TYPE>" COMPILE_DEFINITIONS "${COMPILE_DEFINITIONS}")
string(REPLACE ";" " -Xcc -D" COMPILE_DEFINITIONS "${COMPILE_DEFINITIONS}")

set(IMPLICIT_INCLUDES)
foreach(dir ${CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES})
    string(CONCAT IMPLICIT_INCLUDES ${IMPLICIT_INCLUDES} "-Xcc ")
    string(CONCAT IMPLICIT_INCLUDES ${IMPLICIT_INCLUDES} "-I${dir} ")
endforeach()
foreach(dir ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES})
    string(CONCAT IMPLICIT_INCLUDES ${IMPLICIT_INCLUDES} "-Xcc ")
    string(CONCAT IMPLICIT_INCLUDES ${IMPLICIT_INCLUDES} "-I${dir} ")
endforeach()

target_compile_options(WatchCalcFirmware PUBLIC
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:
        -target ${SWIFT_TARGET}
        -enable-experimental-feature Embedded
        -parse-as-library
        -module-name WatchCalcFirmware
        
        ${CLANG_ARCH_ABI_FLAGS}
        -Xcc -mno-unaligned-access
        -Xcc -fshort-enums
        -Xfrontend -function-sections
        -import-bridging-header ${CMAKE_CURRENT_LIST_DIR}/BridgingHeader.h
        ${COMPILE_DEFINITIONS}
        ${IMPLICIT_INCLUDES}
    >"
    "$<$<COMPILE_LANGUAGE:C>:-mno-unaligned-access>"
)

pico_add_extra_outputs(WatchCalcFirmware)

if (TARGET pico_float_pico_vfp)
    get_target_property(PICO_FLOAT_OPTIONS pico_float_pico_vfp INTERFACE_COMPILE_OPTIONS)
    if (PICO_FLOAT_OPTIONS)
        list(REMOVE_ITEM PICO_FLOAT_OPTIONS "-fno-math-errno")
        set_target_properties(pico_float_pico_vfp PROPERTIES INTERFACE_COMPILE_OPTIONS "${PICO_FLOAT_OPTIONS}")
    endif()
endif()

