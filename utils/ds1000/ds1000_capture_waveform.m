function ds1000_capture_waveform(sock,memdepth,fs,channels)
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
end

