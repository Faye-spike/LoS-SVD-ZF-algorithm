function [p_1_true,p_1,capa,capa1]=waterfill_impove(h_1,u,Power_toal,N0,subcarrier_n)
% 对 subcarrier_n 个并行模式进行加权注水。h_1 为非负幅度增益，u 为功率权重。
% Power_toal 是加权功率预算，N0 是噪声功率。p_1 和 p_1_true 均按输入模式顺序返回。
% p_1 为加权功率行向量，p_1_true 为除以相应权重后的模式功率列向量。
% capa 累加分配功率后各模式的速率，capa1 为保留输出，固定为 0。

h_2=h_1.^2;
[h_2_sorted,ind]=sort(h_2./u); % 按增益平方与功率权重的比值升序排列
h=h_2_sorted/N0; % 除以噪声功率，得到各模式的等效增益
capacity=zeros(1,length(Power_toal));

syms mu_sym

capa=0;
capa1=0;

% 假设排序后的第 k 个至最后一个模式获得正功率。
for k=1:subcarrier_n

    p=zeros(1,subcarrier_n);

    Power_sum_i=0;

    for i=k:subcarrier_n

        Power_sum_i=Power_sum_i+(1/(mu_sym)-1/h(i));

    end

    % 令活动模式的加权功率之和等于预算，求解对偶变量 mu，水位为 1/mu。
    function2mu=Power_sum_i-Power_toal;

    Power_i=solve(function2mu,mu_sym);
    if k==1
        left=0;
    else
        left=h(k-1);
    end

    val_Power_i_numeric = Power_i;
    if isa(Power_i, 'sym')
        val_Power_i_numeric = double(Power_i);
    end

    vpa_processed_Power_i = vpa(val_Power_i_numeric);

    % 将对偶变量及相邻增益转为双精度，供下面的严格不等式比较。
    power_to_compare = double(vpa_processed_Power_i);
    left_for_compare = double(left);
    hk_for_compare = double(h(k));

    % 若 mu 严格位于左边界和 h(k) 之间，则采用当前活动模式集合。
    if power_to_compare > left_for_compare && power_to_compare < hk_for_compare
        for i=k:subcarrier_n
            p(i)=1/(Power_i)-1/h(i);
            capa=capa+log2(1+p(i)*h(i));
        end
        p(i)=vpa(p(i),3); % 仅将最后一个活动模式的加权功率取为 3 位有效数字
        capa=vpa(capa);
        break
    end
end

% 用排序索引将加权功率写回各模式的原始位置。
for i=1:subcarrier_n
    p_1(ind(i))=p(i);
end
p_1_true=p_1'./u;
