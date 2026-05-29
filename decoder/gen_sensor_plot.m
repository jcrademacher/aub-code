function gen_sensor_plot(fvals)
    load hw_params.mat hw_params;
    figure;
    Nsensors = size(fvals,2);

    for i=2:Nsensors
        sensor = hw_params.order(i-1);
        [~,sval] = decode_f2s(fvals(:,i),sensor);

        subplot(Nsensors,1,i-1);
        plot(sval);
        title(sensor);
    end

end

