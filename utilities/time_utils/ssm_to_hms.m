function [t_hms] = ssm_to_hms(t_ssm, varargin)
%
% Convert a time in seconds since midnight to hours-minutes-seconds
% (HH:MM:SS.ddd).
%
% t_hms = ssm_to_hms(t_ssm ...
%                          [, 'to_string', false]  -- return a string
%                          [, 'delimeter', '']     -- ':'-> 'HH:MM:SS.ddd'
%                          [, 'precision', 12])    -- 12 digit decimal sec
%
% See 'test_ssm_to_hms.m' for dif
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check Inputs \\\\\\\\\\\\\\\\%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    inputs = inputParser;
    inputs.addRequired('t_ssm')
    inputs.addParamValue('to_string', false);
    inputs.addParamValue('delimeter', '');
    inputs.addParamValue('precision', 12);
    
    inputs.parse(t_ssm, varargin{:});
    
    inputs = inputs.Results;
    t_ssm = inputs.t_ssm;
    to_string = inputs.to_string;
    delimeter = inputs.delimeter;
    precision = inputs.precision;
    clear inputs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Break into Hours, Minutes, Seconds \\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Extract the hour, minute and second from the SSM time.
    hour = floor(t_ssm/3600);
    minute = floor(mod(t_ssm, 3600)/60);
    second = mod(mod(t_ssm, 3600.0), 60.0);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Keep as Numerical Value? \\\\\\\\\\\\\ %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if to_string == false
        t_hms = hour*10000 + minute*100 + second;
        return
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Convert to String \\\\\\\\\\\\\\\\\\\\ %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    n_times = length(t_ssm);
    
    % Convert the numbers to strings.
    str_hour = num2str(hour, '%02i');
    str_min = num2str(minute, '%02i');
    str_sec = num2str(uint16(second), '%02i');
    str_dec = num2str(uint64(mod(second, 1) * 10^precision), ['%0' num2str(precision) 'i']);
    
    % Create arrays out of the delimeter and decimal point.
    delim = repmat(delimeter, n_times, 1);
    point = repmat('.', n_times, 1);
    
    % Concatenate the time elements.
    t_hms = [str_hour delim str_min delim str_sec point str_dec];
end