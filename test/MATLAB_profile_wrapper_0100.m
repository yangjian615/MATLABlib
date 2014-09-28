% MATLAB_profile_wrapper_0100

clc             % clear the command window
clear variables % clear all variables
clear classes
format compact
format short g  % +, bank, hex, long, rat, short, short g, short eng

profile on -history -timer cpu

% DriftStepAngleToTargetStats_0101
% DriftStepAngleToTargetStats_IDL_0100

CDF_file_data_read_speed_tests_0100

profile viewer
% p = profile ('info');
% profsave (p, 'profile_results')

profile off
