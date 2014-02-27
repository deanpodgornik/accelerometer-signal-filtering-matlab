function nova_vrednost = Popravek_pospeska( data, i, prag_pospesek )
    prag_zadnji_meritev = 0.5;

    %absolutna vrednost
    absVal = 0;
    st = 0;
    for x=0:30
        if i-x>0
            absVal = absVal + data(i-x);
            st = st + 1;
        end
    end
    absVal = absVal / st;
    
    if abs(absVal)<prag_zadnji_meritev
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

