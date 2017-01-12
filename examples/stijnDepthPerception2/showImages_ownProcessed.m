clear;
% setup_nongpu;


% image_filenames = dir('/esat/wasat/r0300219/NYUv2/processed/imgs_1');
% 
% all_filenames={};
% filename_idx = 1;
% for i=1:numel(image_filenames)
%     filename_this = image_filenames(i);
%     if filename_this.bytes ~= 0
%         all_filenames{filename_idx} = strcat('/esat/wasat/r0300219/NYUv2/processed/imgs_1/',filename_this.name);
%         filename_idx = filename_idx + 1;
%     end
% end
% 
% 
% % amountOfImages = 10;
% % amountOfImages = numel(all_filenames);
% image_idx = 6427;
% for i=6427:6434%1:amountOfImages
%     image_names{image_idx} = all_filenames{i};
%     image_idx = image_idx + 1;
%     im1 = imread(image_names{i});
%     im(:,:,:,i) = im1;
% end
% 
% labels_fullset = load('/esat/wasat/r0300219/NYUv2/processed/labels_filled_proc/labels_1_6650.mat');
% 
% labels = labels_fullset.labels_processed;

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
% wanted_dirs = [1,2,3,4,5,7,8,9,10,11,12,13,14];
wanted_dirs = [1];
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

% Load label files out order
all_labeldirs = dir('/esat/wasat/r0300219/NYUv2/processed/labels_filled_proc/');
label_filenames={};
filename_idx = 1;
for i=1:numel(all_labeldirs)
    filename_this = all_labeldirs(i);
    if (filename_this.bytes ~= 0 && isempty(strfind(filename_this.name,'esat')))
        label_filenames{filename_idx} = strcat('/esat/wasat/r0300219/NYUv2/processed/labels_filled_proc/',filename_this.name);
        C = strsplit(filename_this.name,'_');
        D = strsplit(C{3},'.');
        label_dirs(filename_idx) = str2num(C{2}); % folder number
        label_numbers(filename_idx) = str2num(D{1}); % number of all labels till that file
        filename_idx = filename_idx + 1;
    end
end

% Select labels from only the wanted directories
for ii=1:numel(label_dirs)
   if ismember(label_dirs(ii),wanted_dirs)
       mask(ii) = 1;
   else
       mask(ii) = 0;
   end
end

label_filenames = label_filenames(mask==1);
label_dirs = label_dirs(mask==1);
label_numbers = label_numbers(mask==1);

% Order label files.
label_dirs2 = label_dirs;
[label_dirs2, index] = sort(label_dirs2,'ascend');
label_filenames2 = label_filenames(index);
label_numbers2 = label_numbers(index);

% Find begin directory and end directory
folder_nmb_min = label_dirs2(1);
folder_nmb_max = label_dirs2(end);

% Sort all label files of the same directory
folder_nmb = folder_nmb_min;
start = 1;
label_imgnumbers(1) = 0;
for i=1:numel(label_filenames2)
   if(folder_nmb == label_dirs2(i))
      
   else
      [label_numbers2(start:(i-1)), index] = sort(label_numbers2(start:(i-1)),'ascend');
      tmp_labels = label_filenames2(start:(i-1));
      label_filenames2(start:(i-1)) = tmp_labels(index);
      
      for ii=start:i-1
          label_imgnumbers(end+1) = label_imgnumbers(start) + label_numbers2(ii) - 1;
      end
      
      folder_nmb = label_dirs2(i);
      start = i;
   end
end

% Do it the last time
i = i +1;

[label_numbers2(start:(i-1)), index] = sort(label_numbers2(start:(i-1)),'ascend');
tmp_labels = label_filenames2(start:(i-1));
label_filenames2(start:(i-1)) = tmp_labels(index);

for ii=start:i-1
  label_imgnumbers(end+1) = label_imgnumbers(start) + label_numbers2(ii) - 1;
end

label_imgnumbers = label_imgnumbers(2:end);


numel(all_filenames)
% Load all labels at once -- fast alternative/lots of memory needed
tic
labels = zeros(55,74,numel(all_filenames));
lastl= 0;
for i=1:numel(label_filenames2)
    all_labels = load(label_filenames2{i});
    all_labels = all_labels.labels_processed;
    labels(:,:,lastl+1:lastl+size(all_labels,3)) = all_labels;
    lastl = lastl+size(all_labels,3)
end
toc



for i=2457:2460%amountOfImages%nmb_training+1:nmb_training+nmb_results%+1:nmb_images
    
%     image_filename = strcat('/esat/emerald/pchakrav/singleImageDepthDataset/meanSubtractedFlippedRotatedRandomCrop/', num2str(i,'%05d'), '.jpeg');
%     image = im2single(imread(image_filename));
    image = single(imread(all_filenames{i}));
    
    figure;
    subplot(1,3,1);
    imagesc(uint8(image));
    %imagesc(im(:,:,:,1));
    axis off;
    axis equal;
    title('RGB - mean');

    subplot(1,3,2);
    imagesc(labels(:,:,i));
    axis off;
    axis equal;
    title('Depth groundtruth');
    
%     dzdy = [];
%     res=[];
%     res = vl_simplenn(net, image, dzdy, res, ... 
%                       'mode', 'test', ...
%                       'conserveMemory', false, ...
%                       'backPropDepth', +inf, ...
%                       'sync', false, ...
%                       'cudnn', false) ;%);
%     %                       'accumulate', s ~= 1, ...
%     
%     output = reshape(res(end-1).x(1,1,:),[55 74]);
%     
%     %output = reshape(res(end).x(1,1,:),[55 74]);
%     
%     
%     subplot(1,3,3);
%     %imagesc(uint8(output));
%     imagesc(output);
%     axis off;
%     axis equal;
%     title('Depth prediction');
    
%     pause;
end
    
 