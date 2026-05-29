function retval = decode_f2r_2(f,R,decodef)
    f0 = f(1);
    f1 = f(2);

    R0 = R(1);
    R1 = R(2);
    
    tp = (1/f1 - R1/(R0*f0))/(1-R1/R0);
    a = (1/f0-tp)/(2*R0);


    retval = (1-decodef*tp)./(2*decodef*a);
end