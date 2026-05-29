function cond = decode_conductivity(rval)
    offset_r = 2e6;
    K = 1;
    cond_r = rval - offset_r;

    cond = K/cond_r;
end