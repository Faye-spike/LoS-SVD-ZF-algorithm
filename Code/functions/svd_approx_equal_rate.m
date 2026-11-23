function rate = svd_approx_equal_rate(H, model, P, sigma2, alpha1)
% 用首径近似信道的右奇异向量构造预编码，对各模式采用相同的幅度系数。
% 按总功率 P 归一化后，在完整信道 H 上计算加权和速率。
    gramInverse = inv(model.gram);
    beta = sqrt(P/trace(gramInverse))*eye(size(model.gram));
    precoder = model.basis*gramInverse*beta;
    rate = svd_precoder_rate(H,precoder,sigma2,alpha1);
end
