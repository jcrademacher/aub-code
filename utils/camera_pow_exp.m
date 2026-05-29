%% Initialization

addpath("dmm6500");

dmmsock = dmm6500_init();

root = "../../../../../Seascan Measurements/breakdown_3_14_24/";

%% Record Trace for Full Board (1V8_IN) - Image Capture

fs = 1e3;
memdepth = 2e4; %20 seconds = memdepth/fs
current_range = 100e-3;

filename = "Full_Board_4.1V_1V8in_mA_img";

current = record_trace(dmmsock,root,filename,memdepth,fs,current_range);

mAscale = 1e-3; %mA scaling factor
current = current/mAscale; %mA scaling of current

v = 1.8;
t = [0:memdepth-1]/fs;
mw = current*v;

%% Plot Power for Full Board (1V8_IN) - Image Capture

start = 4.145e3;
stop = start+0.832e3;
duration = (stop-start)/fs;

window_t = t(start:stop);
window_mw = mw(1, start:stop);
window_mean_mw = mean(current(1,start:stop)*v);

plot(window_t, window_mw);
xlabel("Time (s)");
ylabel("Power (mW)");
title(filename);
yline(window_mean_mw,'--',{sprintf("%0.2f mW avg", window_mean_mw)},'Color','r');
ylim([0 100]);
grid on;
grid minor;
ax = gca;
ax.FontSize = 14;

%% Record Trace for Full Board (1V8_IN) - Backscatter

fs = 1e3;
memdepth = 2e5; %200 seconds = memdepth/fs
current_range = 100e-3;

filename = "Full_Board_4.1V_1V8in_uA_bsc";

current = record_trace(dmmsock,root,filename,memdepth,fs,current_range);

uAscale = 1e-6; %uA scaling factor
current = current/uAscale; %mA scaling of current

v = 4.1;
t = [0:memdepth-1]/fs;
uw = current*v;

%% Plot Power for Full Board (1V8_IN) - Backscatter

start = 3.448e3;
stop = start+186.1e3;
duration = (stop-start)/fs;

window_t = t(start:stop);
window_uw = uw(1, start:stop);
window_mean_uw = mean(current(1,start:stop)*v);

plot(window_t, window_uw);
xlabel("Time (s)");
ylabel("Power (uW)");
title(filename);
yline(window_mean_uw,'--',{sprintf("%0.2f uW avg", window_mean_uw)},'Color','r');
ylim([0 1e3]);
grid on;
grid minor;
ax = gca;
ax.FontSize = 14;

%% Record Trace for Full Board (2V8_IN) - Image Capture

fs = 1e3;
memdepth = 2e4; %20 seconds = memdepth/fs
current_range = 100e-3;

filename = "Full_Board_4.1V_2V8in_mA_img";

current = record_trace(dmmsock,root,filename,memdepth,fs,current_range);

mAscale = 1e-3; %mA scaling factor
current = current/mAscale; %mA scaling of current

v = 4.1;
t = [0:memdepth-1]/fs;
mw = current*v;

%% Plot Power for Full Board (2V8_IN) - Image Capture

start = 1.1e3;
stop = start+0.832e3;
duration = (stop-start)/fs;

window_t = t(start:stop);
window_mw = mw(1, start:stop);
window_mean_mw = mean(current(1,start:stop)*v);

plot(window_t, window_mw);
xlabel("Time (s)");
ylabel("Power (mW)");
title(filename);
yline(window_mean_mw,'--',{sprintf("%0.2f mW avg", window_mean_mw)},'Color','r');
ylim([0 100]);
grid on;
grid minor;
ax = gca;
ax.FontSize = 14;

%% Record Trace for Full Board (2V8_IN) - Backscatter

fs = 1e3;
memdepth = 2e4; %200 seconds = memdepth/fs
current_range = 100e-3;

filename = "Full_Board_4.1V_2V8in_uA_bsc";

current = record_trace(dmmsock,root,filename,memdepth,fs,current_range);

uAscale = 1e-6; %uA scaling factor
current = current/uAscale; %mA scaling of current

v = 4.1;
t = [0:memdepth-1]/fs;
uw = current*v;

%% Plot Power for Full Board (2V8_IN) - Backscatter

