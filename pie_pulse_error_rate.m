addpath("utils/");

fs = 10e3; %samples per second
fc = 18.5e3;
fb = 100; %bits per second
bit_period = 1/fb;
spb = fs/fb; %samples per bit
amp = 250e-3;


root = 'data/'; %'../../rx_outputs/River_AS_WakeUp_04-09-24/'; %Edit this
%% Random bit sequence
order = 10;
nbits = 904; % 2^order-1;
% seed = [0 0 0 0 0 0 0 0 0 1];
seq = prbs(order, nbits);
bits = seq.';
% bits = [bits];

duty_cycle = 0.75;
% PIE
pie_encoded_bits = [generate_pie(bits, spb, duty_cycle)]; %prepend with 0 for first bit rising edge detection

%% Repeated Wake-Up Packet
packet = [0 1 1 1 0 0 1 0]; %8-bit packet %[0 0 1 0 1 0 0 0]; %3-bit packet
reps = 1000;
seq = [repmat(packet, 1, reps) 0]; %postpend with 0 as tx packet
bits = seq.';


t_bits = [0:1/fs:((length(bits)*spb)-1)/fs].';


duty_cycle = 0.75;
% PIE
pie_encoded_bits = [generate_pie(bits, spb, duty_cycle)]; %prepend with 0 for first bit rising edge detection

%% Wake-Up error detection

% root = '../../rx_outputs/River_AS_WakeUp_04-18-24/'; %'../../rx_outputs/River_AS_WakeUp_04-09-24/'; %Edit this

%Edit these
downlink = read_float_binary(fullfile(root,"wake_up_false_negative_01110010_1000reps_18.5k_250mV_20W_60dm_fs=10e3_scope_downlink_out_1.bin"));
wake_up_signal = read_float_binary(fullfile(root,"wake_up_false_negative_01110010_1000reps_18.5k_250mV_20W_60dm_fs=10e3_scope_correlator_out_1.bin"));

%threshold downlink
downlink(downlink > 1.8/2) = 1;
downlink(downlink < 1.8/2) = 0;

%threshold wake_up_signal
wake_up_signal(wake_up_signal > 1.8/2) = 1;
wake_up_signal(wake_up_signal < 1.8/2) = 0;

%find window of downlink signal
corr = xcorr(downlink*2-1,pie_encoded_bits*2-1)/length(downlink);
corr = corr(length(downlink):end);
[m,mi] = max(corr);
%if mi+length(pie_encoded_bits)-1 > length(downlink)
%    index_arr = 2.4e4:length(downlink);
%else
    index_arr = mi:mi+length(pie_encoded_bits)-1;
%end

%index_arr = mi:mi+length(pie_encoded_bits)-1;

downlink = downlink(index_arr);
wake_up_signal = wake_up_signal(index_arr);

downlink = [0; downlink];
pie_encoded_bits = [0; pie_encoded_bits];

% %% Visualize wake-up errors
% figure(1);
% subplot(4,1,1);
% plot(downlink);
% ylim([-0.5 1.5]);
% ax1 = gca;
% 
% figure(1);
% subplot(4,1,2);
% plot(wake_up_signal);
% ylim([-.5 1.5]);
% ax2 = gca;
% 
% figure(1);
% subplot(4,1,3);
% plot(pie_encoded_bits);
% ylim([-.5 1.5]);
% ax3 = gca;
% 
% figure(1);
% subplot(4,1,4);
% plot(corr);
% ylim([-.5 1.5]);
% ax4 = gca;
% 
% linkaxes([ax1 ax2, ax3, ax4],'x');
% 
% positives = 0;
% 
% for i = [1:length(packet)*spb:reps*length(packet)*spb]
% 
%     num_rising_edges = nnz(diff(wake_up_signal(i:i+length(packet)*spb-1)) == 1);
% 
%     if num_rising_edges > 0
%         positives = positives + 1;
%     end
% 
% end
% 
% FPR = positives / reps;
% FNR = 1 - FPR;
% 
% disp(FNR);


%% FNR from repeated wake-up packets experiments (uses downlink and correlator wake-up signals)

