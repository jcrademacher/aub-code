function sock = dmm6500_init()
    clear sock

    sock = visadev("TCPIP0::192.168.10.11::INSTR"); %TCPIP0::192.168.10.11::INSTR
    % configureTerminator(sock,"CR/LF");

    flush(sock);
    set(sock,'Timeout',60);
end

