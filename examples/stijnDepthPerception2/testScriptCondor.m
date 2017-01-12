% Matlab test job, using GPU

fprintf('Calculate the inverse of a 5000x5000 on GPU');

tic

A = rand(5000,5000,'gpuArray');
B = inv(A);

max(max(A*B))

toc

fprintf('Calculate the inverse of a 5000x5000 on CPU');

tic

A = rand(5000,5000);
B = inv(A);

max(max(A*B))

toc