%preberem csv datoteko
%data1 = dlmread('./Sensor_record_20150428_205937_noHdr.csv', ';');
%data1 = dlmread('./nexus7_1.csv', ',');
%data1 = dlmread('./nexus7_2_drsenje.csv', ',');
%data1 = dlmread('./n_podlaga-1+1.csv', ',');
data1 = dlmread('./n_roka-1+1.csv', ',');

data=data1(:,1:3);

clear pospesek_raw;
clear pospesek;
clear hitrost_raw;
clear hitrost;
clear pozicija_raw;
clear pozicija;
iteracija_gibanja = 0;
firstRun_filtriranjePospeska = 1;

%upoštevam samo pospešek po x-osi
data = data(:,1); %X

source = data;
data_length = length(source);

%inicializacija dvojne integracije (zaèetni pogoji: hitrost = 0 in pozicija = 0)
filteredData = zeros(1,length(source),1);
drift = zeros(1,length(source),1);
hitrost = zeros(1,length(source),1); %po prvi itegraciji dobim hitrost
hitrost_raw = zeros(1,length(source),1);
pozicija = zeros(length(source),1); %po drugi integraciji pa dobim pozicijo
pozicija_raw = zeros(length(source),1);

%èasovni interval
t = 0.005; %fastest asus
freq = 1 / t; %200Hz

%IIR filter
%[b, a] = butter(2, 0.05, 'low');
[b, a] = butter(2, 0.0005, 'low');

%ini bufferja
bufferInput = zeros(1, 2, 1);
bufferOutput = zeros(1, 2, 1);
b_len = 2;

%iterator (real-time simulator)
for i=1:data_length
    
    %-----------------------
    %IIR filtriranje - begin
    %-----------------------
    if(i > 2)
        current_drift = b(1)*source(i) + b(2)*bufferInput(2) + b(3)*bufferInput(1) - a(2)*bufferOutput(2) - a(3)*bufferOutput(1);
        if(abs(source(i)) < 1)
            %filtriranje - uporabim prenosno funkcijo
            drift(i) = current_drift;
        else
            drift(i) = 0;
        end;
    else
        current_drift = 0;
        drift(i) = 0;
    end
    
    %dam v buffer
    bufferInput(1) = bufferInput(2);
    bufferInput(2) = source(i);
    bufferOutput(1) = bufferOutput(2);
    bufferOutput(2) = current_drift;
    
    %drift odštejem od signala pospeška
    filteredData(i) = source(i) - drift(i);        
    
    %---------------------
    %IIR filtriranje - end
    %---------------------
    
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
xlabel('Iteracija vzorèenja');
ylabel('Pospešek (m/s^2)');
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
legend('Signal hitrosti brez filtriranja pospeška','Signal hitrosti na podlagi filtriranega pospeška');
xlabel('Iteracija vzorèenja');
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
legend('Signal pozicije brez filtriranja pospeška', 'Signal pozicije na podlagi filtriranega pospeška');
xlabel('Iteracija vzorèenja');
ylabel('Pozicija (m)');
%xlim([0 7])
%ylim([-0.3 0.3])
hold off; 
grid on
%}