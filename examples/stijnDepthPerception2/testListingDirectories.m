%% A script to synchronize raw Kinect data and to produce RGB-images en depthmaps from it
% Stijn Wellens
% March, 2016

addpath('toolbox_nyu_depth_v2');
run toolbox_nyu_depth_v2/compile;

% The directory where you extracted the raw dataset.
% datasetDir = '/users/start2013/r0300219/Documents/Thesis/depth_mapping_with_CNN/data/NYU'; %[PATH TO THE NYU DEPTH V2 RAW DATASET]
% datasetDir = '.';
datasetDir = '/esat/wasat/r0300219/NYUv2/raw';

% Go over all files in the current datasetDir.
files = dir(datasetDir);
% Search for directories.
dirFlags = [files.isdir];
% Only keep the directories
directories = files(dirFlags);

directories = directories(3:end); % Remove . and ..

for k = 1 :1: size(directories,1)
    % The name of the scene to demo.
    C = strsplit(directories(k).name,'_');
    sceneName = C{1}; %[NAME OF A SCENE YOU WANT TO VIEW]
%     afterName = '_0001a'

    % The absolute directory of the 
%     sceneDir = sprintf('%s/%s', datasetDir, sceneName, afterName);
    sceneDir = sprintf('%s/%s', datasetDir, directories(k).name)    
end