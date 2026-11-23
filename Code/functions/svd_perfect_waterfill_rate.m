function rate = svd_perfect_waterfill_rate(H, model, P, sigma2, alpha1)
% 对完整信道保留的奇异模式进行加权注水，返回加权和速率。
    weights = diag(pinv(model.gram')); % 用 Gram 矩阵共轭转置的伪逆对角元计算各模式的功率权重
    powers = waterfill_impove(model.gains,weights,P,sigma2,numel(weights));
    beta = diag(powers)^(1/2);
    precoder = model.basis*inv(model.gram)*beta;
    rate = svd_precoder_rate(H,precoder,sigma2,alpha1);
end