fs = 10e3; %samples per second
fb = 100; %bits per second
spb = fs/fb; %samples per bit
root = 'data/'; %'../../rx_outputs/River_AS_WakeUp_04-09-24/'; %Edit this

packet = [0 1 1 1 0 0 1 0]; %8-bit packet %[0 0 1 0 1 0 0 0]; %3-bit packet
reps = 1000;
seq = [repmat(packet, 1, reps) 0]; %postpend with 0 as tx packet
bits = seq.';
duty_cycle = 0.75;
pie_encoded_bits = [generate_pie(bits, spb, duty_cycle)]; %PIE

meters_range = [10,20, 40, 60, 80, 100, 120, 140, 160, 180, 200]; %Edit this
txpower_range = [10, 20, 30]; %Edit this
num_trials = 5; %Edit this
file_format = "wake_up_false_negative_01110010_1000reps_18.5k_250mV_%dW_%ddm_fs=10e3_scope_%s_%d.bin"; %Edit this

fnr_results = NaN(length(txpower_range),length(meters_range),num_trials);

for level = 1:length(txpower_range)

    for m = 1:length(meters_range)
        meter = meters_range(m);

        fnr_trials = zeros(length(num_trials));
    
        for trial = 0:(num_trials-1)
    
            downlink_file = sprintf(file_format, txpower_range(level), meter, "downlink_out", trial); %Edit this
            wake_up_file = sprintf(file_format, txpower_range(level), meter, "correlator_out", trial); %Edit this

            % disp(downlink_file)
    
            downlink = read_float_binary(fullfile(root,downlink_file));
            wake_up_signal = read_float_binary(fullfile(root,wake_up_file));

            if ~downlink
                warning("Downlink file does not exist");
                continue;
            elseif ~wake_up_signal
                warning("Wakeup signal file does not exist");
                continue;
            end
    
            [fpr, fnr, ~] = calculate_fpr_fnr(downlink, wake_up_signal, pie_encoded_bits, length(packet), reps, spb);
            
            if fnr~=0
                test=0;
            end
            fnr_results(level,m,trial+1) = fnr;

            % disp(fnr);
    
        end

        % disp(fnr_trials);
    
    end

end

%disp("distance(meters) -> median FRR");
%disp(frr_median_results);

%% FPR from PRBS (not including wake-up sequence)

fs = 10e3; %samples per second
fb = 100; %bits per second
spb = fs/fb; %samples per bit
root = 'data/'; %'../../rx_outputs/River_AS_WakeUp_04-09-24/'; %Edit this

packet_length = 8;
reps = 1000;
order = 10;
nbits = packet_length*reps;
seq = prbs(order, nbits);
bits = seq.';
duty_cycle = 0.75;
pie_encoded_bits = [generate_pie(bits, spb, duty_cycle)]; %PIE

meters_range = [10,20, 40, 60, 80, 100, 120, 140, 160, 180, 200]; %Edit this
txpower_range = [10, 20, 30]; %Edit this
num_trials = 5; %Edit this
file_format = "wake_up_false_positive_pr8bs_1000reps_18.5k_250mV_%dW_%ddm_fs=10e3_scope_%s_%d.bin"; %Edit this
%wake_up_false_positive_pr8bs_113reps_18.5k_%dmV_halfPow_%ddm_fs=100e3_scope_%s_%d.bin

fpr = 0;
fnr = 0;

Nsegs = 1;

fpr_results = NaN(length(txpower_range),length(meters_range),num_trials*Nsegs);

for level = 1:length(txpower_range)
    
    for m = 1:length(meters_range)
        meter = meters_range(m);
        disp(meter/10);

        fpr_trials = [];%zeros(length(num_trials));
    
        for trial = 0:(num_trials-1)
    
            downlink_file = sprintf(file_format, txpower_range(level), meter, "downlink_out", trial); %Edit this
            wake_up_file = sprintf(file_format, txpower_range(level), meter, "correlator_out", trial); %Edit this

            % disp(downlink_file)
    
            downlink = read_float_binary(fullfile(root,downlink_file));
            wake_up_signal = read_float_binary(fullfile(root,wake_up_file));

            if ~downlink
                warning("Downlink file does not exist");
                continue;
            elseif ~wake_up_signal
                warning("Wakeup signal file does not exist");
                continue;
            end
    
            [fpr, fnr, wake_ups] = calculate_fpr_fnr(downlink, wake_up_signal, pie_encoded_bits, packet_length, reps, spb);
            assert(fpr==sum(wake_ups)/length(wake_ups));

            fpr_local = zeros(Nsegs,1);
            for i=1:Nsegs
                fpr_local(i) = sum(wake_ups(reps/Nsegs*(i-1)+1:reps/Nsegs*i))/(reps/Nsegs);
            end
    
            fpr_results(level,m,trial*Nsegs+1:((trial+1)*Nsegs)) = fpr_local;
        end
        
        
    end

