clear;
% setup_nongpu;

% image_filenames = dir('/home/stijnwellens/Documents/Thesis/Test_images');
% image_filenames = dir('/esat/wasat/r0300219/NYUv2/processed/images_esat');
% image_filenames = dir('/esat/wasat/r0300219/NYUv2/processed/images_01');
image_filenames = dir('/esat/wasat/r0300219/NYUv2/processed/imgs_7');
% image_filenames = dir('/esat/wasat/r0300219/NYUv2/processed/images2');
% image_filenames = dir('/esat/wasat/r0300219/NYUv2/processed/images_test');

all_filenames={};
filename_idx = 1;
for i=1:numel(image_filenames)
    filename_this = image_filenames(i);
    if filename_this.bytes ~= 0
%         all_filenames{filename_idx} = strcat('/home/stijnwellens/Documents/Thesis/Test_images/',filename_this.name);
%         all_filenames{filename_idx} = strcat('/esat/wasat/r0300219/NYUv2/processed/images_esat/',filename_this.name);
        all_filenames{filename_idx} = strcat('/esat/wasat/r0300219/NYUv2/processed/imgs_7/',filename_this.name);
%         all_filenames{filename_idx} = strcat('/esat/wasat/r0300219/NYUv2/processed/images_01/',filename_this.name);
%         all_filenames{filename_idx} = strcat('/esat/wasat/r0300219/NYUv2/processed/images2/',filename_this.name);
%         all_filenames{filename_idx} = strcat('/esat/wasat/r0300219/NYUv2/processed/images_test/',filename_this.name);
        filename_idx = filename_idx + 1;
    end
end


amountOfImages = 10;
image_idx = 1;
for i=1:amountOfImages
    image_names{image_idx} = all_filenames{i};
    image_idx = image_idx + 1;
    im1 = imread(image_names{i});
    im(:,:,:,i) = im1;
end

% labels_fullset = load('/home/stijnwellens/Documents/Thesis/Test_images/labels/labels.mat');
% labels_fullset = load('/esat/wasat/r0300219/NYUv2/processed/labels/labels2.mat');
% labels_fullset = load('/esat/wasat/r0300219/NYUv2/processed/labels/labels_esat_2.mat');
% labels_fullset = load('/esat/wasat/r0300219/NYUv2/processed/labels/labels_01.mat');
% labels_fullset = load('/esat/wasat/r0300219/NYUv2/processed/labels/labels_esat_denoised.mat');
% labels_fullset = load('/esat/wasat/r0300219/NYUv2/processed/labels/labels_01_denoised_resized.mat');
% labels_fullset = load('/esat/wasat/r0300219/NYUv2/processed/labels/labels_test_denoised.mat');
labels_fullset = load('/esat/wasat/r0300219/NYUv2/processed/labels_filled/labels_9_163.mat');

labels = labels_fullset.labels_processed;

labels_fullset = load('/esat/wasat/r0300219/NYUv2/processed/labels_filled/labels_9_163.mat');
% labels_fullset = load('/esat/wasat/r0300219/NYUv2/processed/labels/labels_01.mat');
% labels_fullset = load('/esat/wasat/r0300219/NYUv2/processed/labels/labels_test.mat');

labels_orig = labels_fullset.labels_processed;

% nyudepth_augmented_labels = load('/esat/emerald/pchakrav/singleImageDepthDataset/allLabels/labels_flip_rot_rand_crop.mat');
% % labels = nyudepth_augmented_labels.labels_orig_flipped_test;
% labels = nyudepth_augmented_labels.labels_all;
% 
% image_filenames = dir('/esat/emerald/pchakrav/singleImageDepthDataset/meanSubtractedFlippedRotatedRandomCrop/');
% all_filenames={};
% filename_idx = 1;
% for i=1:numel(image_filenames)
%     filename_this = image_filenames(i);
%     if filename_this.bytes ~= 0
%         all_filenames{filename_idx} = strcat('/esat/emerald/pchakrav/singleImageDepthDataset/meanSubtractedFlippedRotatedRandomCrop/',filename_this.name);
%         filename_idx = filename_idx + 1;
%     end
% end


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
    
    subplot(1,3,3);
    imagesc(labels_orig(:,:,i));
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
    
 