%preberem csv datoteko

data = csvread('../../data/acc17.csv') 

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

source = data;


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
hitrost_filtered = zeros(1,length(filteredData),1);
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
        filteredData(i) = Filtering(source, i, 'kalman', {varianca_a, 'pospesek', os_z});      
    else
        filteredData(i) = 0;
    end
    
    %integracija - hitrost
    if(i-1>0)
        hitrost(i) = hitrost(i-1) + Integration_step(source,i,freq,'trapez');   
        hitrost_filtered(i) = hitrost_filtered(i-1) + Integration_step(filteredData,i,freq,'trapez');   
    else
        hitrost(i) = 0;
        hitrost_filtered(i) = 0;
    end
end

%pospešek
delta_t = 1 / 200;
data_length = length(data);
x = delta_t:delta_t:((data_length*delta_t));

%%{
plot(x, source, 'color', 'blue');
hold on;
plot(x, filteredData, 'color', 'red');
xlabel('Èas (s)');
%axis([0 14 -0.1 0.10]);
hold off;
%}

%%{
figure(2);
plot(x, hitrost, 'color', 'blue');
hold on;
plot(x, hitrost_filtered, 'color', 'red');
legend('Signal pospeška (m/s^2)','Signal hitrosti (m/s)');
xlabel('Èas (s)');
ylabel('Hitrost (m/s)       |       Pospešek (m/s^2)');
%axis([0 14 -0.6 0.2]);
xlim([0,8]);
hold off;
%}