# Install script for directory: /Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/src/flyinglightspeck

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/install")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/objdump")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/flyinglightspeck/msg" TYPE FILE FILES "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/src/flyinglightspeck/msg/fls.msg")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/flyinglightspeck/srv" TYPE FILE FILES "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/src/flyinglightspeck/srv/ReadFLS.srv")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/flyinglightspeck/cmake" TYPE FILE FILES "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/build/flyinglightspeck/catkin_generated/installspace/flyinglightspeck-msg-paths.cmake")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE DIRECTORY FILES "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/devel/include/flyinglightspeck")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  execute_process(COMMAND "/Users/flyinglightspec/.matlab/R2022a/ros1/maci64/venv/bin/python3" -m compileall "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/devel/lib/python3.9/site-packages/flyinglightspeck")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/python3.9/site-packages" TYPE DIRECTORY FILES "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/devel/lib/python3.9/site-packages/flyinglightspeck")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig" TYPE FILE FILES "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/build/flyinglightspeck/catkin_generated/installspace/flyinglightspeck.pc")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/flyinglightspeck/cmake" TYPE FILE FILES "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/build/flyinglightspeck/catkin_generated/installspace/flyinglightspeck-msg-extras.cmake")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/flyinglightspeck/cmake" TYPE FILE FILES
    "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/build/flyinglightspeck/catkin_generated/installspace/flyinglightspeckConfig.cmake"
    "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/build/flyinglightspeck/catkin_generated/installspace/flyinglightspeckConfig-version.cmake"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/flyinglightspeck" TYPE FILE FILES "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/src/flyinglightspeck/package.xml")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE DIRECTORY FILES "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/src/flyinglightspeck/include/")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/devel/lib/libflyinglightspeck_matlab.dylib")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libflyinglightspeck_matlab.dylib" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libflyinglightspeck_matlab.dylib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip" -x "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libflyinglightspeck_matlab.dylib")
    endif()
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/m/" TYPE DIRECTORY FILES "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/src/flyinglightspeck/m/" FILES_MATCHING REGEX "/[^/]*\\.m$")
endif()

