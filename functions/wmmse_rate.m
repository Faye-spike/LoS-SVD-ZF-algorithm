function rate = wmmse_rate(H, P, sigma2, alpha1, d, epsilon, max_iter)
% 在完整信道上交替更新接收滤波器、误差权重和发射预编码，计算 WMMSE 加权和速率。
    [I,K] = size(alpha1);
    [R,T] = size(H{1});
    V = cell(I,K);
    for i = 1:I
        for k = 1:K
            v = randn(T,d) + 1i*randn(T,d);
            V{i,k} = sqrt(P/I)*v/norm(v,"fro"); % 每个用户的初始发射功率为 P/I
        end
    end

    rate = sum_rate(H,V,sigma2,R,I,K,alpha1);
    for iter = 1:max_iter
        U = find_U(H,V,sigma2,R,I,K,d);
        W = find_W(U,H,V,I,K,d);
        V = find_V_complexity(alpha1,H,U,W,T,I,K,P);
        nextRate = sum_rate(H,V,sigma2,R,I,K,alpha1);
        % 达到相对变化阈值或迭代上限时，返回本次更新前的 rate。
        if abs(nextRate-rate)/rate < epsilon || iter == max_iter
            break
        end
        rate = nextRate;
    end
end
