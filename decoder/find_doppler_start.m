function start = find_doppler_start(rx,fs,window,starti)
    rx_len = length(rx);
    wlen = length(window);

%     % highpass filter cutoffs


    load bands.mat DOP_BAND;
    
    step = round(wlen/50);
    span = 5*wlen;
    
    freqs = zeros(ceil(span/step),1);
    pows = zeros(ceil(span/step),1);
    indices = zeros(ceil(span/step),1);
    
    searching = 0;
    index = 1;
    found = 0;

    i = 0;

    while ~found
        if index+wlen-1 > length(rx)
            break
        end

        [cfreq, ~, subcfreq, subcpow] = subcarrier_extract(rx(index:index+wlen-1),window,fs,"pb");
        
        if ((subcfreq > DOP_BAND(1) && subcfreq <= DOP_BAND(2)) && index ~= 1)
            searching = 1;

            indices(i+1) = index;
            freqs(i+1) = subcfreq;
            pows(i+1) = subcpow;
            
            i = i + 1;
            index = index + step;
        elseif searching == 0
            index = index + wlen/2;
            continue
        else
            found = 1;
        end
    end

    [val,maxindex] = max(pows);
    start = indices(maxindex);

%     prevpow = 0;
%     subcfound = 0;
%     dir = 1;
%     found = 0;
%     i = 1;
%     span = floor(wlen/2);
% 
%     indices = [];
%     
%     while ~found
% %         itot = i + starti-1;
% %         starttot = start+starti-1;
% 
%         i = min(i,length(rx)-wlen+1);
% 
%         if ~subcfound
%             [cfreq, ~, subcfreq, subcpow] = subcarrier_extract(rx(i:i+wlen-1),window,fs,"pb");
% %             subcfreq = abs(subcfreq-cfreq);
% 
%             % advance window by wlen if subcarrier is not within dopppler band,
%             % and first doppler subcarrier has not been found
%             if (subcfreq <= DOP_BAND(1) || subcfreq > DOP_BAND(2))
%                 i = i + floor(wlen/2);
%                 continue;
%             end
% 
%             subcfound = 1;
%             prevpow = subcpow;
%             start = i;
%             i = i + span;
%             itot = i + starti;
%         end
%         
%         i = min(i,length(rx)-wlen+1);
% 
%         if subcfound
%             
%             [~, ~, subcfreq, subcpow] = subcarrier_extract(rx(i:i+wlen-1),window,fs,"pb");
% %             subcfreq = abs(subcfreq-cfreq);
%             
%             if span == 0
%                 found = 1;
%             end
%             
%             if subcpow > prevpow && (subcfreq > DOP_BAND(1) && subcfreq <= DOP_BAND(2))
%                 start = i;
%                 i = i + dir*span;
%             else
%                 i = i - dir*span;
%                 span = floor(span/2);
%                 dir = -1*dir;
%             end
% 
%             if (subcfreq > DOP_BAND(1) && subcfreq <= DOP_BAND(2))
%                 prevpow = subcpow;
%             end
% 
%             i = max(1,i);
%         end
% 
% 
%     end
end