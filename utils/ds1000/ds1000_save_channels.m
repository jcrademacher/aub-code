function rx = ds1000_save_channels(root,froot,memdepth,fs,channels,chan_names)
    % connect
    if ~exist(root,'dir')
        error("Folder does not exist. Please create it or check your path.");
    end


    if length(channels) ~= length(chan_names)
        error("channels and chan_names must be the same length");
    end

    clear sock;
    
    sock = visadev("TCPIP0::192.168.10.90::INSTR");
    set(sock,'Timeout',60);
    flush(sock);
    
    %Nchan = 3; % num channels to acquire
    
    % one time setup
    %memdepth = 1e6;         % in points (only use 1M or 10M. To use less, fs must be increased)
    %fs = 200e3;             % sample rate
    xspan = memdepth/fs     % horizontal span
    
    % set horizontal / acquire params
    writeline(sock,strcat(":ACQ:MDEP ",num2str(memdepth)));
    writeline(sock,strcat(":TIM:SCAL ",num2str(xspan/10)));
    
    for n=1:4
        if(ismember(n,channels)); boolstr = "ON"; else; boolstr = "OFF"; end
    
        writeline(sock,sprintf(":CHAN%d:DISP %s",n,boolstr));
    end
    
    
    % acquire and read
    disp("Acquiring...");
    writeline(sock,":RUN");
    pause(xspan*1.1);
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
    
    for n=1:length(channels)
        chan = channels(n);
        fname = sprintf("%s_fs=%de3_scope_%s_0.bin",froot,fs/1e3,chan_names(n));
        fullname = fullfile(root,fname);

        if isfile(fullname)
            i=0;
            while isfile(fullname)
                i = i+1;
                fname_mod = sprintf("%s_fs=%de3_scope_%s_%d.bin",froot,fs/1e3,chan_names(n),i);
                fullname = fullfile(root,fname_mod);
                
            end

            warning("%s already exists, renaming trial to %d",fname,i);
        end
            
        fprintf("Saving channel %d...\n",chan);
        write_float_binary(rx(:,n),fullname);
    end
end

