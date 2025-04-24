%Frequency analysis of Quarter-wave Impedance Matching

Z0 = 50; %Characteristic impedance of line to be matched
RL = [70,100,200]; %Load resistance
Z1 = sqrt(Z0 .* RL); %Characteristic impedance of quater-wave transformer

freq = linspace(0,2e9,4000);

freq_match = 1e9; %Impedance matching at 1GHz
theta = pi*freq/(freq_match*2);

Zin = zeros([3,4000]);

for i=1:1:3
    Zin(i,:) = Z1(i)*(RL(i)+1i*Z1(i)*tan(theta)) ./ (Z1(i)+1i*RL(i)*tan(theta));
end

gamma= (Zin - Z0) ./ (Zin + Z0);

plot(freq,abs(gamma(1,:)),'r') 
hold on
plot(freq,abs(gamma(2,:)),'')
plot(freq,abs(gamma(3,:)),'b')
legend('RL=70','RL=100', 'RL=200');
xlim([0,2e9]);
ylim([0,0.8]);


