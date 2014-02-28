%preberem csv datoteko
%data = csvread('../../data/samsung_50_povratna_v2.csv');
%data = csvread('../../data/samsung_50_2_enosmerna.csv');
%data = csvread('../../data/samsung_50_dve_smeri.csv');
%data = csvread('../../data/samsung_50_v_roki.csv');
%data = csvread('../../data/asus_50_povratna.csv');
%data = csvread('../../data/samsung_-1+0.5+0.5.csv');
%data = csvread('../../data/samsung_-0.5-0.5+0.5+0.5.csv');
%data = csvread('../../data/samsung_h_-1+0.5+0.5.csv');
%data = csvread('../../data/samsung_raw_acceleration.csv');
%data = csvread('../../data/asus-1+05+05.csv');
%data = csvread('../../data/asus_-1+1.csv');
%data = csvread('../../data/asus_roka-1+1.csv');
%data = csvread('../../data/asus_triangle_-1+05+05.csv');
%data = csvread('../../data/zacetek_vertikala.csv');
%data = csvread('../../data/asus_pol_test.csv');
    %data = csvread('../../data/asus_pravokotnika+diagonala_and_back.csv');
    %data = csvread('../../data/asus_factory.csv');

%data = csvread('../../data/asus_L_test.csv'); %-1+05+u05+05-u05
%data = csvread('../../data/asus_dvojnitrikotnik05.csv');
%data = csvread('../../data/asus_factory_2.csv');
data = csvread('../../data/asus_+1-1+1-1.csv');
%data = csvread('../../data/asus_hitro_levo_desno.csv');
%data = csvread('../../data/asus_hitro-1+1_2.csv');

%upoštevam samo acceleracijo po x-osi
data = data(:,1);

%debugging
%data = removerows(data,'ind',1500:3500);
%data = removerows(data,'ind',1:800);

prag_pospesek = 0.8;
prag_hitrost = 0.03;

fistRun_pospesek = 1;
fistRun_hitrost = 1;

source = data;
raw_acceleration = data;
%varianca_a = var(source);
varianca_a = 1.7346;
varianca_h = var(source);
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
%t = 0.02; %game
%t = 0.01; %fastest samsung
t = 0.005; %fastest asus
freq = 1 / t; %50Hz

gravity = 0;

%iterator (real-time simulator)
for i=1:data_length
    
    %filtering linear acceleration
    if(i-1>0)
        filteredData(i) = Filtering(source, i, 'kalman', {varianca_a, 'pospesek'});      
    else
        filteredData(i) = 0;
    end
    %popravek filtriranja
    filteredData(i) = Popravek_pospeska(filteredData, i, prag_pospesek);
    
    %integracija - hitrost
    if(i-1>0)
        hitrost_raw(i) = hitrost_raw(i-1) + Integration_step(filteredData,i,freq,'trapez');
        
        %filtriranje
        hitrost(i) = hitrost_raw(i); %brez filtriranja
        %hitrost(i) = Filtering(hitrost_raw, i, 'kalman', {varianca_h, 'hitrost'});  
    else
        hitrost_raw(i) = 0;
        hitrost(i) = 0;
    end
    %popravek filtriranja
    [nova_hitrost fistRun_hitrost] =  Popravek_hitrosti(filteredData, hitrost, i, fistRun_hitrost);
    hitrost(i) = nova_hitrost;

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
    
    %popravek pozicije na podlagi kalibracije
    pozicija(i) = pozicija(i) * 2.2;
end

%pospešek
x = 1:data_length;

%pobrišem grafe
clf

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
legend('hitrost NE-filtrirana','hitrost filtrirana');
ylim([-2 2])
hold off;

%pozicija
subplot(3,1,3);
plot(x, pozicija, 'color', 'blue');
legend('pozicija');