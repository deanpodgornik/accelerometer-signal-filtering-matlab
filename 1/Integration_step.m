function result = Integration_step(input_d, i, freq, method)
    switch method
        case 'pravokotnik'
            result = (1 / freq) * input_d(i);
        case 'trapez'
            result = (1 / freq) * ((input_d(i-1)+input_d(i)) / 2);
    end
end

