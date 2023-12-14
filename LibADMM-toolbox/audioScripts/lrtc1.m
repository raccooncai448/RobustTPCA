addpath(genpath(fullfile(cd, '..')));
clear
opts.mu = 1e-6;
opts.rho = 1.1;
opts.max_iter = 500;
opts.DEBUG = 1;

% Specify the directory containing tensor files
tensorDirectory = '/Users/shcai/RobustTPCA/LibADMM-toolbox/audio'
% Get a list of all tensor files in the directory
tensorFiles = dir(fullfile(tensorDirectory, '*.wav'));

%% TESTING LOOP
totalErr = 0;
totalIter = 0;
RSE = 0;
psnr_original = 0;
psnr_denoised = 0;

%% PARAMTERS for FFT
windowSize = 1024;
overlap = windowSize/2;
nfft = 1024;
for i = 1:numel(tensorFiles)
    fileName = fullfile(tensorDirectory,tensorFiles(i).name);
    % Load audio file
    filename = 'your_audio_file.wav';
    [y, fs] = audioread(fileName);
    y
    
    % Parameters
    window_size = 1024;  % Adjust as needed
    overlap = 512;      % Adjust as needed
    
    % Spectrogram computation
    [S, f, t] = spectrogram(y, hamming(window_size), overlap, [], fs);
    
    % Create a 3D tensor with dimensions time, frequency, and amplitude
    tensor_3d = permute(abs(S), [3, 1, 2]);
    
    % Reshape denoised matrix to 3D tensor
    denoised_tensor = reshape(tensor_3d, size(tensor_3d));
    
    % Reconstruct the denoised audio signal
    denoised_S = permute(denoised_tensor, [2, 3, 1]);
    denoised_y = istft(denoised_S, hamming(window_size), overlap, [], fs);
    
    % Save the denoised audio file
    output_filename = 'denoised_audio.wav';
    audiowrite(output_filename, denoised_y, fs);





    r = 20;
    p = 0.05;
    omega = find(rand(F*T*A,1)>p);
    %size(omega)

    M = randn(F,T,A,1);
    M = 255 * (M - min(M(:))) / (max(M(:)) - min(M(:)));
    M(omega) = audioTensor(omega);
    size(M);

    [Xhat,obj,err,iter,errArr,iterArr] = lrtc_tnn(M,omega,opts);

    %% CALCULATING METRICS HERE
    totalErr = totalErr + err;
    totalIter = totalIter + iter;
    RSE = RSE + norm(audioTensor-Xhat,'fro')/norm(audioTensor,'fro');
    psnr_original = psnr_original + psnr(audioTensor, M);
    psnr_denoised = psnr_denoised + psnr(audioTensor, Xhat);



    outputDir = '/MATLAB Drive/LibADMM-toolbox/audioResults/lrtc1';
    % Check if the output directory exists, if not, create it
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end

end

dirLen = numel(tensorFiles);
totalErr = totalErr/dirLen
totalIter = totalIter/dirLen
psnr_original = psnr_original/dirLen
psnr_denoised = psnr_denoised/dirLen
RSE = RSE/dirLen

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
saveDir = '/MATLAB Drive/LibADMM-toolbox/videoResults/plots';

% Check if the directory exists, and create it if not
if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end

saveas(gcf, fullfile(saveDir, 'lrtc1_plot.png'));