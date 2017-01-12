%% Some code to restore the bad label files into the good ones (size of label files is too big after processing with syncKinectImages function)
% Stijn Wellens
% April, 2016


clear;

%% GET THE DATA

% Use only the directories we want
% wanted_dirs = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,17,23];
% wanted_dirs = [5,16,18,19,21,22];
wanted_dirs = [20];

% Load label files out order
all_labeldirs = dir('/esat/wasat/r0300219/NYUv2/processed/labels_filled/');
label_filenames={};
filename_idx = 1;
for i=1:numel(all_labeldirs)
    filename_this = all_labeldirs(i);
    if (filename_this.bytes ~= 0 && isempty(strfind(filename_this.name,'esat')))
        label_filenames{filename_idx} = strcat('/esat/wasat/r0300219/NYUv2/processed/labels_filled/',filename_this.name);
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

for i=1:numel(label_filenames)
    labels = load(label_filenames{i});
    
    labels_name = labels.labels_name;
    labels_processed = labels.labels_processed;
    labels_processed = labels_processed(:,:,1:numel(labels_name));
    
    save(sprintf('/esat/wasat/r0300219/NYUv2/processed/labels_filled_proc/labels_%d_%d.mat',label_dirs(i), label_numbers(i)), 'labels_processed', 'labels_name');
%     save(sprintf('/esat/wasat/r0300219/NYUv2/processed/labels_filled_proc/labels_esat_%d.mat', label_numbers(i)), 'labels_processed', 'labels_name');
end

