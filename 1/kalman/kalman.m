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
%data = csvread('../../data/asus_-1+1.csv');
%data = csvread('../../data/asus_roka-1+1.csv');
    %data = csvread('../../data/asus_pravokotnika+diagonala_and_back.csv');
    %data = csvread('../../data/asus_factory.csv');
%data = csvread('../../data/asus_triangle_-1+05+05.csv');
%data = csvread('../../data/zacetek_vertikala.csv');

%data = csvread('../../data/asus-1+05+05.csv');
    %data = csvread('../../data/asus_pol_test.csv');
%data = csvread('../../data/asus_L_test.csv'); %-1+05+u05+05-u05
%data = csvread('../../data/asus_dvojnitrikotnik05.csv');
%data = csvread('../../data/asus_factory_2.csv');
%data = csvread('../../data/asus_+1-1+1-1.csv');
%data = csvread('../../data/asus_hitro_levo_desno.csv');
%data = csvread('../../data/asus_hitro-1+1_2.csv');
%data = csvread('../../data/lastTest.csv');
%data = csvread('../../data/hitro_in_posasi.csv');
%data = csvread('../../data/hitro_in_posasi_2.csv');

%data = csvread('../../data/asus_data.csv');

%kratki premiki
%data = csvread('../../data/kratka_razdalja_3x.csv');
%data = csvread('../../data/-20+20-20+20-20+10+10.csv');
%data = csvread('../../data/d20+g20+l20.csv');
%data = csvread('../../data/-10+20.csv');
%data = csvread('../../data/gyro1.csv');
%data = csvread('../../data/gyro2.csv');
%data = csvread('../../data/gyro3.csv');

%data = csvread('../../data/gyro4.csv');
data = csvread('../../data/gyro5.csv');
%data = csvread('../../data/gyro6.csv');

clear pospesek_raw;
clear pospesek;
clear hitrost_raw;
clear hitrost;
clear pozicija_raw;
clear pozicija;

iteracija_gibanja = 0;

giroskop = data(:,6);

%upo�tevam samo acceleracijo po x-osi
data = data(:,1);

%debugging
%data = removerows(data,'ind',1500:3500);
%data = removerows(data,'ind',1:800);

%prag_pospesek = 0.8;
prag_pospesek = 0.4;

prag_hitrost = 0.03;

fistRun_pospesek = 1;
firstRun_filtriranjePospeska = 1;
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

%inicializacija dvojne integracije (za�etni pogoji: hitrost = 0 in pozicija = 0)
hitrost = zeros(1,length(filteredData),1); %po prvi itegraciji dobim hitrost
hitrost_raw = zeros(1,length(filteredData),1);
pozicija = zeros(length(filteredData),1); %po drugi integraciji pa dobim pozicijo
pozicija_raw = zeros(length(filteredData),1);

%�asovni interval
%t = 0.02; %game
%t = 0.01; %fastest samsung
t = 0.005; %fastest asus
freq = 1 / t; %50Hz

gravity = 0;

mejeSistemaX = 0.05;

giroskopIntegracija = 0;

%iterator (real-time simulator)
for i=1:data_length
    
    %filtering linear acceleration
    if(i-1>0)
        filteredData(i) = Filtering(source, i, 'kalman', {varianca_a, 'pospesek'});      
    else
        filteredData(i) = 0;
    end
    
    %{
    test = filteredData(i)
    test
    %}
    
    %popravek filtriranja
    [filteredData(i) firstRun_filtriranjePospeska] = Popravek_pospeska(filteredData, i, prag_pospesek, firstRun_filtriranjePospeska );
    
    %{
    test = filteredData(i)
    if(i>=322)
        i
    end
    %}
    
    %integracija - hitrost
    if(i-1>0)
        hitrost_raw(i) = hitrost_raw(i-1) + Integration_step(filteredData,i,freq,'trapez');
        
        %filtriranje
        hitrost(i) = hitrost_raw(i); %brez filtriranja
        test = hitrost(i);
        i
        %hitrost(i) = Filtering(hitrost_raw, i, 'kalman', {varianca_h, 'hitrost'});  
    else
        hitrost_raw(i) = 0;
        hitrost(i) = 0;
    end
    %popravek filtriranja
    [nova_hitrost fistRun_hitrost iteracija_gibanja] =  Popravek_hitrosti(filteredData, hitrost, i, fistRun_hitrost, iteracija_gibanja);
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
    
    posTmp = pozicija(i)
    if(i>=400)
        posTmp
    end
    
    sprVrednostGledeMej = 0;
    pozicija(i)
    if pozicija(i) < -mejeSistemaX
        sprVrednostGledeMej = -mejeSistemaX;
    end
    if pozicija(i) > mejeSistemaX
        sprVrednostGledeMej = mejeSistemaX;
    end
    %preverim ce je prislo do sprememb mej
    if sprVrednostGledeMej ~= 0
        %omejimo pozicijo
        pozicija(i) = sprVrednostGledeMej;
            pozicija_raw(i) = sprVrednostGledeMej;
        %hitrost tudi postavimo na 0, saj se je zadeva ustavila
        hitrost(i) = 0;
            %hitrost_raw(i) = 0;
        %dolo�im da je nov za�etek gibanja, s �imer se tudi omogo�i
        %instantno spremembo smeri
        iteracija_gibanja = 0;
    end
    
    %popravek pozicije na podlagi kalibracije
    %pozicija(i) = pozicija(i) * 2.2;
    
    %giroskop test
    if(i-1>0)
        giroskopIntegracija(i) = giroskopIntegracija(i-1) + Integration_step(giroskop,i,freq,'trapez');
    else
        giroskopIntegracija(i) = 0;
    end
end

%pospe�ek
x = 1:data_length;

%pobri�em grafe
clf

subplot(5,1,1);
plot(x, source, 'color', 'red');
hold on;
plot(x, filteredData, 'color', 'blue');
legend('originalni podatki pospe�ka','filtrirani podatki pospe�ka');
hold off;

%hitrost
subplot(5,1,2);
%plot(x, hitrost_raw, 'color', 'red');
hold on;
plot(x, hitrost_raw, 'color', 'red');
plot(x, hitrost, 'color', 'blue');
legend('hitrost NE-filtrirana','hitrost filtrirana');
%ylim([-2 2])
ylim([-0.5 0.5])
hold off;

%giroskop
subplot(5,1,3);
plot(x, giroskop, 'color', 'black');
legend('giroskop');
%giroskop integracija
subplot(5,1,4);
plot(x, giroskopIntegracija, 'color', 'black');
legend('giroskop integracija');

%pozicija
subplot(5,1,5);
plot(x, pozicija, 'color', 'blue');
legend('pozicija');