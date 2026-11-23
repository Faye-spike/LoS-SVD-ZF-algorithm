%% 单基站 OTFS 下行仿真：比较五种预编码方案的加权和速率
clc;clear;
% 按入口脚本的位置加载项目函数。
addpath(fullfile(fileparts(mfilename('fullpath')), 'functions'));
tic;
K = 1; % 基站数，当前信道生成器采用单基站模型
N_R = 4; % 每个用户的接收天线数
N_T = 16; % 基站的发射天线数
M = 8; % OTFS 时延维的格点数
N = 8; % OTFS 多普勒维的格点数
I = 4; % 每个基站服务的用户数
P_TR = randi([1,5],1,I); % 每个用户独立抽取 1 至 5 条路径，路径数在所有蒙特卡洛样本间固定
R = N_R*M*N; % 每个用户的接收维度，也是其信道矩阵的行数
epsilon = 1e-3; % WMMSE 相邻两轮加权和速率的相对变化阈值
sigma2 = 1; % 每个接收维度的噪声功率
Mont=5; % 蒙特卡洛信道实现次数
d = R; % WMMSE 分配给每个用户的数据流数
alpha1 = ones(I,K); % 加权和速率的用户权重，此处均为 1
max_iter = 100; % WMMSE 外层迭代次数上限

% 在 N 维上使用归一化 DFT，在 M 维上使用单位矩阵。
F_N = 1/sqrt(N)*dftmtx(N);
F = kron(F_N,eye(M));
Snr = 0:5:25; % 信噪比扫描范围，单位为 dB

for mont=1:Mont
    [H,theta_TR_D_1,h_TR_1] = channel_generation(N_R,N_T,P_TR,F);

    % 两类 SVD 方案均为每个用户保留 M*N 个模式，同一次信道实现供所有信噪比点共用。
    streams = M*N;
    approxModel.basis = zeros(N_T*streams,I*streams);
    approxModel.gains = zeros(I*streams,1);
    perfectModel.basis = zeros(size(H{1},2),I*streams);
    perfectModel.gains = zeros(I*streams,1);
    for i = 1:I
        cols = (i-1)*streams + (1:streams);

        % 用首径的发射阵列响应构造近似基，首径增益的幅值决定各模式的奇异值。
        approxModel.basis(:,cols) = 1/sqrt(N_T)*kron(steeringVec(N_T,theta_TR_D_1(i)),F);
        approxModel.gains(cols) = abs(h_TR_1(i))*sqrt(N_R*N_T);

        % 对完整信道取最大的 M*N 个奇异值和对应的右奇异向量。
        [~,S,V] = svd(H{i,1,1});
        gains = diag(S);
        perfectModel.basis(:,cols) = V(:,1:streams);
        perfectModel.gains(cols) = gains(1:streams);
    end
    approxModel.gram = approxModel.basis'*approxModel.basis;
    perfectModel.gram = perfectModel.basis'*perfectModel.basis;

    for s = 1:numel(Snr)
        P = 10^(Snr(s)/10); % 当前噪声功率为 1，对应的线性发射功率预算
        rate_SMMSE(s) = wmmse_rate(H,P,sigma2,alpha1,d,epsilon,max_iter);
        rate_SVD_my(s) = svd_approx_equal_rate(H,approxModel,P,sigma2,alpha1);
        rate_SVD_tradition(s) = svd_perfect_equal_rate(H,perfectModel,P,sigma2,alpha1);
        rate_SVD_my_ww(s) = svd_approx_waterfill_rate(H,approxModel,P,sigma2,alpha1);
        rate_SVD_tradition_wp(s) = svd_perfect_waterfill_rate(H,perfectModel,P,sigma2,alpha1);
    end
    % 每行对应一次信道实现，各列为不同信噪比下按 M*N 归一化的加权和速率。
    Rate_SMMSE(mont,:)=rate_SMMSE/(M*N); 
    Rate_SVD_my(mont,:)=rate_SVD_my/(M*N);
    Rate_SVD_my_ww(mont,:)=rate_SVD_my_ww/(M*N);
    Rate_SVD_traditional(mont, :) = rate_SVD_tradition/(M*N);
    Rate_SVD_traditional_wp(mont, :) = rate_SVD_tradition_wp/(M*N);
end

% 沿蒙特卡洛样本维度取平均，每条曲线对应图例中的一种预编码方案。
plot(Snr, mean(Rate_SMMSE,1), 'r*-', 'LineWidth', 1.5);
hold on;
plot(Snr, mean(Rate_SVD_my,1),'Color', [0.5 0.5 0],'Marker', 's','LineStyle', '--', 'LineWidth', 1.5);
hold on;
plot(Snr, mean(Rate_SVD_my_ww,1), 'kd--', 'LineWidth', 1.5);
hold on;
plot(Snr,mean(Rate_SVD_traditional,1),'Color',[0 0.4470 0.7410],'Marker', 's','LineStyle', '-','LineWidth', 1.5);
hold on;
plot(Snr,mean(Rate_SVD_traditional_wp,1),'md-','LineWidth',1.5);
hold on;
xlabel('SNR(dB)')
ylabel('WSR(bit/s/Hz)')
grid on
set(gca,'GridLineStyle',':','GridColor','k','GridAlpha',1)
h=legend('WMMSE-Perfect CSI','SVD-Approximate CSI, Equal Power','SVD-Approximate CSI, Water-Filling','SVD-Perfect CSI, Equal Power','SVD-Perfect CSI, Water-Filling');
hold on
set(h,'Interpreter','latex')
toc
