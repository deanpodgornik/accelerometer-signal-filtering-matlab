%preberem csv datoteko

dataTmp = csvread('../../data/demo_n7_t5.csv');
dataTmp = dataTmp(:,1); %X

data = dataTmp(401:1050);
filteredData = data;
filteredData2 = data;

varianca_a = 1.7346;

delta_t = 1 / 200;
data_length = length(data);
x = delta_t:delta_t:((data_length*delta_t));

prag_pospesek = 0.4;
firstRun_filtriranjePospeska = 1;

%iterator (real-time simulator)
for i=1:data_length
    
    %filtering linear acceleration
    if(i-1>0)
        filteredData(i) = Filtering(data, i, 'kalman', {varianca_a, 'pospesek', false});      
    else
        filteredData(i) = 0;
    end
    
    %filtriranje nizkih vrednosti
    [filteredData2(i) firstRun_filtriranjePospeska] = Popravek_pospeska(filteredData, i, prag_pospesek, firstRun_filtriranjePospeska );
end

plot(x, filteredData, 'color', 'blue');
hold on;
plot(x, filteredData2, 'color', 'red');
legend('Signal pospeška brez apliciranega filtriranja nizkih vrednosti','Signal pospeška z apliciranim filtriranjem nizkih vrednosti');
xlabel('Èas (s)');
ylabel('Pospešek (m/s^2)');
xlim([0,3]);
ylim([-1.5,1.5]);
hold off;

