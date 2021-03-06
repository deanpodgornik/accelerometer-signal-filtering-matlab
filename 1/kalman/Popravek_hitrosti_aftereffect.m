function [nova_vrednost, iteracija_gibanja, predznak, zadetekMejeSlike] = Popravek_hitrosti_aftereffect( pospesek, i, iteracija_gibanja, predznak, vhodni_podatek, vhodni_podatek_raw, zadetekMejeSlike)
    persistent potencialnaNapakaPoZadetkuMeje_cum_sum;
    persistent potencialnaNapakaPoZadetkuMeje_st;
    persistent potencialnaNapakaPoZadetkuMeje_queue;
    
    persistent sumPoSpremembiSmeri;
    
    persistent hitraSpremembaSmeri_st;
    persistent hitraSpremembaSmeri_sum_before;
    persistent hitraSpremembaSmeri_sum_after;
    persistent hitraSpremembaSmeri_sum_error;
    persistent hitraSpremembaSmeri_queue_after;
    persistent hitraSpremembaSmeri_queue_before;
    persistent hitraSpremembaSmeri_queue_error;
    persistent hitraSpremembaSmeri_avg_before;
    persistent hitraSpremembaSmeri_avg_after;
    persistent hitraSpremembaSmeri_avg_error;
    persistent hitraSpremembaSmeri_var_before;
    persistent hitraSpremembaSmeri_var_after;
    persistent hitraSpremembaSmeri_var_error;
    
    global popravek_hitrosti_num;
    
    pragNapake = 250;
    prag_potencialnaNapakaPoZadetkuMeje_cum_sum = 7;
    prag_potencialnaNapakaPoZadetkuMeje_st = 80;
    potencialnaNapakaPoZadetkuMeje_var_n = 10;
    faktorSkaliranjaPopravkaNapake = 0.65;
    prag_sumPoSpremembiSmeri = 0.8;
    
    mod1_spodnji_prag = 0.03;
    mod1_zgornji_prag = 0.08;
    mod1_prag_upostevanjaPasu_before = 10;
    mod1_prag_upostevanjaPasu_after = 10;
    mod1_prag_preverjanja = 20;
    mod1_prag_upostevanjaPasu_error = 20;
    mod1_prag_variance_before = 0.00001; 
    mod1_prag_variance_after  = 0.0001;
    mod1_prag_variance_error  = 0.00001;
    
    if iteracija_gibanja == 1
        %nastavim predznak (dolo�im ali je trenuten premik v pozitivni
        %ali negativni smeri
        if vhodni_podatek<0
            predznak = -1;
        else
            predznak = 1;
        end;
        
        sumPoSpremembiSmeri = 0;
        
        potencialnaNapakaPoZadetkuMeje_cum_sum = 0;
        potencialnaNapakaPoZadetkuMeje_st = 0;
        potencialnaNapakaPoZadetkuMeje_queue = zeros(potencialnaNapakaPoZadetkuMeje_st,1);
        
        hitraSpremembaSmeri_st = 0;
        hitraSpremembaSmeri_sum_before = 0;
        hitraSpremembaSmeri_sum_after = 0;
        hitraSpremembaSmeri_sum_error = 0;
        hitraSpremembaSmeri_queue_before = zeros(mod1_prag_upostevanjaPasu_after,1);
        hitraSpremembaSmeri_queue_after = zeros(mod1_prag_preverjanja,1);
        hitraSpremembaSmeri_queue_error = zeros(mod1_prag_preverjanja,1);
        hitraSpremembaSmeri_avg_before = 0;
        hitraSpremembaSmeri_avg_after = 0;
        hitraSpremembaSmeri_avg_error = 0;
        hitraSpremembaSmeri_var_before = 0;    
        hitraSpremembaSmeri_var_after = 0;    
        hitraSpremembaSmeri_var_error = 0;    

        %podatek vrenem nespremenjen
        nova_vrednost = vhodni_podatek;
    else
        if(i>=913)
            i 
            i
        end
                
        %Meritev ni ve� prva zaznana smer gibanja.
        %Preverim ali je pri�lo do spremembe smeri (prvo spremembo
        %smeri zatrem) ali �e smo zadeli mejo slike
        if vhodni_podatek*predznak > 0 && zadetekMejeSlike==0
            %ni spremembe smeri (zadeve ne filtriram)
            nova_vrednost = vhodni_podatek;
            
            %vsota, ki se bele�i od spremembe smeri dalje
            sumPoSpremembiSmeri = sumPoSpremembiSmeri + abs(nova_vrednost);
        else
            %najprej preverim ali je sprememba smeri upravi�ena 
            %(vsota pred spremembo smeri mora biti dovolj velika, ker sicer gre za napako filtriranja nizkih frekvenc)
            
            if( 0 < sumPoSpremembiSmeri && sumPoSpremembiSmeri < prag_sumPoSpremembiSmeri )
                %spremembo smeri obravnavam kot napako filtriranja nizkih
                %frekvenc
                sumPoSpremembiSmeri = 0;
                
                %novo smer dolo�im
                predznak = predznak * (-1);
                
                nova_vrednost = vhodni_podatek;
            else
                %sprememba smeri je upravi�ena
            
                %pri�lo je do spremembe smeri hitrosti
                potencialnaNapakaPoZadetkuMeje_st = potencialnaNapakaPoZadetkuMeje_st + 1;

                %inicializiram vsoto, ki se bele�i od spremembe smeri dalje
                sumPoSpremembiSmeri = 0;

                %obvladovanja spremembe smeri ob zadetku v mejo
                if(zadetekMejeSlike==1)
                    %zaznana posledica zadetka meje

                    nova_vrednost = 0;
                    potencialnaNapakaPoZadetkuMeje_cum_sum = potencialnaNapakaPoZadetkuMeje_cum_sum + abs(vhodni_podatek);

                    %preverim �e smo prekora�ili mejo, ki nam pove ali je pri�lo do spremembe smeri takoj po trku ob mejo
                    %da se izognem pojavitvi "napake" po dalj�em �asu, preverim tudi, da je ta napaka detektirana do iteracije, ki je definirana s pragom prag_potencialnaNapakaPoZadetkuMeje_st
                    if(potencialnaNapakaPoZadetkuMeje_st < prag_potencialnaNapakaPoZadetkuMeje_st)
                        if(potencialnaNapakaPoZadetkuMeje_cum_sum > prag_potencialnaNapakaPoZadetkuMeje_cum_sum)
                            %izra�unam varianco zadnjih 10-ih meritev

                            potencialnaNapakaPoZadetkuMeje_sum = 0;
                            for potencialnaNapakaPoZadetkuMeje_sum_st = 1 : potencialnaNapakaPoZadetkuMeje_var_n
                                potencialnaNapakaPoZadetkuMeje_sum = potencialnaNapakaPoZadetkuMeje_sum + potencialnaNapakaPoZadetkuMeje_queue(potencialnaNapakaPoZadetkuMeje_st - potencialnaNapakaPoZadetkuMeje_sum_st);
                            end
                            potencialnaNapakaPoZadetkuMeje_avg = potencialnaNapakaPoZadetkuMeje_sum / potencialnaNapakaPoZadetkuMeje_var_n;

                            potencialnaNapakaPoZadetkuMeje_var = 0;
                            for potencialnaNapakaPoZadetkuMeje_sum_st = 1 : potencialnaNapakaPoZadetkuMeje_var_n
                                tmp_var_st = potencialnaNapakaPoZadetkuMeje_st - potencialnaNapakaPoZadetkuMeje_sum_st;
                                tmp_var_st
                                potencialnaNapakaPoZadetkuMeje_var = potencialnaNapakaPoZadetkuMeje_var + power((potencialnaNapakaPoZadetkuMeje_queue(tmp_var_st)-potencialnaNapakaPoZadetkuMeje_avg),2);
                            end
                            potencialnaNapakaPoZadetkuMeje_var = potencialnaNapakaPoZadetkuMeje_var / (potencialnaNapakaPoZadetkuMeje_var_n);
                            potencialnaNapakaPoZadetkuMeje_var
                            potencialnaNapakaPoZadetkuMeje_avg
                            i

                            if(potencialnaNapakaPoZadetkuMeje_var < 0.00001 || abs(potencialnaNapakaPoZadetkuMeje_avg)<0.15)
                                %gre le za ve�jo napako po ustavljanju

                                %dolo�im nov popravek
                                popravek_hitrosti_num = vhodni_podatek_raw;

                                nova_vrednost = 0;
                            else
                                %napa�no sem ocenil, ni �lo le za �um ampak za
                                %spremembo smeri. Napako igroniram (predpostavim da je
                                %zanemarljiva)
                                nova_vrednost = vhodni_podatek;
                            end

                            %INICIALIZIRAM ZADEVO

                            %inicializiram zadevo: bele�im kot da je prva iteracija gibanja
                            iteracija_gibanja = 0;

                            %odtranim informacijo, da je v stanju obravnavanja
                            %zadetka meje
                            zadetekMejeSlike = 0;
                        else
                            %dodam meritve v seznam prej�njih meritev
                            potencialnaNapakaPoZadetkuMeje_queue(potencialnaNapakaPoZadetkuMeje_st) = vhodni_podatek_raw;
                        end
                    else
                        %nisem detektiral napak znotraj dolo�enega intervala za
                        %preverjanje napak

                        %inicializiram zadevo: bele�im kot da je prva iteracija gibanja
                        iteracija_gibanja = 0;
                    end
                else
                    %ni zaznanega trka ob mejo

                    %sprememba smeri le posledica �uma in NE dejanske spremembe smeri gibanja naprave
                    nova_vrednost = 0;
                    
                    %MODUL 1
                    %Preverjanje hitre spremembe smeri
                    %najprej preverim ali smo v obratni hitrosti, kot je bila
                    %za�etna smer, ter nato �e �e smo znotraj pasa obravnave.
                    %OPOMBA: �e je pri�lo do spremembe smeri moram preveriti na vhodnem podatku s popravkom (vhodni_podatek)
                    %%{
                    if((predznak*vhodni_podatek_raw)<0)
                        hitraSpremembaSmeri_st = hitraSpremembaSmeri_st + 1;

                        %prvih n meritev ne upo�tevam
                        if(hitraSpremembaSmeri_st > mod1_prag_upostevanjaPasu_before)
                            if(hitraSpremembaSmeri_st <= mod1_prag_upostevanjaPasu_before + mod1_prag_upostevanjaPasu_after)
                                %prvi sklop meritev

                                %izra�unam vsoto da bom lahko nato izra�unal
                                %varianco
                                i
                                vhodni_podatek_raw
                                hitraSpremembaSmeri_sum_before = hitraSpremembaSmeri_sum_before + vhodni_podatek_raw;

                                %shrnaim meritve
                                hitraSpremembaSmeri_queue_before(hitraSpremembaSmeri_st-mod1_prag_upostevanjaPasu_before) = vhodni_podatek_raw;
                            else
                                mod1_st = hitraSpremembaSmeri_st - mod1_prag_upostevanjaPasu_before - mod1_prag_upostevanjaPasu_after;

                                if(mod1_st <= mod1_prag_preverjanja)
                                    %drugi sklop meritev

                                    %ra�unam vsoto, da bom potem lahko izra�unal
                                    %povpre�je ter posledi�no varianco
                                    hitraSpremembaSmeri_sum_after = hitraSpremembaSmeri_sum_after + vhodni_podatek_raw;

                                    %shranim meritve
                                    hitraSpremembaSmeri_queue_after(mod1_st) = vhodni_podatek_raw;

                                    %pogledam, �e je zadostno �tevilo iteracij, da preverim
                                    %spremembo smeri
                                    if(mod1_st >= mod1_prag_preverjanja)
                                        %izra�unam varianco prvega dela
                                        hitraSpremembaSmeri_avg_before = hitraSpremembaSmeri_sum_before / mod1_prag_upostevanjaPasu_after;
                                        for mod1_var_st=1:mod1_prag_upostevanjaPasu_after
                                            hitraSpremembaSmeri_queue_before(mod1_var_st)
                                            hitraSpremembaSmeri_var_before = hitraSpremembaSmeri_var_before + power((hitraSpremembaSmeri_queue_before(mod1_var_st)-hitraSpremembaSmeri_avg_before),2);
                                        end
                                        hitraSpremembaSmeri_var_before = hitraSpremembaSmeri_var_before / (mod1_prag_upostevanjaPasu_after);

                                        %izra�unam varianco drugega dela
                                        hitraSpremembaSmeri_avg_after = hitraSpremembaSmeri_sum_after / mod1_st;
                                        for mod1_var_st=1:mod1_st
                                            hitraSpremembaSmeri_var_after = hitraSpremembaSmeri_var_after + power((hitraSpremembaSmeri_queue_after(mod1_var_st)-hitraSpremembaSmeri_avg_after),2);
                                        end
                                        hitraSpremembaSmeri_var_after = hitraSpremembaSmeri_var_after / (mod1_st);

                                        %preverim ali je pri�lo do spremembe smeri ali ne
                                        %(ali gre le za �um)

                                        i
                                        hitraSpremembaSmeri_var_before
                                        hitraSpremembaSmeri_var_after

                                        if(hitraSpremembaSmeri_var_before < mod1_prag_variance_before && hitraSpremembaSmeri_var_after > mod1_prag_variance_after)
                                            %pri�lo je do hitre spremembe smeri. omogo�im
                                            %upo�tevanje nove smeri (to naredim tako da
                                            %obrnem za�etno zaznano smer (torej predznak))
                                            predznak = predznak * (-1);
                                            popravek_hitrosti_num = 0;

                                            %zadevo ponastavim, da tako za�nem novo iteracijo
                                            %preverjanje v tem, modulu
                                            hitraSpremembaSmeri_st = 0;
                                            hitraSpremembaSmeri_sum_after = 0;
                                            hitraSpremembaSmeri_sum_before = 0;
                                            hitraSpremembaSmeri_sum_error = 0;
                                            hitraSpremembaSmeri_queue_before = zeros(mod1_prag_upostevanjaPasu_after,1);
                                            hitraSpremembaSmeri_queue_after = zeros(mod1_prag_preverjanja,1);
                                            hitraSpremembaSmeri_queue_error = zeros(mod1_prag_preverjanja,1);
                                            hitraSpremembaSmeri_avg_before = 0;
                                            hitraSpremembaSmeri_avg_after = 0;
                                            hitraSpremembaSmeri_avg_error = 0;
                                            hitraSpremembaSmeri_var_before = 0; 
                                            hitraSpremembaSmeri_var_after = 0; 
                                            hitraSpremembaSmeri_var_error = 0; 
                                        else
                                            %nisem detektiral hitre spremembe
                                            %smeri. Preveri� �ez n itercij ali
                                            %sem se zmotil

                                        end                                
                                    end
                                else
                                    %tretji sklop meritev

                                    %ra�unam vsoto, da bom potem lahko izra�unal
                                    %povpre�je ter posledi�no varianco
                                    mod1_st = hitraSpremembaSmeri_st - mod1_prag_upostevanjaPasu_before - mod1_prag_upostevanjaPasu_after - mod1_prag_preverjanja;

                                    if(mod1_st <= mod1_prag_upostevanjaPasu_error)
                                        hitraSpremembaSmeri_sum_error = hitraSpremembaSmeri_sum_error + vhodni_podatek_raw;

                                        %shranim meritve
                                        hitraSpremembaSmeri_queue_error(mod1_st) = vhodni_podatek_raw;
                                    else
                                        %{
                                        mod1_st = mod1_st - 1;

                                        %izra�unam varianco
                                        hitraSpremembaSmeri_avg_error = hitraSpremembaSmeri_sum_error / mod1_st;
                                        for mod1_var_st=1:(mod1_st)
                                            hitraSpremembaSmeri_var_error = hitraSpremembaSmeri_var_error + power((hitraSpremembaSmeri_queue_error(mod1_var_st)-hitraSpremembaSmeri_avg_error),2);
                                        end
                                        hitraSpremembaSmeri_var_error = hitraSpremembaSmeri_var_error / (mod1_st);

                                        %preverim ali je pri�lo do napake
                                        %ocenitve ali ne
                                        if(hitraSpremembaSmeri_var_error > mod1_prag_variance_error)
                                            %pri�lo je do hitre spremembe smeri. omogo�im
                                            %upo�tevanje nove smeri (to naredim tako da
                                            %obrnem za�etno zaznano smer (torej predznak))
                                            predznak = predznak * (-1);
                                            popravek_hitrosti_num = 0;
                                        end

                                        %zadevo ponastavim, da tako za�nem novo iteracijo
                                        %preverjanje v tem, modulu
                                        hitraSpremembaSmeri_st = 0;
                                        hitraSpremembaSmeri_sum_after = 0;
                                        hitraSpremembaSmeri_sum_before = 0;
                                        hitraSpremembaSmeri_sum_error = 0;
                                        hitraSpremembaSmeri_queue_before = zeros(mod1_prag_upostevanjaPasu_after,1);
                                        hitraSpremembaSmeri_queue_after = zeros(mod1_prag_preverjanja,1);
                                        hitraSpremembaSmeri_queue_error = zeros(mod1_prag_preverjanja,1);
                                        hitraSpremembaSmeri_avg_before = 0;
                                        hitraSpremembaSmeri_avg_after = 0;
                                        hitraSpremembaSmeri_avg_error = 0;
                                        hitraSpremembaSmeri_var_before = 0; 
                                        hitraSpremembaSmeri_var_after = 0; 
                                        hitraSpremembaSmeri_var_error = 0; 
                                        %}
                                    end
                                end
                            end
                        end
                    else
                        %vrednost je izven pasu (ta modul mi ne bo pomagal)
                        hitraSpremembaSmeri_st = 0;
                        hitraSpremembaSmeri_sum_after = 0;
                        hitraSpremembaSmeri_sum_before = 0;
                        hitraSpremembaSmeri_sum_error = 0;
                        hitraSpremembaSmeri_queue_before = zeros(mod1_prag_upostevanjaPasu_after,1);
                        hitraSpremembaSmeri_queue_after = zeros(mod1_prag_preverjanja,1);
                        hitraSpremembaSmeri_queue_error = zeros(mod1_prag_preverjanja,1);
                        hitraSpremembaSmeri_avg_before = 0;
                        hitraSpremembaSmeri_avg_after = 0;
                        hitraSpremembaSmeri_avg_error = 0;
                        hitraSpremembaSmeri_var_before = 0;
                        hitraSpremembaSmeri_var_after = 0;
                        hitraSpremembaSmeri_var_error = 0;
                    end
                    %}
                end
            end
        end
    end
end

