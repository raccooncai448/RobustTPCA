addpath(genpath(cd))
addpath(genpath(fileparts(pwd)))
clear
opts.mu = 1e-6;
opts.rho = 1.1;
opts.max_iter = 500;
opts.DEBUG = 1;

% Define the path to the main folder
mainFolderPath = '../faces';

% Get a list of all subfolders in the main folder
subfolders = dir(mainFolderPath);
subfolders = subfolders([subfolders.isdir] & ~ismember({subfolders.name}, {'.', '..'}));

% Check if there are any subfolders
if ~isempty(subfolders)
    % Get the name of the first subfolder
    firstSubfolder = subfolders(1).name;
    
    % Construct the path to the first subfolder
    firstSubfolderPath = fullfile(mainFolderPath, firstSubfolder);
    
    % Get a list of all files in the first subfolder
    files = dir(fullfile(firstSubfolderPath, '*.png'));
    
    % Loop through each file in the first subfolder and load the image
    for i = 1:numel(files)
        filePath = fullfile(firstSubfolderPath, files(i).name);
        img = imread(filePath);
        [height, width] = size(img);

        imageTensor = reshape(img, size(img, 1), size(img, 2), 1);
        imageTensor = double(imageTensor);
        lambda = 1/sqrt(max(height,width));
        
        [Xhat,Shat,obj,err,iter,errArr,iterArr] = trpca_tnn(imageTensor,lambda,opts);
        outputDir = '../faceResults/trpca1';
        % Check if the output directory exists, if not, create it
        if ~exist(outputDir, 'dir')
            mkdir(outputDir);
        end
        
        % Save each 2D slice as a grayscale image
        % Normalize the values to the range [0, 1] (assuming the data is not in this range)
        normalizedSlice = mat2gray(Xhat);
        noisySlice = mat2gray(Shat);
        imageName = sprintf('lowRank_%02d.jpg', i);
        imwrite(normalizedSlice, fullfile(outputDir, imageName))
            
        % Save the grayscale image
        imageName = sprintf('sparse_%02d.jpg', i);  % Adjust the filename format as needed
        imwrite(noisySlice, fullfile(outputDir, imageName));
    end
else
    disp('No subfolders found.');
end

% %% TESTING LOOP
% psnr_original = 0;
% psnr_denoised = 0;
% totalErr = 0;
% totalIter = 0;
% RSE = 0;
% for i = 1:numImages
%     [height, width] = size(images{1});
%     
%     imageTensor = reshape(images{i}, size(images{i}, 1), size(images{i}, 2), 1);
%     imageTensor = double(imageTensor);
%     
%     r = 20;
%     p = 0.25;
%     omega = find(rand(height*width,1)>p);
% 
%     M = randn(height,width,1);
%     M = 255 * (M - min(M(:))) / (max(M(:)) - min(M(:)));
%     M(omega) = imageTensor(omega);
%     lambda = [0.5 0.5 0.5];
%     
%     [Xhat,Shat,err,iter,errArr,iterArr] = trpca_snn(M,lambda,opts);
%     totalErr = totalErr + err;
%     totalIter = totalIter + iter;
%     RSE = RSE + norm(imageTensor-Xhat)/norm(imageTensor);
%     psnr_original = psnr_original + psnr(imageTensor, M);
%     psnr_denoised = psnr_denoised + psnr(imageTensor, Xhat);
%     
%     
%     outputDir = '/MATLAB Drive/LibADMM-toolbox/imageResults/rsnn1';
%     % Check if the output directory exists, if not, create it
%     if ~exist(outputDir, 'dir')
%         mkdir(outputDir);
%     end
%     
%     % Save each 2D slice as a grayscale image
%     % Normalize the values to the range [0, 1] (assuming the data is not in this range)
%     normalizedSlice = mat2gray(Xhat);
%     noisySlice = mat2gray(M);
%     imageName = sprintf('noisy_%02d.jpg', i);
%     imwrite(noisySlice, fullfile(outputDir, imageName))
%         
%     % Save the grayscale image
%     imageName = sprintf('image_%02d.jpg', i);  % Adjust the filename format as needed
%     imwrite(normalizedSlice, fullfile(outputDir, imageName));
% end
% 
% totalErr = totalErr/numImages
% totalIter = totalIter/numImages
% psnr_original = psnr_original/numImages
% psnr_denoised = psnr_denoised/numImages
% RSE = RSE/numImages
% 
% %% PLOTS
% % Line Plot
% figure;
% plot(iterArr, errArr, 'r-', 'LineWidth', 2, 'DisplayName', 'Error');
% hold on;
% xlabel('Iterations');
% ylabel('Error');
% title('Error Plot');
% legend;
% grid on;
% hold off;
% 
% 
% % Save the plot in the specified directory
% saveDir = '/MATLAB Drive/LibADMM-toolbox/imageResults/plots';
% 
% % Check if the directory exists, and create it if not
% if ~exist(saveDir, 'dir')
%     mkdir(saveDir);
% end
% 
% saveas(gcf, fullfile(saveDir, 'snn1_plot.png'));