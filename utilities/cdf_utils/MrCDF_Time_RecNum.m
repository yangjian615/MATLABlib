function [time, recrange] = MrCDF_Time_RecNum(filename, timevar, date, sTime, eTime)
%
%cdf_recnum Retrieve record numbers from a CDF file
%   TIME = cdf_recnums(FILENAME, TIMEVAR)
%       Reads the data from a CDF's time variable.
%
%   [TIME, RECRANGE] = cdf_recnums(FILENAME, TIMEVAR)
%       Reads the time variable's data and returns the 0-based record
%       numbers.
%
%   [TIME, RECRANGE] = cdf_recnums(FILENAME, TIMEVAR, DATE, TSTART, TEND)
%       Reads a CDF's time variable data and keeps all within the interval
%       [TSTART, TEND]. DATE is a string in the form 'YYYYMMDD'. TSTART and 
%       TEND are strings in the form 'HHMMSS.ddd'. RECRANGE is a 2-element
%       vector of the 0-based record numbers corresponding to TSTART and
%       TEND.
%

    % Convert the time range to seconds since midnight.
    if nargin == 4
        sDateNum = datenum([date, ' ', sTime], 'yyyy-mm-dd HH:MM:SS');
        eDateNum = datenum([date, ' ', eTime], 'yyyy-mm-dd HH:MM:SS');
    end

    % Read the time variable's data
    time = cdfread(filename, ...
                   'Variables', timevar, ...
                   'ConvertEpochToDatenum', true, ...
                   'CombineRecords', true);
    
    % Return a subinterval of the data?
    if nargin == 4
        % Find the appropriate index range.
        recrange = zeros(2,1);
        recrange(1) = find(time >= sDateNum, 1);
        recrange(2) = find(time <= eDateNum, 1, 'last');
        
        % Cut out the unwanted times.
        time = time(recrange(1):recrange(2));
    
    % Return all of the data
    else
        recrange = [1 length(time)];
    end
    
    % Convert to 0-based record
    recrange = recrange - 1;
end
    