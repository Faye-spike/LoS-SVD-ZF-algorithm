function W = find_W(U,H,V,I,K,d)
% 根据当前 MMSE 接收滤波器和预编码矩阵，计算每个用户的 d×d 误差权重矩阵。
    W = cell(I,K);
    W(:) = {zeros(d,d)};
    for i=1:I
        for k=1:K
            W{i,k} = inv(eye(d)-U{i,k}'*H{i,k,k}*V{i,k}); % 当前接收估计误差协方差的逆
        end
    end
end