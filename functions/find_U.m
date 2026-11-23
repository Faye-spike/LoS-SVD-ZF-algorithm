function U = find_U(H,V,sigma2,R,I,K,d)
% 更新每个用户的 R×d 线性 MMSE 接收滤波器。
    J = cell(I,K);
    J(:)={zeros(R,R)};
    U = cell(I,K);
    U(:)={zeros(R,d)};
    for i=1:I
        for k=1:K
            % 汇总所有基站、所有数据流在用户 (i,k) 处形成的接收信号协方差。
            for j=1:K
                for l=1:I
                    J{i,k} = J{i,k} + H{i,k,j}*V{l,j}*(V{l,j}')*(H{i,k,j}');
                end
            end
            J{i,k} = J{i,k} + sigma2*eye(R); % 加入空间白噪声协方差
            U{i,k} = J{i,k}\H{i,k,k}*V{i,k}; % 对应线性方程 J{i,k} * U{i,k} = H{i,k,k} * V{i,k}
        end
    end     
end