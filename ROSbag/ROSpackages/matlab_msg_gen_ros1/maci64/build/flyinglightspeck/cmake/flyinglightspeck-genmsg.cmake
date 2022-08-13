# generated from genmsg/cmake/pkg-genmsg.cmake.em

message(STATUS "flyinglightspeck: 1 messages, 1 services")

set(MSG_I_FLAGS "-Iflyinglightspeck:/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/src/flyinglightspeck/msg;-Istd_msgs:/Applications/MATLAB_R2022a.app/sys/ros1/maci64/ros1/share/std_msgs/cmake/../msg;-Istd_msgs:/Applications/MATLAB_R2022a.app/sys/ros1/maci64/ros1/share/std_msgs/cmake/../msg")

# Find all generators
find_package(gencpp REQUIRED)
find_package(genpy REQUIRED)

add_custom_target(flyinglightspeck_generate_messages ALL)

# verify that message/service dependencies have not changed since configure



get_filename_component(_filename "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/src/flyinglightspeck/msg/fls.msg" NAME_WE)
add_custom_target(_flyinglightspeck_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "flyinglightspeck" "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/src/flyinglightspeck/msg/fls.msg" "std_msgs/Header"
)

get_filename_component(_filename "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/src/flyinglightspeck/srv/ReadFLS.srv" NAME_WE)
add_custom_target(_flyinglightspeck_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "flyinglightspeck" "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/src/flyinglightspeck/srv/ReadFLS.srv" ""
)

#
#  langs = gencpp;genpy
#

### Section generating for lang: gencpp
### Generating Messages
_generate_msg_cpp(flyinglightspeck
  "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/src/flyinglightspeck/msg/fls.msg"
  "${MSG_I_FLAGS}"
  "/Applications/MATLAB_R2022a.app/sys/ros1/maci64/ros1/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/flyinglightspeck
)

### Generating Services
_generate_srv_cpp(flyinglightspeck
  "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/src/flyinglightspeck/srv/ReadFLS.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/flyinglightspeck
)

### Generating Module File
_generate_module_cpp(flyinglightspeck
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/flyinglightspeck
  "${ALL_GEN_OUTPUT_FILES_cpp}"
)

add_custom_target(flyinglightspeck_generate_messages_cpp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_cpp}
)
add_dependencies(flyinglightspeck_generate_messages flyinglightspeck_generate_messages_cpp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/src/flyinglightspeck/msg/fls.msg" NAME_WE)
add_dependencies(flyinglightspeck_generate_messages_cpp _flyinglightspeck_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/src/flyinglightspeck/srv/ReadFLS.srv" NAME_WE)
add_dependencies(flyinglightspeck_generate_messages_cpp _flyinglightspeck_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(flyinglightspeck_gencpp)
add_dependencies(flyinglightspeck_gencpp flyinglightspeck_generate_messages_cpp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS flyinglightspeck_generate_messages_cpp)

### Section generating for lang: genpy
### Generating Messages
_generate_msg_py(flyinglightspeck
  "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/src/flyinglightspeck/msg/fls.msg"
  "${MSG_I_FLAGS}"
  "/Applications/MATLAB_R2022a.app/sys/ros1/maci64/ros1/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/flyinglightspeck
)

### Generating Services
_generate_srv_py(flyinglightspeck
  "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/src/flyinglightspeck/srv/ReadFLS.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/flyinglightspeck
)

### Generating Module File
_generate_module_py(flyinglightspeck
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/flyinglightspeck
  "${ALL_GEN_OUTPUT_FILES_py}"
)

add_custom_target(flyinglightspeck_generate_messages_py
  DEPENDS ${ALL_GEN_OUTPUT_FILES_py}
)
add_dependencies(flyinglightspeck_generate_messages flyinglightspeck_generate_messages_py)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/src/flyinglightspeck/msg/fls.msg" NAME_WE)
add_dependencies(flyinglightspeck_generate_messages_py _flyinglightspeck_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/Users/flyinglightspec/src/FLS-Multimedia2022/ROSbag/ROSpackages/matlab_msg_gen_ros1/maci64/src/flyinglightspeck/srv/ReadFLS.srv" NAME_WE)
add_dependencies(flyinglightspeck_generate_messages_py _flyinglightspeck_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(flyinglightspeck_genpy)
add_dependencies(flyinglightspeck_genpy flyinglightspeck_generate_messages_py)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS flyinglightspeck_generate_messages_py)



if(gencpp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/flyinglightspeck)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/flyinglightspeck
    DESTINATION ${gencpp_INSTALL_DIR}
  )
endif()
if(TARGET std_msgs_generate_messages_cpp)
  add_dependencies(flyinglightspeck_generate_messages_cpp std_msgs_generate_messages_cpp)
endif()
if(TARGET std_msgs_generate_messages_cpp)
  add_dependencies(flyinglightspeck_generate_messages_cpp std_msgs_generate_messages_cpp)
endif()

if(genpy_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/flyinglightspeck)
  install(CODE "execute_process(COMMAND \"/Users/flyinglightspec/.matlab/R2022a/ros1/maci64/venv/bin/python3\" -m compileall \"${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/flyinglightspeck\")")
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/flyinglightspeck
    DESTINATION ${genpy_INSTALL_DIR}
  )
endif()
if(TARGET std_msgs_generate_messages_py)
  add_dependencies(flyinglightspeck_generate_messages_py std_msgs_generate_messages_py)
endif()
if(TARGET std_msgs_generate_messages_py)
  add_dependencies(flyinglightspeck_generate_messages_py std_msgs_generate_messages_py)
endif()
