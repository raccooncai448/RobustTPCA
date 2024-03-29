addpath(genpath(cd))
clear

opts.mu = 1e-6;
opts.rho = 1.1;
opts.max_iter = 500;
opts.DEBUG = 1;


%% 7: low-rank tensor recovery from Gaussian measurements based on tensor nuclear norm minimization (lrtr_Gaussian_tnn)
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

r = 0.2*height; % tubal rank

m = int32(3*r*(height+width-r)*numImages+1); % number of measurements
n = height*width*numImages;
A = randn(m,n)/sqrt(m);

b = A*imageTensor(:);
Xsize.n1 = height;
Xsize.n2 = width;
Xsize.n3 = numImages;

[Xhat,obj,err,iter,errArr,iterArr]  = lrtr_Gaussian_tnn(A,b,Xsize,opts);

outputDir = 'imageResults/lrtr1';
% Check if the output directory exists, if not, create it
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Save each 2D slice as a grayscale image
for i = 1:size(Xhat, 3)
    % Extract the 2D slice
    slice = Xhat(:, :, i);
    
    % Normalize the values to the range [0, 1] (assuming the data is not in this range)
    normalizedSlice = mat2gray(slice);
    
    % Save the grayscale image
    imageName = sprintf('image_%02d.jpg', i);  % Adjust the filename format as needed
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

saveas(gcf, fullfile(saveDir, 'lrtr1_plot.png'));

RSE = norm(Xhat(:)-X(:))/norm(X(:))
trank = tubalrank(Xhat)