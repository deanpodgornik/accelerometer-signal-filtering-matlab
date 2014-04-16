function [nova_vrednost, iteracija_gibanja, predznak, zadetekMejeSlike] = Popravek_hitrosti_aftereffect( pospesek, i, iteracija_gibanja, predznak, vhodni_podatek, vhodni_podatek_raw, zadetekMejeSlike )
    persistent potencialnaNapaka_sum;
    persistent potencialnaNapaka_st;
    
    persistent hitraSpremembaSmeri_st;
    persistent hitraSpremembaSmeri_sum;
    persistent hitraSpremembaSmeri_queue;
    persistent hitraSpremembaSmeri_avg;
    persistent hitraSpremembaSmeri_var;
    
    global popravek_hitrosti_num;
    
    pragNapake = 250;
    prag_potencialnaNapaka_sum = 10;
    prag_potencialnaNapaka_st = 80;
    faktorSkaliranjaPopravkaNapake = 0.65;
    
    mod1_spodnji_prag = 0.03;
    mod1_zgornji_prag = 0.08;
    mod1_prag_preverjanja = 30;
    mod1_prag_upostevanjaPasu = 10;
    mod1_prag_variance = 0.0008;
    
    if iteracija_gibanja == 1
        %nastavim predznak (dolo�im ali je trenuten premik v pozitivni
        %ali negativni smeri
        if vhodni_podatek<0
            predznak = -1;
        else
            predznak = 1;
        end;
        
        potencialnaNapaka_sum = 0;
        potencialnaNapaka_st = 0;
        
        hitraSpremembaSmeri_st = 0;
        hitraSpremembaSmeri_sum = 0;
        hitraSpremembaSmeri_queue = zeros(mod1_prag_preverjanja,1);
        hitraSpremembaSmeri_avg = 0;
        hitraSpremembaSmeri_var = 0;    

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
                
        %Meritev ni ve� prva zaznana smer gibanja.
        %Preverim ali je pri�lo do spremembe smeri (prvo spremembo
        %smeri zatrem) ali �e smo zadeli mejo slike
        if vhodni_podatek*predznak > 0 && zadetekMejeSlike==0
            %ni spremembe smeri (zadeve ne filtriram)
            nova_vrednost = vhodni_podatek;
        else
            %pri�lo je do spremembe smeri hitrosti
            potencialnaNapaka_st = potencialnaNapaka_st + 1;
            
            %obvladovanja spremembe smeri ob zadetku v mejo
            if(zadetekMejeSlike==1)
                %zaznana posledica zadetka meje
                
                nova_vrednost = 0;
                potencialnaNapaka_sum = potencialnaNapaka_sum + abs(vhodni_podatek);
                
                %preverim �e smo prekora�ili mejo, ki nam pove ali je pri�lo do spremembe smeri takoj po trku ob mejo
	            %da se izognem pojavitvi "napake" po dalj�em �asu, preverim tudi, da je ta napaka detektirana do iteracije, ki je definirana s pragom prag_potencialnaNapaka_st
	            if(potencialnaNapaka_sum > prag_potencialnaNapaka_sum && potencialnaNapaka_st < prag_potencialnaNapaka_st)
                    %napa�no sem ocenil, ni �lo le za �um ampak za
                    %spremembo smeri. Napako igroniram (predpostavim da je
                    %zanemarljiva)
                    nova_vrednost = vhodni_podatek;
                    
                    %odtranim informacijo, da je v stanju obravnavanja
                    %zadetka meje
                    zadetekMejeSlike = 0;
                    
                    %inicializiram zadevo: bele�im kot da je prva iteracija
                    %gibanja
                    iteracija_gibanja = 0;
                end
            else
                %ni zaznanega trka ob mejo
                %MODUL 1
                %Preverjanje hitre spremembe smeri
                %najprej preverim ali smo v obratni hitrosti, kot je bila
                %za�etna smer, ter nato �e �e smo znotraj pasa obravnave.
                %OPOMBA: �e je pri�lo do spremembe smeri moram preveriti na vhodnem podatku s popravkom (vhodni_podatek)
                %%{
                i
                (predznak*vhodni_podatek_raw)<0
                if((predznak*vhodni_podatek_raw)<0)
                    hitraSpremembaSmeri_st = hitraSpremembaSmeri_st + 1;
                    
                    %prvih 10 meritev ne upo�tevam
                    if(hitraSpremembaSmeri_st > mod1_prag_upostevanjaPasu)
                        %ra�unam vsoto, da bom potem lahko izra�unal
                        %povpre�je ter posledi�no varianco
                        mod1_st = hitraSpremembaSmeri_st - mod1_prag_upostevanjaPasu;
                        hitraSpremembaSmeri_sum = hitraSpremembaSmeri_sum + vhodni_podatek_raw;
                        
                        %shranim meritve
                        mod1_st
                        hitraSpremembaSmeri_queue(mod1_st) = vhodni_podatek_raw;
                        
                        %pogledam, �e je zadostno �tevilo iteracij, da preverim
                        %spremembo smeri
                        if(mod1_st > mod1_prag_preverjanja)
                            %izra�unam varianco
                            hitraSpremembaSmeri_avg = hitraSpremembaSmeri_sum / mod1_st;
                            
                            for mod1_var_st=1:mod1_st
                                hitraSpremembaSmeri_queue
                                i
                                mod1_var_st
                                hitraSpremembaSmeri_avg
                                mod1_var_st-hitraSpremembaSmeri_avg                                
                                
                                hitraSpremembaSmeri_var = hitraSpremembaSmeri_var + power((hitraSpremembaSmeri_queue(mod1_var_st)-hitraSpremembaSmeri_avg),2);
                            end
                            
                            i
                            hitraSpremembaSmeri_var
                            
                            %preverim ali je pri�lo do spremembe smeri ali ne
                            %(ali gre le za �um)
                            if(hitraSpremembaSmeri_var > mod1_prag_variance)
                                %pri�lo je do hitre spremembe smeri. omogo�im
                                %upo�tevanje nove smeri (to naredim tako da
                                %obrnem za�etno zaznano smer (torej predznak))
                                predznak = predznak * (-1);
                                popravek_hitrosti_num = 0;
                            end

                            %zadevo ponastavim, da tako za�nem novo iteracijo
                            %preverjanje v tem, modulu
                            hitraSpremembaSmeri_st = 0;
                            hitraSpremembaSmeri_sum = 0;
                            hitraSpremembaSmeri_queue = zeros(mod1_prag_preverjanja,1);
                            hitraSpremembaSmeri_avg = 0;
                            hitraSpremembaSmeri_var = 0; 
                        end
                    end
                else
                    %vrednost je izven pasu (ta modul mi ne bo pomagal)
                    hitraSpremembaSmeri_st = 0;
                    hitraSpremembaSmeri_sum = 0;
                    hitraSpremembaSmeri_queue = zeros(mod1_prag_preverjanja,1);
                    hitraSpremembaSmeri_avg = 0;
                    hitraSpremembaSmeri_var = 0;
                end
                %}
                
                %MODUL 2
                %preverim ali je pri�l do napake pri ocenitvi, da ne gre za
                %spremembo smeri
                if(potencialnaNapaka_st > pragNapake)
                    %napacno sem ocenil. Pri�lo je do hitre spremembe smeri.
                    %Novih vrednosti ne bom ve� postavil na 0
                    nova_vrednost = vhodni_podatek;

                    %preverim ali popravek sploh obstaja
                    if abs(potencialnaNapaka_sum) > 0                    
                        nova_vrednost = nova_vrednost + (potencialnaNapaka_sum * faktorSkaliranjaPopravkaNapake);
                        %ponastavitev sum-napaka (inicializacija za kasnej�e
                        %potencialne napake)
                        potencialnaNapaka_sum = 0;
                    end
                else
                    %trenutno smo �e mnenja, da je sprememba smeri le posledica
                    %�uma in NE dejanske spremembe smeri gibanja naprave
                    nova_vrednost = 0;
                    potencialnaNapaka_sum = potencialnaNapaka_sum + vhodni_podatek; %pravilno da NI abs, saj tako upo�tevam visoko varianco (ob prehodu �ez 0). Abs pa uporabim pri preverjanju
                end 
            end            
        end
    end
end

