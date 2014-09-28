function [time_data, n_bursts] = rbsp_burst_intervals(sc, date, hour, directory)
    %
    % The start time of each continuous waveform burst included in the CDF
    % files. Read them and count how many there are.
    %


    % Check for a directory. Default to the present working directory
    if nargin < 3
        directory = [pwd, filesep];
    end
    
    % Build the filename and look for it in the filesystem
    filename = ['rbsp-', lower(sc), '_WFR-waveform-continuous-burst_emfisis-L1_', ...
                date, 'T', hour, '_*.cdf'];
    fullname = dir([directory, filename]);
    
    % Make sure it exists
    assert(~isempty(fullname), ['File Name Not Found: ', directory, filename]);

    % The time variable's name
    t_name = 'Epoch';

    % Read the data
    time_data = cdfread([directory, fullname.name], ...
                        'Variable', t_name, ...
                        'CombineRecords', true, ...
                        'ConvertEpochToDatenum', true);

    % Convert serial time values to seconds since midnight starting 
    % on DATE.
    time_data = time_in_day_date(time_data, date);
    
    % Count the number of bursts throughout the day
    n_bursts = length(time_data);
end