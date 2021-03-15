function [u, v] = analytical_solution(a, k, g, omega, t)
%%  analytical solution of
%potential of wave moving to the right
%phi = a*g/omega*exp(k*y)*sin(k*x-omega*t);
u = @(x, y) a*k*g/omega*exp(k*y).*cos(k*x-omega*t);
v = @(x, y) a*k*g/omega*exp(k*y).*sin(k*x-omega*t);

end