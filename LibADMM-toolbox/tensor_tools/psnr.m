function psnr_value = psnr(original_image, reconstructed_image)
    % Ensure the images are of the same size
    assert(all(size(original_image) == size(reconstructed_image)), 'Images must be of the same size');

    % Convert images to double precision
    original_image = double(original_image) / 255.0; % assuming original_image is in the range [0, 255]
    reconstructed_image = double(reconstructed_image) / 255.0; % assuming reconstructed_image is in the range [0, 255]

    % Calculate the Mean Squared Error (MSE)
    mse = mean((original_image(:) - reconstructed_image(:)).^2);

    % Calculate the maximum possible pixel value
    max_pixel_value = 1; % assuming the images are in the range [0, 1]

    % Calculate PSNR
    psnr_value = 10 * log10((max_pixel_value^2) / mse);
end
