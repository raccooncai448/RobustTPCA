addpath(genpath(cd))
clear

opts.mu = 1e-6;
opts.rho = 1.1;
opts.max_iter = 500;
opts.DEBUG = 1;


%% 4: Tensor RRPCA based on tensor nuclear norm minimization (rpca_tnn)
imageDir = '/MATLAB Drive/LibADMM-toolbox/images'; % Replace with the path to your images
imageFiles = dir(fullfile(imageDir, '*.jpg')); % Change the file extension if necessary
numImages = numel(imageFiles);

% Read images and store them in a cell array
images = cell(1, numImages);
for i = 1:numImages
    images{i} = imread(fullfile(imageDir, imageFiles(i).name));
end

[height, width] = size(images{1});
imageTensor = zeros(height, width, numImages);

for i = 1:numImages
    imageTensor(:, :, i) = images{i};
end

r = 0.1*height; % tubal rank

p = 0.05;
m = p*height*width*numImages;
temp = rand(height*width*numImages,1);
[~,I] = sort(temp);
I = I(1:m);
Omega = zeros(height,width,numImages);
Omega(I) = 1;
E = sign(rand(height,width,numImages)-0.5);
S = Omega.*E; % sparse part, S = P_Omega(E)

Xn = imageTensor+S;
lambda = 1/sqrt(numImages*max(height,width));

tic
[Lhat,Shat,obj,err,iter,errArr,iterArr] = trpca_tnn(Xn,lambda,opts);

outputDir = 'imageResults/trpca1';
% Check if the output directory exists, if not, create it
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Save each 2D slice as a grayscale image
for i = 1:size(Lhat, 3)
    % Extract the 2D slice
    slice = Lhat(:, :, i);
    
    % Normalize the values to the range [0, 1] (assuming the data is not in this range)
    normalizedSlice = mat2gray(slice);
    
    % Save the grayscale image
    imageName = sprintf('image_%02d_03.jpg', i);  % Adjust the filename format as needed
    imwrite(normalizedSlice, fullfile(outputDir, imageName));
end

for i = 1:size(Xn, 3)
    % Extract the 2D slice
    slice = Xn(:, :, i);
    
    % Normalize the values to the range [0, 1] (assuming the data is not in this range)
    normalizedSlice = mat2gray(slice);
    
    % Save the grayscale image
    imageName = sprintf('image_corrupted_%02d.jpg', i);  % Adjust the filename format as needed
    imwrite(normalizedSlice, fullfile(outputDir, imageName));
end

% Line Plot
figure;
plot(iterArr, errArr, 'r-', 'LineWidth', 2, 'DisplayName', 'Error');
hold on;
xlabel('Iterations');
ylabel('Error');
title('Error Plot');
legend;
grid on;
hold off;


% Save the plot in the specified directory
saveDir = 'imageResults/plots';

% Check if the directory exists, and create it if not
if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end

saveas(gcf, fullfile(saveDir, 'trpca_plot_3.png'));

RES_L = norm(imageTensor(:)-Lhat(:))/norm(imageTensor(:))
RES_S = norm(S(:)-Shat(:))/norm(S(:))
trank = tubalrank(Lhat)