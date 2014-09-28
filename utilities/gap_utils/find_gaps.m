% NAME:
%   find_gaps
%
% PURPOSE:
%+
%   Find gaps in a sequence of numbers that are suppose to be evently
%   spaced. The index returned will indicate the point occuring prior
%   to the data gap.
%
% :Params:
%   TIME:       in, required, type=float array
%               Monotonic array that is suppose to be evenly spaced. The
%                   data interval is taken to be the mode of the difference
%                   between adjacent points.
%   N_MIN:      in, required, type=float, default=1.5
%               Minimum number of missing data intervals considered to be
%                   a gap.
%   N_MAX:      in, required, type=integer, default=Inf
%               Maximum number of missing data intervals constituting a
%                   data gap.
%
% :Returns:
%   TIME_GAPS:  Index values into `TIME` indicating the last point prior
%                   to a data gap.
%   N_GAPS:     Number of data gaps found.
%-
function [time_gaps, n_gaps] = find_gaps(time, n_min, n_max)
    %
    % Find gaps between n_min and n_max number of samples.
    %
    
    % Calculate the sampling rate at each point.
    %   - Mean() would be too large if gaps are present.
    dt      = diff(time);
    dt_mode = mode(dt);

    % Find data gaps the lie within the specified range
    time_gaps = find(dt >= dt_mode*n_min & ...
                     dt <  dt_mode*n_max);

    % Number of gaps found.
    n_gaps = length(time_gaps);
end