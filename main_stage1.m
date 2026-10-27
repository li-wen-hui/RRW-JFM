close all;
clc;

pool = gcp('nocreate');
if isempty(pool)
    parpool('Threads', 5);
elseif ~isa(pool, 'parallel.ThreadPool')
    error('A process-based parallel pool is active. Close it before running this thread-based script.');
end

K = 15;
T_init = 10000;
num = 128;
Delta = 40;
alpha = 1;
A = 0;
B = 0;
C = 0;
D = 0;
E = 0;
F = 0;

img_path_list = dir(fullfile('Image', '*.bmp'));
img_num = length(img_path_list);
results_FJFM128 = struct('filename', {}, 'p', {}, 'q', {}, 'psnr1', {}, 'psnr_final', {}, 'ber_no_attack', {}, 'image', {}, 'watermark', {}, 'selected_indices', {}, 'temp_results', {});

for j = 1:img_num
    image_name = img_path_list(j).name;
    I = imread(fullfile('Image', image_name));
    p_values = 6:0.1:8;
    q_values = p_values;
    num_pairs = length(p_values);
    temp_results = repmat(struct('p', 0, 'q', 0, 'bernone', 0, 'berawgn', 0, 'berscale', 0, 'berjpeg2000', 0, 'psnr', 0, 'bersum', 0), num_pairs, 1);

    fprintf('\nImage %d/%d: %s, testing %d parameter pairs\n', j, img_num, image_name, num_pairs);

    parfor i = 1:num_pairs
        current_p = p_values(i);
        current_q = q_values(i);
        [psnr1, te_no_attack, te_awgn, te_jpeg2000, te_scale] = FJFM_weight(A, B, C, D, E, F, I, K, current_p, current_q, alpha, T_init, num, Delta);
        temp_results(i) = struct('p', current_p, 'q', current_q, 'bernone', te_no_attack, 'berawgn', te_awgn, 'berscale', te_scale, 'berjpeg2000', te_jpeg2000, 'psnr', psnr1, 'bersum', te_awgn + te_scale + te_jpeg2000);
        fprintf('p=q=%.1f | PSNR=%.4f dB | No-attack BER=%.4f | AWGN BER=%.4f | JPEG2000 BER=%.4f | Scale BER=%.4f\n', current_p, psnr1, te_no_attack/num, te_awgn/num, te_jpeg2000/num, te_scale/num);
    end

    bersum_values = [temp_results.bersum];
    psnr_values = [temp_results.psnr];
    sorted_bersum = sort(bersum_values);
    unique_bersum = unique(sorted_bersum);
    if numel(unique_bersum) >= 2
        min_bersum1 = unique_bersum(1);
        min_bersum2 = unique_bersum(2);
        candidate_idx = find(bersum_values == min_bersum1 | bersum_values == min_bersum2);
        candidate_psnr = psnr_values(candidate_idx);
        if max(candidate_psnr) - min(candidate_psnr) < 0.1
            [~, min_bersum_idx] = min(bersum_values(candidate_idx));
            best_idx = candidate_idx(min_bersum_idx);
        else
            [~, max_psnr_idx] = max(candidate_psnr);
            best_idx = candidate_idx(max_psnr_idx);
        end
    else
        [~, best_idx] = max(psnr_values);
    end

    best_p = temp_results(best_idx).p;
    best_q = temp_results(best_idx).q;
    [Iw_final, w, psnr1, psnr_final, insert_palace, te_no_attack] = FJFM_stage1(I, K, best_p, best_q, alpha, T_init, num, Delta, A, B, C, D, E, F);
    results_FJFM128(j).filename = image_name;
    results_FJFM128(j).p = best_p;
    results_FJFM128(j).q = best_q;
    results_FJFM128(j).psnr1 = psnr1;
    results_FJFM128(j).psnr_final = psnr_final;
    results_FJFM128(j).ber_no_attack = te_no_attack/num;
    results_FJFM128(j).image = Iw_final;
    results_FJFM128(j).watermark = w;
    results_FJFM128(j).selected_indices = insert_palace;
    results_FJFM128(j).temp_results = temp_results;

    fprintf('Image %d/%d completed: %s | Best p=q=%.2f | Initial PSNR=%.4f dB | Final PSNR=%.4f dB | No-attack BER=%.4f\n', j, img_num, image_name, best_p, psnr1, psnr_final, te_no_attack/num);
end
