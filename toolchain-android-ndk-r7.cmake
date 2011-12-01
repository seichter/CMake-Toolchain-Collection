#
# Android NDK toolchain file for CMake
#
# (c) Copyrights 2009-2011 Hartmut Seichter
# 
# Note: this version only targets NDK r7 
#

# need to know where the NDK resides
set(ANDROID_NDK_ROOT "$ENV{NDK_ROOT}" CACHE PATH "Android NDK location")

# set(ANDROID_NDK_TOOLCHAIN_DEBUG ON)

# check host platform
set(ANDROID_NDK_HOST)
if(APPLE)
	set(ANDROID_NDK_HOST "darwin-x86")
elseif(WIN32)
	set(ANDROID_NDK_HOST "windows")
elseif(UNIX)
	set(ANDROID_NDK_HOST "linux-x86")
else()
	message( FATAL_ERROR "Platform not supported" )
endif()

# basic setup
set(CMAKE_CROSSCOMPILING 1)
set(CMAKE_SYSTEM_NAME Linux)

# for convenience
set(ANDROID 1)

# set supported architecture
set(ANDROID_NDK_ARCH_SUPPORTED "arm;armv7;x86")
set(ANDROID_NDK_ARCH "arm" CACHE STRING "Android NDK CPU architecture (${ANDROID_NDK_ARCH_SUPPORTED})")
set_property(CACHE ANDROID_NDK_ARCH PROPERTY STRINGS ${ANDROID_NDK_ARCH_SUPPORTED})

# armeabi / armeabi-v7a / x86
set(ANDROID_NDK_ABI)
set(ANDROID_NDK_ABI_EXT)
set(ANDROID_NDK_GCC_PREFIX)
set(ANDROID_NDK_ARCH_CFLAGS)
set(ANDROID_NDK_ARCH_LDFLAGS)
if("${ANDROID_NDK_ARCH}" STREQUAL "arm" )
	set(ANDROID_NDK_ABI "armeabi")
	set(ANDROID_NDK_ABI_EXT "arm-linux-androideabi")
	set(ANDROID_NDK_GCC_PREFIX "arm-linux-androideabi")
	set(ANDROID_NDK_ARCH_CFLAGS "-mthumb")
endif()	
if("${ANDROID_NDK_ARCH}" STREQUAL "armv7" )
	set(ANDROID_NDK_ABI "armeabi-v7a")
	set(ANDROID_NDK_ABI_EXT "arm-linux-androideabi")
	set(ANDROID_NDK_GCC_PREFIX "arm-linux-androideabi")
	set(ANDROID_NDK_ARCH_CFLAGS "-march=armv7-a -mfloat-abi=softfp")
	set(ANDROID_NDK_ARCH_LDFLAGS "-Wl,--fix-cortex-a8")
endif()
if("${ANDROID_NDK_ARCH}" STREQUAL "x86" )
	set(ANDROID_NDK_ABI "x86")
	set(ANDROID_NDK_ABI_EXT "x86")
	set(ANDROID_NDK_GCC_PREFIX "i686-android-linux")
endif()

if(ANDROID_NDK_TOOLCHAIN_DEBUG)
	message(STATUS "ANDROID_NDK_ABI - ${ANDROID_NDK_ABI}")
	message(STATUS "ANDROID_NDK_ABI_EXT - ${ANDROID_NDK_ABI_EXT}")
	message(STATUS "ANDROID_NDK_ARCH_CFLAGS - ${ANDROID_NDK_ARCH_CFLAGS}")
endif()

# choose NDK STL implementation
set(ANDROID_NDK_STL_SUPPORTED gnu-libstdc++ stlport)
set(ANDROID_NDK_STL "gnu-libstdc++" CACHE STRING "Android NDK STL (${ANDROID_NDK_STL_SUPPORTED})")
set_property(CACHE ANDROID_NDK_STL PROPERTY STRINGS ${ANDROID_NDK_STL_SUPPORTED})


# set the Android Platform
set(ANDROID_API_SUPPORTED "android-8;android-9;android-14")
set(ANDROID_API "android-8" CACHE STRING "Android SDK API (${ANDROID_API_SUPPORTED})")
set_property(CACHE ANDROID_API PROPERTY STRINGS ${ANDROID_API_SUPPORTED})

