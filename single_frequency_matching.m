clc;
clear all;
close all;

% Define parameters
R_L = 100;      % Load resistance (Ohms)
Z0 = 50;        % Transmission line impedance (Ohms)
f0 = 1e9;       % Matching frequency (Hz)
omega0 = 2*pi*f0;

% Check if R_L > Z0 (determine L-network topology)
if R_L > Z0
    % Case 1: Series L, Shunt C
    Q = sqrt((R_L / Z0) - 1);
    L = (Z0 * Q) / omega0;
    C = Q / (R_L * omega0);
    fprintf('Topology: Series L = %.2e H, Shunt C = %.2e F\n', L, C);
else
    % Case 2: Series C, Shunt L
    Q = sqrt((Z0 / R_L) - 1);
    C = 1 / (Z0 * Q * omega0);
    L = (R_L * Q) / omega0;
    fprintf('Topology: Series C = %.2e F, Shunt L = %.2e H\n', C, L);
end

% Frequency sweep
f = linspace(0.1*f0, 2*f0, 1000);  % 10% to 200% of f0
omega = 2*pi*f;

% Compute input impedance Z_in and reflection coefficient Gamma
Gamma = zeros(size(f));
for i = 1:length(f)
    if R_L > Z0
        Z_series = 1i * omega(i) * L;
        Z_shunt = 1 / (1i * omega(i) * C);
        Z_in = Z_series + (Z_shunt * R_L) / (Z_shunt + R_L);
    else
        Z_series = 1 / (1i * omega(i) * C);
        Z_shunt = 1i * omega(i) * L;
        Z_in = Z_series + (Z_shunt * R_L) / (Z_shunt + R_L);
    end
    Gamma(i) = (Z_in - Z0) / (Z_in + Z0);
end

% Plot reflection coefficient magnitude
figure;
plot(f / 1e6, 20*log10(abs(Gamma)));
grid on;
xlabel('Frequency (MHz)');
ylabel('|\Gamma| (dB)');
title('Reflection Coefficient vs Frequency');
xline(f0/1e6, 'r--', 'f_0', 'LabelVerticalAlignment', 'middle');
ylim([-40 0]);
saveas(gcf, 'Reflection_Coefficient.png');  % Always saved

% Plot Smith chart (either with RF Toolbox or fallback)
figure;
if license('test', 'RF_Toolbox')
    smithplot(Gamma);
    title('Smith Chart: Reflection Coefficient');
else
    polarplot(angle(Gamma), abs(Gamma));
    title('Approx Smith Chart (Fallback)');
end
saveas(gcf, 'Smith_Chart.png');  % Always saved

