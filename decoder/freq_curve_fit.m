Vs = 1.8;

R1 = 30e6;
R2 = 30e6;
R3 = 30e6;
C = 135e-12;
Vh = 17e-3;

params0(1) = C*1e9;
params0(2) = Vh*10;

% params0 = params_opt;

Vtp = Vs*R2*(R1+R3)/(R1*R3+R2*(R1+R3));
Vtn = Vs*R2*R3/(R2*R3+R1*(R2+R3));

lktab = readmatrix("../../../lookup_v2.csv");
lktab = lktab(30:end,:);

R = lktab(:,1)*1e3;
fmeas = lktab(:,2);

f = 1./(2*R*C.*log((Vtp+Vh)./(Vtn-Vh)));

func = @(p) 1./(2*R*p(1)/1e9.*log((Vtp+p(2)/10)./(Vtn-p(2)/10)));
func_min = @(params) func(params)-fmeas;

options = optimoptions('lsqnonlin','FunctionTolerance',1e-15,'StepTolerance',1e-15,'MaxFunctionEvaluations',10e3,'Display','iter');
[params_opt,~,~,~,~] = lsqnonlin(func_min,params0,[0 0]',[],options);

figure;
subplot(2,1,1);
plot(R/1e3,func(params_opt)/1e3);
hold on;
plot(R/1e3,fmeas/1e3);
xlabel("Resistance (kOhm)");
ylabel("Frequency (kHz)");

subplot(2,1,2);
plot(R/1e3,(func(params_opt)-fmeas)./fmeas*100);
