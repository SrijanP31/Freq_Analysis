clc; clear; close all;

%% Parameters
R_L = 100;          % Load resistance (Ohms)
Z0 = 50;            % Transmission line impedance (Ohms)
f1 = 0.8e9;         % First matching frequency (Hz)
f2 = 1.6e9;         % Second matching frequency (Hz)
f3 = 2.4e9;         % Third matching frequency (Hz)
omega = 2*pi*[f1 f2 f3];

%% Triple-Frequency Transformation (Eq. 12-14 from paper)
k_inf = 1/(omega(2) - omega(1) + omega(3));
q1 = omega(1)*omega(2)*omega(3)*k_inf;
k1 = k_inf*(omega(1)*omega(2) + omega(2)*omega(3) - omega(1)*omega(3) - q1);

%% Component Calculations (Fig. 6 topology)
R1 = sqrt(R_L*Z0 - Z0^2);      % Intermediate resistance
G2 = R1/(R_L*Z0);

L2 = k_inf*R1;                  % Series elements
C2 = k_inf*G2;

C1 = 1/(k1*R1);                 % Parallel resonant branches
L1 = k1*R1/q1;
L3 = 1/(k1*G2);
C3 = k1*G2/q1;

fprintf('Triple-Frequency Matching Network:\n');
fprintf('L1 = %.2e H, C1 = %.2e F\n', L1, C1);
fprintf('L2 = %.2e H, C2 = %.2e F\n', L2, C2);
fprintf('L3 = %.2e H, C3 = %.2e F\n', L3, C3);

%% Frequency Sweep
f = linspace(0.5*f1, 3*f3, 2000);  % 0.5f1 to 3f3
w = 2*pi*f;

%% Reflection Coefficient Calculation
Gamma = zeros(size(f));
a = (1 - (Z0/R_L)) / (1 + (Z0/R_L));  % DC reflection coefficient

for i = 1:length(w)
    % Transformed frequency variable (Eq. 15)
    Omega = k_inf*w(i) + (k1*w(i))/(q1 - w(i)^2);
    
    % Reflection coefficient (modified Eq. 4)
    Gamma(i) = sqrt(1 / (1 + ((a^-2 - 1) / (1 - Omega^2)^2)));
end

%% Plotting Reflection Coefficient
fig1 = figure('Position', [100 100 800 400]);
subplot(1,2,1);
plot(f/1e9, 20*log10(abs(Gamma)), 'LineWidth', 1.5);
hold on;
xline([f1 f2 f3]/1e9, 'r--', {'f_1','f_2','f_3'});
grid on;
xlabel('Frequency (GHz)');
ylabel('|\Gamma| (dB)');
title('Reflection Coefficient');
ylim([-40 0]);

subplot(1,2,2);
plot(f/1e9, abs(Gamma), 'LineWidth', 1.5);
hold on;
xline([f1 f2 f3]/1e9, 'r--', {'f_1','f_2','f_3'});
grid on;
xlabel('Frequency (GHz)');
ylabel('|\Gamma| (Linear)');
title('Matching Detail');
ylim([0 1]);

% Save this plot
saveas(fig1, 'Triple_Frequency_Reflection_Coefficient.png');

%% Smith Chart (if RF Toolbox available)
if license('test', 'RF_Toolbox')
    fig2 = figure;
    smithplot(Gamma.*exp(1i*angle(Gamma))); % Assume minimal phase shift
    title('Triple-Frequency Smith Chart');

    % Save smith chart
    saveas(fig2, 'Triple_Frequency_Smith_Chart.png');
end

%% Critical Frequency
alpha3 = sqrt(q1 + k1/k_inf);
fprintf('\nCritical Frequency between f2 and f3: %.2f GHz\n', alpha3/(2*pi*1e9));
