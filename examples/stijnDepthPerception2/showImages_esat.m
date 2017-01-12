clear;
% setup_nongpu;

% Load all images from the ESAT testset
all_filenames={};
image_filenames = dir('/esat/wasat/r0300219/NYUv2/processed/images_esat_filled/');
filename_idx = numel(all_filenames) + 1;
for i=1:numel(image_filenames)
    filename_this = image_filenames(i);
    if filename_this.bytes ~= 0
        all_filenames{filename_idx} = strcat('/esat/wasat/r0300219/NYUv2/processed/images_esat_filled/',filename_this.name);
        filename_idx = filename_idx + 1;
    end
end

% Load label files out order
all_labeldirs = dir('/esat/wasat/r0300219/NYUv2/processed/labels_filled_proc/');
label_filenames={};
filename_idx = 1;
for i=1:numel(all_labeldirs)
    filename_this = all_labeldirs(i);
    if (filename_this.bytes ~= 0 && ~isempty(strfind(filename_this.name,'esat')))
        label_filenames{filename_idx} = strcat('/esat/wasat/r0300219/NYUv2/processed/labels_filled_proc/',filename_this.name);
        C = strsplit(filename_this.name,'_');
        D = strsplit(C{3},'.');
%         label_dirs(filename_idx) = str2num(C{2}); % folder number
        label_numbers(filename_idx) = str2num(D{1}); % number of all labels till that file
        filename_idx = filename_idx + 1;
    end
end

% Sort all label files of the same directory
start = 1;
label_imgnumbers(1) = 0;

[label_numbers, index] = sort(label_numbers,'ascend');
label_filenames = label_filenames(index);


numel(label_filenames)
numel(all_filenames)
% Load all labels at once -- fast alternative/lots of memory needed
tic
labels = zeros(55,74,numel(all_filenames));
lastl= 0;
for i=1:numel(label_filenames)
    all_labels = load(label_filenames{i});
    all_labels = all_labels.labels_processed;
    labels(:,:,lastl+1:lastl+size(all_labels,3)) = all_labels;
    lastl = lastl+size(all_labels,3)
end
toc

amountOfImages = 5;
image_idx = 1;
for i=1:amountOfImages
    image_names{image_idx} = all_filenames{i};
    image_idx = image_idx + 1;
    im1 = imread(image_names{i});
    im(:,:,:,i) = im1;
end

for i=1:amountOfImages%nmb_training+1:nmb_training+nmb_results%+1:nmb_images
    
%     image_filename = strcat('/esat/emerald/pchakrav/singleImageDepthDataset/meanSubtractedFlippedRotatedRandomCrop/', num2str(i,'%05d'), '.jpeg');
%     image = im2single(imread(image_filename));
    image = single(im(:,:,:,i));
    
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
    
%     subplot(1,3,3);
%     imagesc(labels_orig(:,:,i));
%     axis off;
%     axis equal;
%     title('Depth groundtruth');
    
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
    
 