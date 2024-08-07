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

#KS: Allow user to define CMAKE_CUDA_ARCHITECTURES
if(NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
      #KS: See this for more info https://cmake.org/cmake/help/latest/prop_tgt/CUDA_ARCHITECTURES.html
  if( ${CMAKE_VERSION} VERSION_GREATER_EQUAL 3.23 )
      set(CMAKE_CUDA_ARCHITECTURES all )
          #KS: Consider using native, requires cmake 3.24... will be terrible for containers but should results in more optimised code
      #set(CMAKE_CUDA_ARCHITECTURES native )
  else()
  #KS: Apparently with newer cmake and GPU
      set(CMAKE_CUDA_ARCHITECTURES 60 61 70 75 80 86)
  endif()
#KS: Bit hacky but to properly pass cuda flags we need
string(REPLACE ";" " " CMAKE_CUDA_ARCHITECTURES_STRING "${CMAKE_CUDA_ARCHITECTURES}")
else()
#KS this may look hacky however CPM isn't build for passing stuff like this. If CMAKE_CUDA_ARCHITECTURES is passed CPM it will be string not list. Thus we convert it to list
set(CMAKE_CUDA_ARCHITECTURES_STRING ${CMAKE_CUDA_ARCHITECTURES})
string(REPLACE " " ";" CMAKE_CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
endif()

message(STATUS "Set CUDA ARCHITECTURES options: ${CMAKE_CUDA_ARCHITECTURES_STRING}")

add_library(ProbGPU SHARED probGpu.cu)

target_include_directories(
  ProbGPU PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:include>
)

set_target_properties(ProbGPU PROPERTIES
			      CUDA_SEPARABLE_COMPILATION ON
			      LINKER_LANGUAGE CUDA
			      EXPORT_NAME ProbGPU)

set_property(TARGET ProbGPU PROPERTY CUDA_ARCHITECTURES ${CMAKE_CUDA_ARCHITECTURES})

install(TARGETS ProbGPU 
                EXPORT ProbGPU-target
                LIBRARY DESTINATION lib/
                PUBLIC_HEADER DESTINATION include/)

install(EXPORT ProbGPU-target
  FILE ProbGPUTargets.cmake
  NAMESPACE ProbGPU::
  DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/cmake/ProbGPU
)
