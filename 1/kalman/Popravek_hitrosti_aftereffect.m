function [nova_vrednost, iteracija_gibanja, predznak, zadetekMejeSlike] = Popravek_hitrosti_aftereffect( pospesek, i, iteracija_gibanja, predznak, vhodni_podatek, zadetekMejeSlike )
    persistent potencialnaNapaka_sum;
    persistent potencialnaNapaka_st;
    pragNapake = 250;
    prag_potencialnaNapaka_sum = 10;
    faktorSkaliranjaPopravkaNapake = 0.65;

    %%{
    if(i>710)
        i
    end
    %}
    
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

        %podatek vrenem nespremenjen
        nova_vrednost = vhodni_podatek;
    else
        %Meritev ni ve� prva zaznana smer gibanja.
        %Preverim ali je pri�lo do spremembe smeri (prvo spremembo
        %smeri zatrem) ali �e smo zadeli mejo slike
        if vhodni_podatek*predznak > 0 && zadetekMejeSlike==0
            %ni spremembe smeri (zadeve ne filtriram)
            nova_vrednost = vhodni_podatek;
        else
            %pri�lo je do spremembe smeri hitrosti
            potencialnaNapaka_st = potencialnaNapaka_st + 1;
            
            %testiranje novega pristopa obvladovanja spremembe smeri ob zadetku v mejo
            if(zadetekMejeSlike==1)
                %zaznana posledica zadetka meje
                
                nova_vrednost = 0;
                potencialnaNapaka_sum = potencialnaNapaka_sum + abs(vhodni_podatek)
                
                %preverim �e smo prekora�ili 
                if(potencialnaNapaka_sum > prag_potencialnaNapaka_sum)
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

