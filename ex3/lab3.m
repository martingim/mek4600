Rel = 400;
Ret = 4000;
D = 0.01;

L_laminar = 0.05*Rel*D;
L_turbulent = 4.4*D*Ret^(1/6);

%%

g = 9.81;
rho = 997;
mu = 1e-3;
D = 0.01;
h = 1;
L = 1;
dPdx = rho*h*g/L;
Re = rho*D^3*dPdx/(32*mu^2)

%%
Re = 4000;
z = (Re*mu/(rho*D))^2/(2*g)                                                                                                