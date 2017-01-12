
% Set up Matconvnet for any CNN application
% Needs to be run before any CNN code in this folder.
% 
% Jay Chakravarty
% Aug 2016.

cd '/users/visics/pchakrav/Documents/MATLAB/utils/matconvnet-1.0-beta19/'

disp('run setup');
run  matlab/vl_setupnn
disp('compile');
vl_compilenn('enableGpu', true, ...
'cudaRoot', '/usr/local/cuda-7.5/', ...
'enableCudnn', false, ...
'verbose', true );

cd '/users/visics/pchakrav/Documents/MATLAB/utils/matconvnet-1.0-beta19/examples/stijnDepthPerception2/'
%coarse_scale_network()
% finetune_coarse_scale_network2()