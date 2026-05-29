
start = 500e3;
step = wlen/10;
span = 4*wlen;

freqs = zeros(span/step,1);
pows = zeros(span/step,1);
indices = zeros(span/step,1);

%test = rx(start:end);
test = (0.01*[square(2*pi*500*[0:wlen-1]/fs) ...
        square(2*pi*750*[wlen:2*wlen-1]/fs) ...
        square(2*pi*1000*[2*wlen:3*wlen-1]/fs) ...
        square(2*pi*1250*[3*wlen:4*wlen-1]/fs)]+1).*cos(2*pi*18.5e3*[0:4*wlen-1]/fs);
test = test.';

for i=0:span/step-1
    index = i*step+1;
    [cfreq, ~, subcfreq, subcpow] = subcarrier_extract(test(index:index+wlen-1),wfunc(wlen),fs,"pb");
    
    indices(i+1) = index;
    freqs(i+1) = subcfreq;
    pows(i+1) = subcpow;
end

subplot(3,1,1);
plot(rxdf(start:start+span-1));
ax1 = gca;

subplot(3,1,2);
plot(indices,pows);
ax2 = gca;

subplot(3,1,3);
plot(indices,freqs);
ax3 = gca;

linkaxes([ax1 ax2 ax3],'x');



