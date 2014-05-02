function [nova_vrednost, firstRun, iteracija_gibanja, zadetekMejeSlike] = Popravek_hitrosti( pospesek, data, data_raw, i, firstRun, iteracija_gibanja, zadetekMejeSlike)
    persistent ponavljajoca_vrednost;
    persistent st_ponavljanja;
    persistent predznak;
    global popravek_hitrosti_num;
    pragPonavljanja = 40;
    pragPonavljanja_priNicli = 25;
    
    if firstRun == 1
        ponavljajoca_vrednost = 0;
        st_ponavljanja = 0;
        popravek_hitrosti_num = 0;
        predznak = 1;
        
        firstRun = 0;
    end
    %vrednost na za�etku postavim tako, da upo�tevam predhodne popravke (zaradi napa�ne konstantne vrednosti)
    %(ob prvi iteraciji je popravek_hitrosti_num 0, torej ni� ne vpliva na za�etku)
    vhodni_podatek = data(i) + ((-1) * popravek_hitrosti_num);
    
    %rezultat v primeru da ne pride do filtriranja
    nova_vrednost = vhodni_podatek;
    
    %preverim ali je na voljo nova ponavljajo�a vrednost    
    %if abs(vhodni_podatek - ponavljajoca_vrednost) < 0.0001
    %povi�al sem mejo obravnavanja enakosti, saj na ta� na�in dobim enakost med vrednostimi, ki se malo razlikujejo
        %preverjanje (za ALI) dodano zaradi te�ave z detekcijo ponavljajo�e vrednosti ob prehodu v obmo�je nizkih frekvenc
    if ((abs(vhodni_podatek - ponavljajoca_vrednost) < 0.0005) || (vhodni_podatek==0 && data_raw(i)<0.04 && abs(data_raw(i) - ponavljajoca_vrednost) < 0.0005))
        %najdena ponavljajo�a vrednost (imamo konstantno hitrost - torej naprava miruje)
        
        %s tem omogo�im vi�ji prag iskanja enakosti
        ponavljajoca_vrednost = vhodni_podatek;
        
        st_ponavljanja = st_ponavljanja + 1;
        
        if(i>=625)
           i
           i
        end
        
        %preverim prag popnavljanja. Prog ponavljanja v primeru, da so
        %vrednosti okoli 0, je ni�ji
        if((st_ponavljanja > pragPonavljanja) || (st_ponavljanja > pragPonavljanja_priNicli && abs(ponavljajoca_vrednost)<0.002))
            %potreben je popravek zaradi napa�ne konstantne hitrost
            %(popravimo na 0)
            popravek_hitrosti_num = data(i);
            
            %s tem povem algoritmu za odstranjevanje "aftereffekta", da se
            %naprave sedaj ne giba
            iteracija_gibanja = 0;
            %posledi�no tudi velja da nimamo ve� efekta zadetka v mejo
            %sistema
            zadetekMejeSlike = 0;
            
            %ob ugotovitvi ponavljanja, moram postaviti rezultat na 0, ker
            %se aplikacija popravka nahaja na za�etku algoritma
            if st_ponavljanja == pragPonavljanja+1
                nova_vrednost = 0;
                ponavljajoca_vrednost = 0;
            end
        else
            %ni potreben popravek konstantne hitrosti
            
            iteracija_gibanja = iteracija_gibanja + 1;
            
            [nova_vrednost, iteracija_gibanja, predznak, zadetekMejeSlike] = Popravek_hitrosti_aftereffect(pospesek, i, iteracija_gibanja, predznak, vhodni_podatek, data_raw(i), zadetekMejeSlike);
        end
    else
        %vrednost se ne ponavlja (naprava je v gibanju)
        i
        
        st_ponavljanja = 0;
        %nastavim novo vrednost, ki se mora ponavljati
        ponavljajoca_vrednost = vhodni_podatek;
        
        iteracija_gibanja = iteracija_gibanja + 1;
        [nova_vrednost, iteracija_gibanja, predznak, zadetekMejeSlike] = Popravek_hitrosti_aftereffect(pospesek, i, iteracija_gibanja, predznak, vhodni_podatek, data_raw(i), zadetekMejeSlike);
    end
end

