function [ max_hitrosti_pri_enem_premiku ] = preveri_novo_max_vrednost( max_hitrosti_pri_enem_premiku, nova_vrednost )

    if(max_hitrosti_pri_enem_premiku == 0)
        max_hitrosti_pri_enem_premiku = nova_vrednost;
    else
        if(max_hitrosti_pri_enem_premiku < 0)
            if(nova_vrednost < max_hitrosti_pri_enem_premiku)
                max_hitrosti_pri_enem_premiku = nova_vrednost;
            end
        else
            if(nova_vrednost > max_hitrosti_pri_enem_premiku)
                max_hitrosti_pri_enem_premiku = nova_vrednost;
            end
        end;
    end;
    
end

