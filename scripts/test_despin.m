data_dir = '/Users/argall/Documents/Work/Data/20121114/';
kernel = '/Users/argall/Documents/External_Libraries/Spice/rbsp_current_argall.txt';
filename = [data_dir, 'rbsp-a_magnetometer_emfisis-L1_20121114_v1.2.2.cdf'];

mission = 'RBSP';
sc = 'A';
date = '20121114';
tstart = '000000';
tend = '080000';

% Read the data
t_name = 'Epoch';
b_name = 'Mag';
met_name = 'MET';
cdfdata = cdfread(filename, ...
                  'Variable', {t_name, b_name, met_name}, ...
                  'CombineRecords', true, ...
                  'KeepEpochAsIs', true);

% Separate the data into their own arrays
t_epoch_fgm = cdfdata{1}';
b_fgm = cdfdata{2};
t_met_fgm = cdfdata{3};
clear cdfdata

% Load the SPICE kernel
cspice_furnsh(kernel);

% Convert       1 record from TT2000 --> UTC --> ET takes  0.020046s
% Convert     100 record from TT2000 --> UTC --> ET takes  0.018694s
% Convert    1000 record from TT2000 --> UTC --> ET takes  0.020661s
% Convert   10000 record from TT2000 --> UTC --> ET takes  0.047293s
% Convert  100000 record from TT2000 --> UTC --> ET takes  0.275077s
% Convert 1000000 record from TT2000 --> UTC --> ET takes  2.533192s
% Convert 5000000 record from TT2000 --> UTC --> ET takes 12.514485s
t_UTC_fgm = double(t_epoch_fgm)*1e-9 - 35.0 - 32.184;
t_deltaET = cspice_deltet(t_UTC_fgm, 'UTC');
t_ET_fgm = t_UTC_fgm + t_deltaET;

t_gse = test_mice_despin(b_fgm, t_ET_fgm, sc, 'n_sec', 5);

cspice_kclear;