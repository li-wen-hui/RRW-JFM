function im_rec = FJFM_R(nMax, MMT, N, p, q, alpha)
[X,Y] = meshgrid(-1:(2/(N-1)):1, -1:(2/(N-1)):1);
[theta,r] = cart2pol(X,Y);
idx = uint8(r<=1);
im_rec = zeros(N);
for order = 0:nMax
    R_precomputed{order+1} = getRadialPoly(order, r, p, q, alpha);
end

K = size(MMT,2);
for k = 1:K
    order = MMT(1,k);
    m = MMT(2,k);
    coeff = MMT(3,k);
    R_k = R_precomputed{order+1};
    H_k = R_k.*exp(1i*m*theta);
    im_rec = im_rec + coeff*H_k;
end
im_rec = im_rec.*double(idx);
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
