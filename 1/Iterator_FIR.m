function result = Iterator_FIR(data, cur, factors)
    result = 0;
    
    if(cur<length(factors))
        result = 0;
    else
        for i = 1:length(factors)
            %result = result + data(cur-length(factors)+i)*factors(i);
            result = result + data(cur-i+1)*factors(i);
        end
    end
end