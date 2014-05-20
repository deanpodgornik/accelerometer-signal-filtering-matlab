function [ponavljajoca_vrednost, firstRun_os_z] = Popravek_hitrosti_os_z( firstRun_os_z, i, hitrost, ponavljajoca_vrednost, iteracija_gibanja, predznak, zadetekMejeSlike )
    global popravek_hitrosti_num;
    
    persistent max;
    
    pragObmocjaNapakeUstavljanja = 0.3;
    
    if(firstRun_os_z == 1)
        firstRun_os_z = 0;
    end
    
    if(firstRun_os_z == 1 || iteracija_gibanja == 1 || zadetekMejeSlike == 1)
        max = hitrost;
        pragPonavljanja = 40; %postavim na privzeto vrednost
    end
    
    %pridobitev max
    if(hitrost > max)
        max = hitrost;
    end
    
    %preverim ali meritev spada v omboèje popravna napake ustavljanja
    if(hitrost > 0 && (hitrost < (max * pragObmocjaNapakeUstavljanja)))
        popravek_hitrosti_num = hitrost;
    end    
end