start = 1.867e3;
stop = 20e3;%start+186.1e3;
duration = (stop-start)/fs;

window_t = t(start:stop);
window_uw = uw(1, start:stop);
window_mean_uw = mean(current(1,start:stop)*v);

plot(t, uw);
xlabel("Time (s)");
ylabel("Power (uW)");
title(filename);
yline(window_mean_uw,'--',{sprintf("%0.2f uW avg", window_mean_uw)},'Color','r');
ylim([0 1000]);
grid on;
grid minor;
ax = gca;
ax.FontSize = 14;

%% Record Trace for STM32 - Image Capture

fs = 1e3;
memdepth = 2e4; %20 seconds = memdepth/fs
current_range = 100e-3;

filename = "STM32_1.8V_mA_img";

current = record_trace(dmmsock,root,filename,memdepth,fs,current_range);

mAscale = 1e-3; %mA scaling factor
current = current/mAscale; %mA scaling of current

v = 1.8;
t = [0:memdepth-1]/fs;
mw = current*v;

%% Plot Power for STM32 - Image Capture

start = 0.988e3;
stop = start+0.832e3;
duration = (stop-start)/fs;

window_t = t(start:stop);
window_mw = mw(1, start:stop);
window_mean_mw = mean(current(1,start:stop)*v);

plot(window_t, window_mw);
xlabel("Time (s)");
ylabel("Power (mW)");
title(filename);
yline(window_mean_mw,'--',{sprintf("%0.2f mW avg", window_mean_mw)},'Color','r');
ylim([0 100]);
grid on;
grid minor;
ax = gca;
ax.FontSize = 14;

%% Record Trace for STM32 - Backscatter

fs = 1e3;
memdepth = 2e5; %200 seconds = memdepth/fs
current_range = 100e-3;

filename = "STM32_1.8V_mA_bsc";

current = record_trace(dmmsock,root,filename,memdepth,fs,current_range);

uAscale = 1e-6; %uA scaling factor
current = current/uAscale; %uA scaling of current

v = 1.8;
t = [0:memdepth-1]/fs;
uw = current*v;

%% Plot Power for STM32 - Backscatter

start = 2.198e3;
stop = start+186.1e3;
duration = (stop-start)/fs;

window_t = t(start:stop);
window_uw = uw(1, start:stop);
window_mean_uw = mean(current(1,start:stop)*v);

plot(window_t, window_uw);
xlabel("Time (s)");
ylabel("Power (uW)");
title(filename);
yline(window_mean_uw,'--',{sprintf("%0.2f uW avg", window_mean_uw)},'Color','r');
ylim([0 1e3]);
grid on;
grid minor;
ax = gca;
ax.FontSize = 14;

%% Record Trace for 1.8V Rail (STM32+Cameras) - Image Capture

fs = 1e3;
memdepth = 2e4; %20 seconds = memdepth/fs
current_range = 100e-3;

filename = "STM32+Cameras_1.8V_mA_img";

current = record_trace(dmmsock,root,filename,memdepth,fs,current_range);

mAscale = 1e-3; %mA scaling factor
current = current/mAscale; %mA scaling of current

v = 1.8;
t = [0:memdepth-1]/fs;
mw = current*v;

%% Plot Power for 1.8V Rail (STM32+Cameras) - Image Capture

start = 1.652e3;
stop = start+0.832e3;
duration = (stop-start)/fs;

window_t = t(start:stop);
window_mw = mw(1, start:stop);
window_mean_mw = mean(current(1,start:stop)*v);

plot(t, mw);
xlabel("Time (s)");
ylabel("Power (mW)");
title(filename);
yline(window_mean_mw,'--',{sprintf("%0.2f mW avg", window_mean_mw)},'Color','r');
ylim([0 100]);
grid on;
grid minor;
ax = gca;
ax.FontSize = 14;

%% Record Trace for 1.8V Rail (STM32+Cameras) - Backscatter

fs = 1e3;
memdepth = 2e5; %200 seconds = memdepth/fs
current_range = 1;

filename = "STM32+Cameras_1.8V_uA_bsc";

current = record_trace(dmmsock,root,filename,memdepth,fs,current_range);

uAscale = 1e-6; %uA scaling factor
current = current/uAscale; %uA scaling of current

v = 1.8;
t = [0:memdepth-1]/fs;
uw = current*v;

