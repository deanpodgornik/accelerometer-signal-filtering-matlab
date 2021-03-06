%preberem csv datoteko

%data = csvread('./nexus7_1.csv') 

data1 = dlmread('./Sensor_record_20150428_205937_noHdr.csv', ';');
% data0=data1(1:1500,1:3); %ustaljeno stanje
% Ninit=0;
% data00=repmat(data0,Ninit,1);
% data2=data1(:,1:3);
% data=[data00;data2];
data=data1(:,1:3);

clear pospesek_raw;
clear pospesek;
clear hitrost_raw;
clear hitrost;
clear pozicija_raw;
clear pozicija;
iteracija_gibanja = 0;

%upo�tevam samo pospe�ek po x-osi
%data = data(:,1); %X
data = data(:,1); %xYz

source = data;
data_length = length(source);

%filteredData = iir_high(source);
%[B, A] = butter(10, 0.0145, 'high');
[b, a] = butter(2, 0.0005, 'high');
filteredData = filter(b,a,source);

%pore�emo za�etni del za inicializacijo
% source = source(Ninit*1500+1:length(source));
% filteredData = filteredData(Ninit*1500+1:length(filteredData));
% data_length = length(source);

%inicializacija dvojne integracije (za�etni pogoji: hitrost = 0 in pozicija = 0)
hitrost = zeros(1,length(filteredData),1); %po prvi itegraciji dobim hitrost
hitrost_raw = zeros(1,length(filteredData),1);
pozicija = zeros(length(filteredData),1); %po drugi integraciji pa dobim pozicijo
pozicija_raw = zeros(length(filteredData),1);

%�asovni interval
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

%pospe�ek
x = 1:data_length;

clf

%%{
subplot(3,1,1);
plot(x, source, 'color', 'red');
hold on;
plot(x, filteredData, 'color', 'blue');
legend('Originalen signal pospe�ka','Filtriran signal pospe�ka');
xlabel('�as (s)');
ylabel('Pospe�ek (m/s^2)');
%xlim([0 7])
%ylim([-4 4])
hold off;
grid on
%}


%hitrost
%%{
subplot(3,1,2);
%plot(x, hitrost_raw, 'color', 'red');
hold on;
plot(x, hitrost_raw, 'color', 'red');
plot(x, hitrost, 'color', 'blue');
legend('Signal hitrosti brez filtriranja pospe�ka','Signal hitrosti na podlagi filtriranega pospe�ka');
xlabel('�as (s)');
ylabel('Hitrost (m/s)');
%xlim([0 7])
%ylim([-0.5 0.7])
hold off;
grid on
%}

%pozicija
%%{
subplot(3,1,3);
hold on;
plot(x, pozicija_raw, 'color', 'red');
plot(x, pozicija, 'color', 'blue');
legend('Signal pozicije brez filtriranja pospe�ka', 'Signal pozicije na podlagi filtriranega pospe�ka');
xlabel('�as (s)');
ylabel('Pozicija (m)');
%xlim([0 7])
%ylim([-0.3 0.3])
hold off; 
grid on
%}