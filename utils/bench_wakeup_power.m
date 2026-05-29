addpath("dmm6500");
clear dmmsock;

fs = 1e3;
memdepth = 2e4; %20 seconds = memdepth/fs
current_range = 1e-3;

% tx_filepath = "../../../tx_outputs/networking_bench_dual_single_packet_10000010_250mV.dat";
tx_bench_filepath = "../../../tx_outputs/networking_bench_dual_single_packet_10000010_250mV.dat";

tx = read_complex_binary(tx_bench_filepath);
% write_complex_binary(tx/2-1j*tx/2,tx_bench_filepath);

nsamps = 10*2e5;

dmmsock = dmm6500_init();

%% Record Trace


usrpcmdstr = sprintf(['./../../../build/rx_tx_samples_to_file ' ...
        '--args "addr0=192.168.10.2" ' ...
        '--tx-file "%s" ' ...
        '--nsamps %d --tx-rate 200000 --rx-rate 200000 --settling 1 ' ...
        '--tx-channels "0" --rx-channels "0" --rx-subdev "A:AB" --tx-subdev "A:AB" --ref "internal" --sync "now"'],tx_bench_filepath,nsamps);

system(strcat(usrpcmdstr," &"),"-echo");
pause(0.5);
dmm6500_current_trace(dmmsock,memdepth,fs,current_range);

pause(memdepth/fs*1.1); %pause for a little longer than 20 seconds

filename = "rx_8bit_wake_up_test_full_system_10000010.bin";
root = "../../../rx_outputs/Wake_Up_Power_12-08-24";

current = dmm6500_read_buffer(dmmsock,root,filename,memdepth,fs);
% current = read_float_binary(fullfile(root, "rx_8bit_wake_up_test_ext_supply_fs=1e3_current_0.bin")).';

v = 1.8;
t = [0:memdepth-1]/fs;
mw = current/1e-3*v;
uw = mw/1e-3;

%% Plot
mov_avg_uw = movmean(uw, 250);
start = 2688;
stop = 18e3;
duration = (stop-start)/fs;
mean_uw = mean(mov_avg_uw(start:stop));

% rx_t = t(1:(stop-start+1));
% rx_uw = mov_avg_uw(1, start:stop);
rx_mean_uw = mean(mov_avg_uw(start:stop));

plot(t, mov_avg_uw, "LineWidth", 2);
xlabel("Time (s)");
ylabel("Power (uW)");
avg_line = yline(rx_mean_uw,'--',{sprintf("%0.2f uW \nAverage",rx_mean_uw)},'Color','r', "LineWidth", 2);
avg_line.FontSize = 10;
% ylim([0 60]);
% xlim([0 10]);
grid on;
grid minor;
ax = gca;
ax.FontSize = 14;
% saveas(gcf, "C:\Users\rik\Documents\Paper Figures\AUB\power_results.svg")