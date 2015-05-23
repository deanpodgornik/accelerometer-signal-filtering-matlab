function [ rezultat ] = mozno_preverjanje_ponavljanja( i, max_hitrosti_pri_enem_premiku, ponavljajoca_vrednost, st_ponavljanja, pragPonavljanja, pragPonavljanja_priNicli, predznak )
%MOZNO_PREVERJANJE_PONAVLJANJA Summary of this function goes here

    if(i >= 800)
        test = 2;
    end

    rezultat = false;
    
    if(ponavljajoca_vrednost * predznak > 0)
        %ni pri�lo do spremembe smeri 
        if ( ( abs(max_hitrosti_pri_enem_premiku) < 0.2 ) || ( abs(ponavljajoca_vrednost) < abs(max_hitrosti_pri_enem_premiku) * 0.6 ) )
            % tukaj lahko preverjam ali gre za ponavljajo�o vrednost ali ne
            % (NATAN�NEJE, meritev ni v obmo�ju maksimalne zaznane hitrosti trenutne iteracije gibanja)
            if( (st_ponavljanja > pragPonavljanja) || (st_ponavljanja > pragPonavljanja_priNicli && abs(ponavljajoca_vrednost)<0.002) )
                rezultat = true;
            end;
        end;
    else
        %pri�lo je do spremembe smeri - smo v procesu zatiranja
        if( (st_ponavljanja > pragPonavljanja) || (st_ponavljanja > pragPonavljanja_priNicli && abs(ponavljajoca_vrednost)<0.002) )
            rezultat = true;
        end;
    end;    
    
end

