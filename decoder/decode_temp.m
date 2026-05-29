function temp = decode_temp(rval)
%     Rp = 1e6;
%     rval = rval*Rp./(Rp-rval);
    
    R25 = 2.2e6; % nominal NTC resistance at 25 C
    beta = 5200;
    
    T25 = 298.15; % temp in kelvin at 25 C
    T0 = 273.15; % temp in kelvin at 0 C
    
%     temp = T25*beta./(beta-T25*log(2*freq*R25*C*log((Vtp+Vh)/(Vtn-Vh))))-T0;

    temp = T25*beta./(beta+T25*log(rval/R25))-T0;
end