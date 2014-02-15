function [nova_vrednost, firstRun] = Popravek_filtra_aftereffect( data, i, firstRun )
    persistent ponavljajoca_vrednost;
    persistent st_ponavljanja;
    persistent popravek;
    prag = 10;
    
    if firstRun == 1
        ponavljajoca_vrednost = 0;
        st_ponavljanja = 0;
        popravek = 0;
        
        firstRun = 0;
    end
    
    %preverim ali je na voljo nova ponavljajoèa vrednost
    [data(i) ponavljajoca_vrednost]
    
    if abs(data(i) - ponavljajoca_vrednost) < 0.0001
        %equal
        st_ponavljanja = st_ponavljanja + 1
        if st_ponavljanja > prag
            popravek = data(i);
        end
        %[ponavljajoca_vrednost data(i) st_ponavljanja popravek]
    else
        %not equal
        st_ponavljanja = 0;
        ponavljajoca_vrednost = data(i);
    end
    
    %dodam popravek (na zaèetku je 0)
    nova_vrednost = data(i) + ((-1) * popravek);
    nova_vrednost;
end

