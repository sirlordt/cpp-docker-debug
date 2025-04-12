cmake_minimum_required(VERSION 3.15)

# Set output directory for executables
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Read project name from .build_env file if it exists
set(PROJECT_NAME "main")  # Default name
if(EXISTS "${CMAKE_SOURCE_DIR}/.build_env")
    file(STRINGS "${CMAKE_SOURCE_DIR}/.build_env" ENV_CONTENTS)
    foreach(LINE ${ENV_CONTENTS})
        if(LINE MATCHES "^App_Name=(.*)$")
            set(PROJECT_NAME ${CMAKE_MATCH_1})
            message(STATUS "Using project name from .build_env: ${PROJECT_NAME}")
        endif()
    endforeach()
endif()

# Create a symbolic link for backward compatibility
add_custom_command(
    OUTPUT ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/main
    COMMAND ${CMAKE_COMMAND} -E create_symlink ${PROJECT_NAME} main
    WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    DEPENDS ${PROJECT_NAME}
    COMMENT "Creating symbolic link for backward compatibility"
)
add_custom_target(main_symlink ALL DEPENDS ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/main)

# C++ executable
add_executable(${PROJECT_NAME} main.cpp)
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_23)  # Explicitly set C++23 for this target
target_compile_options(${PROJECT_NAME} PRIVATE -g -Wall -fsanitize=address,undefined,leak)
target_link_options(${PROJECT_NAME} PRIVATE -fsanitize=address,undefined,leak)
add_dependencies(main_symlink ${PROJECT_NAME})

# C executable
add_executable(sample sample.c)
target_compile_options(sample PRIVATE -g -Wall -fsanitize=address,undefined,leak)
target_link_options(sample PRIVATE -fsanitize=address,undefined,leak)

# If you add dependencies with Conan, link them here
# Example:
# find_package(fmt REQUIRED)
# target_link_libraries(main fmt::fmt)
