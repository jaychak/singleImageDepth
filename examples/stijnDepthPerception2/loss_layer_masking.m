function L = loss_layer(Y,Y_groundtruth,dzdy)
% Scale-Invariant Error as Training Loss
%    

% lambda = 0.5;

% fprintf('Size of feature map Y in loss layer: %d x %d x %d x %d\n',size(Y,1),size(Y,2),size(Y,3),size(Y,4));
% fprintf('Size of groundtruth Y_groundtruth in loss layer: %d x %d x %d x %d\n',size(Y,1),size(Y,2),size(Y,3),size(Y,4));
% size(Y)
% size(Y_groundtruth)

% Y1 = reshape(Y(1,1,:,1),[55 74]);
% figure;
% % Show the image.
% imagesc(Y1);
% axis off;
% axis equal;
% 
% figure;
% % Show the image.
% imagesc(Y_groundtruth(:,:,1));
% axis off;
% axis equal;

% L = []; %%JAY: removing this because this assigns L as double - 
% we want it to be a GPU array.
for i=1:size(Y,4)
    
    % Select the groundtruth image
    Y_grndtrth = Y_groundtruth(:,:,i);
    
    % Find the mask with black points
    mask = (Y_grndtrth(:,:) >= 0.5 & Y_grndtrth(:,:) <= 10);
    
    % Make matrix of array of feature maps 4070 = 55*74
    Y1 = reshape(Y(1,1,:,i),[55 74]);
    
%     Y1 = squeeze(Y(1,1,:,i));
%     Y_ground = Y_groundtruth(:,:,i);
   
    % Determing the amount of pixels
    n = size(Y_grndtrth,1)*size(Y_grndtrth,2);
    
%     Y_ground = reshape(Y_ground,n,1);

    % Calculate difference matrix between predicted depth map Y and groundtruth
    % Y*
%     d = Y1-log(Y_ground); %? Output network is already log y, because the final linear layer predicts the log depth?
%     d = Y1-log(Y_grndtrth); % Euclidean loss
%     d = zeros(size(mask),'gpuArray');
%     d = Y1;
    d = zeros(size(mask),'gpuArray');
    d(mask) = Y1(mask)-log(Y_grndtrth(mask));
    
    alpha = (1/n)*sum(sum(log(Y_grndtrth(mask))-Y1(mask),'omitnan'),'omitnan');
%     alpha = 1/n*sum(alpha,'omitnan');
    
    % Make vector of difference matrix
%     d = reshape(d,n,1);
    one = ones(size(d), 'gpuArray');
    
    if nargin <= 2        
        L(i) = (1/n)*sum(sum((d(mask) + one(mask)*alpha).^2, 'omitnan'), 'omitnan');
%          L(i) = (1/n)*sum(sum(d.^2,'omitnan'),'omitnan') - lambda*(1/n^2)*(sum(sum(d,'omitnan'),'omitnan'))^2; % Eigen loss
%          L(i) = (1/n)*sum(sum(d.^2,'omitnan'),'omitnan'); % Euclidean loss
%             L(i)= (1/n)*sum(sum((d+ones(size(d))*alpha).^2,'omitnan'),'omitnan');
    else
%         dzdx = dzdy*((1/n)*2*d - ones(size(Y1))*((2/n^2)*sum(d)));   % This is not working
%             dzdx = dzdy*(d+ones(size(d))*alpha)*(2-2/n);
%              dzdx = dzdy*d.*(2*ones(size(d))-(2/n)./Y1)+alpha*(2./Y1-(2/n)./Y1);
% dzdx = dzdy*(2)*(d+(1/n)*ones(size(d))*sum(reshape(log(Y_groundtruth(:,:,i))-Y1,n,1),1))*((1/n));
%         dzdx = dzdy*(2)*(d+(1/n)*ones(size(d))*sum(reshape(log(Y_groundtruth(:,:,i))-Y1,n,1),1)).*(1./Y1_r+(-1/n)*sum(1./Y1_r,1));
%            dzdx = dzdy*(2*d -(1/n^2)*sum(sum(d,'omitnan'),'omitnan')*ones(size(d)));  
%          dzdy = dzdy*(1/n)*sum(d);
%         dzdx = (d*dzdy)./reshape(Y1,n,1); % Start with only Euclidean loss
%         dzdx = 2*d*dzdy; % Euclidean loss
        dzdx = 2*d*dzdy;
        dzdx(mask) = dzdx(mask) + 2*one(mask)*alpha*dzdy;
%         dzdx = 2*(d + ones(size(d))*alpha)*dzdy;
%         dzdx = dzdy*(2/n)*d; % Euclidean loss in logaritmic space
%         dzdx =dzdy*((1/n)*2*d./Y1 - ones(size(Y1))*((2/n^2)*sum(d)*sum(1./Y1)));
%         dzdx =dzdy*((1/n)*2*d./Y1 - ((2/n^2)*(d./Y1)));
%           dzdx = ones(size(Y1))*dzdy*((1/n)*2*sum(d./Y1) -
%           ((2/n^2)*sum(d)*sum(1./Y1))); No specific location error
        L(:,:,:,i) = reshape(dzdx,1,1,4070);
    end
    
end

L = single(L);

end

