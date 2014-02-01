%preberem csv datoteko
data = csvread('../data/asus_50_game_hitro.csv');
data(:,4)=[];
%upoštevam samo acceleracijo po x-osi
data = data(:,1);
freq = 50; %Hz

filteredData = data;

%Postopek integriranja
hitrost_raw = zeros(length(filteredData),1);
hitrost = zeros(length(filteredData),1);
pozicija_raw = zeros(length(filteredData),1);
pozicija = zeros(length(filteredData),1);

%iterator (real-time simulator)
for i=1:length(filteredData)
    
    %integracija - hitrost
    if(i-1>0)
        hitrost_raw(i) = hitrost_raw(i-1) + Integration_step(filteredData,i,freq,'trapez');
        hitrost(i) = hitrost_raw(i);
    else
        hitrost_raw(i) = 0;
        hitrost(i) = 0;
    end

    %integracija - pozicija
    if(i-1>0)
        pozicija_raw(i) = pozicija_raw(i-1) + Integration_step(hitrost,i,freq,'trapez');;
        pozicija(i) = pozicija_raw(i);
    else
        pozicija_raw(i) = 0;
        pozicija(i) = 0;
    end
end

x = 1:length(data);

subplot(3,1,1), plot(x,data); title('NE-filtriran signal');

subplot(3,1,2), plot(x,hitrost); title('hitrost');

subplot(3,1,3), plot(x,pozicija); title('pozicija');