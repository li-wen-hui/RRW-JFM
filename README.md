# Robust Reversible Image Watermarking Based on the Zeros Distribution of Orthogonal Moments

This repository provides the MATLAB implementation of the method presented in our paper, *"Robust Reversible Image Watermarking Based on the Zeros Distribution of Orthogonal Moments,"* published in **Signal Processing**.

The implementation employs Jacobi–Fourier moments (JFMs) for robust watermark embedding, image-adaptive kernel parameter selection, and dynamic error compensation.

## Requirements

- MATLAB
- Grayscale BMP images for testing

## Files

| File            | Description                                                                         |
| --------------- | ----------------------------------------------------------------------------------- |
| `main_stage1.m` | Performs parameter search and evaluates the watermarking performance for each image |
| `FJFM_stage1.m` | Performs watermark embedding and dynamic error compensation                         |
| `FJFM_weight.m` | Evaluates watermark robustness under simulated attacks                              |
| `FJFM_D.m`      | Computes Jacobi–Fourier moments                                                     |
| `FJFM_R.m`      | Reconstructs images from moment coefficients                                        |
| `Image/`        | Contains grayscale BMP images used for testing                                      |

## Usage

1. Download or clone this repository.
2. Open MATLAB and set the current working directory to the repository root.
3. Ensure that the input grayscale BMP images are available in the `Image/` directory.
4. Run `main_stage1.m` to perform parameter search and image evaluation.

## Parameter Settings

The parameter `alpha` is set to `1` for the Jacobi–Fourier moment calculations in this implementation.

## Citation

Xiuli Chai, Wenhui Li, Yajing Zhang, Huiqun Zou, Yang Lu, and Zhihua Gan, "Robust reversible image watermarking based on the zeros distribution of orthogonal moments," *Signal Processing*, vol. 252, Art. no. 110947, 2027.

DOI: [https://doi.org/10.1016/j.sigpro.2026.110947](https://doi.org/10.1016/j.sigpro.2026.110947)

[Publication](https://www.sciencedirect.com/science/article/pii/S0165168426004603)
