function [psnr1, te_no_attack, te_awgn, te_jpeg2000, te_scale] = FJFM_weight(A, B, C, D, E, F, I, K, p, q, alpha, T_init, num, Delta)
[Iw_final, w, psnr1, ~, insert_palace, te_no_attack] = FJFM_stage1(I, K, p, q, alpha, T_init, num, Delta, A, B, C, D, E, F);

rng(0, 'twister');
noisy_img_AWGN = imnoise(uint8(Iw_final), 'gaussian', 0, 0.029);
te_awgn = extract_errors(noisy_img_AWGN, K, p, q, alpha, T_init, Delta, insert_palace, w);

rng(0, 'twister');
image_imresize = imresize(uint8(Iw_final), 0.6);
image_imresize = imresize(image_imresize, size(uint8(Iw_final)));
te_scale = extract_errors(image_imresize, K, p, q, alpha, T_init, Delta, insert_palace, w);

rng(0, 'twister');
temp_file = tempname;
imwrite(uint8(Iw_final), temp_file, 'jp2', 'CompressionRatio', 100);
compressed_image = imread(temp_file);
delete(temp_file);
te_jpeg2000 = extract_errors(compressed_image, K, p, q, alpha, T_init, Delta, insert_palace, w);
end

function error_count = extract_errors(I_attacked, K, p, q, alpha, T_init, Delta, insert_palace, w)
MMT = FJFM_D(I_attacked, K, p, q, alpha);
temp_X = [abs(MMT(1,:)+1i*MMT(2,:)); MMT(1,:); MMT(2,:); MMT(3,:)];
[sorted_MMT, ~] = sortrows(temp_X');
Mnm = sorted_MMT';

d_0 = (1/2 - 1/16) * Delta * ones(1, length(w));
d_1 = d_0 + Delta/2;
w_ex = zeros(1, length(w));
moment = 0;
for k = 1:length(Mnm)
    if ismember(k, insert_palace)
        moment = moment + 1;
        T = T_init - abs(Mnm(2,k)+1i*Mnm(3,k))*30;
        MRnm_w = (Mnm(4,k)/Mnm(4,1))*T;
        MRnm_w_j0 = round((abs(MRnm_w)-d_0(moment))/Delta)*Delta+d_0(moment);
        MRnm_w_j1 = round((abs(MRnm_w)-d_1(moment))/Delta)*Delta+d_1(moment);
        if (abs(MRnm_w)-abs(MRnm_w_j0))^2 <= (abs(MRnm_w)-abs(MRnm_w_j1))^2
            w_ex(moment) = 0;
        else
            w_ex(moment) = 1;
        end
    end
end
error_count = sum(abs(w-w_ex));
end
