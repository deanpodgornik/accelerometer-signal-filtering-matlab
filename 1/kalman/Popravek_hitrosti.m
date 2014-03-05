function [nova_vrednost, firstRun] = Popravek_hitrosti( pospesek, data, i, firstRun )
    persistent ponavljajoca_vrednost;
    persistent st_ponavljanja;
    persistent popravek;
    persistent iteracija_gibanja;
    persistent predznak;
    pragPonavljanja = 40;
    
    if firstRun == 1
        ponavljajoca_vrednost = 0;
        iteracija_gibanja = 0;
        st_ponavljanja = 0;
        popravek = 0;
        predznak = 1;
        
        firstRun = 0;
    end
    %vrednost na zaèetku postavim tako, da upoštevam predhodne popravke (zaradi napaène konstantne vrednosti)
    %(ob prvi iteraciji je popravek 0, torej niè ne vpliva na zaèetku)
    vhodni_podatek = data(i) + ((-1) * popravek);
    
    %brez filtriranja (privzeti rezultat)
    nova_vrednost = vhodni_podatek;
    
    %debug
    %{
    if i>=1235
        i 
        vhodni_podatek
        data(i)
        x=1;
    end
    %}
    
    %preverim ali je na voljo nova ponavljajoèa vrednost    
    if abs(vhodni_podatek - ponavljajoca_vrednost) < 0.0001
        %najdena ponavljajoèa vrednost (imamo konstantno hitrost - torej naprava miruje)
        
        st_ponavljanja = st_ponavljanja + 1;
        
        if st_ponavljanja > pragPonavljanja
            %potreben je popravek zaradi napaène konstantne hitrost
            %(popravimo na 0)
            popravek = data(i);
            
            %s tem povem algoritmu za odstranjevanje "aftereffekta", da se
            %naprave sedaj ne giba
            iteracija_gibanja = 0;
            
            %ob ugotovitvi ponavljanja, moram postaviti rezultat na 0, ker
            %se aplikacija popravka nahaja na zaèetku algoritma
            if st_ponavljanja == pragPonavljanja+1
                nova_vrednost = 0;
            end
        else
            %ni potreben popravek konstantne hitrosti
            [nova_vrednost, iteracija_gibanja, predznak] = Popravek_hitrosti_aftereffect(pospesek, i, iteracija_gibanja, predznak, vhodni_podatek);
        end
    else
        %vrednost se ne ponavlja (naprava je v gibanju)
        
        st_ponavljanja = 0;
        %nastavim novo vrednost, ki se mora ponavljati
        ponavljajoca_vrednost = vhodni_podatek;
        
        iteracija_gibanja = iteracija_gibanja + 1;
        [nova_vrednost, iteracija_gibanja, predznak] = Popravek_hitrosti_aftereffect(pospesek, i, iteracija_gibanja, predznak, vhodni_podatek);
    end
end

