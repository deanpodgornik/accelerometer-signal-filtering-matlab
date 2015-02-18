dataTmp = csvread('../../data/acc5.csv');
dataTmp = dataTmp(:,1); %X
data = dataTmp(201:599);

varianca_a = 1.7346;

delta_t = 1 / 200;
data_length = length(data);
x = delta_t:delta_t:((data_length*delta_t));

%iterator (real-time simulator)
for i=1:data_length
    
    %filtering linear acceleration
    if(i-1>0)
        filteredData(i) = Filtering_dem(data, i, 'kalman', {varianca_a, 'pospesek', false});      
    else
        filteredData(i) = 0;
    end
end

plot(x, data, 'color', 'red');
hold on;
plot(x, filteredData, 'color', 'blue');
legend('originalen signal pospeškometra','filtriran signal pospeškometra');
xlabel('Èas (s)');
ylabel('Pospešek (m/s^2)');
hold off;

%izraèun hitrosti in premika (brez pravil)

%inicializacija dvojne integracije (zaèetni pogoji: hitrost = 0 in pozicija = 0)
hitrost = zeros(1,length(filteredData),1); %po prvi itegraciji dobim hitrost
hitrost_raw = zeros(1,length(filteredData),1);
pozicija = zeros(length(filteredData),1); %po drugi integraciji pa dobim pozicijo
pozicija_raw = zeros(length(filteredData),1);
freq = 200;

for i=1:data_length
        
    %integracija - hitrost
    if(i-1>0)
        hitrost_raw(i) = hitrost_raw(i-1) + Integration_step(data,i,freq,'trapez');
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

figure(2);
plot(x, hitrost_raw, 'color', 'red');
hold on;
plot(x, hitrost, 'color', 'blue');
legend('Signal hitrosti pridobljen iz nefiltriranega signala pospeška','Signal hitrosti pridobljen iz filtriranega signala pospeška');
xlabel('Èas (s)');
ylabel('Hitrost (m/s)');
ylim([-0.25 0.32])
hold off;

%{
figure(3);
plot(x, pozicija_raw, 'color', 'red');
hold on;
plot(x, pozicija, 'color', 'blue');
legend('Signal pozicije pridobljen iz nefiltriranega signala pospeška','Signal pozicije pridobljen iz filtriranega signala pospeška');
xlabel('Èas (s)');
ylabel('Pozicija (m/s)');
hold off;
%}