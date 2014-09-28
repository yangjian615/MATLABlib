function [igroup_start, nconsec] = find_cont_intervals(array, max_offset)
    %
    % Find continuous intervals within a monotonically increasing 1D array
    % whose spacing is assumed to be uniform. Continuous intervals are 
    % taken to be any interval within which the spacing between points is
    % less than "diff_max". If "diff_max" is not provided, the mode of
    % "array" will be taken.
    %
    % igroup_start          -   start indes of each continuous interval
    % nconsec               -   the number of consecutive points following
    %                               each igroup_start.
    %

    % Take the difference between adjacent points. For index "k", the k-th
    % offset will indicate how far after array(k) array(k+1) occurs.
    offset = diff(array);
    npts = length(array);

    % Check for a max offset. Default to the mode of of "offset"
    if nargin < 2
        max_offset = mode(array);
    end

    % Look for non-consectutive intervals. I.e. offsets that are more than
    % "diff_max".
    non_consec = find((offset > max_offset) == 1)';

    % The non-consecutive bursts mark the end of a group
    igroup_start = [1 non_consec+1];
    igroup_end = [non_consec npts];

    % Calculate the number of bursts per group 
    nconsec = igroup_end - igroup_start + 1;
end