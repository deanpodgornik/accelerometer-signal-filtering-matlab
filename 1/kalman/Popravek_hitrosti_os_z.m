function [hitrost, firstRun_os_z] = Popravek_hitrosti_os_z( firstRun_os_z, i, hitrost, iteracija_gibanja, predznak, zadetekMejeSlike )
    global popravek_hitrosti_num;
    
    persistent max;
    
    if(firstRun_os_z == 1)
        firstRun_os_z = 0;
    end
    
    hitrost_raw = hitrost + popravek_hitrosti_num;

    %filtriranje nizkih frekvenc hitrosti
    if(abs(hitrost)<0.15)
        hitrost = 0;
    end
    
    %skaliranje rezultata hitrosti z-osi
    if(hitrost>0)
        hitrost = hitrost * 1;
    else
        hitrost = hitrost * 1;
    end
end
