data_dir = '/Users/argall/Documents/Work/Data/RBSP/20130323/';

mission = 'RBSP';
sc = 'A';
date = '20130323';
hour = '23';
tstart = '230000';
tend = '240000';
multiplier = 32;
ref_time = '-1';

start_datenum = datenum(date, 'yyyymmdd');
xrange = [hms_to_ssm(000000), hms_to_ssm(240000)] / 86400 + start_datenum;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Burst Information \\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get the start times of each burst the number of bursts
[tstart_bursts, n_bursts] = rbsp_burst_intervals(sc, date, hour, data_dir);

% Get the index of each group and how many bursts in a row there are.
gap_duration = 0.04;        %seconds
[group_start, nconsec] = rbsp_consec_bursts(tstart_bursts, gap_duration);

% Pick a random interval that has the most in a row
maxGroups = find(nconsec == max(nconsec));
thisGroup = maxGroups(end);

% Start and end time of the group of bursts (pad the times so we are sure
% to get all the data).
tstart_ssm = tstart_bursts(group_start(thisGroup)) - 1;
tend_ssm = tstart_ssm + nconsec(thisGroup)*(208896/35000.0 + gap_duration) + 5;
tstart = num2str(ssm_to_hms(tstart_ssm));
tend = num2str(ssm_to_hms(tend_ssm));
clear tstart_bursts gap_duration thisGroup group_start nconsec tstart_ssm ...
      tend_ssm


%%%%%%%%%%%%%%%%%%
% Merge the data %
%%%%%%%%%%%%%%%%%%
[t_merge, b_merge, fgm, scm] = fgm_scm_merge(mission, sc, date, tstart, tend, ...
                                             'ref_time', ref_time, ...
                                             'multiplier', multiplier, ...
                                             'coord_sys', 'SPIN', ...
                                             'fgm_data_dir', data_dir, ...
                                             'scm_data_dir', data_dir);

%%%%%%%%%%%%%%
% MAKE PLOTS %
%%%%%%%%%%%%%%

[t_splice, b_splice, fgm_intervals, scm_intervals] ...
    = rbsp_splice(fgm.t, fgm.b, t_merge, b_merge);

%%%%%%%%%%%%%%
% Despin     %
%%%%%%%%%%%%%%

fgm.b = rbsp_despin_t1(fgm.t, fgm.b);
b_splice = rbsp_despin_t1(t_splice, b_splice);
b_merge = rbsp_despin_t1(t_merge, b_merge);

%%%%%%%%%%%%%%
% MAKE PLOTS %
%%%%%%%%%%%%%%
disp('Plotting...')
xrange = [hms_to_ssm(str2double(tstart)), hms_to_ssm(str2double(tend))] / 86400 + start_datenum;
% convert the times to date numbers
t_mg = start_datenum + t_merge/86400;
t_fg = start_datenum + fgm.t/86400;
t_sc = start_datenum + scm.t/86400;
clear start_datenum
% 
% comp_fgm_merge
%
subplot(3,1,1)
plot(t_fg, fgm.b(:,1), t_mg, b_merge(:,1))
legend('FGM', 'Merged')
xlim(xrange)

if exist('yrange', 'var') == 1
    ylim(yrange)
end
ylim([-145,-70])

title(['Comparison between B SCM, FGM and Merged ', date])
xlabel('UT (HH:MM:SS)')
ylabel('Bx (nT) (GSE)')
datetick('x', 'HH:MM:SS', 'keeplimits', 'keepticks')


subplot(3,1,2)
plot(t_fg, fgm.b(:,2), t_mg, b_merge(:,2))
legend('FGM', 'Merged')
xlim(xrange)

if exist('yrange', 'var') == 1
    ylim(yrange)
end
ylim([20,110])

title(['Comparison between B SCM, FGM and Merged ', date])
xlabel('UT (HH:MM:SS)')
ylabel('By (nT) (GSE)')
datetick('x', 'HH:MM:SS', 'keeplimits', 'keepticks')


subplot(3,1,3)
plot(t_fg, fgm.b(:,3), t_mg, b_merge(:,3))
legend('FGM', 'Merged')
xlim(xrange)

ylim([-22,-13])

title(['Comparison between B SCM, FGM and Merged ', date])
xlabel('UT (HH:MM:SS)')
ylabel('Bz (nT) (GSE)')
datetick('x', 'HH:MM:SS', 'keeplimits', 'keepticks')

clear t_mg t_sc t_fg