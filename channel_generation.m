function [H,theta_TR_D_1,h_TR_1] = channel_generation(N_R,N_T,P_TR,F)
% 生成一次单基站下行 OTFS 多径信道。P_TR(i) 为用户 i 的路径数。
% F 是 M*N 阶变换矩阵，H{i,1,1} 的大小为 (N_R*M*N) × (N_T*M*N)。
% theta_TR_D_1 和 h_TR_1 分别保存各用户首径的发射方向参数和复增益。
    I = numel(P_TR);
    gridSize = size(F,1);
    omega = exp(1j*2*pi/gridSize);
    H = cell(I,1);
    theta_TR_D_1 = zeros(1,I);
    h_TR_1 = zeros(1,I);

    for i = 1:I
        Delay_TR = randi([0,10],1,P_TR(i)); % 以采样间隔计的整数时延，从 0 至 10 均匀抽取
        Doppler_TR = 2*rand(1,P_TR(i)); % 在 0 至 2 之间均匀抽取的归一化多普勒偏移
        theta_TR_A = rand(1,P_TR(i));
        theta_TR_D = rand(1,P_TR(i));
        h_TR = zeros(1,P_TR(i));
        % 首径复增益的平均功率为 1，其余各径的平均功率为 0.01。
        h_TR(1) = sqrt(1/2)*(randn(1,1) + 1j*randn(1,1));
        h_TR(2:P_TR(i)) = 0.1*sqrt(1/2)*(randn(1,P_TR(i)-1) + 1j*randn(1,P_TR(i)-1));
        theta_TR_D_1(i) = theta_TR_D(1);
        h_TR_1(i) = h_TR(1);

        H_dir = zeros(gridSize*N_R,gridSize*N_T);
        for p = 1:P_TR(i)
            % 将路径的收发阵列响应与时延、多普勒变换组合，并按复增益累加。
            spatial = steeringVec(N_R,theta_TR_A(p))*steeringVec(N_T,theta_TR_D(p))';
            G = F*circshift(eye(gridSize),Delay_TR(p))*...
                diag(omega.^((0:gridSize-1)*Doppler_TR(p)))*F';
            H_dir = H_dir + h_TR(p)*kron(spatial,G);
        end
        H{i,1,1} = H_dir;
    end
end
