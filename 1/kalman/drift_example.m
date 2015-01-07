data = csvread('../../data/drift_asus_1.csv')

data = data(:,1); %X

delta_t = 1 / 200;
x = delta_t:delta_t:(length(data)*delta_t);
%{
plot(x, data, 'color', 'blue');
hold on;
legend('Signal pospeška');
xlabel('Èasovna perioda (200 Hz)');
ylabel('Pospešek');
axis([0 1000 -0.05 0.05]);
hold off;
%}

%integracija
hitrost = zeros(length(data),1);
pozicija = zeros(length(data),1);
for i=1:length(data)
    %hitrost
    if(i-1>0)
        hitrost(i) = hitrost(i-1) + Integration_step(data,i,200,'trapez');
    else
        hitrost(i) = 0;
    end
    
    %pozicija
    if(i-1>0)
        pozicija(i) = pozicija(i-1) + Integration_step(hitrost,i,200,'trapez');
    else
        pozicija(i) = 0;
    end
end

%%{
plot(x, data, 'color', 'blue');
hold on;
legend('Signal pospeška (m/s^2)');
xlabel('Èas (s)');
ylabel('Pospešek (m/s^2)');
%axis([0 14 -0.1 0.10]);
%hold off;
%}

%%{
plot(x, pozicija, 'color', 'red');
hold on;
legend('Signal pospeška (m/s^2)','Signal premika (m)');
xlabel('Èas (s)');
ylabel('Premik (m)                       Pospešek (m/s^2)');
axis([0 14 -0.6 0.2]);
hold off;
%}