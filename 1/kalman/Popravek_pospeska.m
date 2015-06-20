function [nova_vrednost firstRun] = Popravek_pospeska( data, i, prag_pospesek, firstRun)    
    persistent iteracijaGibanja;
    persistent ponavljajocaVrednost;
    persistent stPonovitev;
    persistent stIteracijNeupostevanja;
    persistent neupostevanjePredznakaPorabljeno;
    
    global os_z;
    
    pragPrevirjanjaSpremembeSmeri = 20;
    pragPonavljanja = 20;
    
    if(os_z)    
        iniStIteracijNeupostevanja = 100;
    else
        iniStIteracijNeupostevanja = 200;
    end
        
    if firstRun == 1
        stIteracijNeupostevanja = 0;
        iteracijaGibanja = 0;
        predznak = 0;
        neupostevanjePredznakaPorabljeno = false;
        ponavljajocaVrednost = 0;
        stPonovitev = 0;
        
        firstRun = 0;
    end
    
    %opravim filtriranje nizkih frekvenc
    filtriranaVrednost = data(i);
    if abs(data(i)) < prag_pospesek
        filtriranaVrednost = 0;
    end
    
    %preverim ali je na voljo nova ponavljajo�a vrednost    
    if abs(filtriranaVrednost - ponavljajocaVrednost) < 0.0001
        %najdena ponavljajo�a vrednost (imamo konstantno hitrost - torej naprava miruje)
        
        stPonovitev = stPonovitev + 1;
        
        if stPonovitev > pragPonavljanja            
            %s tem povem, da se naprave sedaj ne giba
            iteracijaGibanja = 0;
            
            %neupo�tevanja filtranja nizkih frekcenc
            if stIteracijNeupostevanja==0
                neupostevanjePredznakaPorabljeno = false;
            end
        end        
    else
        %vrednost se ne ponavlja (naprava je v gibanju)
        
        stPonovitev = 0;
        %nastavim novo vrednost, ki se mora ponavljati
        ponavljajocaVrednost = filtriranaVrednost;
        
        iteracijaGibanja = iteracijaGibanja + 1;
        
        %SEKCIJA: PREVERJANJE ZA OBMO�JE NEUPO�TEVANJA FILTRIRANJA NIZKIH
        %FREKVENC
        if neupostevanjePredznakaPorabljeno == false
            if iteracijaGibanja > pragPrevirjanjaSpremembeSmeri 
                if abs(filtriranaVrednost) < 0.0001
                    %prihaja do prve spremembe smeri hitrosti
                    %samo prvi prehod prekinem
                    stIteracijNeupostevanja = iniStIteracijNeupostevanja;
                    neupostevanjePredznakaPorabljeno = true;
                end
            end
        end
    end
    
    %SEKCIJA: preverim ali smo v obmo�ju neupo�tevanja nizkih frekvenc
    if stIteracijNeupostevanja>0
        %obmo�je neupo�tevanja filtriranja nizkih frekvenc
        neupostevanjePredznakaPorabljeno;
        stIteracijNeupostevanja = stIteracijNeupostevanja - 1;
        nova_vrednost = data(i);
    else
        %obmo�je upo�tevanja filtriranja nizkih frekvenc
        nova_vrednost = filtriranaVrednost;
    end

end

