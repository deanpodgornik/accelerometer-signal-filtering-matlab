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
data = csvread('../../data/hitro_in_posasi_2.csv');

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
%data = csvread('../../data/gyro5.csv');
%data = csvread('../../data/gyro6.csv');

%data = csvread('../../data/gyro10.csv'); %Y
%data = csvread('../../data/gyro12.csv'); %Y
%data = csvread('../../data/gyro13.csv'); %Y
%data = csvread('../../data/gyro15.csv') %Z
%data = csvread('../../data/gyro16.csv') %Z
%data = csvread('../../data/acc1.csv'); %Y

%data = csvread('../../data/gyro9.csv');
%data = csvread('../../data/gyro11.csv');

%data = csvread('../../data/acc2.csv');
%data = csvread('../../data/acc3.csv');
%data = csvread('../../data/acc4.csv');
%data = csvread('../../data/acc6.csv');

%data = csvread('../../data/acc8.csv');

%data = csvread('../../data/acc5.csv');
%data = csvread('../../data/acc7.csv');
%data = csvread('../../data/acc10.csv')

%data = csvread('../../data/acc12.csv')
%data = csvread('../../data/acc13.csv')
%data = csvread('../../data/acc14.csv')


%data = csvread('../../data/acc17.csv')

%data = csvread('../../data/acc19.csv')
%data = csvread('../../data/acc21.csv')

%napake
%data = csvread('../../data/acc22.csv')

%data = csvread('../../data/acc23.csv')
%data = csvread('../../data/acc24.csv')
%data = csvread('../../data/acc25.csv')
%data = csvread('../../data/acc26.csv')

%data = csvread('../../data/acc18.csv')
%data = csvread('../../data/acc20.csv')
%data = csvread('../../data/acc27.csv')
%data = csvread('../../data/acc28.csv')

%data = csvread('../../data/acc9.csv');
%data = csvread('../../data/acc11.csv')
%data = csvread('../../data/acc15.csv')
%data = csvread('../../data/acc16.csv')

%data = csvread('../../data/s4_1.csv')
%data = csvread('../../data/s4_2.csv')
%data = csvread('../../data/s4_3.csv')
%data = csvread('../../data/s4_4.csv')

%data = csvread('../../data/s4_napaka.csv')
%data = csvread('../../data/s4_napaka_2.csv')

%data = csvread('../../data/asus_z_1.csv') %Z
%data = csvread('../../data/asus_z_2.csv') %Z
%data = csvread('../../data/asus_z_3.csv') %Z
%data = csvread('../../data/asus_z_4.csv') %Z
%data = csvread('../../data/asus_z_5.csv') %Z
%data = csvread('../../data/asus_z_6.csv') %Z
data = csvread('../../data/asus_z_7.csv') %Z

clear pospesek_raw;
clear pospesek;
clear hitrost_raw;
clear hitrost;
clear pozicija_raw;
clear pozicija;

iteracija_gibanja = 0;

%upoštevam samo acceleracijo po x-osi
%data = data(:,1); %X
%data = data(:,2); %Y
data = data(:,3); %Z

global os_z;
os_z = true;

%doloèim koliko oddaljena je meja slike od izhodišèa
mejeSistemaX = 110.10958966816079618;
mejeSistemaY = 110.09015211004304888;

%debugging
%data = removerows(data,'ind',1500:3500);
%data = removerows(data,'ind',1:800);

if(os_z)
    prag_pospesek = 0.8;
else
    prag_pospesek = 0.4;
end
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

prag_filtriranja_niz_frek = 0.04;

global popravek_hitrosti_num;

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
%t = 0.01; %fastest samsung
t = 0.005; %fastest asus
freq = 1 / t; %50Hz

gravity = 0;

%spremenljivka drži informacijo ali smo zadeli mejo slike ali ne
zadetekMejeSlike = 0;

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
    
    %%{
    test = filteredData(i)
    if(i>=220)
        i
    end
    %}
    
    %integracija - hitrost
    if(i-1>0)
        hitrost_raw(i) = hitrost_raw(i-1) + Integration_step(filteredData,i,freq,'trapez');
        
        i
        if(i>400)
            i
        end
        
        %filtriranje nizkih frekvenc
        if abs(hitrost_raw(i)-popravek_hitrosti_num) < prag_filtriranja_niz_frek
            hitrost(i) = popravek_hitrosti_num;
        else
            hitrost(i) = hitrost_raw(i);
        end
        
        %hitrost(i) = Filtering(hitrost_raw, i, 'kalman', {varianca_h, 'hitrost'});  
    else
        hitrost_raw(i) = 0;
        hitrost(i) = 0;
    end
    %popravek filtriranja hitrosti
    [nova_hitrost fistRun_hitrost iteracija_gibanja zadetekMejeSlike] =  Popravek_hitrosti(filteredData, hitrost, hitrost_raw, i, fistRun_hitrost, iteracija_gibanja, zadetekMejeSlike);
    hitrost(i) = nova_hitrost;

    %integracija - pozicija
    if(i-1>0)
        %faktor_pozicije = 2.2;
        faktor_pozicije = 2.2;
        pozicija_raw(i) = pozicija_raw(i-1) + Integration_step(hitrost,i,freq,'trapez') * faktor_pozicije;
        
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
    
    %preverjanje trka ob mejo slike
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
        %doloèim da je nov zaèetek gibanja, s èimer se tudi omogoèi
        %instantno spremembo smeri
        iteracija_gibanja = 0;
        
        %shranim informacijo da je prišlo do zadetka v mojo slike
        zadetekMejeSlike = 1;
    end
    
    %popravek pozicije na podlagi kalibracije (skaliranje)
    if(os_z)
        %brez skaliranja z-osi
    else
        %skaliranje x in y osi
        pozicija(i) = pozicija(i) * 2.2;
    end
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
%ylim([-2 2])
ylim([-1.5 1.5])
hold off;

%pozicija
subplot(3,1,3);
plot(x, pozicija, 'color', 'blue');
legend('pozicija (m)');