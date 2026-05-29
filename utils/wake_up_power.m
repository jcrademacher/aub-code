addpath("dmm6500");

fs = 1e3;
memdepth = 2e4; %20 seconds = memdepth/fs
current_range = 10e-3;

dmmsock = dmm6500_init();

%% Record Trace

dmm6500_current_trace(dmmsock,memdepth,fs,current_range);

pause(memdepth/fs*1.1); %pause for a little longer than 20 seconds

filename = "rx_8bit_wake_up_test_ext_supply_decoderOnly";
root = "../../../rx_outputs/Wake_Up_Power_12-08-24";

current = dmm6500_read_buffer(dmmsock,root,filename,memdepth,fs);

current = read_float_binary(fullfile(root, "rx_8bit_wake_up_test_ext_supply_fs=1e3_current_0.bin")).';

v = 1.8;
t = [0:memdepth-1]/fs;
mw = current/1e-3*v;
uw = mw/1e-3;

%% Plot
mov_avg_uw = movmean(uw, 100);
start = 2000;
stop = 12000;
duration = (stop-start)/1e3;
mean_uw = mean(mov_avg_uw);

rx_t = t(1:(stop-start+1));
rx_uw = mov_avg_uw(1, start:stop);
rx_mean_uw = mean(mov_avg_uw(start:stop));

plot(rx_t, rx_uw, "LineWidth", 2);
xlabel("Time (s)");
ylabel("Power (uW)");
avg_line = yline(rx_mean_uw,'--',{sprintf("%0.2f uW \nAverage",rx_mean_uw)},'Color','r', "LineWidth", 2);
avg_line.FontSize = 10;
ylim([0 60]);
xlim([0 10]);
grid on;
grid minor;
ax = gca;
ax.FontSize = 14;
saveas(gcf, "C:\Users\rik\Documents\Paper Figures\AUB\power_results.svg")