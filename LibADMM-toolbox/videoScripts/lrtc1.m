addpath(genpath(cd))
clear
currentDir = pwd;
disp(['Current Directory: ' currentDir]);
opts.mu = 1e-6;
opts.rho = 1.1;
opts.max_iter = 500;
opts.DEBUG = 1;

% Specify the directory containing tensor files
tensorDirectory = '../videoTensor/';
% Get a list of all tensor files in the directory
tensorFiles = dir(fullfile(tensorDirectory, '*.mat'));

%% TESTING LOOP
totalErr = 0;
totalIter = 0;
RSE = 0;
psnr_original = 0;
psnr_denoised = 0;
totalImages = 0;
for i = 1:numel(tensorFiles)
    fileName = tensorFiles(i).name;
    tensorData = load(fullfile(tensorDirectory, fileName));
    imageTensor = tensorData.imageArray;
    %size(imageTensor)

    [height, width, numImages] = size(imageTensor);
    imageTensor = double(imageTensor);

    r = 30;
    p = 0.25;
    omega = find(rand(height*width*numImages,1)>p);
    %size(omega)

    M = randn(height,width,numImages,1);
    M = 255 * (M - min(M(:))) / (max(M(:)) - min(M(:)));
    M(omega) = imageTensor(omega);
    size(M);

    [Xhat,obj,err,iter,errArr,iterArr] = lrtc_tnn(M,omega,opts);

    %% CALCULATING METRICS HERE
    totalErr = totalErr + err;
    totalIter = totalIter + iter;
    RSE = RSE + norm(imageTensor-Xhat,'fro')/norm(imageTensor,'fro');
    psnr_original = psnr_original + psnr(imageTensor, M);
    psnr_denoised = psnr_denoised + psnr(imageTensor, Xhat);
    totalImages = totalImages + numImages;



    outputDir = '../videoResults/lrtc1';
    % Check if the output directory exists, if not, create it
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end

    % Loop through each image in the tensor and save it to the output directory
    for j = 1:numImages
        % Extract the image from the tensor
        currentImage = Xhat(:,:,j);
        % Convert the double values back to uint8 (0-255 range)
        currentImage = uint8(currentImage);
        currentImage = squeeze(currentImage);
        % Create a file name (adjust as needed)
        fileName = sprintf('image_%04d.png', j);
        % Save the image to the output directory
        imwrite(currentImage, fullfile(outputDir, fileName));
    end
end

totalErr = totalErr/totalImages
totalIter = totalIter/totalImages
psnr_original = psnr_original/totalImages
psnr_denoised = psnr_denoised/totalImages
RSE = RSE/totalImages

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
saveDir = '../videoResults/plots';

% Check if the directory exists, and create it if not
if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end

saveas(gcf, fullfile(saveDir, 'lrtc1_plot.png'));