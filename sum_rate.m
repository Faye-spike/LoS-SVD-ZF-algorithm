function system_rate = sum_rate(H,V,sigma2,R,I,K,alpha1)
% 在完整信道 H 上计算预编码 V 的加权和速率，返回值尚未除以 OTFS 格点数。
    rate = zeros(I,K);
    for i=1:I
        for k = 1:K
            temp = zeros(R,R);
            for l=1:I
                for j=1:K
                    % 排除用户 (i,k) 的期望信号，其余各项计入干扰协方差。
                    if l~=i || j~=k
                        temp = temp + H{i,k,j}*V{l,j}*(V{l,j}')*(H{i,k,j}');
                    end
                end
            end
            % 由期望信号协方差及干扰加噪声协方差计算该用户的 log2 行列式速率。
            rate(i,k) = log2(det(eye(R)+H{i,k,k}*V{i,k}*(V{i,k}')*(H{i,k,k}')*pinv(temp + sigma2*eye(R))));
        end
    end
    system_rate = real(sum(sum(rate.*alpha1,1),2));
end