function [alpha] = compute_alpha(Uw, Vw, idx, omega, a, g, k)
%compute alpha



%compute alpha
[M, N] = size(Uw);
V_norm = (Uw.^2 + Vw.^2).^0.5;
V_norm_mean = zeros(M,1)*NaN;

for i=1:M
    n = 0;
    s = 0;
    for j=1:N
        if idx(i,j)==1
            n = n + 1;
            s = s + V_norm(i,j);
        end
    end 
    V_norm_mean(i) = s/n;
end

alpha = omega/(a*g*k)*V_norm_mean;


end

