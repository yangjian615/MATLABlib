function [fgm_intervals, scm_intervals] = find_merge_intervals(t_fgm, t_scm, fgm_gaps, scm_gaps)

    %
    % Find all of the continuous data intervals that span both FGM and SCM
    % data sets.
    %

    % Add the last time stamp to the list of data gaps. This way, the last
    % data gap will also mark the end of the last data interval.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FGM Prepare Gaps              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % *_gaps are the indices of the data point preceeding a data gap. As
    % such, data intervals run from 
    %   [1,   ..., i]
    %   [i+1, ..., j]
    %   [j+1, ..., k], etc.
    %
    % *_gaps are indicated by the indices [i,j,k] in the preceeding
    % example, except in the case where k is the last point in the data
    % set. The last point of the dataset must be appended to *_gaps in
    % order to have paired start and stop index values for all data
    % intervals.
    %
    
    % Add the last data point.
    if ~exist('fgm_gaps', 'var')
        fgm_gaps = length(t_fgm);
        
    % Otherwise, add the last index value to the list of fgm_gaps.
    else

        %the concatenation that follows requires a row vector
        if iscolumn(fgm_gaps)
            fgm_gaps = fgm_gaps';
        end

        fgm_gaps = [fgm_gaps length(t_fgm)];
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SCM Prepare Gaps              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~exist('scm_gaps', 'var')
        scm_gaps = length(t_scm);
    else

        %the concatenation that follows requires a row vector
        if iscolumn(scm_gaps)
            scm_gaps = scm_gaps';
        end

        scm_gaps = [scm_gaps length(t_scm)];
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Allocate Memory to Output     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % count the number of gaps
    ngaps_fgm = length(fgm_gaps);
    ngaps_scm = length(scm_gaps);
    ngaps = ngaps_fgm + ngaps_scm;

    % Initialize arrays that will containt the start and stop index for each
    % continuous data interval in FGM and SCM.
    fgm_intervals = zeros(ngaps, 2);
    scm_intervals = zeros(ngaps, 2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sync First Data Interval      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Set up the initial conditions for the loop.
    %
    % Determine which instrument starts second, then find a matching time
    % stamp in the other, searching in the forward direction (since there
    % are no times before the first recorded time).
    %

    % the start indices for the first merging interval
    [~, inst] = max([t_fgm(1) t_scm(1)]);
    if inst == 1
        [this_start_scm, this_start_fgm] = sync_t(t_scm, t_fgm, 1, 'FORWARD');
    else
        [this_start_fgm, this_start_scm] = sync_t(t_fgm, t_scm, 1, 'FORWARD');
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sync Other Data Interval      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Now that we have the start index of the first interval, search
    % through the gaps arrays for the end of the interval. j and k will be
    % used as starting points while looking for a synchronous end time for
    % the interval.
    j = find(fgm_gaps > this_start_fgm, 1);
    k = find(scm_gaps > this_start_scm, 1);

    % Step through each gap
    stop = 0;       % Stop the loop?
    i = 1;          % Count the total number of intervals
    while stop == 0

        % figure out which gap is first, 
        [~, inst] = min([t_fgm(fgm_gaps(j)), t_scm(scm_gaps(k))]);

        % if the earlier data gap comes from FGM
        if inst == 1
            % the end of the continuous interval will occur at the data gap
            % marked by j. Search SCM for time synchronous to this.
            this_end_fgm = fgm_gaps(j);
            [this_end_scm, this_end_fgm] = sync_t(t_scm, t_fgm, this_end_fgm, 'BACKWARD');

            % if we have reached the end of last continuous data interval
            % then exit the loop.
            if j == ngaps_fgm
                stop = 1;
                
            %otherwise find the start of the next interval
            else
                next_start_fgm = fgm_gaps(j) + 1;

                % if the start of the next interval for FGM is after the
                % last data point in SCM, then there are no more continuous
                % data intervals remaining and we must stop
                if t_fgm(next_start_fgm) > t_scm(end)
                    stop = 1;
                % otherwise, search the SCM for the start of the next
                % interval
                else
                    [next_start_scm, next_start_fgm] = sync_t(t_scm, t_fgm, next_start_fgm, 'FORWARD');
                end
            end

        %otherwise, the earlier data gap must be from SCM. Do the same as
        %above.
        else
            % the end of the continuous interval will occur at the data gap
            % marked by k. Search FGM for time synchronous to this.
            this_end_scm = scm_gaps(k);
            [this_end_fgm, this_end_scm] = sync_t(t_fgm, t_scm, this_end_scm, 'BACKWARD');

            %if we have reached the end of last continuous data interval
            %then exit the loop.
            if k == ngaps_scm
                stop = 1;
            
            %otherwise find the start of the next interval
            else
                next_start_scm = scm_gaps(k) + 1;

                %if the start of the next interval for SCM is after the
                %last data point in FGM, then there are no more continuous
                %data intervals remaining and we must stop
                if t_scm(next_start_scm) > t_fgm(end)
                    stop = 1;
                %otherwise, search the FGM for the start of the next
                %interval
                else
                    [next_start_fgm, next_start_scm] = sync_t(t_fgm, t_scm, next_start_scm, 'FORWARD');
                end
            end
        end

        % record the data interval only if the start and stop times
        % are not the same
        if this_start_fgm ~= this_end_fgm && this_start_scm ~= this_end_scm
            fgm_intervals(i,:) = [this_start_fgm this_end_fgm];
            scm_intervals(i,:) = [this_start_scm this_end_scm];

            i = i + 1;
        end

        if stop == 0
            % go to the beginning of the next interval
            this_start_fgm = next_start_fgm;
            this_start_scm = next_start_scm;

            % Find candidates for the end of the next continuous interval
            j = find(t_fgm(fgm_gaps) > t_fgm(this_start_fgm), 1);
            k = find(t_scm(scm_gaps) > t_scm(this_start_scm), 1);
        end
    end

    %i increases upon exiting the loop. go back one
    fgm_intervals = fgm_intervals(1:i-1, :);
    scm_intervals = scm_intervals(1:i-1, :);
end