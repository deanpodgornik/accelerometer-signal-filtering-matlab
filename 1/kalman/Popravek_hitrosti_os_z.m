function [hitrost, ponavljajoca_vrednost, firstRun_os_z] = Popravek_hitrosti_os_z( firstRun_os_z, i, hitrost, ponavljajoca_vrednost, iteracija_gibanja, predznak, zadetekMejeSlike )
    global popravek_hitrosti_num;
    
    persistent max;
    
    pragObmocjaNapakeUstavljanja = 0.4;
    
    if(firstRun_os_z == 1)
        firstRun_os_z = 0;
    end
    
    
    hitrost_raw = hitrost + popravek_hitrosti_num;
    
    if(firstRun_os_z == 1 || iteracija_gibanja == 1 || zadetekMejeSlike == 1)
        max = hitrost_raw;
    end
    
    %pridobitev max
    if(hitrost_raw > max)
        max = hitrost_raw;
    end
    
    %skaliranje rezultat hitrosti z-osi
    if(hitrost>0)
        hitrost = hitrost * 0.35;
    else
        hitrost = hitrost * 1.1;
    end
    
    if(i > 960)
        i
    end
    
    %preverim ali meritev spada v omboèje popravljanja napake ustavljanja
    %if(hitrost > 0 && ((hitrost_raw - popravek_hitrosti_num) < ((max - popravek_hitrosti_num) * pragObmocjaNapakeUstavljanja)))
    if(hitrost > 0 && ((hitrost_raw - popravek_hitrosti_num) < ((max-popravek_hitrosti_num) * pragObmocjaNapakeUstavljanja)))
        i
        popravek_hitrosti_num = hitrost_raw;
        %hitrost = 0;
    end    
end

