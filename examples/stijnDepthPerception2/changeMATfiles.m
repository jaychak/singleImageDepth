% Script to go from the coarsecnn.m file to a net-epoch-x.m file
% Stijn Wellens
% 3 March 2016

clear;

epoch = 20;
coarsecnn = load('data/coarse_depth/coarsecnn.mat');
lastit = load('data/coarse_depth/last_it.mat');

% net = coarsecnn;