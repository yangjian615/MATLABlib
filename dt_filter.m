%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate dB/dt of the merged data and filter it %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
v_n = 1;                    % m/s
mu_0 = 1.25663706e-6;       % m kg s-2 A-2

max_freq = 40;
dB_dt_lmn = derivative(b_fgm_lmn, t_fgm) / (1e6 * mu_0 * v_n);
dB_dt_merge_lmn = derivative(b_merge_lmn, t_merge) / (1e6 * mu_0 * v_n);%(1e6 -> mA/m s) %(1e3 -> uA/m s)

J_lp_merge = zeros(size(dB_dt_merge_lmn));
for ii = 1:length(scm.intervals(:,1))
    
    istart_merge = scm.intervals(ii,1);
    iend_merge = scm.intervals(ii,2);
    
    dt_merge = mean(diff(t_merge(istart_merge:iend_merge)));
    
    if mod(length(J_lp_merge(istart_merge:iend_merge, 2)), 2) ~= 0
        istart_merge = istart_merge + 1;
    end
    
    J_lp_merge(istart_merge:iend_merge,:) = lowpass(dt_merge, dB_dt_merge_lmn(istart_merge:iend_merge,:), max_freq);
end

clear ii v_n mu_0 max_freq istart_merge iend_merge dt_merge ...
      dB_dt_lmn
  