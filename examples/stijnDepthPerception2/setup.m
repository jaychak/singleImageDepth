function setup(varargin)

% addpath('/users/start2013/r0300219/Documents/Thesis/depth_mapping_with_CNN/matconvnet-1.0-beta17/');
% run vlfeat/toolbox/vl_setup ;
% addpath matconvnet/examples ;
% run vl_setupnn;

run /users/start2013/r0300219/Documents/Thesis/depth_mapping_with_CNN/matconvnet-1.0-beta19/matlab/vl_setupnn;

% opts.useGpu = true ;
% opts.verbose = true ;
% opts = vl_argparse(opts, varargin) ;
% 
% try
%   vl_nnconv(single(1),single(1),[]) ;
% catch
%   warning('VL_NNCONV() does not seem to be compiled. Trying to compile it now.') ;
%   vl_compilenn('enableGpu', opts.useGpu, 'verbose', opts.verbose) ;
% end

% if opts.useGpu    
  addpath(genpath('/usr/local/cuda-7.5/')); % cuda 7.5
  addpath(genpath('/users/start2013/r0300219/Documents/Thesis/cuda/')); %cuDNN genpath = to add subfolders  
%     addpath('/usr/lib64/libstdc++.so.6');
%   try
%     vl_nnconv(gpuArray(single(1)),gpuArray(single(1)),[]) ;
%   catch
%     vl_compilenn('enableGpu', true, 'cudaMethod', 'nvcc', 'cudaRoot', '/usr/local/cuda-7.5' , 'enableCudnn', 'true', 'cudnnRoot', '/users/start2013/r0300219/Documents/Thesis/cuda');
%     vl_compilenn('enableGpu', true, 'cudaMethod', 'nvcc', 'cudaRoot', '/usr/local/cuda-7.5/', 'enableCudnn', false);

%     warning('GPU support does not seem to be compiled in MatConvNet. Trying to compile it now') ;
%   end

vl_compilenn('enableGpu', true, ...
               'cudaMethod', 'nvcc', ...
               'cudaRoot', '/usr/local/cuda-7.5', ...
               'enableCudnn', true, ...
               'cudnnRoot', '/users/start2013/r0300219/Documents/Thesis/cuda') ;

end
