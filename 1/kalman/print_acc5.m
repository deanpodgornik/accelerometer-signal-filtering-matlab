dataTmp = csvread('../../data/acc5.csv');
dataTmp = dataTmp(:,1); %X
data = dataTmp(200:599);

varianca_a = 1.7346;

delta_t = 1 / 200;
data_length = length(data);
x = delta_t:delta_t:(data_length*delta_t);

%iterator (real-time simulator)
for i=1:data_length
    
    %filtering linear acceleration
    if(i-1>0)
        filteredData(i) = Filtering(data, i, 'kalman', {varianca_a, 'pospesek', false});      
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