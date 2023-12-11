import numpy as np
import imageio
import argparse
import os

'''
grayScale = np.load('l/gray_scale.npy')
print(grayScale.shape)

numImages = 50
for i in range(numImages):
    grayImage = grayScale[i]
    output_path = f"images/grayImage{i}.jpg"
    imageio.imsave(output_path, grayImage)
'''
def process_grayscale(images : np.ndarray):
    NUM_IMAGES = 50
    OUT_DIR = "images"
    if not os.path.exists(OUT_DIR):
        os.makedirs(OUT_DIR)
    for i in range(NUM_IMAGES):
        imageio.imsave(f"images/grayImage{i+1}.jpg", images[i])




def main(args):
    if args.grayScale:
        images = np.load('../data/grayscale/gray_scale.npy')
        process_grayscale(images)


if __name__ == "__main__":
    # Create ArgumentParser object
    parser = argparse.ArgumentParser(description="Your script description")

    # Add command-line arguments
    #parser.add_argument("--input_folder", type=str, required=True)
    parser.add_argument("--grayScale", action="store_true")
    parser.add_argument("--colorImage", action="store_true")
    parser.add_argument("--video", action="store_true")
    parser.add_argument("--audio", action="store_true")
    parser.add_argument("--faces", action="store_true")

    # Parse the command-line arguments
    args = parser.parse_args()

    # Call the main function with parsed arguments
    main(args)