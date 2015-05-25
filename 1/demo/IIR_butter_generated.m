%preberem csv datoteko
data = csvread('./nexus7_2_drsenje.csv') 

clear pospesek_raw;
clear pospesek;
clear hitrost_raw;
clear hitrost;
clear pozicija_raw;
clear pozicija;
iteracija_gibanja = 0;

%upoštevam samo pospešek po x-osi
data = data(:,1); %X

source = data;
data_length = length(source);

%IIR filter - cheby1
Fstop = 0.09;  % Stopband Frequency
Fpass = 0.1;   % Passband Frequency
Astop = 60;    % Stopband Attenuation (dB)
Apass = 1;     % Passband Ripple (dB)
Fs    = 200;     % Sampling Frequency

h = fdesign.highpass('fst,fp,ast,ap', Fstop, Fpass, Astop, Apass, Fs);

Hd = design(h, 'butter', ...
    'MatchExactly', 'stopband');
filteredData = filter(Hd, source);


%inicializacija dvojne integracije (zaèetni pogoji: hitrost = 0 in pozicija = 0)
hitrost = zeros(1,length(filteredData),1); %po prvi itegraciji dobim hitrost
hitrost_raw = zeros(1,length(filteredData),1);
pozicija = zeros(length(filteredData),1); %po drugi integraciji pa dobim pozicijo
pozicija_raw = zeros(length(filteredData),1);

%èasovni interval
t = 0.005; %fastest asus
freq = 1 / t; %200Hz

%iterator (real-time simulator)
for i=1:data_length
    
    %integracija - hitrost
    if(i-1>0)
        hitrost_raw(i) = hitrost_raw(i-1) + Integration_step(source,i,freq,'trapez');       
        hitrost(i) = hitrost(i-1) + Integration_step(filteredData,i,freq,'trapez');       
    else
        hitrost_raw(i) = 0;
        hitrost(i) = 0;
    end    

    %integracija - pozicija
    if(i-1>0)
        pozicija_raw(i) = pozicija_raw(i-1) + Integration_step(hitrost_raw,i,freq,'trapez');
        pozicija(i) = pozicija(i-1) + Integration_step(hitrost,i,freq,'trapez');  
    else
        pozicija_raw(i) = 0;
        pozicija(i) = 0;
    end
end

%pospešek
x = 1:data_length;

clf

%%{
subplot(3,1,1);
plot(x, source, 'color', 'red');
hold on;
plot(x, filteredData, 'color', 'blue');
legend('Originalen signal pospeška','Filtriran signal pospeška');
xlabel('Èas (s)');
ylabel('Pospešek (m/s^2)');
%xlim([0 7])
%ylim([-4 4])
hold off;
%}


%hitrost
%%{
subplot(3,1,2);
%plot(x, hitrost_raw, 'color', 'red');
hold on;
plot(x, hitrost_raw, 'color', 'red');
plot(x, hitrost, 'color', 'blue');
legend('Signal hitrosti na podlagi filtriranega pospeška','Signal hitrosti brez filtriranja pospeška');
xlabel('Èas (s)');
ylabel('Hitrost (m/s)');
%xlim([0 7])
%ylim([-0.5 0.7])
hold off;
%}

%pozicija
%%{
subplot(3,1,3);
hold on;
plot(x, pozicija_raw, 'color', 'red');
plot(x, pozicija, 'color', 'blue');
legend('Signal pozicije na podlagi filtriranega pospeška','Signal pozicije brez filtriranja pospeška');
xlabel('Èas (s)');
ylabel('Pozicija (m)');
%xlim([0 7])
%ylim([-0.3 0.3])
hold off;
%}