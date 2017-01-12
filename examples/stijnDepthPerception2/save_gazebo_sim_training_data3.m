function save_gazebo_sim_training_data3(root_dir_str)
 %% Calculate Stijn single image depth maps for Many worlds data
 %% Jay Chakravarty 
 %% Aug 2016

% cd '/users/visics/pchakrav/Documents/MATLAB/utils/matconvnet-1.0-beta19/'
% 
% disp('run setup');
% run  matlab/vl_setupnn
% disp('compile');
% vl_compilenn('enableGpu', true, ...
% 'cudaRoot', '/usr/local/cuda-7.5/', ...
% 'enableCudnn', false, ...
% 'verbose', true );

% cd '/users/visics/pchakrav/Documents/MATLAB/utils/matconvnet-1.0-beta19/examples/stijnDepthPerception2/'


% Load network (Jay fine-tuned above Stijnnet with 10k more images.)
fprintf('Loading Network ...  \n');

net =  load('/esat/emerald/pchakrav/singleImageDepthDataset/models/10Aug/coarse_depth2/coarsecnn.mat');
fprintf('Finished loading Network.  \n');


%root_dir = '/esat/emerald/tmp/remote_images/continuous_expert/';
root_dir = root_dir_str;% '/esat/emerald/tmp/remote_images/dagger2/';

%dir_files = dir(root_dir);

% Calculate depth images and save features


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


for i=3:numel(dir_files)
    this_dir_name = dir_files(i).name
    if numel(strfind(this_dir_name,'.txt')) == 0
        
        control_info_file_name = fullfile(root_dir,this_dir_name,'control_info.txt');
        control_info_this      = dlmread(control_info_file_name);
        
        gazebo_sim_dataset = [];
        write_folder_name = fullfile(root_dir,this_dir_name,'cnn_features');
        for j=1:size(control_info_this,1)
            file_name = fullfile(root_dir,this_dir_name,'RGB',strcat(sprintf('%010d',control_info_this(j,1)+1),'.jpg'))
            % Not every line in the control info file has a
            % corresponding RGB image because the RGB and Kinect depth images
            % are simulated and saved at different rates. For the lines
            % in the control file that have no corresponding RGB
            % images, saving a row of -1s.
            if exist(file_name) ~= 0
                
                im = imread(file_name);
                im_ = imresize(im, [240,320]);
                dzdy = [];
                res = [];

                res = vl_simplenn(net, single(im_), dzdy, res, ... 
                              'mode', 'test', ...
                              'conserveMemory', false, ...
                              'backPropDepth', +inf, ...
                              'sync', false, ...
                              'cudnn', false) ;%);\
                output = reshape(res(end).x(1,1,:,1),[1 4070]);
                output_rescaled = (output+1)/1.75;

                gazebo_sim_dataset.names(j,:) = {file_name};
                gazebo_sim_dataset.labels(j,:) = output_rescaled';
            else
                output = (-1*ones(1,4070));
                gazebo_sim_dataset.names(j,:) = {file_name};
                gazebo_sim_dataset.labels(j,:) = output';
            end
        end
        save(strcat(write_folder_name,'/depth_estimate_',this_dir_name,'_stijn.mat'), 'gazebo_sim_dataset');
    end
end

