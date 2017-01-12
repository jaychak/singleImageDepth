%% Calculate the mean image of a set of images
% Stijn Wellens
% March, 2016

% setup;

%% Get the data

% image_filenames = dir('/esat/wasat/r0300219/NYUv2/processed/images_01/');
% all_filenames={};
% filename_idx = 1;
% for i=1:numel(image_filenames)
%     filename_this = image_filenames(i);
%     if filename_this.bytes ~= 0
%         all_filenames{filename_idx} = strcat('/esat/wasat/r0300219/NYUv2/processed/images_01/',filename_this.name);
%         filename_idx = filename_idx + 1;
%     end
% end
% 
% all_filenames = all_filenames(1:43648);

% Find all directories with images in one directory
all_dirs = dir('/esat/wasat/r0300219/NYUv2/processed/');
dir_list={};
for ii=1:numel(all_dirs)
    dir_this = all_dirs(ii);
    if(~isempty(strfind(dir_this.name,'imgs')))
          C = strsplit(dir_this.name,'_');
          nmb = str2num(C{2});
          dir_list{nmb} = strcat('/esat/wasat/r0300219/NYUv2/processed/',dir_this.name,'/');
    end
end

% Use only the directories we want
wanted_dirs = [1,2,3,4,6,7,8,9,10,11,12,13,14,16,17,18,19];
% wanted_dirs = [11];
tmp_dir_list = {};
for ii=1:numel(dir_list)
   if ismember(ii,wanted_dirs)
       tmp_dir_list{end+1} = dir_list{ii};
   end
end

dir_list = tmp_dir_list;

all_filenames={};
for ii=1:numel(dir_list)
    if(~isempty(dir_list{ii}))
        image_filenames = dir(dir_list{ii});
        filename_idx = numel(all_filenames) + 1;
        for i=1:numel(image_filenames)
            filename_this = image_filenames(i);
            if filename_this.bytes ~= 0
                all_filenames{filename_idx} = strcat(dir_list{ii},filename_this.name);
                filename_idx = filename_idx + 1;
            end
        end
    end
end

all_filenames = all_filenames(1:314432);

%% Get mean image
batch_size = 32;
% mean_idx = 1;
image_means = [];
for i=1:batch_size:numel(all_filenames)
    for j=1:batch_size
        image_names{j} = all_filenames{i+j-1};
    end
    
    images = vl_imreadjpeg(image_names, 'NumThreads', 8);
    
    for k=1:numel(images)
        im(:,:,:,k) = images{k};
    end
    
    image_means(:,:,:,end+1) = mean(im, 4);
%     mean_idx = mean_idx + 1;
    i
end

image_mean = mean(image_means,4);
% figure,imshow(uint8(image_mean));
save('/esat/wasat/r0300219/Thesis/mean_image_NYUv2.mat', 'image_mean');

