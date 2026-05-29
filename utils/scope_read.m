addpath("ds1000");
addpath("dmm6500");

distance = 1; % meters
channels = [1];
chan_names = ["osc_out"];

fs_scope = 100e3;
memdepth = 1e6;

clear scopesock
scopesock = ds1000_init();

ds1000_capture_waveform(scopesock,memdepth,fs_scope,channels);
% dmm6500_current_trace(dmmsock,memdepth,fs);
pause(memdepth/fs_scope*1.03);

% savefilename = rx_froot; %sprintf("%s_%ddm",tx_filename,distance*10);

rx_root = "~/Documents/MIT/sk/oceans/analog-sensing/rx_outputs/River_AS_Networking_05-05-2024";
savefilename = sprintf("rx_%dm_board2_moving",distance);


tic
ideal_rx = ds1000_read_waveform(scopesock,rx_root,savefilename,memdepth,fs_scope,channels,chan_names);
toc

%%
% ideal_rx = read_float_binary("../../../rx_outputs/dummy_fs=100e3_scope_osc_out_9.bin");
wfunc = @blackmanharris;
wlen_t = 30e-3;
overlap = 0.5;
wleni = round(wlen_t*fs_scope);
Nffti = 10*wleni;
track_ideal = stft(ideal_rx-mean(ideal_rx),fs_scope,"Window",wfunc(wleni),"OverlapLength",round(overlap*wleni),"FFTLength",Nffti,"FrequencyRange","onesided");

freq_ideal = zeros(size(track_ideal,2),1);

for i=1:size(track_ideal,2)
    [~,indexi] = max(track_ideal(:,i));
    freq_ideal(i) = (indexi-1)*fs_scope/Nffti;
end

fcal = [440 576.67];
rcal = [1.332e6 1e6];

%%
figure(1);
hold on;
plot(freq_ideal);

figure(2);
hold on;
plot(decode_f2r_2(fcal,rcal,freq_ideal));
% plot(decode_f2r(freq_ideal,"analytic","freq",ahat))