end

%% Fix scaling error with the tx_input files
% tx_data = read_float_binary(fullfile(root,'100Hz_fb_00101000_packet_113reps_single_tone_800mV_10dm_fs=100e3_scope_tx_input_0.bin'));
% updated_data = 10 * tx_data;
% figure();
% plot(updated_data);
% write_float_binary(updated_data, fullfile(root,'100Hz_fb_00101000_packet_113reps_single_tone_800mV_10dm_fs=100e3_scope_tx_input_0.bin'));

%% TX Power
% ohms = 0.5;
% tx_input_250mV = read_float_binary(fullfile(root,"100Hz_fb_00101000_packet_113reps_single_tone_250mV_10dm_fs=100e3_scope_tx_input_0.bin"));
% tx_250mV_on = tx_input_250mV(2.8e4:3.4e4);
% tx_250mV_power = rms(tx_250mV_on)^2/ohms;
% disp(tx_250mV_power);
% 
% tx_input_500mV = read_float_binary(fullfile(root,"100Hz_fb_00101000_packet_113reps_single_tone_500mV_10dm_fs=100e3_scope_tx_input_0.bin"));
% tx_500mV_on = tx_input_500mV(1.4e4:2.2e4);
% tx_500mV_power = rms(tx_500mV_on)^2/ohms;
% disp(tx_500mV_power);
% 
% tx_input_800mV = read_float_binary(fullfile(root,"100Hz_fb_00101000_packet_113reps_single_tone_800mV_10dm_fs=100e3_scope_tx_input_0.bin"));
% tx_800mV_on = tx_input_800mV(2.9e4:3.7e4);
% tx_800mV_power = rms(tx_800mV_on)^2/ohms;
% disp(tx_800mV_power);

% tx_power = [sprintf("%0.0fW",tx_250mV_power), sprintf("%0.0fW",tx_500mV_power), sprintf("%0.0fW",tx_800mV_power)];

tx_power = ["10W", "20W", "30W"]; %["20.4W"];

% figure(1);
% plot(tx_250mV_on);
% ax1 = gca;



BER_min = 1/reps;
tx_power = ["10W", "20W", "30W"]; %["20.4W"];





median_wus = median(1-fnr_results,3,'omitnan').';
third_q_wus = prctile(1-fnr_results,75,3).';
first_q_wus = prctile(1-fnr_results,25,3).';

fnr_results(1,5:end,:) = NaN;
fnr_results(2,6:end,:) = NaN;

ert_results = 1./(1-fnr_results)-1;

median_fnr = median(fnr_results,3,'omitnan').';
third_q_fnr = prctile(fnr_results,75,3).';
first_q_fnr = prctile(fnr_results,25,3).';

median_ert = median(ert_results,3,'omitnan').';
third_q_ert = prctile(ert_results,75,3).';
first_q_ert = prctile(ert_results,25,3).';



%% Wakeup Success
figure(1);
errorbar(meters_range/10,median_wus,median_wus-first_q_wus,third_q_wus-median_wus,'LineWidth',2);
legend(tx_power, "location","best");
xlabel("Range (m)");
ylabel("Waekup Success Rate");
% ylim([1e-3, 1e-2]);
xlim([1 20]);
xticks(meters_range/10);
ax = gca;
ax.FontSize = 14;
% ax.YAxis.Scale = "log";
%ax.FontWeight = "Bold";
grid on;

