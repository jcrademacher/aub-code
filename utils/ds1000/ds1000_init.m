function sock = ds1000_init()
    clear sock;
    
    sock = visadev("TCPIP0::192.168.10.90::INSTR");
    set(sock,'Timeout',60);
    flush(sock);
end

