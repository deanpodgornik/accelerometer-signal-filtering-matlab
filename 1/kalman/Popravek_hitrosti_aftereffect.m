function [nova_vrednost, iteracija_gibanja, predznak] = Popravek_hitrosti_aftereffect( pospesek, i, iteracija_gibanja, predznak, vhodni_podatek )
    persistent potencialnaNapaka_sum;
    persistent potencialnaNapaka_st;
    pragNapake = 150;

    if iteracija_gibanja == 1
        %nastavim predznak (dolo�im ali je treuten premik v pozitivni
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
        %smeri zatrem)
        if vhodni_podatek*predznak > 0
            %ni spremembe smeri (zadeve ne filtriram)
            nova_vrednost = vhodni_podatek;
        else
            %pri�lo je do spremembe smeri hitrosti
            potencialnaNapaka_st = potencialnaNapaka_st + 1;
            
            if(potencialnaNapaka_st > pragNapake)
                %napacno sem ocenil. Pri�lo je do hitre spremembe smeri.
                %Novih vrednosti ne bom ve� postavil na 0
                nova_vrednost = vhodni_podatek;
                %popravek zaradi napake
                if abs(potencialnaNapaka_sum) > 0
                    nova_vrednost = nova_vrednost + potencialnaNapaka_sum;
                    %ponastavitev sum-napaka (inicializacija za kasnej�e
                    %potencialne napake)
                    potencialnaNapaka_sum = 0;
                end
            else
                %trenutno smo �e mnenja, da je sprememba smeri le posledica
                %�uma in NE dejanske spremembe smeri gibanja naprave
                nova_vrednost = 0;
                potencialnaNapaka_sum = potencialnaNapaka_sum + vhodni_podatek;
            end
        end
    end
end

