function save_gazebo_sim_training_data()

%% Load network (Jay fine-tuned above Stijnnet with 10k more images.)
net =  load('/esat/emerald/pchakrav/singleImageDepthDataset/models/10Aug/coarse_depth2/coarsecnn.mat');


root_dir = '/esat/emerald/tmp/remote_images/';

folder_names = dir(root_dir);

for folder_idx = 4:10%numel(folder_names)
    folder_name = folder_names(folder_idx).name
    write_folder_name = fullfile(root_dir,folder_name,'cnn_features');
    read_folder_name = fullfile(root_dir,folder_name,'RGB');
    file_names = dir(read_folder_name);
    gazebo_sim_dataset = [];
    for file_idx = 3:numel(file_names)
        file_name = file_names(file_idx).name
        file_name = fullfile(read_folder_name,file_name);
        im = imread(file_name);
        im_ = imresize(im, [240,320]);
%         figure(1);
%         subplot(1,2,1);
%         imagesc(im_);
        
        dzdy = [];
        res = [];

        res = vl_simplenn(net, single(im_), dzdy, res, ... 
                      'mode', 'test', ...
                      'conserveMemory', false, ...
                      'backPropDepth', +inf, ...
                      'sync', false, ...
                      'cudnn', false) ;%);\
        output = reshape(res(end).x(1,1,:,1),[1 4070]);
        
%         subplot(1,2,2);
%         imagesc(output);
        
        gazebo_sim_dataset.names(file_idx-2,:) = {file_name};
        %gazebo_sim_dataset.images(:,:,:,dataset_idx) = im_;
        gazebo_sim_dataset.labels(file_idx-2,:) = output';
%         pause(0.05);
 
    end
    
    if exist(write_folder_name) == 0
        mkdir(write_folder_name);
    end
    
    save(strcat(write_folder_name,'/depth_estimate_',folder_name,'_stijn.mat'), 'gazebo_sim_dataset');

end

% save('/esat/emerald/pchakrav/singleImageDepthDataset/trainingImagesGazebo/gazebo_sim_training1_10.mat', 'gazebo_sim_dataset','-v7.3');