%% Plot Power for 1.8V Rail (STM32+Cameras) - Backscatter

start = 2.083e3;
stop = start+186.1e3;
duration = (stop-start)/fs;

window_t = t(start:stop);
window_uw = uw(1, start:stop);
window_mean_uw = mean(current(1,start:stop)*v);

plot(window_t, window_uw);
xlabel("Time (s)");
ylabel("Power (uW)");
title(filename);
yline(window_mean_uw,'--',{sprintf("%0.2f uW avg", window_mean_uw)},'Color','r');
ylim([0 1e6]);
grid on;
grid minor;
ax = gca;
ax.FontSize = 14;

%% Record Trace for 2.8V Cameras - Image Capture

fs = 1e3;
memdepth = 2e4; %20 seconds = memdepth/fs
current_range = 100e-3;

filename = "Cameras_2.8V_mA_img";

current = record_trace(dmmsock,root,filename,memdepth,fs,current_range);

mAscale = 1e-3; %mA scaling factor
current = current/mAscale; %mA scaling of current

v = 2.8;
t = [0:memdepth-1]/fs;
mw = current*v;

%% Plot Power for 2.8V Cameras - Image Capture

start = 2.40e3;
stop = start+0.832e3;
duration = (stop-start)/fs;

window_t = t(start:stop);
window_mw = mw(1, start:stop);
window_mean_mw = mean(current(1,start:stop)*v);

plot(window_t, window_mw);
xlabel("Time (s)");
ylabel("Power (mW)");
title(filename);
yline(window_mean_mw,'--',{sprintf("%0.2f mW avg", window_mean_mw)},'Color','r');
ylim([0 100]);
grid on;
grid minor;
ax = gca;
ax.FontSize = 14;

%% Record Trace for 2.8V Cameras - Backscatter

fs = 1e3;
memdepth = 2e5; %200 seconds = memdepth/fs
current_range = 100e-3;

filename = "Cameras_2.8V_uA_bsc";

current = record_trace(dmmsock,root,filename,memdepth,fs,current_range);

uAscale = 1e-6; %uA scaling factor
current = current/uAscale; %mA scaling of current

v = 2.8;
t = [0:memdepth-1]/fs;
uw = current*v;

%% Plot Power for 2.8V Cameras - Backscatter

start = 2.198e3;
stop = start+186.1e3;
duration = (stop-start)/fs;

window_t = t(start:stop);
window_uw = uw(1, start:stop);
window_mean_uw = mean(current(1,start:stop)*v);

plot(t, uw);
xlabel("Time (s)");
ylabel("Power (uW)");
title(filename);
yline(window_mean_uw,'--',{sprintf("%0.2f uW avg", window_mean_uw)},'Color','r');
ylim([0 1000]);
grid on;
grid minor;
ax = gca;
ax.FontSize = 14;

%% Open saved trace and plot

filename = "Full_Board_4.1V_1V8in_mA_img_fs=1e3_current_0.bin";
current = read_float_binary(fullfile(root,filename)).';

fs = 1e3;
memdepth = 2e4; %seconds = memdepth/fs

scale = 1e-3; %1e-3 %scaling factor of current
current = current/scale; %scaling current

v = 4.1; %2.8 %1.8 %4.1
t = [0:memdepth-1]/fs;
power = current*v;

start = 0.952e3+.6e3; %1 %+.60e3
stop = start+.23e3; %start+.60e3 %+.23e3
duration = (stop-start)/fs;

window_t = t(start:stop);
window_power = power(1, start:stop);
window_mean_power = mean(current(1,start:stop)*v);

plot(t, power);
xlabel("Time (s)");
ylabel("Power");
title("Time v Power");
yline(window_mean_power,'--',{sprintf("%0.2f mW avg", window_mean_power)},'Color','r');
ylim([0 100]);
grid on;
grid minor;
ax = gca;
ax.FontSize = 14;

%% Helper Functions

function current = record_trace(dmmsock,root,filename,memdepth,fs,range)

    dmm6500_current_trace(dmmsock,memdepth,fs,range);

    pause(memdepth/fs*1.1); %pause for a little longer than 100 seconds

    current = dmm6500_read_buffer(dmmsock,root,filename,memdepth,fs);

end