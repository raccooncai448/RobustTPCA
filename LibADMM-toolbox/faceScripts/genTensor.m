addpath(genpath(cd))
clear
opts.mu = 1e-6;
opts.rho = 1.1;
opts.max_iter = 500;
opts.DEBUG = 1;

% Specify the path to the video folder
videoFolderPath = '/MATLAB Drive/LibADMM-toolbox/video/';

% Get a list of all subfolders in the video folder
subfolders = dir(videoFolderPath);
subfolders = subfolders([subfolders.isdir] & ~ismember({subfolders.name}, {'.', '..'}));

% Initialize a cell array to store tensors
tensorList = cell(1, numel(subfolders));

% Loop through each subfolder
for folderIdx = 1:numel(subfolders)
    disp(['Processed folder ', num2str(folderIdx), '/', num2str(numel(subfolders))]);
    currentFolder = fullfile(videoFolderPath, subfolders(folderIdx).name);

    % Get a list of all images in the current subfolder
    imageFiles = dir(fullfile(currentFolder, '*.png')); % Assuming the images are in PNG format

    % Read the first image to get its dimensions
    firstImage = imread(fullfile(currentFolder, imageFiles(1).name));
    [height, width, channels] = size(firstImage);
    numImages = numel(imageFiles);
    imageArray = zeros([round(height/10), round(width/10), numImages], 'uint8');

    % Loop through each image and concatenate them into a tensor
    for imageIdx = 1:numel(imageFiles)
        img = imread(fullfile(currentFolder, imageFiles(imageIdx).name));
        img = imresize(img, 1/10);
        img = rgb2gray(img);
        % Store the image in the array
        %size(img)
        imageArray(:, :, imageIdx) = img;
    end

    size(imageArray)

    save(['/MATLAB Drive/LibADMM-toolbox/videoTensor/', 'tensor_', num2str(folderIdx), '.mat'], 'imageArray');
end