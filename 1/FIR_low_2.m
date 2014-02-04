%preberem csv datoteko
data = csvread('../data/asus_50_povratna.csv');
data(:,4)=[];
%upoštevam samo acceleracijo po x-osi
data = data(:,1);

prag_pospeska = 0.05;
prag_hitrosti = 0.05;

%filter design
freq = 50; %Hz

%FILTRIRANJE
Fpass = 0.6;   % Passband Frequency
Fstop = 0.62;  % Stopband Frequency
Apass = 1;     % Passband Ripple (dB)
Astop = 6;    % Stopband Attenuation (dB)   
h = fdesign.lowpass('fp,fst,ap,ast', Fpass, Fstop, Apass, Astop);    
Hd = design(h, 'kaiserwin');
set(Hd,'PersistentMemory',true);
filteredData = filter(Hd,data);

%filteredData = data;

%podrobno filtriranje
for i=1:length(filteredData)
    if(i<2)
        filteredData(i) = 0;
    else
        if(abs(filteredData(i))<prag_pospeska)
           filteredData(i) = 0; 
        end        
    end
end

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
        
        %fine filter
        %hitrost(i) = Iterator_FIR(data, i, Hd.Numerator);
        %raw filter
        if(abs(hitrost(i))<prag_pospeska)
           hitrost(i) = 0; 
        end
    else
        hitrost_raw(i) = 0;
        hitrost(i) = 0;
    end
    
    %integracija - pozicija
    if(i-1>0)
        pozicija_raw(i) = pozicija_raw(i-1) + Integration_step(hitrost,i,freq,'trapez');
        pozicija(i) = pozicija_raw(i);
    else
        pozicija_raw(i) = 0;
        pozicija(i) = 0;
    end
end

x = 1:length(data);

subplot(4,1,1), plot(x,data); title('NE-filtriran signal');

subplot(4,1,2), plot(x,filteredData); title('filtriran signal');

subplot(4,1,3), hold on, plot(x,hitrost_raw, 'color', 'red'), plot(x,hitrost, 'color', 'blue'), hold off; title('hitrost');

subplot(4,1,4), plot(x,pozicija); title('pozicija');