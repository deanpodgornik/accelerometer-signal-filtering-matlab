%preberem csv datoteko

data = csvread('../../data/x_axe.csv');

clear pospesek_raw;
clear pospesek;
clear hitrost_raw;
clear hitrost;
clear pozicija_raw;
clear pozicija;

iteracija_gibanja = 0;

%upoštevam samo acceleracijo po x-osi
data = data(:,1); %X
%data = data(1600:2100);
%data = data(50:480);

global os_z;
os_z = false;

%pospešek
delta_t = 1 / 200;
data_length = length(data);
x = delta_t:delta_t:(data_length*delta_t);

%hitrost
%plot(x, hitrost_raw, 'color', 'red');
plot(x, data, 'color', 'red');
legend('Signal pospeška');
%ylim([-0.15 0.15])
xlim([0 11])
xlabel('Èas (s)');
ylabel('Pospešek (m/s^2)');
