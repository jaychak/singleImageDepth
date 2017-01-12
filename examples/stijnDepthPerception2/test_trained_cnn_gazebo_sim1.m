function test_trained_cnn_gazebo_sim1()

%% Load single image depth network and data and run network on every new image
%% in the dir specified.

% Jay trained with 1400 images
% net = load('/esat/emerald/pchakrav/singleImageDepthDataset/models/10Aug/coarse_depth1/coarsecnn.mat');

% Stij trained
% net1 = load('/esat/wasat/r0300219/Thesis/net-epoch-30.mat');
% net = net1.net;

% Jay fine-tuned above Stijnnet with 10k more images.
net =  load('/esat/emerald/pchakrav/singleImageDepthDataset/models/10Aug/coarse_depth2/coarsecnn.mat');
% Jay fine-tuned on Gazebo sim data (2500 images).
%net1 = load('/esat/emerald/pchakrav/singleImageDepthDataset/models/10Aug/coarse_depth3/coarsecnn.mat');

%rgb_dir = '/esat/emerald/pchakrav/singleImageDepthDataset/trainingImagesGazebo/remote_images/';
%rgb_dir = '/esat/emerald/tmp/remote_images/set_online/RGB/';

%rgb_dir = '/usr/data/pchakrav/alienware/depth_estimation';
rgb_dir = '/usr/data/pchakrav/droneImagesFromAlienware/';
%% Process image in dir
while (1)
    tic
    process_flag = 0;
    rgb_filenames = dir(rgb_dir);
    image_idx = -1;
    for i=1:numel(rgb_filenames)
        file_name_this = rgb_filenames(i).name;
        if strcmp(file_name_this,'imageReady') ~= 0
            process_flag = 1;
        else
            process_flag = 0;
        end
        
        if strcmp(file_name_this,'image.jpg') == 1
            image_idx = i;
        end
    end
    process_flag
    if process_flag == 1
        rgb_filename = rgb_filenames(image_idx).name;
        rgb_image = imread(fullfile(rgb_dir,rgb_filename));
        rgb_image_ = imresize(rgb_image, [240,320]);
        dzdy = [];
        res = [];

        res = vl_simplenn(net, single(rgb_image_), dzdy, res, ... 
                      'mode', 'test', ...
                      'conserveMemory', false, ...
                      'backPropDepth', +inf, ...
                      'sync', false, ...
                      'cudnn', false) ;%);\
        output = reshape(res(end).x(1,1,:,1),[55 74]);
        output_rescaled = (output+1)/1.75;
        fprintf('############## PROCESSED IMAGE ########################### \n');
        figure(1);
        subplot(1,2,1);
        imagesc(rgb_image_);
        subplot(1,2,2);
        imagesc(output_rescaled);
        %pause(0.05);
        
        %imwrite(output,(fullfile(rgb_dir,'depth.jpg')));
        imwrite(output_rescaled,(fullfile(rgb_dir,'depth.jpg')));
        fopen(fullfile(rgb_dir,'depthReady'),'w');
        delete((fullfile(rgb_dir,'imageReady')));
    end
    pause(0.05);
    toc
end    