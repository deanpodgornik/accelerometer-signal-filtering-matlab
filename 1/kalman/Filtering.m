function output_data = Filtering( input_data, i, filter_type, parameters )
%FILTERING aplicira filter na vhodne podatke
%   Detailed explanation goes here

    persistent firstRun_a A_a H_a Q_a R_a x_a P_a xp_a Pp_a K_a;
    persistent firstRun_h A_h H_h Q_h R_h x_h P_h xp_h Pp_h K_h;
    persistent firstRun_p A_p H_p Q_p R_p x_p P_p xp_p Pp_p K_p;

    switch filter_type
        case 'kalman'
            %Kalman filter   
            
            varianca = cell2mat(parameters(1));
            namen = parameters{2};
            
            if strcmp(namen,'pospesek')==1 && isempty(firstRun_a)
                firstRun_a = 0;
                %kovarianca šuma procesa (manjše kot je, bolj zaupamo merilnemu sistemu)
                %manjše kot je bolj je funkcija  blizu 0
                %Q_a = 0.00003;
                %Q_a = 0.006; %working
                %Q_a = 0.02; %working
                %Q_a = 0.008; %working
                Q_a = 0.08; %working
                
                %R_a = varianca;
                %R_a = varianca;
                R_a = 1.7;
            end

            if strcmp(namen,'hitrost')==1 && isempty(firstRun_h)
                firstRun_h = 0;
                %kovarianca šuma procesa (manjše kot je, bolj zaupamo merilnemu sistemu)
                %manjše kot je bolj je funkcija  blizu 0
                Q_h = 0.001;

                R_h = varianca;
            end

            if strcmp(namen,'pozicija')==1 && isempty(firstRun_p)
                firstRun_p = 0;
                %kovarianca šuma procesa (manjše kot je, bolj zaupamo sistemu)
                Q_p = 0.0005;

                R_p = varianca;  
            end
            
            switch namen
                case 'pospesek'
                    [output_data, firstRun_a, A_a, H_a, Q_a, R_a, x_a, P_a, xp_a, Pp_a, K_a] = Filter_SimpleKalman(input_data(i), varianca, firstRun_a, A_a, H_a, Q_a, R_a, x_a, P_a, xp_a, Pp_a, K_a);
                case 'hitrost'
                    [output_data, firstRun_h, A_h, H_h, Q_h, R_h, x_h, P_h, xp_h, Pp_h, K_h] = Filter_SimpleKalman(input_data(i), varianca, firstRun_h, A_h, H_h, Q_h, R_h, x_h, P_h, xp_h, Pp_h, K_h);
                case 'pozicija'
                    [output_data, firstRun_p, A_p, H_p, Q_p, R_p, x_p, P_p, xp_p, Pp_p, K_p] = Filter_SimpleKalman(input_data(i), varianca, firstRun_p, A_p, H_p, Q_p, R_p, x_p, P_p, xp_p, Pp_p, K_p);
                otherwise
                    output_data = input_data(i);
            end
        case 'custom_highpass'
            %custom high pass filter
            %prag = cell2mat(parameters(1))
            %output_data = Filter_custom_highpass_filter(input_data, i, prag);
        case 'fir'   
            %FIR filter
            %output_data = Filter_FIR_lowpass(input_data, i);
        otherwise
            %brez filtriranja
            output_data = input_data(i);
    end
end