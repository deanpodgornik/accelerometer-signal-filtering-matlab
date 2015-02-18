data = csvread('../../data/grav_test_3_acc.csv')
data2 = csvread('../../data/grav_test_3_grav.csv')

data = data(:,1); %X
data2 = data2(:,1); %X

data = data(760:1800);
data2 = data2(760:1800);

delta_t = 1 / 200;
x = delta_t:delta_t:(length(data)*delta_t);
x2 = delta_t:delta_t:(length(data2)*delta_t);
%{
plot(x, data, 'color', 'blue');
hold on;
legend('Signal pospeška');
xlabel('Èasovna perioda (200 Hz)');
ylabel('Pospešek');
axis([0 1000 -0.05 0.05]);
hold off;
%}

%%{
plot(x, data, 'color', 'blue');
hold on;
plot(x2, data2, 'color', 'red');
legend('Signal pospeška (m/s^2)','Signal gravitacije (m/s^2)');
xlabel('Èas (s)');
ylabel('Pospešek (m/s^2)');
%axis([4 9 -0.1 0.10]);
xlim([0,5]);
hold off;
%}