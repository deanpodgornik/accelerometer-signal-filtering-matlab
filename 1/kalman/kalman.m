%preberem csv datoteko
data = csvread('../../data/asus_50_povratna.csv');
data(:,4)=[];
%upoštevam samo acceleracijo po x-osi
data = data(:,1);

prag_pospesek = 0.08;
prag_hitrost = 0.08;

source = data;
varianca_a = var(source);
varianca_h = var(source);
varianca_p = 0.0054;
data_length = length(source);

%inicializacija
filteredData = source;
clear Filtering;
clear Filter_SimpleKalman;

%inicializacija dvojne integracije (zaèetni pogoji: hitrost = 0 in pozicija = 0)
hitrost = zeros(1,length(filteredData),1); %po prvi itegraciji dobim hitrost
hitrost_raw = zeros(1,length(filteredData),1);
pozicija = zeros(length(filteredData),1); %po drugi integraciji pa dobim pozicijo
pozicija_raw = zeros(length(filteredData),1);

%èasovni interval
t = 0.02; %game 
freq = 1 / t; %50Hz

%iterator (real-time simulator)
for i=1:data_length
    if(i-1>0)
        filteredData(i) = Filtering(source, i, 'kalman', {varianca_a, 'pospesek'});      
    else
        filteredData(i) = 0;
    end
    %raw filtering
    if(abs(filteredData(i))<prag_pospesek)
        filteredData(i) = 0;
    end
    
    %integracija - hitrost
    if(i-1>0)
        hitrost_raw(i) = hitrost_raw(i-1) + Integration_step(filteredData,i,freq,'trapez');
        
        %filtriranje
        hitrost(i) = hitrost_raw(i); %brez filtriranja
        %hitrost(i) = Filtering(hitrost_raw, i, 'kalman', {varianca_h, 'hitrost'}) + 0.06;  
    else
        hitrost_raw(i) = 0;
        hitrost(i) = 0;
    end
    %raw filtering
    if(abs(hitrost(i))<prag_hitrost)
        hitrost(i) = 0;
    end

    %integracija - pozicija
    if(i-1>0)
        pozicija_raw(i) = pozicija_raw(i-1) + Integration_step(hitrost,i,freq,'trapez');
        
        %filtriranje
        %pozicija(i) = Filtering(pozicija_raw, i);
        pozicija(i) = pozicija_raw(i);
    else
        pozicija_raw(i) = 0;
        pozicija(i) = 0;
    end
end

%IIR
%filteredData = IIR2(source);

%pospešek
x = 1:data_length;

subplot(3,1,1);
plot(x, source, 'color', 'red');
hold on;
plot(x, filteredData, 'color', 'blue');
legend('originalni podatki pospeška','filtrirani podatki pospeška');
hold off;

%hitrost
subplot(3,1,2);
%plot(x, hitrost_raw, 'color', 'red');
hold on;
plot(x, hitrost_raw, 'color', 'red');
plot(x, hitrost, 'color', 'blue');
legend('hitrost');
hold off;

%pozicija
subplot(3,1,3);
plot(x, pozicija, 'color', 'blue');
legend('pozicija');

