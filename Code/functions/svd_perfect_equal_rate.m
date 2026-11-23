function rate = svd_perfect_equal_rate(H, model, P, sigma2, alpha1)
% 用完整信道的右奇异向量和 Gram 矩阵的伪逆构造等功率预编码。
% 由总功率 P 确定各模式共用的幅度系数，返回完整信道上的加权和速率。
    gramInverse = pinv(model.gram);
    beta = sqrt(P/trace(gramInverse))*eye(size(model.gram));
    precoder = model.basis*gramInverse*beta;
    rate = svd_precoder_rate(H,precoder,sigma2,alpha1);
end
