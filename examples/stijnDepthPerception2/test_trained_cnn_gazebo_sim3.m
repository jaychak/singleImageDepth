function test_trained_cnn_gazebo_sim3(depth_dir)

%% Load single image depth network and data and run network on every new image
%% in the dir specified. This is run in conjunction with the Alienware computer
%% running the simulated drone in real-time and sending the images through the network.

%% This version also has the capability to save the depthmaps in a mat file on the computer
%% running the LSTM (Qayd).

% Jay trained with 1400 images
% net = load('/esat/emerald/pchakrav/singleImageDepthDataset/models/10Aug/coarse_depth1/coarsecnn.mat');

% Stij trained
% net1 = load('/esat/wasat/r0300219/Thesis/net-epoch-30.mat');
% net = net1.net;

% Jay fine-tuned above Stijnnet with 10k more images.
fprintf('Loading Network ...  \n');
net =  load('/esat/emerald/pchakrav/singleImageDepthDataset/models/10Aug/coarse_depth2/coarsecnn.mat');
fprintf('Finished loading Network.  \n');
% Jay fine-tuned on Gazebo sim data (2500 images).

rgb_dir = '/usr/data/pchakrav/droneImagesFromAlienware/';

%% UNCOMMENT FOR SAVING IMAGES ON QAYD
rgb_dir = '/esat/emerald/tmp/socket_images/';

%depth_dir = '/esat/emerald/tmp/remote_features/';
%% Process image in dir
image_processed_idx = 1;
while (1)
    tic
    if exist(fullfile(rgb_dir,'imageReady'),'file') == 2
        process_flag = 1;
    else
        process_flag = 0;
    end
%     rgb_filenames = dir(rgb_dir);
%     image_idx = -1;
%     for i=1:numel(rgb_filenames)
%         file_name_this = rgb_filenames(i).name;
%         if strcmp(file_name_this,'imageReady') ~= 0
%             process_flag = 1;
%         else
%             process_flag = 0;
%         end
%         
%         if strcmp(file_name_this,'image.jpg') == 1
%             image_idx = i;
%         end
%     end
    process_flag
    if process_flag == 1
        %rgb_filename = rgb_filenames(image_idx).name;
        rgb_image = imread(fullfile(rgb_dir,'image.jpg'));%imread(fullfile(rgb_dir,rgb_filename));
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
        output_rescaled_alienware = (output+1)/1.75;
        fprintf('############## PROCESSED IMAGE ########################### \n');
%         figure(1);
%         subplot(1,2,1);
%         imagesc(rgb_image_);
%         subplot(1,2,2);
%         imagesc(output_rescaled_alienware);
        %pause(0.05);
        
        %imwrite(output,(fullfile(rgb_dir,'depth.jpg')));
        imwrite(output_rescaled_alienware,(fullfile(rgb_dir,'depth.jpg')));
        
        
        output_lstm = reshape(res(end).x(1,1,:,1),[1 4070]);
        output_rescaled_qayd = (output_lstm+1)/1.75;
        gazebo_sim_dataset = [];
        file_name = '';
        gazebo_sim_dataset.names(1,:) = {file_name};
        gazebo_sim_dataset.labels(1,:) = output_rescaled_qayd';
        %% UNCOMMENT FOR SAVING IMAGES ON QAYD
        save(strcat(depth_dir,num2str(image_processed_idx),'_stijn.mat'), 'gazebo_sim_dataset');
        image_processed_idx = image_processed_idx + 1;
        
        
        
        
        fid = fopen(fullfile(rgb_dir,'depthReady'),'w');
        fclose(fid);
        delete((fullfile(rgb_dir,'imageReady')));
    end
    %pause(0.05);
    toc
end    