%preberem csv datoteko

data = csvread('../../data/demo_n7_t5.csv') 

clear pospesek_raw;
clear pospesek;
clear hitrost_raw;
clear hitrost;
clear pozicija_raw;
clear pozicija;

iteracija_gibanja = 0;

%upoštevam samo acceleracijo po x-osi
data = data(:,1); %X
%data = data(:,2); %Y
%data = data(:,3); %Z

%data = data(200:1600);

global os_z;
os_z = false;

%doloèim koliko oddaljena je meja slike od izhodišèa
mejeSistemaX = 110.10958966816079618;
mejeSistemaY = 110.09015211004304888;

%debugging
%data = removerows(data,'ind',1500:3500);
%data = removerows(data,'ind',1:800);

%potrebno za znizati povpreèje pospeška z osi
razlika_od_povprecja = 0;

prag_pospesek = 0.4;

source = data;

%popravek podatkov pospeška (odštevanje povpreène vrednosti)
data_length = length(source);
for i=1:data_length
    data(i) = data(i) - razlika_od_povprecja;
end

%odpravljanje napake zaèetne nestabilnosti (Samsung S4)
st_ponavljajoce_vrednosti = 0;
pragPonavljanja = 400; %2s
ponavljajoca_vrednost = source(i);
zacetnaNestabilnostSt = 0;
prag_pospeseka_nestabilnosti = 0.1;
for i=2:data_length
    %opravim filtriranje nizkih frekvenc
    vhodni_podatek = source(i);
    if abs(vhodni_podatek) < prag_pospeseka_nestabilnosti
        vhodni_podatek = 0;
    end    
    
    if (abs(vhodni_podatek - ponavljajoca_vrednost) < 0.0005)
        st_ponavljajoce_vrednosti = st_ponavljajoce_vrednosti + 1;
    else
        ponavljajoca_vrednost = vhodni_podatek;
        st_ponavljajoce_vrednosti = 0;
    end
    
    if(st_ponavljajoce_vrednosti>pragPonavljanja)
        zacetnaNestabilnostSt = i;
        break;
    end
end
zacetnaNestabilnostRezultat = zacetnaNestabilnostSt - pragPonavljanja
%data = data(zacetnaNestabilnostRezultat:end);
%source = data;
data_length = length(source);

fistRun_pospesek = 1;
firstRun_filtriranjePospeska = 1;
fistRun_hitrost = 1;

raw_acceleration = data;
%varianca_a = var(source);
varianca_a = 1.7346;
varianca_h = var(source);

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

for i=1:length(data)
    
    %filtering linear acceleration
    if(i-1>0)
        filteredData(i) = Filtering_dem(source, i, 'kalman', {varianca_a, 'pospesek', os_z});      
    else
        filteredData(i) = 0;
    end
    
    %popravek filtriranja
    [filteredData(i) firstRun_filtriranjePospeska] = Popravek_pospeska(filteredData, i, prag_pospesek, firstRun_filtriranjePospeska );
    
    %integracija - hitrost
    if(i-1>0)
        hitrost_raw(i) = hitrost_raw(i-1) + Integration_step(filteredData,i,freq,'trapez');
        
    else
        hitrost_raw(i) = 0;
        hitrost(i) = 0;
    end
end

%pospešek
delta_t = 1 / 200;
data_length = length(data);
x = delta_t:delta_t:((data_length*delta_t));

%%{
plot(x, filteredData, 'color', 'blue');
hold on;
xlabel('Èas (s)');
%axis([0 14 -0.1 0.10]);
%hold off;
%}

%%{
plot(x, hitrost_raw, 'color', 'red');
hold on;
legend('Signal pospeška (m/s^2)','Signal hitrosti (m/s)');
xlabel('Èas (s)');
ylabel('Hitrost (m/s)       |       Pospešek (m/s^2)');
%axis([0 14 -0.6 0.2]);
xlim([0,8]);
hold off;
%}