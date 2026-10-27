# RRW-JFM: Robust Watermarking with Dynamic Error Compensation

MATLAB implementation of the **Stage-I robust watermarking** method presented in:

> X. Chai et al., "Robust reversible image watermarking based on the zeros distribution of orthogonal moments," *Signal Processing*, vol. 252, 110947, 2027.

The implementation uses Jacobi–Fourier moments (JFM) for robust watermark embedding, image-adaptive kernel parameter selection, and dynamic error compensation. It includes watermark extraction and robustness evaluation under representative image attacks.

## Files

| File | Description |
| --- | --- |
| `main_stage1.m` | Runs the parameter search and evaluates each image |
| `FJFM_stage1.m` | Embeds the watermark and performs dynamic error compensation |
| `FJFM_weight.m` | Evaluates watermark robustness under simulated attacks |
| `FJFM_D.m` | Computes Jacobi–Fourier moments |
| `FJFM_R.m` | Reconstructs images from moment coefficients |
| `Image/` | Input grayscale BMP images |

With `alpha = 1`, they compute the JFM configuration used in this repository.

## Citation

Xiuli Chai, Wenhui Li, Yajing Zhang, Huiqun Zou, Yang Lu, and Zhihua Gan, "Robust reversible image watermarking based on the zeros distribution of orthogonal moments," Signal Processing, vol. 252, Art. no. 110947, 2027. https://doi.org/10.1016/j.sigpro.2026.110947

[Publication](https://www.sciencedirect.com/science/article/pii/S0165168426004603)
