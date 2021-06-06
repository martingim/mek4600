L = 0.008;
rho = 997; %density of water
mu = 8.9e-4; %dynamic viscosity of water
nu = mu/rho;
e0 = sum(2*nu*f.^2.*p)/(f(2)-f(1));

eta = (nu^3/e0)^(1/4);
C = 100;
E = C*e0^(2/3)*f.^(-5/3);


