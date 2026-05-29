function retval = decode_f2r(in,mode,input,varargin)
    Vs = 1.8;

    R1 = 30e6;
    R2 = 30e6;
    R3 = 30e6;
    C = 1e-9;
    Vh = 17.16e-3;
    tp = 85e-6;
    
    Vf_needed = Vh*(R1*R3+R2*R3+R1*R2)/(R1*R2);
    Vf = 0;
    
    Vtp = Vs*R2*(R1+R3)/(R1*R3+R2*(R1+R3))-Vf*R1*R2/(R1*R2+R1*R3+R2*R3);
    Vtn = Vs*R2*R3/(R2*R3+R1*(R2+R3))+Vf*R1*R2/(R1*R2+R1*R3+R2*R3);
    
    if mode == "analytic"
        if isempty(varargin)
            if input == "freq"
                retval = (1-in*tp)./(2*in*C.*log((Vtp+Vh/2)./(Vtn-Vh/2)));
            elseif input == "res"
                retval = 1./(2*in*C.*log((Vtp+Vh/2)./(Vtn-Vh/2))+95e-6);
            else
                error("Please specify one of 'res' or 'freq' for input");
            end
        else
            if input == "freq"
                ahat = varargin{1};
                retval = (1-in*tp)./(2*in*ahat);
            else
                error("idk");
            end
        end
    elseif mode == "lookup"
        lktab = readmatrix("../../lookup_v2.csv");

        if input == "freq"
            retval = interp1(lktab(:,2),lktab(:,1),in,'spline','extrap')*1e3;
        elseif input == "res"
            retval = interp1(lktab(:,1),lktab(:,2),in/1e3,'spline','extrap');
        else
            error("Please specify one of 'res' or 'freq' for input");
        end
    else
        error("Please specify one of 'analytic' or 'lookup'");
    end
end