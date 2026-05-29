function compfreq = doppler_compensate(cfreq,doppcfreq,subcfreq)
    fdopp_act = 500;

    if isnan(doppcfreq)
        doppcfreq = fdopp_act;
    end

%     subcsign = sign(doppcfreq-cfreq);
    c = 1500;
    v = (fdopp_act-doppcfreq)./(fdopp_act+2*cfreq)*c;

    compfreq = (subcfreq+cfreq*2*v/c)./(1-v/c);

%     df = doppcfreq - fdopp_act;
%     bbfreq = subcfreq-df;
end