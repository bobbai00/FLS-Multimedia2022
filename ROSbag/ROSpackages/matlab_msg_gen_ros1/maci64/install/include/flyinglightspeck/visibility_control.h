#ifndef FLYINGLIGHTSPECK__VISIBILITY_CONTROL_H_
#define FLYINGLIGHTSPECK__VISIBILITY_CONTROL_H_
#if defined _WIN32 || defined __CYGWIN__
  #ifdef __GNUC__
    #define FLYINGLIGHTSPECK_EXPORT __attribute__ ((dllexport))
    #define FLYINGLIGHTSPECK_IMPORT __attribute__ ((dllimport))
  #else
    #define FLYINGLIGHTSPECK_EXPORT __declspec(dllexport)
    #define FLYINGLIGHTSPECK_IMPORT __declspec(dllimport)
  #endif
  #ifdef FLYINGLIGHTSPECK_BUILDING_LIBRARY
    #define FLYINGLIGHTSPECK_PUBLIC FLYINGLIGHTSPECK_EXPORT
  #else
    #define FLYINGLIGHTSPECK_PUBLIC FLYINGLIGHTSPECK_IMPORT
  #endif
  #define FLYINGLIGHTSPECK_PUBLIC_TYPE FLYINGLIGHTSPECK_PUBLIC
  #define FLYINGLIGHTSPECK_LOCAL
#else
  #define FLYINGLIGHTSPECK_EXPORT __attribute__ ((visibility("default")))
  #define FLYINGLIGHTSPECK_IMPORT
  #if __GNUC__ >= 4
    #define FLYINGLIGHTSPECK_PUBLIC __attribute__ ((visibility("default")))
    #define FLYINGLIGHTSPECK_LOCAL  __attribute__ ((visibility("hidden")))
  #else
    #define FLYINGLIGHTSPECK_PUBLIC
    #define FLYINGLIGHTSPECK_LOCAL
  #endif
  #define FLYINGLIGHTSPECK_PUBLIC_TYPE
#endif
#endif  // FLYINGLIGHTSPECK__VISIBILITY_CONTROL_H_
// Generated 04-Aug-2022 11:00:09
// Copyright 2019-2020 The MathWorks, Inc.
