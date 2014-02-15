function [nova_vrednost, iteracija_gibanja, predznak] = Popravek_hitrosti_aftereffect( iteracija_gibanja, predznak, vhodni_podatek )
    if iteracija_gibanja == 1
        %nastavim predznak (doloèim ali je treuten premik v pozitivni
        %ali negativni smeri
        if vhodni_podatek<0
            predznak = -1;
        else
            predznak = 1;
        end;

        %podatek vrenem nespremenjen
        nova_vrednost = vhodni_podatek;
    else
        %Meritev ni veè prva zaznana smer gibanja.
        %Preverim ali je prišlo do spremembe smeri (prvo spremembo
        %smeri zatrem)
        if vhodni_podatek*predznak > 0
            %ni spremembe smeri (zadeve ne filtriram)
            nova_vrednost = vhodni_podatek;
        else
            %prišlo je do spremembe smeri (zatrem zadevo => podatek
            %postavim na 0)
            nova_vrednost = 0;
        end
    end
end

