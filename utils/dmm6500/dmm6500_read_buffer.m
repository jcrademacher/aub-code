function floatdata = dmm6500_read_buffer(sock,root,froot,memdepth,fs)
    buffername = "defbuffer1";
    disp("Reading buffer...");
    writeline(sock,sprintf(':TRAC:DATA? %d, %d, "%s"',1,memdepth,buffername));
    tracedata = uint8(read(sock,8*memdepth+3,"uint8"));
    tracedata = tracedata(3:end-1);
    floatdata = typecast(tracedata,"double");

    fname = sprintf("%s_fs=%de3_current_0.bin",froot,fs/1e3);
    fullname = fullfile(root,fname);

    if isfile(fullname)
        i=0;
        while isfile(fullname)
            i = i+1;
            fname_mod = sprintf("%s_fs=%de3_current_%d.bin",froot,fs/1e3,i);
            fullname = fullfile(root,fname_mod);
        end

        warning("%s already exists, renaming trial to %d",fname,i);
    end
        
    fprintf("Saving current trace...\n");
    write_float_binary(floatdata,fullname);
end

