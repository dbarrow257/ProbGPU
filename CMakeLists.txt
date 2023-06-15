cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

SET(ProbGPU_VERSION 0.0)
project(ProbGPU VERSION ${ProbGPU_VERSION} LANGUAGES CXX C CUDA)

#Changes default install path to be a subdirectory of the build dir.
#Can set build dir at configure time with -DCMAKE_INSTALL_PREFIX=/install/path
if(CMAKE_INSTALL_PREFIX STREQUAL "" OR CMAKE_INSTALL_PREFIX STREQUAL
  "/usr/local")
  set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/${CMAKE_SYSTEM_NAME}")
elseif(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/${CMAKE_SYSTEM_NAME}")
endif()

add_library(ProbGPU SHARED probGpu.cu)

set_target_properties(ProbGPU PROPERTIES 
			      CUDA_SEPARABLE_COMPILATION ON 
			      LINKER_LANGUAGE CUDA
			      EXPORT_NAME ProbGPU)

set_property(TARGET ProbGPU PROPERTY CUDA_ARCHITECTURES 35 52 60 61 70 75)

target_include_directories(
  ProbGPU PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
                       $<INSTALL_INTERFACE:include>
)

install(TARGETS ProbGPU 
                EXPORT ProbGPU-target
                LIBRARY DESTINATION lib/
                PUBLIC_HEADER DESTINATION include/)

install(EXPORT ProbGPU-target
  FILE ProbGPUTargets.cmake
  NAMESPACE ProbGPU::
  DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/cmake/ProbGPU
)
