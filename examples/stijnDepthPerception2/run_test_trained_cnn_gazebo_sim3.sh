#!/bin/sh
# script for execution of deployed applications
#
# Sets up the MATLAB Runtime environment for the current $ARCH and executes 
# the specified command.
#
exe_name=$0
exe_dir=`dirname "$0"`
echo "------------------------------------------"
if [ "x$1" = "x" ]; then
  echo Usage:
  echo    $0 \<deployedMCRroot\> args
else
  echo Setting up environment variables
  MCRROOT="$1"
  export LD_PRELOAD=/usr/lib64/libstdc++.so.6
  echo ---
  LD_LIBRARY_PATH=.:${MCRROOT}/runtime/glnxa64 ;
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/bin/glnxa64 ;
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/sys/os/glnxa64;
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/sys/opengl/lib/glnxa64;
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/users/visics/pchakrav/Documents/MATLAB/utils/matconvnet-1.0-beta19/examples/stijnDepthPerception2;
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda-7.5;
  #LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/users/visics/pchakrav/Documents/MATLAB/utils/cudnn-4.0/cuda/lib64;
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/users/visics/pchakrav/Documents/MATLAB/utils/matconvnet-1.0-beta19/matlab/mex;
  export LD_LIBRARY_PATH;
  echo LD_LIBRARY_PATH is ${LD_LIBRARY_PATH};
  shift 1
  args=
  while [ $# -gt 0 ]; do
      token=$1
      args="${args} \"${token}\"" 
      shift
  done
  eval "\"${exe_dir}/test_trained_cnn_gazebo_sim3\"" $args
fi
exit

