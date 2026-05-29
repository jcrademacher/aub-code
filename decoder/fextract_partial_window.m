function [tdx,fd,fn] = fextract_partial_window(rx,fs,wfunc)
    rx_len = length(rx);
    wlen_t = 25e-3;     % window length (seconds)
    wov = 0.5;          % overlap decimal (pct 0-1)
    
    wlen = round(wlen_t*fs);          % window length (samples)
    window = wfunc(wlen);              % window function
    wov_len = round(wov*wlen);          % overlap length (samples)
    coffs = ceil(get_n2n_width(window,fs)); %200*Nfft/fs_n;%
   
    Nslices = floor((rx_len-wlen)/(wlen-wov_len)+1);
    
    fd = zeros(Nslices,1);
    fn = zeros(Nslices,1);
    tdx = zeros(Nslices,1);
    
%     wint = zeros(Nslices,wlen);
    
    for i=1:Nslices
        b = (wlen-wov_len)*(i-1)+1;
        e = b+wlen-1;

        [~, ~, subcfreq, ~] = subcarrier_extract(rx(b:e),window,fs,coffs,"pb");

        fd(i) = subcfreq;
        if i==1
            fn(i) = fd(i);
        else
            fn(i) = 1/(i-1)*(fn(i-1)*(i-2)+fd(i-1));
        end
    
        tdx(i) = floor((b+e-1)/2);
%         wint(i,:) = t(b:e);
    end
end