# set sysroot - in Android this in function of Android API and architecture
set(ANDROID_NDK_SYSROOT)
if("${ANDROID_NDK_ARCH}" STREQUAL "arm" OR "${ANDROID_NDK_ARCH}" STREQUAL "armv7" )
	set(ANDROID_NDK_SYSROOT "${ANDROID_NDK_ROOT}/platforms/${ANDROID_API}/arch-arm" CACHE PATH "NDK sysroot" FORCE)
elseif("${ANDROID_NDK_ARCH}" STREQUAL "x86")
	set(ANDROID_NDK_SYSROOT "${ANDROID_NDK_ROOT}/platforms/${ANDROID_API}/arch-x86" CACHE PATH "NDK sysroot" FORCE)
endif()


# set version
set(ANDROID_NDK_GCC_VERSION "4.4.3")


# STL
set(ANDROID_NDK_STL_CXXFLAGS)
set(ANDROID_NDK_STL_LIBRARYPATH)
set(ANDROID_NDK_STL_LDFLAGS)
if ("${ANDROID_NDK_STL}" STREQUAL "stlport") 
	set(ANDROID_NDK_STL_CXXFLAGS "${ANDROID_NDK_ROOT}/sources/cxx-stl/${ANDROID_NDK_STL}/stlport")
	set(ANDROID_NDK_STL_LIBRARYPATH "-I${ANDROID_NDK_ROOT}/sources/cxx-stl/${ANDROID_NDK_STL}/libs/${ANDROID_NDK_ABI}")
	set(ANDROID_NDK_STL_LDFLAGS)
else()
	set(ANDROID_NDK_STL_CXXFLAGS "-I${ANDROID_NDK_ROOT}/sources/cxx-stl/${ANDROID_NDK_STL}/include -I${ANDROID_NDK_ROOT}/sources/cxx-stl/${ANDROID_NDK_STL}/libs/${ANDROID_NDK_ABI}/include")
	set(ANDROID_NDK_STL_LIBRARYPATH "${ANDROID_NDK_ROOT}/sources/cxx-stl/${ANDROID_NDK_STL}/libs/${ANDROID_NDK_ABI}")
	set(ANDROID_NDK_STL_LDFLAGS)
endif()


# some overrides (see docs/STANDALONE-TOOLCHAIN.html)
set(CMAKE_C_FLAGS "--sysroot=${ANDROID_NDK_SYSROOT} -DANDROID ${ANDROID_NDK_ARCH_CFLAGS} ${ANDROID_NDK_ARCH_LDFLAGS}" CACHE STRING "C flags" FORCE)
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} ${ANDROID_NDK_STL_CXXFLAGS} -L${ANDROID_NDK_STL_LIBRARYPATH} -lstdc++ -lsupc++" CACHE STRING "C++ flags" FORCE)


# specify compiler
set(CMAKE_C_COMPILER   "${ANDROID_NDK_ROOT}/toolchains/${ANDROID_NDK_ABI_EXT}-${ANDROID_NDK_GCC_VERSION}/prebuilt/${ANDROID_NDK_HOST}/bin/${ANDROID_NDK_GCC_PREFIX}-gcc" CACHE PATH "C compiler" FORCE)
set(CMAKE_CXX_COMPILER "${ANDROID_NDK_ROOT}/toolchains/${ANDROID_NDK_ABI_EXT}-${ANDROID_NDK_GCC_VERSION}/prebuilt/${ANDROID_NDK_HOST}/bin/${ANDROID_NDK_GCC_PREFIX}-g++" CACHE PATH "C++ compiler" FORCE)

if(ANDROID_NDK_TOOLCHAIN_DEBUG)
	message(STATUS "c compiler: ${CMAKE_C_COMPILER}")
	message(STATUS "c++ compiler: ${CMAKE_CXX_COMPILER}")
	message(STATUS "sysroot: ${ANDROID_NDK_SYSROOT}")
endif()

# root path
set(CMAKE_FIND_ROOT_PATH ${ANDROID_NDK_SYSROOT})

# search paths
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
