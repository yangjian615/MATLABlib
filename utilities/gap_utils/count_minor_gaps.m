function [n] = count_minor_gaps(t, intervals, n_min, n_max)
    %
    % Count the total number of minor data gaps in all of the major data
    % intervals. I.e. the number of data gaps that are between n_min and
    % n_max number of samples.
    %

    % number of major intervals
    n_ints = length(intervals(:,1));

    % minor data gap counter
    n = 0;

    % step through all of the major intervals
    for i = 1:n_ints
        % count the number of minor data gaps in the ith data interval
        [~, n_gaps] = find_gaps(t(intervals(i,1):intervals(i,2)), n_min, n_max);

        % add up all of the minor gaps spanning all major intervals
        n = n + n_gaps;
    end
end