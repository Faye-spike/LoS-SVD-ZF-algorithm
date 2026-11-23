function [V,iter_V] = find_V_complexity(alpha1,H,U,W,T,I,K,P)
% 更新发射预编码矩阵 V，各基站分别按功率预算 P 搜索对偶变量。
% iter_V 为最后一个基站的二分迭代次数乘以基站数 K。
    V = cell(I,K);
    A = cell(K);
    A(:) = {zeros(T,T)};

    for k=1:K
        for j=1:K
            for l=1:I
                % 累加基站 k 到用户 (l,j) 的信道对加权二次项的贡献。
                A{k} = A{k} + alpha1(l,j)*H{l,j,k}'*U{l,j}*W{l,j}*(U{l,j}')*H{l,j,k};
            end
        end   
    end 

    max_iter = 100;
    mu = zeros(K,1);
    for k=1:K
        mu_min = 0;
        mu_max = 10; % 二分搜索的初始上界
        iter = 0;
        while(1)
            mu1 = (mu_max+mu_min) / 2;
            P_tem = 0;
            for i=1:I
                V_tem = inv((A{k}+mu1*eye(T)))*alpha1(i,k)*((H{i,k,k}')*U{i,k}*W{i,k});
                P_tem = P_tem + real(trace(V_tem*V_tem')); % 累加基站 k 在所有用户上的发射功率
            end
            % 功率超过预算时提高对偶变量的下界，以减小候选预编码的发射功率。
            if P_tem > P
                mu_min = mu1;
            else
                mu_max = mu1; % 二分搜索的初始上界
            end
            iter = iter + 1;

            if abs(mu_max - mu_min) < 1e-5 || iter > max_iter
                break
            end
        end
        mu(k) = mu1;
        iter_V = iter;
    end
    iter_V = iter_V * K;

    for i=1:I
        for k=1:K
            V{i,k} =  inv((A{k}+mu(k)*eye(T)))*alpha1(i,k)*((H{i,k,k}')*U{i,k}*W{i,k});
        end 
    end 
end