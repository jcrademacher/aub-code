addpath("ds1000");

fs_scope = 100e3; %100s trial
memdepth = 1e6;

tx_filename = "250kHz_tone_18500_3s_250mV_2x"; %fpr tx
% tx_filename = "250kHz_chirp_16500_20500_3s_500mV_2x";
tx_root = "../../../tx_outputs/";
tx_filepath = strcat(tx_root,tx_filename,".dat");
    
rx_root = "../../../rx_outputs/River_LP_Wakeup_10-09-24";

usrp_fs = 250e3;
nsamps = usrp_fs*10; %trial nsamps - 100s

% clear scopesock
% 
% scopesock = ds1000_init();

channels = [1 2 3]; %[1 2]; %[1 2 3 4]; %[1]; %[3 4];
chan_names = ["txfmr" "rect_out" "comp_out"]; %["tx_diff"]; %["downlink_out" "correlator_out" "diff_transformer" "rectifier_out"];    

for trial=1:1

    distance = 20; % meters
    pow = 10;

    usrpcmdstr = sprintf(['./../../../build/rx_tx_samples_to_file ' ...
        '--args "addr0=192.168.10.6" ' ...
        '--tx-file "%s" ' ...
        '--nsamps %d --tx-rate 250000 --rx-rate 250000 --settling 1 ' ...
        '--tx-channels "0" --rx-channels "0" --rx-subdev "A:AB" --tx-subdev "A:AB" --ref "internal" --sync "now"'],tx_filepath,nsamps);
    system(strcat(usrpcmdstr," &"),"-echo");
    pause(0.5);
%     ds1000_capture_waveform(scopesock,memdepth,fs_scope,channels);
%     % dmm6500_current_trace(dmmsock,memdepth,fs);
%     pause(memdepth/fs_scope*1.03);
    
    savefilename = sprintf("%s_%ddm",tx_filename,distance*10);
    tic
    sigs = ds1000_save_channels(rx_root,savefilename,memdepth,fs_scope,channels,chan_names);
    toc
    t = [0:memdepth-1]/fs_scope;
    
    figure
    axes = zeros(length(channels),1);
    
    for n=1:length(channels)
        subplot(length(channels),1,n);
        chan = channels(n);
        plot(t,sigs(:,n));
        if chan==1
            title("Differential Transformer Voltage");
        elseif chan==2
            title("Rectifier Output");
        elseif chan==3
            title("Downlink Output");
        elseif chan==4
            title("Correlator Output");
        end
        xlabel("Time (s)");
        ylabel("Voltage (V)");
        axes(n) = gca;
    
        grid on;
        grid minor;
    end

    linkaxes(axes,'x');

end

%% TX Power
Z_real = 3.31;
Z_mag = abs(Z_real-1.06i);
tx_input_250mV = sigs(:,1); %read_float_binary(fullfile(rx_root,"wake_up_false_positive_pr8bs_113reps_18.5k_250mV_halfPow_0dm_fs=100e3_scope_tx_diff_20clicks.bin"));
tx_250mV_on = tx_input_250mV(1.13e5:1.22e5); %change index if necessary
tx_250mV_power = max(tx_250mV_on)^2/Z_mag^2 * Z_real;
disp(tx_250mV_power);

% tx_power = [sprintf("%0.0fW",tx_250mV_power), sprintf("%0.0fW",tx_500mV_power), sprintf("%0.0fW",tx_800mV_power)];

tx_power = ["250mV"];

figure;
plot(tx_input_250mV);
ax1 = gca;

%%

% uw = current/1e-6*1.8;
% mean_uw = mean(current/1e-6*1.8);
% 
% hold on;
% plot(t,uw)
% xlabel("Time (s)");
% ylabel("Power (uW)");
% title("SMPS Output Power, Dynamic, Full System Bench Simulation");
% yline(mean_uw,'--',{sprintf("%0.2f uW average",mean_uw)},'Color','r');
% grid on;
% grid minor;
% ax = gca;
% ax.FontSize = 14;



