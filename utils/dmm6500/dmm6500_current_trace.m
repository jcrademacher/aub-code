function dmm6500_current_trace(sock,memdepth,fs,range)
    buffername = "defbuffer1";
    % writeline(sock,sprintf(':TRAC:DEL "%s"',buffername));
    % writeline(sock,sprintf(':TRAC:MAKE "%s", %d',buffername,memdepth));
    writeline(sock,sprintf(':TRAC:POIN %d, "%s"',memdepth,buffername));
    writeline(sock, 'DIG:FUNC "CURR"');
    writeline(sock, sprintf('DIG:COUN %d',memdepth));
    writeline(sock, sprintf("DIG:CURR:SRATE %d",fs));
    writeline(sock, sprintf(":DIG:CURR:RANG %d",range));
    writeline(sock,":FORM REAL");
    writeline(sock,":FORM:BORD SWAP");
    writeline(sock,sprintf(':TRAC:CLE "%s"',buffername));
    % tracedata = writeread(sock,":MEAS:DIG?");
    % writeline(sock,sprintf(':TRAC:FILL:MODE CONT, "%s"',buffername));
    writeline(sock,sprintf(':TRIG:LOAD "SimpleLoop", %d, 0, "%s"',memdepth,buffername));
    writeline(sock,":INIT");
    disp("Measuring current...");
end
