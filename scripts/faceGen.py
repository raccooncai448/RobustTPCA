import numpy as np
import cv2
import random
import os


# image_path = 'noisy/0/1.pgm'
# image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

# # Check if the image is loaded successfully
# if image is not None:
#     # Display the image using OpenCV
#     cv2.imshow('PGM Image', image)
#     cv2.waitKey(0)
#     cv2.destroyAllWindows()
# else:
 #   print(f"Failed to load the image at path: {image_path}")

def load_images(root_folder):
    all_images = []
    sub_list = []

    # Traverse the root folder
    for folder_name, subfolders, filenames in os.walk(root_folder):
        if (folder_name == "../data/faces"):
            continue
        images_in_folder = []
        sub_list.append(folder_name)

        for filename in filenames:
            # Check if the file is a PGM image
            if filename.endswith('.pgm'):
                # Construct the full path to the image
                image_path = os.path.join(folder_name, filename)
                #print('here')

                # Read the PGM image using cv2
                image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

                # Append the image to the list for the current subfolder
                images_in_folder.append(image)

        # Append the list of images for the current subfolder to the main list
        all_images.append(images_in_folder)

    return all_images, sub_list

# Provide the path to the root folder containing subfolders with PGM files
root_folder_path = "../data/faces"
# Call the function to parse the faces folder
image_list, subdirs = load_images(root_folder_path)

for i, (dir, original_subdir) in enumerate(zip(image_list, subdirs)):
    new_subdir_path = "noisy/" + str(i)
    if not os.path.exists(new_subdir_path):
        os.makedirs(new_subdir_path, exist_ok=True)
    
    for idx in range(len(dir)):
        image = dir[idx]
        # Choose a random sublist
        random_sublist = random.choice(image_list)

        # Choose a random image from the selected sublist
        random_img = random.choice(random_sublist)
        # Blend faces
        for alpha in [0.5, 0.6, 0.7, 0.8, 0.9, 1.0]:
            blended_face = cv2.addWeighted(image, alpha, random_img, 1 - alpha, 0)
            file_path = os.path.join(new_subdir_path, str(idx)+"-"+str(alpha*10)+".png")
            cv2.imwrite(file_path, blended_face)
