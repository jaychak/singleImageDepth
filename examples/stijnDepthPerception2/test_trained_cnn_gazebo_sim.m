function test_trained_cnn_gazebo_sim()

%% Load network and data

% Jay trained with 1400 images
% net = load('/esat/emerald/pchakrav/singleImageDepthDataset/models/10Aug/coarse_depth1/coarsecnn.mat');

% Stij trained
% net1 = load('/esat/wasat/r0300219/Thesis/net-epoch-30.mat');
% net = net1.net;

% Jay fine-tuned above Stijnnet with 10k more images.
net =  load('/esat/emerald/pchakrav/singleImageDepthDataset/models/10Aug/coarse_depth2/coarsecnn.mat');
% Jay fine-tuned on Gazebo sim data (2500 images).
net1 = load('/esat/emerald/pchakrav/singleImageDepthDataset/models/10Aug/coarse_depth3/coarsecnn.mat');

rgb_dir = '/esat/qayd/tmp/remote_images/set_6/RGB/';
depth_dir = '/esat/qayd/tmp/remote_images/set_6/depth/';

rgb_filenames = dir(rgb_dir);
depth_filenames = dir(depth_dir);

num_images = 1000;
for i=1501:2500
    rgb_filename = rgb_filenames(i).name;
    im = imread(fullfile(rgb_dir,rgb_filename));
    im_ = imresize(im, [240,320]);
    subplot(1,4,1);
    imagesc(im_);
    
    depth_filename = depth_filenames(i-1).name;
    depth = imread(fullfile(depth_dir,depth_filename));
    depth_ = imresize(depth, [55,74]);
    subplot(1,4,2);
    imagesc(depth_);
    
    dzdy = [];
    res = [];
   
    res = vl_simplenn(net, single(im_), dzdy, res, ... 
                      'mode', 'test', ...
                      'conserveMemory', false, ...
                      'backPropDepth', +inf, ...
                      'sync', false, ...
                      'cudnn', false) ;%);

                      
    %output = reshape(res(end-1).x(1,1,:,1),[55 74]);
    output = reshape(res(end).x(1,1,:,1),[55 74]);
    subplot(1,4,3);
    imagesc(output);
    
    dzdy = [];
    res1 = [];
   
    res1 = vl_simplenn(net1, single(im_), dzdy, res, ... 
                      'mode', 'test', ...
                      'conserveMemory', false, ...
                      'backPropDepth', +inf, ...
                      'sync', false, ...
                      'cudnn', false) ;%);
                  
    output1 = reshape(res1(end).x(1,1,:,1),[55 74]);
    subplot(1,4,4);
    imagesc(output1);
                  
                  
    pause(0.05);
    
end


