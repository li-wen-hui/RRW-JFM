function [Iw_final, w, psnr1, psnr_final, insert_palace, te_no_attack] = FJFM_stage1(I, K, p, q, alpha, T_init, num, Delta, A, B, C, D, E, F)
rng(0, 'twister');
I1 = I;
w = randi([0, 1], 1, num);
d_0 = (1/2 - 1/16) * Delta * ones(1, num);
d_1 = d_0 + Delta/2;
N = size(I, 1);

X = FJFM_D(I, K, p, q, alpha);
temp_X = [abs(X(1,:) + 1i*X(2,:)); X(1,:); X(2,:); X(3,:)];
[X_1, ~] = sortrows(temp_X');
Fnm = X_1';

tem = zeros(1, num*2);
moment = 0;
for k = 1:length(Fnm)
    if mod(Fnm(3,k), 4) ~= 0 ...
            && (Fnm(2,k)==0 && abs(Fnm(3,k))<=15)==0 ...
            && (Fnm(2,k)==1 && abs(Fnm(3,k))<=13)==0 ...
            && (Fnm(2,k)==2 && abs(Fnm(3,k))<=10)==0 ...
            && (Fnm(2,k)==3 && abs(Fnm(3,k))<=7)==0 ...
            && (Fnm(2,k)==4 && abs(Fnm(3,k))<=7)==0 ...
            && (Fnm(2,k)==5 && abs(Fnm(3,k))<=7)==0 ...
            && (Fnm(2,k)==6 && abs(Fnm(3,k))<=5)==0 ...
            && (Fnm(2,k)==7 && abs(Fnm(3,k))<=5)==0 ...
            && (Fnm(2,k)==8 && abs(Fnm(3,k))<=3)==0 ...
            && (Fnm(2,k)==9 && abs(Fnm(3,k))<=1)==0
        if Fnm(2,k) >= 0 && Fnm(3,k) > 0
            moment = moment + 1;
            tem(moment) = k;
        end
    end
end
insert_palace = tem(1:num);
tem_n = zeros(1, length(insert_palace));
tem_m = zeros(1, length(insert_palace));
moment = 0;
for k = 1:length(Fnm)
    if ismember(k, insert_palace)
        moment = moment + 1;
        tem_n(moment) = Fnm(2,k);
        tem_m(moment) = Fnm(3,k);
    end
end

T = zeros(1, length(tem_n));
for i = 1:length(tem_n)
    T(i) = T_init - abs(tem_n(i) + 1i*tem_m(i))*30;
end

num_elements = length(Fnm);
VRnm = zeros(1, num_elements);
VRnm_j = zeros(2, num_elements);
VRw = zeros(1, num_elements);
Vw = zeros(1, num_elements);
F_1 = zeros(3, num_elements);
d_int = zeros(1, sum(ismember(1:num_elements, insert_palace)));
moment = 0;
for k = 1:length(Fnm)
    if ismember(k, insert_palace)
        moment = moment + 1;
        VRnm(k) = (Fnm(4,k)/Fnm(4,1))*T(moment);
        VRnm_j(1,k) = round((abs(VRnm(k))-d_0(moment))/Delta)*Delta+d_0(moment);
        VRnm_j(2,k) = round((abs(VRnm(k))-d_1(moment))/Delta)*Delta+d_1(moment);
        d_int(moment) = round(abs(VRnm_j(w(moment)+1,k))-abs(VRnm(k)));
        VRw(k) = abs(VRnm(k)) + d_int(moment);
        Vw(k) = (abs(VRw(k))/abs(VRnm(k)))*Fnm(4,k);
        F_1(1,k) = Fnm(2,k);
        F_1(2,k) = Fnm(3,k);
        F_1(3,k) = Vw(k)-Fnm(4,k);
        [~, col] = find(Fnm(2,:)==Fnm(2,k) & Fnm(3,:)==-Fnm(3,k));
        Vw(col) = conj(Vw(k));
        F_1(1,col) = Fnm(2,col);
        F_1(2,col) = Fnm(3,col);
        F_1(3,col) = Vw(col)-Fnm(4,col);
    end
end

Irw1 = FJFM_R(K, F_1, N, p, q, alpha);
Iw1 = round(double(I1) + Irw1);
Iw1(Iw1>255) = 255;
Iw1(Iw1<0) = 0;
psnr1 = psnr(I1, uint8(Iw1));

compensation_results = struct();
compensation_results(1).psnr = psnr(uint8(I), uint8(Iw1));
compensation_results(1).image = Iw1;
stop_flag = false;
cumulative_compensation = zeros(size(I));
Iw_prev = Iw1;
comp_iter = 1;

while ~stop_flag
    Iw_current = FJFM_D(Iw_prev, K, p, q, alpha);
    temp_X = [abs(Iw_current(1,:)+1i*Iw_current(2,:)); Iw_current(1,:); Iw_current(2,:); Iw_current(3,:)];
    [X_1, ~] = sortrows(temp_X');
    Vnm_w = X_1';

    F_comp = zeros(3, size(Vnm_w,2));
    for k = 1:length(Vnm_w)
        if ismember(k, insert_palace)
            F_comp(1,k) = Vnm_w(2,k);
            F_comp(2,k) = Vnm_w(3,k);
            F_comp(3,k) = Vw(k) - Vnm_w(4,k);
            [~, col] = find(Vnm_w(2,:)==Vnm_w(2,k) & Vnm_w(3,:)==-Vnm_w(3,k));
            F_comp(1,col) = Vnm_w(2,col);
            F_comp(2,col) = Vnm_w(3,col);
            F_comp(3,col) = Vw(col) - Vnm_w(4,col);
        end
    end

    Irw_comp = FJFM_R(K, F_comp, N, p, q, alpha);
    Irw_comp(isnan(Irw_comp)) = 0;
    cumulative_compensation = cumulative_compensation + Irw_comp;
    Iw_new = round(Iw1 + cumulative_compensation);
    Iw_new = min(max(Iw_new, 0), 255);
    current_psnr = psnr(uint8(I), uint8(Iw_new));

    if comp_iter >= 1
        if current_psnr > compensation_results(comp_iter).psnr
            Iw_final = compensation_results(comp_iter).image;
            stop_flag = true;
            break;
        end
    end

    compensation_results(comp_iter+1).psnr = current_psnr;
    compensation_results(comp_iter+1).image = Iw_new;
    Iw_prev = Iw_new;
    comp_iter = comp_iter + 1;
end

psnr_final = psnr(uint8(I), uint8(Iw_final));

Fnm_final_raw = FJFM_D(Iw_final, K, p, q, alpha);
temp_final = [abs(Fnm_final_raw(1,:)+1i*Fnm_final_raw(2,:)); Fnm_final_raw(1,:); Fnm_final_raw(2,:); Fnm_final_raw(3,:)];
[Fnm_final_sorted, ~] = sortrows(temp_final');
Fnm_final = Fnm_final_sorted';
w_ex = zeros(1, length(insert_palace));
moment = 0;
for k = 1:length(Fnm_final)
    if ismember(k, insert_palace)
        moment = moment + 1;
        FRnm_final = (Fnm_final(4,k)/Fnm_final(4,1))*T(moment);
        FRnm_final_j0 = round((abs(FRnm_final)-d_0(moment))/Delta)*Delta+d_0(moment);
        FRnm_final_j1 = round((abs(FRnm_final)-d_1(moment))/Delta)*Delta+d_1(moment);
        if (abs(FRnm_final)-abs(FRnm_final_j0))^2 <= (abs(FRnm_final)-abs(FRnm_final_j1))^2
            w_ex(moment) = 0;
        else
            w_ex(moment) = 1;
        end
    end
end
te_no_attack = sum(abs(w-w_ex));
end
