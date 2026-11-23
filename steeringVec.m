function a_steering=steeringVec(N,theta)
% 生成半波长间距均匀线阵的 N×1 导向矢量，每个阵元响应的幅值为 1。
% theta 为归一化空间方向参数，相邻阵元的相位差为 pi*theta 弧度。
a_steering=exp(1j*2*pi*1/2*(0:N-1)'*theta);