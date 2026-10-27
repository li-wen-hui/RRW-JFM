function Fnm = FJFM_D(img, T, p, q, alpha)
N = size(img, 1);
[X,Y] = meshgrid(-1:(2/(N-1)):1, -1:(2/(N-1)):1);
[theta,r] = cart2pol(X,Y);
idx = uint8(r<=1);
img2 = uint8(img).*idx;

num = 0;
for n = 0:T
    for l = -T:T
        num = num + 1;
        Fnm(:,num) = [n; l];
    end
end

R1_cache = cell(T+1, 1);
for n = 0:T
    R1_cache{n+1} = getRadialPoly(n, r, p, q, alpha);
end

Fnm(3,:) = 0;
Fnm = complex(Fnm);
iteration_count = 0;
n = 0;
for k = 1:size(Fnm,2)
    R1 = R1_cache{n+1};
    H = R1.*exp(1i*Fnm(2,k).*theta);
    Fnm(3,k) = sum(sum(conj(H).*double(img2).*double(idx)));
    iteration_count = iteration_count + 1;
    if iteration_count >= 2*T+1
        n = n + 1;
        iteration_count = 0;
    end
end
Fnm(3,:) = Fnm(3,:)*2/(pi*N^2);
end

function output = getRadialPoly(order, rho, p, q, alpha)
n = order;
if n>=2
    P0 = (gamma(p)/gamma(q))*ones(size(rho));
    P1 = (gamma(p+1)/gamma(q))*(1-((p+1)/q)*(rho.^alpha));
    PN1 = P1;
    PN2 = P0;
    for k = 2:n
        L1 = -((2*k+p-1)*(2*k+p-2))/(k*(q+k-1));
        L2 = (p+2*k-2)+(((k-1)*(q+k-2)*L1)/(p+2*k-3));
        L3 = ((p+2*k-4)*(p+2*k-3)/2)+((q+k-3)*(k-2)*L1/2)-((p+2*k-4)*L2);
        PN = (L1*(rho.^alpha)+L2).*PN1+L3.*PN2;
        PN2 = PN1;
        PN1 = PN;
    end
elseif n==1
    PN = (gamma(p+1)/gamma(q))*(1-((p+1)/q)*(rho.^alpha));
elseif n==0
    PN = (gamma(p)/gamma(q))*ones(size(rho));
end

if n>=1
    A0 = sqrt(gamma(q)/(gamma(p)*gamma(p-q+1)));
    AN1 = A0;
    for k = 1:n
        AN = sqrt(k*(q+k-1)/((p+k-1)*(p-q+k)))*AN1;
        AN1 = AN;
    end
elseif n==0
    AN = sqrt(gamma(q)/(gamma(p)*gamma(p-q+1)));
end
output = sqrt((p+2*n)*alpha*((1-rho.^alpha).^(p-q)).*(rho.^(alpha*q-1))./rho)*AN.*PN;
end
