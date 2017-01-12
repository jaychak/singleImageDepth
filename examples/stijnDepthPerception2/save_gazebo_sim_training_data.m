function save_gazebo_sim_training_data()

%% Load images from directory and save as mat file.
rgb_dir = '/esat/qayd/tmp/remote_images/set_6/RGB/';
depth_dir = '/esat/qayd/tmp/remote_images/set_6/depth/';

rgb_filenames = dir(rgb_dir);
depth_filenames = dir(depth_dir);

num_images = 2500;
start_dx = 4;
dataset_idx = 1;
for i=start_dx:num_images
    rgb_filename = rgb_filenames(i).name;
    im = imread(fullfile(rgb_dir,rgb_filename));
    im_ = imresize(im, [240,320]);
    subplot(1,2,1);
    imagesc(im_);
    
    depth_filename = depth_filenames(i-1).name;
    depth = imread(fullfile(depth_dir,depth_filename));
    depth_ = imresize(depth, [55,74]);
    subplot(1,2,2);
    imagesc(depth_);
    
    
    gazebo_sim_dataset.images(:,:,:,dataset_idx) = im_;
    gazebo_sim_dataset.labels(:,:,dataset_idx) = depth_;
    
    dataset_idx = dataset_idx + 1;
    pause(0.05);
end

save('/esat/emerald/pchakrav/singleImageDepthDataset/trainingImagesGazebo/gazebo_sim_training1.mat', 'gazebo_sim_dataset');


