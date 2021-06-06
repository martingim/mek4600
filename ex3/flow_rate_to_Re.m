function [Re] = flow_rate_to_Re(flow_rate, D)
%flow rate in ml/min, diameter of pipe in m.

flow_rate = flow_rate/1000000/60;%convert the flow rate from ml/min to M^3/s

A =  pi*(D/2)^2; %area of the crossetcion of the pipe

u = flow_rate/A; %mean flow speed

rho = 997; %density of water
mu = 8.9e-4; %dynamic viscosity of water
Re = rho*u*D/mu;
end

