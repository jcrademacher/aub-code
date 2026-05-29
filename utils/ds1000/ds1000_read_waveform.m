function rx = ds1000_read_waveform(sock,root,froot,memdepth,fs,channels,chan_names)
    if length(channels) ~= length(chan_names)
        error("channels and chan_names must be the same length");
    end

    writeline(sock,":STOP");
    
    rx = zeros(memdepth,length(channels));
    
    for n=1:length(channels)
        chstr = num2str(channels(n));
        
        disp(strcat("Reading channel ",chstr,"..."));
    
        writeline(sock,strcat(":WAV:SOUR CHAN",chstr));
        writeline(sock,":WAV:MODE RAW");
        writeline(sock,":WAV:FORM ASC");
        writeline(sock,":WAV:STAR 1");
        writeline(sock,strcat(":WAV:STOP ",num2str(memdepth)))
    
        writeline(sock,":WAV:DATA?");
        datachararr = char(read(sock,14*(memdepth),"char"));
    
        % idk why this needs to be done but the scope drops some commas for
        % some reason
        erri = regexp(datachararr,"[0-9][+-]");
        for i=1:length(erri)
            datachararr = insertAfter(datachararr,erri(i)+i-1,',');
        end
        
        datastr = convertCharsToStrings(datachararr);
        dataread = 10*str2double(split(datastr,","));
    
        rx(1:length(dataread),n) = dataread;
    end
    
    disp("Done");
    % analyze
    
    % write to new binary files
    %root = "../../../rx_outputs/";
    %froot = "test0";
end

