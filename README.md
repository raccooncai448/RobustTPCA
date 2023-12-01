# RobustTPCA
A Final Project for CSCI 2952Q: Robust Algorithms for Machine Learning

## TODO

Create a test suite with the following methods:

### Implemented (MATLAB)

1. **TRPCA with Sum of Nuclear Norm (trpca_snn)**
2. **TRPCA with Tensor Nuclear Norm (trpca_tnn)**

### Not Implemented (Python)

1. [TRPCA with Scaled GD](https://github.com/hdong920/tensor_rpca_scaledgd) - **IN PROGRESS**
2. [TRPCA with CP-decomposition](https://github.com/junsupan/TensorPCA)

For the test suite, include:

- Video Experiments (height x width x 5/10/50/100 frames)
- Facial Recognition (height x width x 3 x 5/10/50/100 people)

For the final TRPCA with CP implementation, change the PCA method to use Robust PCA: [robust-pca](https://github.com/dganguli/robust-pca)

## Note
- For now, suffices to use pip install and try to get Python code running locally; eventually want to embed that whole altered codebase in this repo.
