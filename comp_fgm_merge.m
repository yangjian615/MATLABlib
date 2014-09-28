%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dB/dt (LMN)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1)
subplot(4,1,1)
plot(t_fgm, b_fgm_lmn)
line([t_fgm(1) t_fgm(end)], [0 0], 'Color', 'black')
legend('N', 'M', 'L')
xlim(xrange)
title(['FGM Magnetic Field (LMN) ', date])
xlabel('UT (HH:MM:SS)')
ylabel('B (nT)')
datetick('x', 'HH:MM:SS', 'keeplimits', 'keepticks')

subplot(4,1,2)
plot(t_merge(1:end-1), dB_dt_merge_lmn(:,1), t_fgm(1:end-1), dB_dt_lmn(:,1))
legend('Merged', 'FGM')
xlim(xrange)

if exist('yrange', 'var') == 1
    ylim(yrange)
end

title(['d(Bn)/dt', date])
xlabel('UT (HH:MM:SS)')
ylabel('J (uA/m^2)')
datetick('x', 'HH:MM:SS', 'keeplimits', 'keepticks')

subplot(4,1,3)
plot(t_merge(1:end-1), dB_dt_merge_lmn(:,2), t_fgm(1:end-1), dB_dt_lmn(:,2))
legend('Merged', 'FGM')
xlim(xrange)

if exist('yrange', 'var') == 1
    ylim(yrange)
end

title(['d(Bm)/dt', date])
xlabel('UT (HH:MM:SS)')
ylabel('J (uA/m^2)')
datetick('x', 'HH:MM:SS', 'keeplimits', 'keepticks')

subplot(4,1,4)
plot(t_merge(1:end-1), dB_dt_merge_lmn(:,3), t_fgm(1:end-1), dB_dt_lmn(:,3))
legend('Merged', 'FGM')
xlim(xrange)

if exist('yrange', 'var') == 1
    ylim(yrange)
end

title(['d(Bl)/dt', date])
xlabel('UT (HH:MM:SS)')
ylabel('J (uA/m^2)')
datetick('x', 'HH:MM:SS', 'keeplimits', 'keepticks')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dB/dt (LMN) Filtered
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2)
subplot(4,1,1)
plot(t_fgm, b_fgm_lmn)
line([t_fgm(1) t_fgm(end)], [0 0], 'Color', 'black')
legend('N', 'M', 'L')
xlim(xrange)
title(['FGM Magnetic Field (LMN) ', date])
xlabel('UT (HH:MM:SS)')
ylabel('B (nT)')
datetick('x', 'HH:MM:SS', 'keeplimits', 'keepticks')

subplot(4,1,2)
plot(t_merge(1:end-1), J_lp_merge(:,1), t_fgm(1:end-1), dB_dt_lmn(:,1))
legend('Merged', 'FGM')
xlim(xrange)

if exist('yrange', 'var') == 1
    ylim(yrange)
end

title(['d(Bn)/dt Filtered (0-40Hz)', date])
xlabel('UT (HH:MM:SS)')
ylabel('J (uA/m^2)')
datetick('x', 'HH:MM:SS', 'keeplimits', 'keepticks')

subplot(4,1,3)
plot(t_merge(1:end-1), J_lp_merge(:,2), t_fgm(1:end-1), dB_dt_lmn(:,2))
legend('Merged', 'FGM')
xlim(xrange)

if exist('yrange', 'var') == 1
    ylim(yrange)
end

title(['d(Bm)/dt Filtered (0-40Hz)', date])
xlabel('UT (HH:MM:SS)')
ylabel('J (uA/m^2)')
datetick('x', 'HH:MM:SS', 'keeplimits', 'keepticks')

subplot(4,1,4)
plot(t_merge(1:end-1), J_lp_merge(:,3), t_fgm(1:end-1), dB_dt_lmn(:,3))
legend('Merged', 'FGM')
xlim(xrange)

if exist('yrange', 'var') == 1
    ylim(yrange)
end

title(['d(Bl)/dt Filtered (0-40Hz)', date])
xlabel('UT (HH:MM:SS)')
ylabel('J (uA/m^2)')
datetick('x', 'HH:MM:SS', 'keeplimits', 'keepticks')
