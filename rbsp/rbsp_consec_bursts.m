function [igroup_start, nconsec] = rbsp_consec_bursts(tstart_bursts, gap_duration)
    %
    % Find groups of consectutive bursts from the WFR continuous burst mode
    % data on RBSP.
    %

    % Check for a gap duration. Default to 0.04s. Minimum is 0.0315s.
    if nargin < 2
        gap_duration = 0.04;
    end
    
    % The spin period is about 11 seconds. Each burst is 208896 points long at
    % a sampling rate of 35kHz, which means the burst lasts for 5.9685 seconds.
    % A consecutive burst will begin on the 6th second, leaving a 0.0315 second
    % data gap.
    %
    % The goal here is to group the bursts that fall within 40ms of each other
    % together and count how many there are in a row.
    
    points_per_burst = 208896;
    sample_rate = 35000.0;
    burst_length = points_per_burst / sample_rate;
    n_bursts = length(tstart_bursts);

    % Take the difference in start times. For index "k", the k-th delay will
    % indicate how long after time_burst(k) time_burst(k+1) occurs.
    delay = tstart_bursts(2:end) - tstart_bursts(1:end-1);

    % Look for non-consectutive bursts. I.e. bursts that are longer 40ms away
    % from the previous burst.
    non_consec = find((delay > burst_length + gap_duration) == 1)';

    % The non-consecutive bursts mark the end of a group
    igroup_start = [1 non_consec+1];
    group_end = [non_consec n_bursts];

    % Calculate the number of bursts per group 
    nconsec = group_end - igroup_start + 1;
end