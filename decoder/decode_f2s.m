function [rval,sval] = decode_f2s(freq,sensor,varargin)
    assert(isstring(sensor));

    load bands.mat C_BAND T_BAND DEP_BAND DOP_BAND;

    switch sensor
        case "temp"
            band = T_BAND;
            dfunc = @decode_temp;
        case "depth"
            band = DEP_BAND;
            dfunc = @decode_depth;
        case "cond"
            band = C_BAND;
            dfunc = @decode_conductivity;
        case "dopp"
            band = DOP_BAND;
            dfunc = @(f) f;
        otherwise
            error("Please use one of 'temp', 'depth', 'cond', or 'dopp'")
    end
    
    % segment frequency vector into which sensor they correspond to
%     idx = logical((freq >= band(1)).*(freq <= band(2)));
    if isempty(varargin)
        rval = decode_f2r(freq,"lookup","freq");
    else
        rval = decode_f2r(freq,"analytic","freq",varargin{1});
    end


    if sensor == "dopp"
        sval = dfunc(freq);
    else
        sval = dfunc(rval);
    end
end



