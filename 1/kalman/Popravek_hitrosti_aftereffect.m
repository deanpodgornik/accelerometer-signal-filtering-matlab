function [nova_vrednost, iteracija_gibanja, predznak, zadetekMejeSlike] = Popravek_hitrosti_aftereffect( pospesek, i, iteracija_gibanja, predznak, vhodni_podatek, vhodni_podatek_raw, zadetekMejeSlike )
    persistent potencialnaNapaka_sum;
    persistent potencialnaNapaka_st;
    
    persistent hitraSpremembaSmeri_st;
    persistent hitraSpremembaSmeri_sum_before;
    persistent hitraSpremembaSmeri_sum_after;
    persistent hitraSpremembaSmeri_queue_after;
    persistent hitraSpremembaSmeri_queue_before;
    persistent hitraSpremembaSmeri_avg_before;
    persistent hitraSpremembaSmeri_avg_after;
    persistent hitraSpremembaSmeri_var_before;
    persistent hitraSpremembaSmeri_var_after;
    
    global popravek_hitrosti_num;
    
    pragNapake = 250;
    prag_potencialnaNapaka_sum = 10;
    prag_potencialnaNapaka_st = 80;
    faktorSkaliranjaPopravkaNapake = 0.65;
    
    mod1_spodnji_prag = 0.03;
    mod1_zgornji_prag = 0.08;
    mod1_prag_preverjanja = 20;
    mod1_prag_upostevanjaPasu_before = 10;
    mod1_prag_upostevanjaPasu_after = 10;
    mod1_prag_variance_before = 0.00001; 
    mod1_prag_variance_after  = 0.0001;
    
    if iteracija_gibanja == 1
        %nastavim predznak (doloèim ali je trenuten premik v pozitivni
        %ali negativni smeri
        if vhodni_podatek<0
            predznak = -1;
        else
            predznak = 1;
        end;
        
        potencialnaNapaka_sum = 0;
        potencialnaNapaka_st = 0;
        
        hitraSpremembaSmeri_st = 0;
        hitraSpremembaSmeri_sum_before = 0;
        hitraSpremembaSmeri_sum_after = 0;
        hitraSpremembaSmeri_queue_before = zeros(mod1_prag_upostevanjaPasu_after,1);
        hitraSpremembaSmeri_queue_after = zeros(mod1_prag_preverjanja,1);
        hitraSpremembaSmeri_avg_before = 0;
        hitraSpremembaSmeri_avg_after = 0;
        hitraSpremembaSmeri_var_before = 0;    
        hitraSpremembaSmeri_var_after = 0;    

        %podatek vrenem nespremenjen
        nova_vrednost = vhodni_podatek;
    else
        if(i>1725)
            i 
        end
        if(i>1840)
            i 
        end
        if(i>1815)
            i 
        end
                
        %Meritev ni veè prva zaznana smer gibanja.
        %Preverim ali je prišlo do spremembe smeri (prvo spremembo
        %smeri zatrem) ali èe smo zadeli mejo slike
        if vhodni_podatek*predznak > 0 && zadetekMejeSlike==0
            %ni spremembe smeri (zadeve ne filtriram)
            nova_vrednost = vhodni_podatek;
        else
            %prišlo je do spremembe smeri hitrosti
            potencialnaNapaka_st = potencialnaNapaka_st + 1;
            
            %obvladovanja spremembe smeri ob zadetku v mejo
            if(zadetekMejeSlike==1)
                %zaznana posledica zadetka meje
                
                nova_vrednost = 0;
                potencialnaNapaka_sum = potencialnaNapaka_sum + abs(vhodni_podatek);
                
                %preverim èe smo prekoraèili mejo, ki nam pove ali je prišlo do spremembe smeri takoj po trku ob mejo
	            %da se izognem pojavitvi "napake" po daljšem èasu, preverim tudi, da je ta napaka detektirana do iteracije, ki je definirana s pragom prag_potencialnaNapaka_st
	            if(potencialnaNapaka_sum > prag_potencialnaNapaka_sum && potencialnaNapaka_st < prag_potencialnaNapaka_st)
                    %napaèno sem ocenil, ni šlo le za šum ampak za
                    %spremembo smeri. Napako igroniram (predpostavim da je
                    %zanemarljiva)
                    nova_vrednost = vhodni_podatek;
                    
                    %odtranim informacijo, da je v stanju obravnavanja
                    %zadetka meje
                    zadetekMejeSlike = 0;
                    
                    %inicializiram zadevo: beležim kot da je prva iteracija
                    %gibanja
                    iteracija_gibanja = 0;
                end
            else
                %ni zaznanega trka ob mejo
                %MODUL 1
                %Preverjanje hitre spremembe smeri
                %najprej preverim ali smo v obratni hitrosti, kot je bila
                %zaèetna smer, ter nato še èe smo znotraj pasa obravnave.
                %OPOMBA: èe je prišlo do spremembe smeri moram preveriti na vhodnem podatku s popravkom (vhodni_podatek)
                %%{
                i
                (predznak*vhodni_podatek_raw)<0
                if((predznak*vhodni_podatek_raw)<0)
                    hitraSpremembaSmeri_st = hitraSpremembaSmeri_st + 1;
                    
                    %prvih n meritev ne upoštevam
                    if(hitraSpremembaSmeri_st > mod1_prag_upostevanjaPasu_before)
                        if(hitraSpremembaSmeri_st <= mod1_prag_upostevanjaPasu_before + mod1_prag_upostevanjaPasu_after)
                            %prvi sklop meritev

                            %izraèunam vsoto da bom lahko nato izraèunal
                            %varianco
                            i
                            vhodni_podatek_raw
                            hitraSpremembaSmeri_sum_before = hitraSpremembaSmeri_sum_before + vhodni_podatek_raw;

                            %shrnaim meritve
                            hitraSpremembaSmeri_queue_before(hitraSpremembaSmeri_st-mod1_prag_upostevanjaPasu_before) = vhodni_podatek_raw;
                        else
                            %drugi sklop meritev

                            %raèunam vsoto, da bom potem lahko izraèunal
                            %povpreèje ter posledièno varianco
                            mod1_st = hitraSpremembaSmeri_st - mod1_prag_upostevanjaPasu_before - mod1_prag_upostevanjaPasu_after;
                            hitraSpremembaSmeri_sum_after = hitraSpremembaSmeri_sum_after + vhodni_podatek_raw;

                            %shranim meritve
                            hitraSpremembaSmeri_queue_after(mod1_st) = vhodni_podatek_raw;

                            %pogledam, èe je zadostno število iteracij, da preverim
                            %spremembo smeri
                            if(mod1_st >= mod1_prag_preverjanja)
                                %izraèunam varianco prvega dela
                                hitraSpremembaSmeri_avg_before = hitraSpremembaSmeri_sum_before / mod1_prag_upostevanjaPasu_after;
                                for mod1_var_st=1:mod1_prag_upostevanjaPasu_after
                                    hitraSpremembaSmeri_queue_before(mod1_var_st)
                                    hitraSpremembaSmeri_var_before = hitraSpremembaSmeri_var_before + power((hitraSpremembaSmeri_queue_before(mod1_var_st)-hitraSpremembaSmeri_avg_before),2);
                                end
                                hitraSpremembaSmeri_var_before = hitraSpremembaSmeri_var_before / (mod1_prag_upostevanjaPasu_after);

                                %izraèunam varianco drugega dela
                                hitraSpremembaSmeri_avg_after = hitraSpremembaSmeri_sum_after / mod1_st;
                                for mod1_var_st=1:mod1_st
                                    hitraSpremembaSmeri_var_after = hitraSpremembaSmeri_var_after + power((hitraSpremembaSmeri_queue_after(mod1_var_st)-hitraSpremembaSmeri_avg_after),2);
                                end
                                hitraSpremembaSmeri_var_after = hitraSpremembaSmeri_var_after / (mod1_st);

                                %preverim ali je prišlo do spremembe smeri ali ne
                                %(ali gre le za šum)

                                i
                                hitraSpremembaSmeri_var_before
                                hitraSpremembaSmeri_var_after

                                if(hitraSpremembaSmeri_var_before < mod1_prag_variance_before && hitraSpremembaSmeri_var_after > mod1_prag_variance_after)
                                    %prišlo je do hitre spremembe smeri. omogoèim
                                    %upoštevanje nove smeri (to naredim tako da
                                    %obrnem zaèetno zaznano smer (torej predznak))
                                    predznak = predznak * (-1);
                                    popravek_hitrosti_num = 0;
                                end

                                %zadevo ponastavim, da tako zaènem novo iteracijo
                                %preverjanje v tem, modulu
                                hitraSpremembaSmeri_st = 0;
                                hitraSpremembaSmeri_sum_after = 0;
                                hitraSpremembaSmeri_sum_before = 0;
                                hitraSpremembaSmeri_queue_before = zeros(mod1_prag_upostevanjaPasu_after,1);
                                hitraSpremembaSmeri_queue_after = zeros(mod1_prag_preverjanja,1);
                                hitraSpremembaSmeri_avg_before = 0;
                                hitraSpremembaSmeri_avg_after = 0;
                                hitraSpremembaSmeri_var_before = 0; 
                                hitraSpremembaSmeri_var_after = 0; 
                            end
                        end
                    end
                else
                    %vrednost je izven pasu (ta modul mi ne bo pomagal)
                    hitraSpremembaSmeri_st = 0;
                    hitraSpremembaSmeri_sum_after = 0;
                    hitraSpremembaSmeri_sum_before = 0;
                    hitraSpremembaSmeri_queue_before = zeros(mod1_prag_upostevanjaPasu_after,1);
                    hitraSpremembaSmeri_queue_after = zeros(mod1_prag_preverjanja,1);
                    hitraSpremembaSmeri_avg_before = 0;
                    hitraSpremembaSmeri_avg_after = 0;
                    hitraSpremembaSmeri_var_before = 0;
                    hitraSpremembaSmeri_var_after = 0;
                end
                %}
                
                %MODUL 2
                %preverim ali je prišlo do napake pri ocenitvi, da ne gre za
                %spremembo smeri
                if(potencialnaNapaka_st > pragNapake)
                    %napacno sem ocenil. Prišlo je do hitre spremembe smeri.
                    %Novih vrednosti ne bom veè postavil na 0
                    nova_vrednost = vhodni_podatek;

                    %preverim ali popravek sploh obstaja
                    if abs(potencialnaNapaka_sum) > 0                    
                        nova_vrednost = nova_vrednost + (potencialnaNapaka_sum * faktorSkaliranjaPopravkaNapake);
                        %ponastavitev sum-napaka (inicializacija za kasnejše
                        %potencialne napake)
                        potencialnaNapaka_sum = 0;
                    end
                else
                    %trenutno smo še mnenja, da je sprememba smeri le posledica
                    %šuma in NE dejanske spremembe smeri gibanja naprave
                    nova_vrednost = 0;
                    potencialnaNapaka_sum = potencialnaNapaka_sum + vhodni_podatek; %pravilno da NI abs, saj tako upoštevam visoko varianco (ob prehodu èez 0). Abs pa uporabim pri preverjanju
                end 
            end            
        end
    end
end

