#!/usr/bin/bash
echo 'run_the_thing has started' 
export LD_PRELOAD=/usr/lib64/libstdc++.so.6
export LD_LIBRARY_PATH=/usr/local/cuda-7.5/lib64:$LD_LIBRARY_PATH

#Added due to stuck @ check compute capability
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/games:/usr/local/sbin:/usr/sbin:$PATH
export MODULEPATH=/usr/share/Modules/modulefiles:/etc/modulefiles:/usr/share/modulefiles:$MODULEPATH
export MODULESHOME=/usr/share/Modules

printenv

cd /users/visics/pchakrav/Documents/MATLAB/utils/matconvnet-1.0-beta19/examples/stijnDepthPerception2
echo 'went to directory'
#cat do_the_thing.m
#pwd
/software/bin/matlab -nodisplay -r 'run_course_scale_network;exit()'
echo 'run_the_thing has finished' 
