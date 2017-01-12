function [ directions ] = getDirections( depth, window_length)
%GETDIRECTIONS Calculate all directions where the drone could go to
%   Returns a matrix for each depth map with the accessible directions (1) and
%   the directions not to go to (0)

% Choose the time window length = nmb of frames took together
% window_length = 10;
columnWidth = 5;
nmbDirections = 3; % HARDCODED!

windowNmb = 1;
directions = ones(nmbDirections,size(depth,3)); 
for i=1:window_length:size(depth,3)

    % The depth images are 74 pixels wide
    windowDepth = mean(depth(:,:,i:i+window_length-1),3);

    % Scan region in the middle of the image for close obstacles and ignore
    % these directions
%     windowDepth_inMiddle = windowDepth(10:45,:,:);
%     [I,J] = find(windowDepth_inMiddle <= 1); % If depth in that direction is lower than 1 meter, don't go in that direction 
%     
%     if ~isempty(J)
%        for ii=1:size(J)
%            if J(ii) <= 74/nmbDirections
%                 directions(1,i:window_length+i) = 0;
%            else if J(ii) > 2*(74/nmbDirections)
%                 directions(3,i:window_length+i) = 0;   
%            else
%                 directions(2,i:window_length+i) = 0; 
%            end
%        end
%     end
    
    depthColumns = [];
    for ii = 1:74-columnWidth
        depthColumns(:,ii) = mean(windowDepth(:,ii:ii+columnWidth),2);
    end
    
    % Select only points where drone flies (it can fly above objects)
    depthColumns = depthColumns(11:45,:);%16:40,:);
    
    factor = size(depthColumns,2)/3;
    
    depthDirection(1) = min(min(depthColumns(:,1:ceil(factor))));
    depthDirection(2) = min(min(depthColumns(:,ceil(factor):floor(2*factor))));
    depthDirection(3) = min(min(depthColumns(:,floor(2*factor):size(depthColumns,2))));
    
    for k=1:size(depthDirection,2)
       if(0.1<= depthDirection(k) && depthDirection(k) <= 1.6) % If depth in that direction is lower than 2 meters, don't go in that direction 
           directions(k,i:i+window_length-1) = 0;
       elseif(1.6<depthDirection(k) && depthDirection(k) <= 10)
           directions(k,i:i+window_length-1) = 1;    
       else
           directions(k,i:i+window_length-1) = -1;
       end        
    end
    
%     [M, I] = max(depthColumns); % The direction where obstacles are the furthest away

%     nmbColumns = size(depthColumns,2);
%     factor = nmbColumns/nmbDirections;
%     directions(windowNmb) = round((I-1)/factor);

    windowNmb = windowNmb +1;
end

% Smoothing
alpha = 0.55;
beta = 0.35;
for i=3:size(directions,2)
   directions(:,i) = round(directions(:,i)*alpha + directions(:,i-1)*beta + directions(:,i-2)*(1-(alpha+beta))); 
end

end

