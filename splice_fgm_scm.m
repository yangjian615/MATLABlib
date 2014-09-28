mission = 'RBSP';
sc = 'A';
date = '20120929';
tstart = '000000';
tend = '080000';
data_dir = '/Users/argall/Documents/Work/data/20120929/';

fgm = rbsp_data_merge();
scm = rbsp_data_merge();
fgm.get_data('FGM', sc, date, tstart, tend, ...
             'scm_data_dir', data_dir, ...
             'fgm_data_dir', data_dir);
scm.get_data('SCM', sc, date, tstart, tend, ...
             'scm_data_dir', data_dir, ...
             'fgm_data_dir', data_dir);


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
[scm_gaps, n_gaps] = find_gaps(scm.t, n_min, n_max);