function [t_filled, b_filled, intervals] = fill_gaps(t, b, n_min, n_max, intervals)
    %
    % Fill data gaps that are between n_min and n_max number of samples.
    % "intervals" is an array of start and end indices that outline the
    % intervals in which to look for these data gaps.
    %

    % default to the full data period
    if nargin < 5
        intervals = [1; length(t)];
    end

    % count the number of minor gaps so that we can allocate memory to the
    % filled time and field arrays
    n_minor_gaps = count_minor_gaps(t, intervals, n_min, n_max);
    
    % If there are no gaps to fill, return right away.
    if n_minor_gaps == 0
        t_filled = t;
        b_filled = b;
        return
    end
    
    n_pts = length(t);

    % allocate memory to the time and field arrays
    t_filled = zeros(n_pts + n_minor_gaps*(n_max + 1), 1);
    b_filled = zeros(n_pts + n_minor_gaps*(n_max + 1), 3);
    t_filled(1:n_pts) = t;
    b_filled(1:n_pts, :) = b;

    %
    % Fill in the minor gaps for each major interval
    %
    n_gaps = length(intervals(:,1));
    n_diff_total = 0;

    % st
    for i = 1:n_gaps
        % get ith data interval
        t_temp = t_filled(intervals(i,1):intervals(i,2));
        b_temp = b_filled(intervals(i,1):intervals(i,2), :);

        % fill in the minor gaps
        [t_temp, b_temp] = fill_minor_gaps(t_temp, b_temp, n_min, n_max);

        % find how many points were added
        n_new = length(t_temp);
        n_old = intervals(i,2) - intervals(i,1) + 1;
        n_diff = n_new - n_old;
        n_diff_total = n_diff_total + n_diff;

        % shift the end of the array down to make room for the new
        % points. "circshift" will shift all of the points to the
        % right by "n_diff", wrapping the final zeros back around
        % to the beginning. The wrap-around is ok because those
        % points are going to be over-written in a second.
        t_filled(intervals(i,2)+1:end)   = circshift(t_filled(intervals(i,2)+1:end),   [n_diff, 0]);
        b_filled(intervals(i,2)+1:end,:) = circshift(b_filled(intervals(i,2)+1:end,:), [n_diff, 0]);

        % add that number of points to the remaining intervals
        intervals(i,2) = intervals(i,2) + n_diff;
        if i < n_gaps
            intervals(i+1:end,:) = intervals(i+1:end,:) + n_diff;
        end

        % store the current segment of data into the total field array
        t_filled(intervals(i,1):intervals(i,2))    = t_temp;
        b_filled(intervals(i,1):intervals(i,2), :) = b_temp;
    end

    %remove the extra points at the end
    t_filled = t_filled(1:n_pts+n_diff_total);
    b_filled = b_filled(1:n_pts+n_diff_total, :);
end