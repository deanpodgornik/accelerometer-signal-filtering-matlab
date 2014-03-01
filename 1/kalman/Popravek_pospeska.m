function [nova_vrednost firstRun stNeBlizuNic] = Popravek_pospeska( data, i, prag_pospesek, firstRun, stNeBlizuNic )    
    persistent stIteracijNeupostevanja;
    pragNeBlizuNic = 20;
    stIteracij = 100;

    if firstRun == 1
        stNeBlizuNic = 0;
        stIteracijNeupostevanja = 0;
        firstRun = 0;
    end
    
    %debug
    if(i > 700)
        i
    end
    
    %MORAM NAJPREJ VRŠT NA 0, ÈE USTREZA PRAGU
    if abs(data(i)) < prag_pospesek
        tmp_val = 0;
    else
        tmp_val = data(i);
    end
    
    if tmp_val == 0
        %pospesek je enaka 0
        
        %ce je vrsta stevil razlicnih stevil dovolj velika, potem
        %naslednjih N iteracij ne upostevam filtriranja nizkih frekvenc
        if stNeBlizuNic > pragNeBlizuNic
            stIteracijNeupostevanja = stIteracij;
        end
        
        stNeBlizuNic = 0;
    else
        %pospesek ni blizu 0
        stNeBlizuNic = stNeBlizuNic + 1;
    end
    
    if stIteracijNeupostevanja > 0
        %ne upoštevam filtriranja nizkih frekvenc
        nova_vrednost = data(i);
        
        stIteracijNeupostevanja = stIteracijNeupostevanja - 1;
    else
        %upoštevam filtriranje nizkih frekvenc
        if(abs(data(i))<prag_pospesek)
            nova_vrednost = 0;
        else
            nova_vrednost = data(i);
        end
    end
end

