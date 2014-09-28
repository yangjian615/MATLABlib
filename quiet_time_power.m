%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the Inputs \\\\\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mission = 'C';
sc = '1';
date = '20050125';
tstart = '142500';
tend = '163500';
multiplier = 64;
ref_time = '144000';
data_dir = '/Users/argall/Documents/Work/data/20050125_142500_163500/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the Data \\\\\\\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(mission, 'C')
    fgm = cluster_data_merge();
    scm = cluster_data_merge();
else
    fgm = rbsp_data_merge();
    scm = rbsp_data_merge();
end

fgm.get_data('FGM', sc, date, tstart, tend, ...
             'scm_data_dir', data_dir, ...
             'fgm_data_dir', data_dir);
scm.get_data('SCM', sc, date, tstart, tend, ...
             'scm_data_dir', data_dir, ...
             'fgm_data_dir', data_dir);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the Reference Time \\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If "ref_time" is < 0, then it indicates an index into SCM
% time array. Convert it to a number, get the time, then
% convert the time to a string in the form 'HHMMSS'.
if strcmp(ref_time(1), '-')
    ref_index = abs(str2double(ref_time));
    ref_time = scm.t(ref_index);
    ref_time = num2str(hms_to_ssm(ref_time, 1));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find Gaps Between Bursts \\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% There is typically a 0.0315 ms (+/- a little) 1 gap between continuous
% bursts. Set up a window to catch these... SCM has a sample rate of 35k
% while in continuous burst mode.
sample_rate = 35000;        % samples/sec
dt_min = 28e-3;             % seconds
dt_max = 35e-3;             % seconds

% Get the window in number of samples.
n_min = dt_min * sample_rate;
n_max = dt_max * sample_rate;

% Find gaps between n_min and n_max
[scm_burst_gaps, n_gaps] = find_gaps(scm.t, n_min, n_max);

clear n_min n_max dt_min dt_max sample_rate n_gaps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find All Gaps \\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% all data gaps between burst intervals
fgm_major_gaps = find_gaps(fgm.t, 6, inf);
scm_major_gaps = find_gaps(scm.t, 6, inf);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select a Continuous Data Interval \\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Keep the full time and field array safe.
t_fgm = fgm.t;
b_fgm = fgm.b;
t_scm = scm.t;
b_scm = scm.b;

% Get the index at which to start
[fgm_istart, scm_istart] = get_start_ind(t_fgm, t_scm, ref_time);

% Find the Intervals for which Data can be Merged
[fgm_intervals, scm_intervals] ...
    = find_merge_intervals(t_fgm, t_scm, fgm_major_gaps, scm_major_gaps);

% Find which continuous data interval contains the reference time
thisInterval = find(fgm_intervals(:,1) <= fgm_istart, 1, 'last');

% Transfer the continuous interval into the data objects
fgm.t = fgm.t(fgm_intervals(thisInterval,1):fgm_intervals(thisInterval,2));
fgm.b = fgm.b(fgm_intervals(thisInterval,1):fgm_intervals(thisInterval,2), :);
scm.t = scm.t(scm_intervals(thisInterval,1):scm_intervals(thisInterval,2));
scm.b = scm.b(scm_intervals(thisInterval,1):scm_intervals(thisInterval,2), :);

clear thisInterval fgm_intervals scm_intervals fgm_major_gaps scm_major_gaps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calibrate and Prepare FFT parameters \\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fgm.get_sample_rate
scm.get_sample_rate
[fgm.n, scm.n] = fgm.get_dt_ratio(fgm.dt, scm.dt);
fgm.calibrate
scm.calibrate
fgm.prep_fft(multiplier)
scm.prep_fft(multiplier)
scm.load_transfr_fn
scm.interp_transfr_fn

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reference Power for FGM \\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

win = fgm.win_ham;

% Calculate the start and stop indices of the FFT interval 
fgm_istop = fgm_istart + fgm.clen - 1;

% Select out the referenced time interval
fgm.t = t_fgm(fgm_istart:fgm_istop);
fgm.b = b_fgm(fgm_istart:fgm_istop, :);

% Take the FFT and find the power.
fgm.take_fft(1, length(fgm.t), win);
fgm_fft = fgm.b_fft;
fgm_pwr = weighting_psd(fgm.b_fft, fgm.dt, fgm.clen, scm.clen);
fgm_freqs = fgm.freqs;

clear t_fgm b_fgm fgm_istart fgm_istop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reference Power for SCM \\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

win = scm.win_ham;

% Calculate the start and stop indices of the FFT interval 
scm_istop = scm_istart + scm.clen - 1;

% Select out the referenced time interval
scm.t = t_scm(scm_istart:scm_istop);
scm.b = b_scm(scm_istart:scm_istop, :);

% SCM requires a transfer function, so get that.
scm.get_df
scm.get_freqs
scm.load_transfr_fn
scm.interp_transfr_fn

% Take the FFT and find the power.
scm.take_fft(1, length(scm.t), win);
scm_fft = scm.b_fft;
scm_pwr = weighting_psd(scm.b_fft, scm.dt, fgm.clen, scm.clen);
scm_freqs = scm.freqs;

clear fgm t_scm b_scm scm_istart scm_istop win
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot the Reference Power \\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

thisMany = length(scm_pwr(:,1));
xrange = [0.3,1.5];%[0,  fgm_freqs(end-1)];

% subplot(3,1,1)
% plot(scm_freqs(1:thisMany), log10(scm_pwr(:,1)), fgm_freqs(1:end-1)', log10(fgm_pwr(:,1)))
% legend('SCM', 'FGM')
% title('Comparison the Noise Floors of SCM and FGM')
% ylabel('Power Bx (nT^2 / Hz)')
% xlabel('Log Frequency [log(Hz)]')
% xlim(xrange)

% subplot(3,1,2)
plot(fgm_freqs(1:end-1)', log10(fgm_pwr(:,2)), scm_freqs(1:thisMany), log10(scm_pwr(:,2)))
legend('FGM', 'SCM')
title('Comparison the Noise Floors of SCM and FGM')
ylabel('Power By (nT^2 / Hz)')
xlabel('Frequency (Hz)')
xlim(xrange)

% subplot(3,1,3)
% plot(scm_freqs(1:thisMany), log10(scm_pwr(:,3)), fgm_freqs(1:end-1)', log10(fgm_pwr(:,3)))
% legend('SCM', 'FGM')
% title('Comparison the Noise Floors of SCM and FGM')
% ylabel('Power Bz (nT^2 / Hz)')
% xlabel('Log Frequency [log(Hz)]')
% xlim(xrange)

