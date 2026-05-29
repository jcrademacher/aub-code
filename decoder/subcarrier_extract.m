function [cfreq,cpow,subcfreqs,subc_cnrs] = subcarrier_extract(slice,window,fs,mode,Npeaks)
    wlen = length(window);
    Nfft = 20*wlen;
    cfoffs = 400*Nfft/fs;
    
    search_width = 2e3;

    sfft = abs(fft(slice.*window,Nfft));
    sfft = sfft(1:round(Nfft/2));

    pxx_movmed = movmedian(20*log10(sfft),round(Nfft/100));

%     figure(1);
%     plot(20*log10(sfft));

    if strcmp(mode,"pb")
        [cpow,mi] = max(sfft);
        cfreq = (mi-1)*fs/Nfft;
    
        search_right = round(mi-1+cfoffs+1);
        search_left = round(mi-1-(cfoffs+1));
    
        search_right_end = search_right+round(search_width*Nfft/fs);
        search_left_end = search_left - round(search_width*Nfft/fs);
    
        [peaks,locs] = findpeaks(sfft(search_right+1:search_right_end),"NPeaks",Npeaks,"SortStr","descend");

%         [mxr,next_max_r] = max(sfft(search_right+1:search_right_end));
%         [mxl,next_max_l] = max(sfft(search_left_end+1:search_left));
    
%         if mxr >= mxl

        
% 
        max_idxs = locs;
        absfreqs = (max_idxs+search_right-1)*fs/Nfft;
%         subcpow = mxr;

        subc_cnrs = 20*log10(peaks)-pxx_movmed(max_idxs+search_right-1);
%             max_idx = next_max_l;
%             subcfreq = (max_idx+search_left_end-1)*fs/Nfft;
%             subcpow = mxl;
%         else
%             max_idx = next_max_l;
%             subcfreq = (max_idx+search_left_end-1)*fs/Nfft;
%             subcpow = mxl;
%         end

        subcfreqs = abs(absfreqs-cfreq);
    elseif strcmp(mode,"bb")
    else
        error("Please specify one of 'pb' or 'bb' for subcarrier extraction method");
    end
    %     figure(2);
    %     plot(slice);
    %     hold on;
    %     xlim([10e3 30e3]);
    %     if i==300
    %         test = 0;
    %     end
end