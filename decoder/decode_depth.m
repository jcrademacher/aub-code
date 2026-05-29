function depth = decode_depth(rval)
    Rpar = 510e3;
    Rser = 680e3;

    pdown = readmatrix("../../../rx_outputs/River_AS_Pressure_02-21-24/pressure_test_down.csv");
    pup = readmatrix("../../../rx_outputs/River_AS_Pressure_02-21-24/pressure_test_up.csv");

    depth = pdown(:,1);
    pdown = mean(pdown(:,2:end),2);
    pup = mean(pup(:,2:end),2);

    lookup = [depth mean([pdown pup],2)*1000];

    rval = (rval-Rser).*Rpar./(Rpar-(rval-Rser));

    if rval < 0
        depth = 0;
    else
        depth = interp1(lookup(:,2),lookup(:,1),rval);
    end
end