%% Expected Retransmissions 
% Distance vs FNR for each power level
figure(2);
errorbar(meters_range/10,median_ert,median_ert-first_q_ert,third_q_ert-median_ert,'LineWidth',2);
%errorbar(meters_range/10,median_wus,median_wus-first_q_wus,third_q_wus-median_wus,'LineWidth',2);
% ax.YAxis.
% errorbar(meters_range/10,median_fpr,std_fpr);
%semilogy(short_range_median_fpr_results{1}.keys()/10, short_range_median_fpr_results{1}.values(), ...
%    "LineWidth", 2);
legend(tx_power, "location","best");
xlabel("Range (m)");
ylabel("Expected Retransmissions");
% ylim([1e-3, 1e-2]);
xlim([1 20]);
xticks(meters_range/10);
ax = gca;
ax.FontSize = 14;
% ax.YAxis.Scale = "log";
%ax.FontWeight = "Bold";
grid on;
% grid minor;

function r=ert(x)
    r=1./(1-x)-1;
end

%% Plot Median FPR Results

BER_min = 1/reps;
tx_power = ["10W", "20W", "30W"]; %["20.4W"];

fpr_results(1,5:end,:) = NaN;
fpr_results(2,6:end,:) = NaN;
% fpr_results(3)

median_fpr = median(fpr_results,3,'omitnan').';
third_q_fpr = prctile(fpr_results,75,3).';
first_q_fpr = prctile(fpr_results,25,3).';
std_fpr = std(fpr_results,0,3,'omitnan').';

% median_fpr = clip(median_fpr,BER_min,1);
% third_q_fpr = clip(third_q_fpr,BER_min,1);
% first_q_fpr = clip(first_q_fpr,BER_min,1);
% 


% Distance vs FPR for each power level
figure(3);
errorbar(meters_range/10,median_fpr,median_fpr-first_q_fpr,third_q_fpr-median_fpr,'LineWidth',2);

% ax.YAxis.
% errorbar(meters_range/10,median_fpr,std_fpr);
%semilogy(short_range_median_fpr_results{1}.keys()/10, short_range_median_fpr_results{1}.values(), ...
%    "LineWidth", 2);
legend(tx_power, "location","best");
xlabel("Range (m)");
ylabel("False Positive Wake-Up Rate");
% ylim([1e-3, 1e-2]);
xlim([0 21]);
xticks(meters_range/10);
ax = gca;
ax.FontSize = 14;
%ax.YAxis.Scale = "log";
%ax.FontWeight = "Bold";
grid on;
% grid minor;

%% Functions

function med = median_result(results, meter, reps)
   med = median(cell2mat(results(meter)));
   if med == 0; med = 1/reps; end
end

%Function to calculate FPR from prbs without wake-up seq and FNR from repeated wake-up packets experiments using downlink and wake-up signals
function [FPR, FNR, wake_ups] = calculate_fpr_fnr(downlink, wake_up_signal, pie_encoded_bits, packet_len, reps, spb)
    
    %threshold downlink
    downlink(downlink > 1.8/2) = 1;
    downlink(downlink < 1.8/2) = 0;
    
    %threshold wake_up_signal
    wake_up_signal(wake_up_signal > 1.8/2) = 1;
    wake_up_signal(wake_up_signal < 1.8/2) = 0;
    
    %find window of downlink signal
    corr = xcorr(downlink*2-1,pie_encoded_bits*2-1)/length(downlink);
    corr = corr(length(downlink):end-length(pie_encoded_bits));
    [m,mi] = max(corr);
    %if mi+length(pie_encoded_bits)-1 > length(downlink)
    %    index_arr = 2.4e4:length(downlink); %edge case for fnr 250mV 65dm trial 0 - need a better solution
    %else
    index_arr = mi:mi+length(pie_encoded_bits)-1;
    %end

    wake_up_signal = wake_up_signal(index_arr);

   wake_ups = zeros(reps,1);
   num_wake_ups =0;
   % 
   % figure(10);
   % plot(downlink);
   % hold on;
   % plot(wake_up_signal);
   % hold off;

   c=1;
    for i = [1:packet_len*spb:reps*packet_len*spb]+spb/2
        
        endex = min(i+(packet_len)*spb,length(wake_up_signal));
        num_rising_edges = sum(diff(wake_up_signal(i:endex)) > 0);

        if num_rising_edges > 0
            num_wake_ups = num_wake_ups + 1;
            wake_ups(c) = 1;
        else
            test=0;
        end
        c = c+1;

    end
    
    FPR = num_wake_ups /reps;
    FNR = 1 - FPR;

