function rate = svd_precoder_rate(H, precoder, sigma2, alpha1)
% 将单基站预编码矩阵按用户分成等宽的列块，在完整信道上计算加权和速率。
    numUsers = size(H,1);
    streams = size(precoder,2)/numUsers;
    V = cell(numUsers,1);
    for i = 1:numUsers
        cols = (i-1)*streams + (1:streams);
        V{i,1} = precoder(:,cols);
    end
    rate = sum_rate(H,V,sigma2,size(H{1},1),numUsers,1,alpha1);
end
