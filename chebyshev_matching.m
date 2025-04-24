Z0 = 50;
RL = 100;

%Order 4 filter with Gamma_m = 0.05, for RL/Z0 = 2
Z_vals = [1.1201, 1.2979, 1.5409, 1.7855]*Z0;

freq = linspace(0,2e9,4000);

freq_match = 1e9; %Impedance matching at 1GHz
theta = pi*freq/(freq_match*2);

Zin = zeros([3,4000]);

gamma_coeff = zeros([1,4]);

gamma_coeff(1) = (Z_vals(1)-Z0)/(Z_vals(1)+Z0);
gamma_coeff(2) = (Z_vals(2)-Z_vals(1))/(Z_vals(2)+Z_vals(1));
gamma_coeff(3) = (Z_vals(3)-Z_vals(2))/(Z_vals(3)+Z_vals(2));
gamma_coeff(4) = (Z_vals(4)-Z_vals(3))/(Z_vals(4)+Z_vals(3));
gamma_coeff(5) = (RL-Z_vals(4))/(RL+Z_vals(4));

gamma = 0.05*exp(-1i*4*theta).*(gamma_coeff(1)*cos(4*theta)+gamma_coeff(2)*cos(2*theta)+gamma_coeff(3)*0.5);

plot(freq,abs(gamma));
