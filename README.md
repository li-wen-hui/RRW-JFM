# RRW-JFM: Robust Watermark Embedding with Dynamic Error Compensation

MATLAB implementation of the **first-stage robust watermark embedding** component of the RRW-JFM scheme described in:

> *Robust reversible image watermarking based on the zeros distribution of orthogonal moments*, Signal Processing, 252 (2027), 110947.

This repository focuses on **Jacobi–Fourier moments (JFM)**, attack-driven parameter selection, robust watermark embedding, and dynamic error compensation.

**Scope:** Only Stage I is included. The reversible watermark embedding stage, authentication, and lossless image recovery are **not** provided. Consequently, this code should not be described as a complete robust *reversible* watermarking implementation.

## Features

- Computation and reconstruction of Jacobi–Fourier moments using a recursive radial-polynomial formulation.
- Selection of stable moment coefficients as watermark carriers.
- Attack-driven selection of Jacobi kernel parameters under the constraint `p = q`.
- Embedding of a 128-bit binary watermark into normalized moment magnitudes using quantization.
- Dynamic error compensation after image reconstruction.
- No-attack watermark extraction from the dynamically compensated image and evaluation under Gaussian noise, scaling, and JPEG2000 compression.

## Repository Structure

```text
.
├── README.md
├── main_stage1.m
├── FJFM_stage1.m
├── FJFM_weight.m
├── FJFM_D.m
├── FJFM_R.m
└── Image/
    ├── image_01.bmp
    └── ...
```

`Image/` is the user-supplied input directory and is not included in the source-code package. The filenames above reflect the currently provided MATLAB files. The `FJFM_*` functions implement a parameterized Jacobi–Fourier basis; setting `alpha = 1` reduces it to conventional JFM. Function names alone do not determine which moments are computed.

| File | Purpose |
| --- | --- |
| `main_stage1.m` | Main entry point, parameter configuration, image iteration, and candidate selection |
| `FJFM_stage1.m` | Stage-I watermark embedding and dynamic error compensation |
| `FJFM_weight.m` | Attack simulation and watermark bit-error evaluation |
| `FJFM_D.m` | Moment decomposition |
| `FJFM_R.m` | Moment-domain image reconstruction |

## Requirements

- MATLAB with the Image Processing Toolbox.
- MATLAB Parallel Computing Toolbox for the `Threads` pool and `parfor`.
- Support for JPEG2000 image reading and writing (`.jp2`).
- Grayscale BMP test images, preferably `512 × 512`, as used in the paper's experiments.

The implementation has been inspected statically, but numerical reproducibility has **not** been verified by running MATLAB in the preparation environment.

## Configuration for RRW-JFM

For the **RRW-JFM experimental setting** described in the paper, check the following values in `main_stage1.m`:

```matlab
K = 15;
T_init = 10000;
num = 128;
Delta = 40;
alpha = 1;
```

The published JFM parameter-search interval uses:

```matlab
p_values = 6:0.1:8;
q_values = p_values;
```

The main script in this package uses `p_values = 6:0.1:8`. `K` is the maximum moment order.

For clarity:

- `alpha = 1`: conventional JFM.
- `alpha != 1`: fractional-order parameterization of JFM (FJFM).
- This repository targets **JFM**, not the separate RRW-FJFM experimental variant.

## Usage

1. Place the five MATLAB `.m` files in one directory.
2. Create a subdirectory named `Image` and place grayscale `.bmp` images in it.
3. Confirm that `main_stage1.m` uses the RRW-JFM settings shown above.
4. Set the MATLAB Current Folder to the project directory.
5. Run:

   ```matlab
   main_stage1
   ```

The main script processes each `.bmp` file found in `Image/`. It evaluates candidate kernel parameters under the implemented attacks, selects a candidate, embeds a random watermark, and applies dynamic error compensation.

The resulting MATLAB workspace structure is currently named `results_FJFM128` in the supplied script, even when `alpha = 1`. It contains image names, selected `p`/`q`, PSNR values, no-attack BER values, watermarked images, watermark bits, and selected moment indices. The script does **not** automatically write these results to disk.

## Evaluation

The supplied implementation includes these attack simulations:

| Attack | Code setting |
| --- | --- |
| Additive Gaussian noise | Mean `0`, variance `0.029` |
| Scaling | Resize factor `0.6`, followed by resizing back |
| JPEG2000 compression | Compression ratio `100` |

Bit errors are measured by comparison with the embedded watermark. The candidate-selection logic combines the error counts from the three attacks and uses PSNR when selecting among candidates.

The reported **No-attack BER** is extracted from `Iw_final`, the robust watermarked image after dynamic error compensation, and is calculated as the number of erroneous bits divided by `128`.

No reversible-information data is constructed, encoded, measured, or embedded. All code associated with residual reconstruction and reversible-information bit counting has been omitted from this Stage-I release.

## Important Notes on Reproducibility

- The paper presents a **two-stage** robust reversible watermarking method; the public code here intentionally implements **only Stage I**.
- The code provides Stage-I metrics only; it cannot reproduce the reversible-information measurements or full reversible-recovery results reported for the two-stage method.
- The current code uses a quantization dither offset different from the simplified dither values stated in the paper's Eq. (12). This difference has been preserved from the supplied implementation and should be checked before claiming exact numerical reproduction.
- Results depend on input images and the parameter-search procedure. The paper's complete reported robust-reversible results also depend on Stage II, which is absent here.
- The implementation was prepared without changing the core embedding, reconstruction, or dynamic-compensation algorithms beyond the Stage-I extraction previously requested.

## Reference

*Robust reversible image watermarking based on the zeros distribution of orthogonal moments*. **Signal Processing**, 252 (2027), 110947.

Publication page: https://www.sciencedirect.com/science/article/pii/S0165168426004603

If you use this work in academic research, please cite the original article.

## License

No open-source license has been assigned in this package. The repository owner should add a `LICENSE` file specifying the intended permissions before public release.
