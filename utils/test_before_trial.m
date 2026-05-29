addpath("ds1000");

fs_scope = 100e3; %10s test before trial
memdepth = 1e6;

%10s - test before trial
tx_filename = "wake_up_false_negative_01110010_113reps_18.5k_250mV_halfPow"; 
%tx_filename = "wake_up_false_positive_pr8bs_1000reps_18.5k_250mV";
pause_length = 1.1;

tx_root = "../../../tx_outputs/";
tx_filepath = strcat(tx_root,tx_filename,".dat");
    
rx_root = "../../../rx_outputs/River_AS_WakeUp_04-22-24/";
   
usrp_fs = 200e3;
nsamps = usrp_fs*10; %test before trial 10s nsamps

clear scopesock
    
scopesock = ds1000_init();

channels = [1 2 3 4]; %[1 2 3 4]; %[1]; %[3 4];
chan_names = ["downlink_out" "correlator_out" "rectifier_out" "diff_transformer"]; %["downlink_out" "correlator_out"]; %["tx_diff"];    

for trial=1:1

    distance = 4; % meters
    pow = 30;

    usrpcmdstr = sprintf(['./../../../build/rx_tx_samples_to_file ' ...
        '--args "addr0=192.168.10.6" ' ...
        '--tx-file "%s" ' ...
        '--nsamps %d --tx-rate 200000 --rx-rate 200000 --settling 1 ' ...
        '--tx-channels "0" --rx-channels "0" --rx-subdev "A:AB" --tx-subdev "A:AB" --ref "internal" --sync "now"'],tx_filepath,nsamps);
    system(strcat(usrpcmdstr," &"),"-echo");
    pause(1.3);
    ds1000_capture_waveform(scopesock,memdepth,fs_scope,channels);
    pause(memdepth/fs_scope*pause_length);
    
    savefilename = sprintf("test_trial");
        
    sigs = ds1000_read_waveform(true, scopesock,rx_root,savefilename,memdepth,fs_scope,channels,chan_names);
    t = [0:memdepth-1]/fs_scope;

    figure
    axes = zeros(length(channels),1);
    
    for n=1:length(channels)
        subplot(length(channels),1,n);
        chan = channels(n);
        plot(t,sigs(:,n));
        if chan==4
            title("Differential Transformer Voltage");
        elseif chan==3
            title("Rectifier Output");
        elseif chan==1
            title("Downlink Output");
        elseif chan==2
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



