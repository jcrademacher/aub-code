function [vals,pows,starts] = fextract_full_window(rx,fs,wfunc,wlen,Ns)
    rx_len = length(rx);
    window = wfunc(wlen);              % window function

    vals = [];
    pows = [];

    done = 0;
    start = -3*wlen+2;
    starts = [];

    while ~done
        i = start + 3*wlen-1;
        start = find_doppler_start(rx(i:end),fs,window,i)+i-1;
        starts = [starts; start];

        if start+4*wlen-1 > rx_len
            done = 1;
            continue;
        end
        
        [doppcfreq, ~, doppfreq, doppcnr] = subcarrier_extract(rx(start:start+wlen-1),window,fs,"pb");
        
        s = zeros(1,Ns+1);
        s(1) = doppfreq;

        p = zeros(1,Ns+1);
        p(1) = doppcnr;

        

        for i=1:Ns
            [cfreq, ~, sfreq, scnr] = subcarrier_extract(rx(start+i*wlen:start+(i+1)*wlen-1),window,fs,"pb");
            s(i+1) = sfreq;
            p(i+1) = scnr;
        end
        
        vals = [vals; s];
        pows = [pows; p];
    end
end