function [epoch_type] = cdf_epoch_type(t_epoch)
    %
    % Determine the type of CDF Epoch type of 't_epoch'
    %
    % CDF_EPOCH
    %   Double precision floating point array indicating the number of milliseconds since
    %   year 0 AD on the Gregorian Calendar.
    %
    % CDF_EPOCH16
    %   Complex double precision floating point array indicating the number of picoseconds
    %   since year 0AD on the Gregorian Calendar. The real part (t_epoch(:,1)) is the
    %   number of whole seconds while the complex part (t_epoch(:,2)) is the number of
    %   picoseconds.
    %
    % CDF_TIME_TT2000
    %   64-bit integer indicating the number of nanoseconds in time base J2000
    %
    %       J2000 = Julian Day 2451545.0 
    %             = Terrestrial Time Jan 1st, 2000, 12:00:00h
    %
    %   See the reference for more information. Not that TT ~= UTC
    %
    % REFERENCE
    %   http://cdf.gsfc.nasa.gov/html/leapseconds.html
    %       Accessed on January 26, 2013.
    %
    if isa(t_epoch, 'int64')
        epoch_type = 'CDF_TIME_TT2000';
    elseif isa(t_epoch, 'double') && size(t_epoch, 1) == 1
        epoch_type = 'CDF_EPOCH';
    elseif isa(t_epoch, 'double') && size(t_epoch, 1) == 2
        epoch_type = 'CDF_EPOCH16';
    else
        epoch_type = ''
    end
end