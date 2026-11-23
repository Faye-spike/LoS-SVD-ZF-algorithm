function rate = svd_approx_waterfill_rate(H, model, P, sigma2, alpha1)
% 对首径近似信道的奇异模式进行加权注水，在完整信道 H 上计算加权和速率。
    weights = diag(inv(model.gram')); % 各模式在总发射功率约束中的权重
    powers = waterfill_impove(model.gains,weights,P,sigma2,numel(weights));
    beta = diag(powers)^(1/2);
    precoder = model.basis*inv(model.gram)*beta;
    rate = svd_precoder_rate(H,precoder,sigma2,alpha1);
end