end
%% read raw simulation signal from SPICE

% LTdata = importdata("../../spice/harvesting/ltspice_export_waveform.txt").data;
% t = LTdata(:, 1);
% signal = LTdata(:, 2);
% 
% plot(t, signal);
% xlabel("Time (ms)");
% ylabel("Amp");

%downsample_factor = floor((1/(t(end)/length(t))/fs));
%usrp_signal = downsample(signal,downsample_factor)/3;
%usrp_t = [0:1/fs:(length(usrp_signal)-1)/fs].';

%% read manchester decoded bits and wakeup signal from usrp rx, and plot signal with expected signal

%fs_sig = 50e3;
% downlink = read_float_binary(fullfile(root,"100Hz_fb_00101000_packet_113reps_single_tone_250mV_fs=100e3_scope_dwnlk_0.bin"));
% dbits = read_float_binary(fullfile(root,"100Hz_fb_900_prbs_PIE_single_tone_250mV_2m_fs=100e3_scope_dbits_0.bin"));
% q1reg = read_float_binary(fullfile(root,"100Hz_fb_900_prbs_PIE_single_tone_250mV_2m_fs=100e3_scope_q1reg_0.bin"));
% 
% dbits(dbits > 1.8/2) = 1;
% dbits(dbits < 1.8/2) = 0;
% 
% q1reg(q1reg > 1.8/2) = 1;
% q1reg(q1reg < 1.8/2) = 0;
% % txfmr = read_float_binary('../../rx_outputs/River_AS_02-23-24/piesingle0,5m0_txfmrd.bin');
% 
% % threshold
% downlink(downlink > 1.8/2) = 1;
% downlink(downlink < 1.8/2) = 0;
% 
% %find window of downlink signal
% corr = xcorr(downlink*2-1,pie_encoded_bits*2-1)/length(downlink);
% corr = corr(length(downlink):end);
% [m,mi] = max(corr);
% index_arr = mi:mi+length(pie_encoded_bits)-1;
% 
% downlink = downlink(index_arr);
% dbits = dbits(index_arr);
% q1reg = q1reg(index_arr);
% 
% downlink = [0; downlink];
% pie_encoded_bits = [0; pie_encoded_bits];
% 
% figure(1);
% subplot(3,1,1);
% plot(downlink);
% ax1 = gca;
% 
% subplot(3,1,2);
% plot(dbits);
% ax2 = gca;
% 
% subplot(3,1,3);
% plot(q1reg);
% ax3 = gca;
% 
% linkaxes([ax1 ax2 ax3],'x');
% % plot(pie_encoded_bits);
% % plot(dbits);
% % plot(q1reg);
% % legend("Downlink Signal","Q1");
% % plot(corr);
% 
% %add some glitching
% 
% %% Calculate Pulse Widths and Display Histogram
% pulses = pulsewidth(downlink, fs);
% pulses_ideal = pulsewidth(pie_encoded_bits,fs);
% 
% %Histogram
% edges = linspace(0, bit_period, 50); %0:bit_period/(11-1):bit_period
% 
% figure(2);
% histogram(pulses, edges);
% ax = gca;
% % hold on;
% % histogram(ax,pulses_ideal,edges);
% hold on;
% xline(duty_cycle/fb,'--','Color','red','LineWidth',2);
% xline((1-duty_cycle)/fb,'--','Color','red','LineWidth',2);
% 
% pulses_gt_period = nnz(pulses >= bit_period); %pulses greater than period
% 
% %% Find glitches in signal
% 
% % falling_edges_per_window = dictionary();
% % rising_edges_per_window = dictionary();
% % glitches_window_i = [];
% % 
% % % Look at each bit interval (1ms period) in the signal
% % for window_i = [1:spb:length(downlink)-spb-1]
% % 
% %     num_rising_edges = nnz(diff(downlink(window_i:window_i+spb-1)) == 1);
% %     num_falling_edges = nnz(diff(downlink(window_i:window_i+spb-1)) == -1);
% % 
% %     rising_edges_per_window(window_i) = num_rising_edges;
% %     falling_edges_per_window(window_i) = num_falling_edges;
% % 
% %     if num_rising_edges ~= 1 || num_falling_edges > 2 % glitches when there are extra pulses
% %         glitches_window_i = cat(2, glitches_window_i, [window_i]);
% %     end
% % 
% % end
% % 
% % if ~isempty(glitches_window_i)
% %     
% %     i = 1; %change the index to plot a specific glitch
% %     plot(t_bits(glitches_window_i(i):glitches_window_i(i)+spb)/1e-3, downlink(glitches_window_i(i):glitches_window_i(i)+spb));
% %     xlabel("Time (ms)");
% %     ylabel("Amp");
% %     ylim([-1 2]);
% % end
% % 
% % figure;
% % plot(downlink);
% % hold on;
% % plot(pie_encoded_bits);
% % plot(glitches_window_i,0.5*ones(1,length(glitches_window_i)),'x');
% % 
% % 
% % %% View Signal
% % figure;
% % plot(t_bits/1e-3, pie_encoded_bits);
% % xlabel("Time (ms)");
% % ylabel("Amp");
% % ylim([-1 2]);
% % 
% % %% Group pulses based on pulse width range
% % step = bit_period/10;
% % pulses_in_range = struct('range', [0:step:bit_period], 'pulses', []);
% % 
% % for lower_bound = pulses_in_range.range
% % 
% %     if lower_bound == bit_period
% %         pulses_in_range.pulses = cat(2, pulses_in_range.pulses, [nnz(pulses >= lower_bound)]);
% %     else
% %         pulses_in_range.pulses = cat(2, pulses_in_range.pulses, [nnz(pulses >= lower_bound & pulses < lower_bound+step)]);
% %     end
% %     
% % end
% 
% %% compute BER
% decoded_bits = pulses > 0.6/fb;
% BER_pw = sum(decoded_bits ~= bits(1:length(decoded_bits)))/length(bits)
% 
% falling_edges = (downlink(1:end-1) - downlink(2:end)) > 0;
% edge_decoded_bits = dbits(falling_edges);
% BER_edge = sum(edge_decoded_bits ~= bits(1:length(edge_decoded_bits)))/length(bits)
% 
% figure(3);
% 
% subplot(3,1,1);
% plot(downlink);
% title("Downlink Output");
% ax1 = gca;
% 
% subplot(3,1,2);
% plot(dbits);
% title("Decoded Bits");
% ax2 = gca;
% 
% subplot(3,1,3);
% plot(repelem(edge_decoded_bits ~= bits(1:length(edge_decoded_bits)),spb));
% title("Error Locations");
% ax3 = gca;
% 
% linkaxes([ax1 ax2 ax3],'x');
% 
% % 
% % figure;
% % hold on;
% % plot(decoded_signal);
% % plot(pie_encoded_bits);
% % plot([1:length(decoded_bits)]*spb,decoded_bits ~= bits(2:end));

% %%
% 
% packet = [0 1 1 1 0 0 1 0]; %8-bit packet %[0 0 1 0 1 0 0 0]; %3-bit packet
% reps = 113;
% seq = repmat(packet, 1, reps);
% bits = seq.';
% duty_cycle = 0.75;
% pie_encoded_bits_1 = [generate_pie(bits, spb, duty_cycle)]; %PIE
% 
% packet_length = 8;
% reps = 113;
% order = 10;
% nbits = packet_length*reps;
% seq = prbs(order, nbits);
% bits = seq.';
% duty_cycle = 0.75;
% pie_encoded_bits_2 = [generate_pie(bits, spb, duty_cycle)]; %PIE
% 
% figure(5);
% 
% subplot(3,1,1);
% plot(pie_encoded_bits_1);
% title("PIE wake-up");
% ax1 = gca;
% 
% subplot(3,1,2);
% plot(pie_encoded_bits_2);
% title("PIE random");
% ax2 = gca;
% 
% linkaxes([ax1 ax2],'x');
