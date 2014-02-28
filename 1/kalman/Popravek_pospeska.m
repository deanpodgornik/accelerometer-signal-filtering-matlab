function nova_vrednost = Popravek_pospeska( data, i, prag_pospesek )
    prag_zadnji_meritev = 0.5;

    %povpreèje
    mean = 0;
    st = 0;
    var_N = 20;
    for x=0:var_N
        if i-x>0
            mean = mean + data(i-x);
            st = st + 1;
        end
    end
    mean = mean / st;
    
    if(i>=500)
        i
    end
    
    %varianca
    varianca = 0;
    for x=0:st-1
        varianca = varianca + (data(i-x) - mean)^2;
    end
    varianca = varianca / st
    
    if varianca < 0.05
        %ni veèjih razlik v zadnjim meritvah
        if(abs(data(i))<prag_pospesek)
            nova_vrednost = 0;
        else
            nova_vrednost = data(i);
        end
    else
        %v zadnjih meritvah je veliko meritev, torej smo v stanju hitrega
        %gibanja. Posledièno zadeve ne postavimo na 0 (ne filtriramo nizkih
        %frekvenc) v primeru majhnih vrednosti
        nova_vrednost = data(i);
    end
end

