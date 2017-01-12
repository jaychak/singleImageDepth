function normalize_gazebo_sim_training_data()


root_dir = '/esat/emerald/tmp/remote_images/continuous_expert/';

dir_files = dir(root_dir);

% Calculate depth images and save features

for i=3:numel(dir_files)
    
    this_dir_name = dir_files(i).name
    if numel(strfind(this_dir_name,'.txt')) == 0
        write_folder_name = fullfile(root_dir,this_dir_name,'cnn_features');
        
        read_file_name = strcat(write_folder_name,'/depth_estimate_',this_dir_name,'_stijn.mat');%, 'gazebo_sim_dataset');
        
        gazebo_sim_dataset_ = load(read_file_name)
        gazebo_sim_dataset = gazebo_sim_dataset_.gazebo_sim_dataset;
        for j=1:size(gazebo_sim_dataset.labels,1)
            depth_map_this = gazebo_sim_dataset.labels(j,:);
            depth_map_this_normalized = (depth_map_this+1)/1.75;
            gazebo_sim_dataset.labels(j,:) = depth_map_this_normalized;
        end
        save(strcat(write_folder_name,'/depth_estimate_normalized_',this_dir_name,'_stijn.mat'), 'gazebo_sim_dataset');
        
    end
end