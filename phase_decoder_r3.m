addpath("./utils");
addpath("./decoder");

fs = 192e3;
fs_i = 20e3;
fc = 18.5e3;

f0 = 500;
f1 = 900;
% r1 = decode_f2r(f1,"lookup","freq");
% ahat = 1/(464*9.726e6);

Ract = [1.332 0.850 1 0.694]*1e6;
global fcal rcal;

fcal = [812.5 448.67];
rcal = [0.694 1.332]*1e6;

% sact = [1.5864 1.9281 7.2181 11.5964];
% Fact = decode_f2r(Ract,"analytic","res");

c = 1500;

ranges = [1 2 5 10 15 20];
errors = zeros(length(ranges),2);
errors_fq = zeros(length(ranges),2);
errors_tq = zeros(length(ranges),2);
errors_s = zeros(length(ranges),2);
errors_s_fq = zeros(length(ranges),2);
errors_s_tq = zeros(length(ranges),2);

type='m';

trial = 0;
ext = ".dat";
scope_ext = "_fs=100e3_scope_osc_out";
folder = "data";
rx_froot = "rx_doppler_board2_moving_iso_%dm_2m_depth_250mV_muxclk=2s_aub_multichannel";

for i=1:length(ranges)
    rx_filename = sprintf(rx_froot,ranges(i));
    rx_filepath = sprintf('%s/%s_%d%s',folder,rx_filename,trial,ext);
    
    %% generate ideal signal
    % 
    ideal_rx = read_float_binary(sprintf("%s/rx_%dm_board2_moving_fs=20e3_scope_osc_out_0.bin",folder,ranges(i)));
    
    %%
    
    if strcmp(type,'r')
        sig = read_complex_binary(rx_filepath);
        rx = real(sig) - imag(sig);
        rx = rx(1e4:end);
        t = [0:length(rx)-1].'/fs;
    elseif strcmp(type,'m')
        fid = fopen(rx_filepath,'r');
        sig = fread(fid,[8 5760000],'float32').';
    %     rx = sig(:,4);   
        rx = sum(sig,2);
        [rxenv,~] = envelope(rx);
        rx = rx(rxenv > 0.2*max(rx));
        t = [0:length(rx)-1].'/fs;
    else
        Nfft = fs;
        w = 2*pi*[0:fs/Nfft:fs-1];
        G = 0.1;
        chan_f = G*(1 + 0.9*exp(-1j*(w*0e-6)));
        chan_t = real(ifft(chan_f,Nfft));
        
        fb = 500;
        t = [0:1/fs:10].';
        tx = sin(2*pi*fc*t);
        bscr = conv(chan_t,tx);
        bsc = bscr.*square(2*pi*fb*[0:length(bscr)-1].'/fs);
        bsc_rx = conv(bsc,chan_t);
        rx = sin(2*pi*fc*[0:length(bsc_rx)-1].'/fs)+bsc_rx;
        t = [0:length(rx)-1].'/fs;
    end
    
    [freqcomp,freqr,freql,freq_meas] = fftdecode(rx,fs,ideal_rx,fs_i,fc);
    % freq_ideal = circshift(freq_ideal,starti);
    res_ideal = gen_ideal_res(freq_meas,Ract,0);
    res_meas = decode_f2r_2(fcal,rcal,freq_meas);
%     s_ideal = gen_ideal_sens(freq_meas,sact,ahat);
% 
    res_comp = decode_f2r_2(fcal,rcal,freqcomp);
    res_r = decode_f2r_2(fcal,rcal,freqr);
    res_l = decode_f2r_2(fcal,rcal,freql);

    s_ideal = decode_temp(res_ideal);
    s_comp = decode_temp(res_comp);
    s_r = decode_temp(res_r);
    s_l = decode_temp(res_l);

%     [r_comp,s_comp] = decode_f2s(freqcomp,"temp",ahat);
%     [r_r,s_r] = decode_f2s(freqr,"temp",ahat);
%     [r_l,s_l] = decode_f2s(freql,"temp",ahat);
    
    rmse_comp = median(abs(res_ideal-res_comp)./res_ideal*100);
    rmse_r = median(abs(res_ideal-res_r)./res_ideal*100);
    rmse_l = median(abs(res_ideal-res_l)./res_ideal*100);
    rmse_uncomp = mean([rmse_r rmse_l]);

    comp_errs = abs(res_ideal-res_comp)./res_ideal*100;
    uncomp_errs = mean([abs(res_ideal-res_r)./res_ideal*100 abs(res_ideal-res_l)./res_ideal*100]);

    comp_errs_s = abs(s_ideal-s_comp);
    uncomp_errs_s = mean([abs(s_ideal-s_r) abs(s_ideal-s_l)]);

    rmse_s_comp = median(abs(s_ideal-s_comp));
    rmse_s_r = median(abs(s_ideal-s_r));
    rmse_s_l = median(abs(s_ideal-s_l));
    rmse_s_uncomp = mean([rmse_s_r rmse_s_l]);

%     rmse_comp = median(abs(freq_meas-freqcomp));
%     rmse_r = median(abs(freq_meas-freqr));
%     rmse_l = median(abs(freq_meas-freql));
%     rmse_uncomp = mean(rmse_r,rmse_l);%sqrt(rmse_r^2+rmse_l^2);
    
    errors(i,1) = median(comp_errs);
    errors_fq(i,1) = quantile(comp_errs,0.25);
    errors_tq(i,1) = quantile(comp_errs,0.75);

    errors(i,2) = median(uncomp_errs);
    errors_fq(i,2) = quantile(uncomp_errs,0.25);
    errors_tq(i,2) = quantile(uncomp_errs,0.75);

    errors_s(i,1) = median(comp_errs_s);
    errors_s_fq(i,1) = quantile(comp_errs_s,0.25);
    errors_s_tq(i,1) = quantile(comp_errs_s,0.75);

    errors_s(i,2) = median(uncomp_errs_s);
    errors_s_fq(i,2) = quantile(uncomp_errs_s,0.25);
    errors_s_tq(i,2) = quantile(uncomp_errs_s,0.75);
    % tvec = [0:length(freqcomp)-1] * wlen_t;
%     figure(1);
%     plot(freq_meas);
%     hold on;
%     plot(freqcomp);
%     plot(freqr);
%     plot(freql);
%     legend("Ideal","Comp","Left","Right");

end

% figure(1);
% plot(res_ideal);
% hold on;
% plot(res_meas);
% plot(res_comp);
% plot(res_r);
% legend("Ideal Ground Truth Resistance", "Measured Scope Resistance", "Compensated Resistance","Uncompensated");
% 
% 
% figure(2);
% plot(freq_meas);
% hold on;
% % plot(freqcomp);
% legend("Scope Measured","Compensated");


%%
figure(3);
labels = arrayfun(@num2str,ranges,'UniformOutput',0);
X = categorical(labels);
X = reordercats(X,labels);
b = bar(X, errors);
legend("AUB","Baseline");
ylabel("Median Percent Resistance Error (%)");
xlabel("Range (m)");
hold on;
% Calculate the number of groups and number of bars in each group
[ngroups,nbars] = size(errors);
% Get the x coordinate of the bars
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end
% Plot the errorbars
errorbar(x',errors,errors-errors_fq,errors+errors_tq,'k','linestyle','none');
hold off
yscale log
grid on;
grid minor;
% text(b(1).XEndPoints,zeros(2,1),repelem(["Comp"],2),"HorizontalAlignment","Center","VerticalAlignment","Top");

figure(4);
labels = arrayfun(@num2str,ranges,'UniformOutput',0);
X = categorical(labels);
X = reordercats(X,labels);
b = bar(X, errors_s);
legend("AUB","Baseline");
ylabel("Median Absolute Temperature Error (deg C)");
xlabel("Range (m)");
grid on;
grid minor;


hold on;
% Calculate the number of groups and number of bars in each group
[ngroups,nbars] = size(errors_s);
% Get the x coordinate of the bars
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end
% Plot the errorbars
errorbar(x',errors_s,errors_s-errors_s_fq,errors_s+errors_s_tq,'k','linestyle','none');
hold off

yscale log;

function res_ideal = gen_ideal_res(freq_meas,Ract,ahat)
    global fcal rcal;
    res_ideal = zeros(size(freq_meas));

%     res_meas = decode_f2r(freq_meas,"analytic","freq",ahat);
    res_meas = decode_f2r_2(fcal,rcal,freq_meas);
    
    win = 0.1;

    r1i = (res_meas > Ract(1)*(1-win/8)) .* (res_meas < Ract(1)*(1+win/8));
    r2i = (res_meas > Ract(2)*(1-win/2)) .* (res_meas < Ract(2)*(1+win/2));
    r3i = (res_meas > Ract(3)*(1-win)) .* (res_meas < Ract(3)*(1+win));
    r4i = (res_meas > Ract(4)*(1-win/2)) .* (res_meas < Ract(4)*(1+win/2));

    res_ideal(logical(r2i)) = Ract(2);
    res_ideal(logical(r3i)) = Ract(3);
    res_ideal(logical(r4i)) = Ract(4);
    res_ideal(logical(r1i)) = Ract(1);

end

function sens_ideal = gen_ideal_sens(freq_meas,sact,ahat)
    global fcal rcal;
    sens_ideal = zeros(size(freq_meas));

    res = decode_f2r_2(fcal,rcal,freq_meas);
    s_meas = decode_temp(res);

%         [~,s_meas] = decode_f2s(freq_meas,"temp",ahat);
    
    win = 0.3;

    r1i = (s_meas > sact(1)*(1-win/2)) .* (s_meas < sact(1)*(1+win/2));
    r2i = (s_meas > sact(2)*(1-win/2)) .* (s_meas < sact(2)*(1+win/2));
    r3i = (s_meas > sact(3)*(1-win)) .* (s_meas < sact(3)*(1+win));
    r4i = (s_meas > sact(4)*(1-win/2)) .* (s_meas < sact(4)*(1+win/2));

    sens_ideal(logical(r1i)) = sact(1);
    sens_ideal(logical(r2i)) = sact(2);
    sens_ideal(logical(r3i)) = sact(3);
    sens_ideal(logical(r4i)) = sact(4);
end

function [fcomp,fr,fl,fideal] = fftdecode(rx,fs,ideal_rx,fs_i,fc)
    dfac = 20;
    dc = decimate(exp(-1j*2*pi*fc*[0:length(rx)-1].'/fs).*rx,dfac,"fir");
%     t = downsample(t,dfac);
    fs = fs / dfac;
    
    order = 300;
    
    sensfilt_freqs = [-fs/2 300 400 1000 1100 fs/2]/(fs/2);
    sensfilt_amps = [0 0 1 1 0 0];
    
    sensfiltr = cfirpm(order,sensfilt_freqs,sensfilt_amps);
    sensfiltl = cfirpm(order,-flip(sensfilt_freqs),flip(sensfilt_amps));
    
    notchf = firpm(100,[0 1 400 fs/2]/(fs/2),[0 0 1 1]);
    
    rxr = fftfilt(sensfiltr,dc);
    rxl = fftfilt(sensfiltl,dc);
    
    rxrn = fftfilt(notchf,rxr);
    rxln = fftfilt(notchf,rxl);
    
    track = rxrn.*conj(rxln);
    
    wfunc = @blackmanharris;
    wlen_t = 300e-3;
    overlap = 0.9;
    wlen = round(wlen_t*fs);
    wleni = round(wlen_t*fs_i);
%     mode = "lookup";
    Nfft = 10*wlen;
    Nffti = 10*wleni;
    
    trackf = stft(track,fs,"Window",wfunc(wlen),"OverlapLength",round(overlap*wlen),"FFTLength",Nfft,"FrequencyRange","twosided");
    trackrf = stft(rxrn,fs,"Window",wfunc(wlen),"OverlapLength",round(overlap*wlen),"FFTLength",Nfft,"FrequencyRange","twosided");
    tracklf = stft(rxln,fs,"Window",wfunc(wlen),"OverlapLength",round(overlap*wlen),"FFTLength",Nfft,"FrequencyRange","twosided");
    track_ideal = stft(ideal_rx-mean(ideal_rx),fs_i,"Window",wfunc(wleni),"OverlapLength",round(overlap*wleni),"FFTLength",Nffti,"FrequencyRange","onesided");
    track_ideal = track_ideal(:,1:size(trackf,2));

    
    
    freqcomp = zeros(size(trackf,2),1);
    freqr = zeros(size(trackf,2),1);
    freql = zeros(size(trackf,2),1);
    freq_ideal = zeros(size(track_ideal,2),1);
    
    for i=1:size(trackf,2)
        [~,index] = max(trackf(:,i));
        [~,indexr] = max(trackrf(:,i));
        [~,indexl] = max(tracklf(:,i));
        [~,indexi] = max(track_ideal(:,i));
    
        freqcomp(i) = (index-1)*fs/Nfft/2;
        freqr(i) = (indexr-1)*fs/Nfft;
        freql(i) = fs-(indexl-1)*fs/Nfft;
        freq_ideal(i) = (indexi-1)*fs_i/Nffti;
    end
    
    % compensated cov
    [corr,lags] = xcov(freqcomp,freq_ideal);
%     corr = corr(-lags(1)+1:end);
    [~,mi] = max(corr);
    starti = lags(mi);
    
    if starti < 0
        fideal = freq_ideal(-starti+1:end);
        fr = freqr(1:length(fideal));
        fl = freql(1:length(fideal));
        fcomp = freqcomp(1:length(fideal));
    else
        fcomp = freqcomp(starti+1:end);
        fr = freqr(starti+1:end);
        fl = freql(starti+1:end);
        fideal = freq_ideal(1:length(fcomp));
    end
end
