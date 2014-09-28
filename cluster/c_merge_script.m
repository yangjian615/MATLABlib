data_dir = '/Users/argall/Documents/Work/Data/20050125_142500_163500/';

mission = 'C';
sc = '1';
date = '20050125';
hour = '';
tstart = '142500';
tend = '163500';
multiplier = 64;
ref_time = '-1';
srt_dir = '/Users/argall/Documents/Work/Programs/Magnetic Merging/MergingClass/orbit/';
attitude_dir = '/Users/argall/Documents/Work/Programs/Magnetic Merging/MergingClass/orbit/';

start_datenum = datenum(date, 'yyyymmdd');
xrange = [hms_to_ssm(144700), hms_to_ssm(145200)] / 86400 + start_datenum;


%%%%%%%%%%%%%%%%%%
% Merge the data %
%%%%%%%%%%%%%%%%%%
[t_merge, b_merge, fgm, scm] = fgm_scm_merge(mission, sc, date, tstart, tend, ...
                                             'ref_time', ref_time, ...
                                             'multiplier', multiplier, ...
                                             'coord_sys', 'GSE', ...
                                             'fgm_data_dir', data_dir, ...
                                             'scm_data_dir', data_dir);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Despin Non-Merged Data    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b_fgm_despun = cluster_despin(fgm.t, fgm.b, fgm.sc, fgm.date, attitude_dir, srt_dir);

%%%%%%%%%%%%%%
% MAKE PLOTS %
%%%%%%%%%%%%%%
disp('Plotting...')
%xrange = [hms_to_ssm(str2double(tstart)), hms_to_ssm(str2double(tend))] / 86400 + start_datenum;
% convert the time stamps to date numbers
t_mg = start_datenum + t_merge/86400;
t_fg = start_datenum + fgm.t/86400;
t_sc = start_datenum + scm.t/86400;

clear start_datenum
% 
% Comparison between Despun Fluxgate and Despun Merged
%
% X-Component
%
subplot(3,1,1)
plot(t_fg, b_fgm_despun(:,1), t_mg, b_merge(:,1))
legend('FGM', 'Merged')
xlim(xrange)

if exist('yrange', 'var') == 1
    ylim(yrange)
end

title(['Comparison between B SCM, FGM and Merged ', date])
xlabel('UT (HH:MM:SS)')
ylabel('Bx (nT) (GSE)')
datetick('x', 'HH:MM:SS', 'keeplimits', 'keepticks')

% 
% Y-Component
%
subplot(3,1,2)
plot(t_fg, b_fgm_despun(:,2), t_mg, b_merge(:,2))
legend('FGM', 'Merged')
xlim(xrange)

if exist('yrange', 'var') == 1
    ylim(yrange)
end

title(['Comparison between B SCM, FGM and Merged ', date])
xlabel('UT (HH:MM:SS)')
ylabel('By (nT) (GSE)')
datetick('x', 'HH:MM:SS', 'keeplimits', 'keepticks')

% 
% Z-Component
%
subplot(3,1,3)
plot(t_fg, b_fgm_despun(:,3), t_mg, b_merge(:,3))
legend('FGM', 'Merged')
xlim(xrange)

title(['Comparison between B SCM, FGM and Merged ', date])
xlabel('UT (HH:MM:SS)')
ylabel('Bz (nT) (GSE)')
datetick('x', 'HH:MM:SS', 'keeplimits', 'keepticks')

clear t_mg t_sc t_fg