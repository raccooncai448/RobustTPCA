addpath(genpath(cd))
clear
opts.mu = 1e-6;
opts.rho = 1.1;
opts.max_iter = 500;
opts.DEBUG = 1;
imageDir = '/MATLAB Drive/LibADMM-toolbox/images'; % Replace with the path to your images
imageFiles = dir(fullfile(imageDir, '*.jpg')); % Change the file extension if necessary
numImages = numel(imageFiles);
images = cell(1, numImages);
for i = 1:numImages
    images{i} = imread(fullfile(imageDir, imageFiles(i).name));
end

%% TESTING LOOP
psnr_original = 0;
psnr_denoised = 0;
totalErr = 0;
totalIter = 0;
RSE = 0;
for i = 1:numImages
    [height, width] = size(images{1});
    
    imageTensor = reshape(images{i}, size(images{i}, 1), size(images{i}, 2), 1);
    imageTensor = double(imageTensor);
    
    r = 20;
    p = 0.25;
    omega = find(rand(height*width,1)>p);

    M = randn(height,width,1);
    M = 255 * (M - min(M(:))) / (max(M(:)) - min(M(:)));
    M(omega) = imageTensor(omega);
    lambda = [0.5 0.5 0.5];
    
    [Xhat,err,iter,errArr,iterArr] = lrtcR_snn(M,omega,lambda,opts);
    totalErr = totalErr + err;
    totalIter = totalIter + iter;
    RSE = RSE + norm(imageTensor-Xhat)/norm(imageTensor);
    psnr_original = psnr_original + psnr(imageTensor, M);
    psnr_denoised = psnr_denoised + psnr(imageTensor, Xhat);
    
    
    outputDir = '/MATLAB Drive/LibADMM-toolbox/imageResults/rsnn1';
    % Check if the output directory exists, if not, create it
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    % Save each 2D slice as a grayscale image
    % Normalize the values to the range [0, 1] (assuming the data is not in this range)
    normalizedSlice = mat2gray(Xhat);
    noisySlice = mat2gray(M);
    imageName = sprintf('noisy_%02d.jpg', i);
    imwrite(noisySlice, fullfile(outputDir, imageName))
        
    % Save the grayscale image
    imageName = sprintf('image_%02d.jpg', i);  % Adjust the filename format as needed
    imwrite(normalizedSlice, fullfile(outputDir, imageName));
end

totalErr = totalErr/numImages
totalIter = totalIter/numImages
psnr_original = psnr_original/numImages
psnr_denoised = psnr_denoised/numImages
RSE = RSE/numImages

%% PLOTS
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

saveas(gcf, fullfile(saveDir, 'rsnn1_plot.png'));