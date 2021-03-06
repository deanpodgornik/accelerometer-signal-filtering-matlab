function [nova_vrednost, firstRun, iteracija_gibanja, zadetekMejeSlike] = Popravek_hitrosti( pospesek, data, data_raw, i, firstRun, iteracija_gibanja, zadetekMejeSlike)
    persistent ponavljajoca_vrednost;
    persistent st_ponavljanja;
    persistent predznak;
    persistent firstRun_os_z;
    global popravek_hitrosti_num;
    global os_z;
    persistent pragPonavljanja;
    persistent max_hitrosti_pri_enem_premiku;
    
    pragPonavljanja = 20;
    
    pragPonavljanja_priNicli = 40;
    
    if firstRun == 1
        ponavljajoca_vrednost = 0;
        st_ponavljanja = 0;
        popravek_hitrosti_num = 0;
        predznak = 1;
        max_hitrosti_pri_enem_premiku = 0;
        
        firstRun_os_z = 1;
        
        firstRun = 0;
    end
    
    %vrednost na za�etku postavim tako, da upo�tevam predhodne popravke (zaradi napa�ne konstantne vrednosti)
    %(ob prvi iteraciji je popravek_hitrosti_num 0, torej ni� ne vpliva na za�etku)
    vhodni_podatek = data(i) + ((-1) * popravek_hitrosti_num);
    
    %rezultat v primeru da ne pride do filtriranja
    nova_vrednost = vhodni_podatek;
    
    if (iteracija_gibanja == 1)
        max_hitrosti_pri_enem_premiku = 0;
    end;
    
    if(i == 750)
        test = 1;
    end;
    
    %preverim ali je na voljo nova ponavljajo�a vrednost    
    %if abs(vhodni_podatek - ponavljajoca_vrednost) < 0.0001
    %povi�al sem mejo obravnavanja enakosti, saj na ta� na�in dobim enakost med vrednostimi, ki se malo razlikujejo
        %preverjanje (za ALI) dodano zaradi te�ave z detekcijo ponavljajo�e vrednosti ob prehodu v obmo�je nizkih vrednosti
    if ((abs(vhodni_podatek - ponavljajoca_vrednost) < 0.0008) || (vhodni_podatek==0 && data_raw(i)<0.04 && abs(data_raw(i) - ponavljajoca_vrednost) < 0.0005))
        %najdena ponavljajo�a vrednost (imamo konstantno hitrost - torej naprava miruje)
        
        %s tem omogo�im vi�ji prag iskanja enakosti
        ponavljajoca_vrednost = vhodni_podatek;
        
        st_ponavljanja = st_ponavljanja + 1;
        
        %preverim prag popnavljanja. Prag ponavljanja v primeru, da so
        %vrednosti okoli 0, je ni�ji
        %if( (st_ponavljanja > pragPonavljanja) || (st_ponavljanja > pragPonavljanja_priNicli && abs(ponavljajoca_vrednost)<0.002))
        %if( 1 )
        if( mozno_preverjanje_ponavljanja( i, max_hitrosti_pri_enem_premiku, ponavljajoca_vrednost, st_ponavljanja, pragPonavljanja, pragPonavljanja_priNicli, predznak ) )        
            
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
            
            max_hitrosti_pri_enem_premiku = 0;
        else
            %ni potreben popravek konstantne hitrosti
            
            max_hitrosti_pri_enem_premiku = preveri_novo_max_vrednost(max_hitrosti_pri_enem_premiku, nova_vrednost);
            
            iteracija_gibanja = iteracija_gibanja + 1;
            
            [nova_vrednost, iteracija_gibanja, predznak, zadetekMejeSlike] = Popravek_hitrosti_aftereffect(pospesek, i, iteracija_gibanja, predznak, vhodni_podatek, data_raw(i), zadetekMejeSlike);
        end
    else
        %vrednost se ne ponavlja (naprava je v gibanju)
        
        st_ponavljanja = 0;
        %nastavim novo vrednost, ki se mora ponavljati
        ponavljajoca_vrednost = vhodni_podatek;
        
        iteracija_gibanja = iteracija_gibanja + 1;
        
        max_hitrosti_pri_enem_premiku = preveri_novo_max_vrednost(max_hitrosti_pri_enem_premiku, nova_vrednost);
       
        [nova_vrednost, iteracija_gibanja, predznak, zadetekMejeSlike] = Popravek_hitrosti_aftereffect(pospesek, i, iteracija_gibanja, predznak, vhodni_podatek, data_raw(i), zadetekMejeSlike);
    end
    
    if(os_z)
        [nova_vrednost, firstRun_os_z] = Popravek_hitrosti_os_z(firstRun_os_z, i, nova_vrednost, iteracija_gibanja, predznak, zadetekMejeSlike);
    end
end

