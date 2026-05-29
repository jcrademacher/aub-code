filearr = [ %"manchchirp1m0_vs.txt";
"manchchirp1m0";
%"manchchirp3m0_vs.txt";
"manchchirp3m0";
%"manchchirp5m0_vs.txt";
"manchchirp5m0";
%"manchsingle1m0_vs.txt";
"manchsingle1m0";
%"manchsingle3m0_vs.txt";
"manchsingle3m0";
%"manchsingle5m0_vs.txt";
"manchsingle5m0";
%"piechirp1m0_vs.txt";
"piechirp1m0";
%"piechirp3m0_vs.txt";
"piechirp3m0";
%"piechirp5m0_vs.txt";
"piechirp5m0";
%"piesingle1m0_vs.txt";
"piesingle1m0";
%"piesingle3m0_vs.txt";
"piesingle3m0";
%"piesingle5m0_vs.txt";
"piesingle5m0"
            ];

root = "../../../rx_outputs/River_AS_02-12-24/";
addpath("../");


for n=1:length(filearr)
    disp(strcat("Processing ", filearr(n)));
    filepath = strcat(root,filearr(n),".csv");

    sig = 10*readmatrix(filepath); % ONLY x10 BECAUSE OF SCOPE ATTENUATION

    for i=1:size(sig,2)
        if i==1
            chname = "txfmrd";
        elseif i==2
            chname = "compout";
        elseif i==3
            chname = "rectout";
        elseif i==4
            chname = "rectref";
        end
        filepath_w = strcat(root,filearr(n),".bin");
        write_float_binary(sig(:,i),filepath_w);
    end
end