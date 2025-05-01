clc;
clear;
close all;

% Define parameters
R_L = 100;          % Load resistance (Ohms)
Z0 = 50;            % Transmission line impedance (Ohms)
f1 = 1e9;           % First matching frequency (Hz)
f2 = 2e9;           % Second matching frequency (Hz)
omega1 = 2*pi*f1;
omega2 = 2*pi*f2;

% Frequency transformation parameters (Eq. 8 from the paper)
k_inf = 1 / (omega2 - omega1);
k0 = (omega1 * omega2) / (omega2 - omega1);

% Component calculations (L-network transformed to dual-frequency)
R1 = sqrt(R_L * Z0 - Z0^2);  % Intermediate resistance
G2 = R1 / (R_L * Z0);

% Element values (Eq. 1-3 in the paper)
L1 = k_inf * R1;
C1 = 1 / (k0 * R1);
L2 = 1 / (k0 * G2);
C2 = k_inf * G2;

fprintf('Dual-Frequency Matching Network:\n');
fprintf('L1 = %.2e H, C1 = %.2e F\n', L1, C1);
fprintf('L2 = %.2e H, C2 = %.2e F\n', L2, C2);

% Frequency sweep
f = linspace(0.5*f1, 3*f2, 1000);  % Sweep from 0.5f1 to 3f2
omega = 2*pi*f;

% Compute reflection coefficient Gamma
Gamma = zeros(size(f));
for i = 1:length(f)
    % Transformed frequency variable (Eq. 7)
    Omega = k_inf * omega(i) - k0 / omega(i);
    
    % Reflection coefficient (Eq. 4, with omega → Omega)
    a = (1 - (Z0/R_L)) / (1 + (Z0/R_L)); % Corrected parentheses
    Gamma(i) = sqrt(1 / (1 + ((a^-2 - 1) / (1 - Omega^2)^2))); % Corrected
end

% Plot reflection coefficient (dB scale)
figure;
plot(f/1e9, 20*log10(abs(Gamma))); 
grid on;
xlabel('Frequency (GHz)');
ylabel('|\Gamma| (dB)');
title('Dual-Frequency Matching: Reflection Coefficient');
xline([f1 f2]/1e9, 'r--', {'f_1', 'f_2'});
ylim([-40 0]);

% Save Reflection Coefficient plot with a unique name
saveas(gcf, 'Dual_Frequency_Reflection_Coefficient.png');

% Smith chart (requires RF Toolbox)
if license('test', 'RF_Toolbox')
    figure;
    smithplot(Gamma .* exp(1i * angle(Gamma))); % Corrected
    title('Smith Chart: Dual-Frequency Matching');
    
    % Save Smith Chart with a unique name
    saveas(gcf, 'Dual_Frequency_Smith_Chart.png');
end
