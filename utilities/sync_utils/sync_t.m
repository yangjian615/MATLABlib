function [it, it_ref] = sync_t(time, t_ref, ref_index, direction)

    %
    % Given reference instrument (FGM or SCM) and a reference index, search
    % the other instrument (SCM or FGM) for a synchronous time stamp.
    %
    
    % Check the inputs
    assert(strcmp(direction, 'FORWARD') || strcmp(direction, 'BACKWARD') || ...
           strcmp(direction, 'BOTH'), ...
           '"direction" must be "FORWARD", "BACKWARD", or "BOTH".')

    n = length(t_ref);

    %
    % If BACKWARD (FORWARD) is set, only look for points that are
    % earlier (later) than t_ref(ref_index).
    %
    % Find the closest time before (after) the reference
    % time. Then, adjust the reference time in case there were
    % missing points in time.
    %
    % Set the seachable range to be before (after) the first
    % reference time. Include a pad on the other side that extends
    % up to the reference index. Take a maximum of 100 points.
    %
    % BACKWARD
    if strcmp(direction, 'BACKWARD')
        % Find the first time ahead of the reference time.
        first_time = find(time  <= t_ref(ref_index), 1, 'last');
        
        % If there are data gaps in time, then time(first_time) could be
        % very far ahead of t_ref. Adjust ref_index accordingly.
        first_ref  = find(t_ref <= time(first_time), 1, 'last');

        % Scan a range of indices.
        %   - In case first_time matched "<" and not "=", start one index
        %       prior to first_ref
        %   - As an estimate of the number of points to scan, use the
        %       difference between ref_time and first_ref, but scan no more
        %       than 100 points.
        irange = [first_ref-1, abs(ref_index - first_ref)];
        irange(irange > 100) = 100;

    % FORWARD
    %   - Same as above, but in the other direction.
    elseif strcmp(direction, 'FORWARD') || strcmp(direction, 'BOTH')
        first_time = find(time  >= t_ref(ref_index), 1);
        first_ref  = find(t_ref >= time(first_time), 1);

        irange = [abs(ref_index - first_ref), n-first_ref];
        irange(irange > 100) = 100;
    end

    % BOTH
    %   - Combine the index range to scan.
    if strcmp(direction, 'BOTH')
        irange = [first_ref-1, n-first_ref];
        irange(irange > 100) = 100;
    end

    %
    % For each point within irange of ref_t, find the closest
    % corresponding time in scrub_t. The minimum of that set will
    % be the most synchronous time between FGM and FGM.
    %
    dte = zeros(irange(1)+irange(2)+1, 1);
    k = 1;
    iStart = first_ref-irange(1);
    iStop  = first_ref+irange(2);
    
    if iStart < 1
        iStart = 1;
    end
    if iStop > length(t_ref)
        iStop = length(t_ref);
    end
    
    
    for jst = iStart:iStop
        indexm = find(time >= t_ref(jst),1);

        % since both indexm and (indexm-1) are being tested, make
        % room for (indexm-1).
        if indexm == 1
            indexm = 2;
        end

        if isempty(indexm)
            dte(k) = inf;
        else
            % Look at scrub_t one point on either side of 
            % ref_t(jst), since it does not matter if FGM or SCM 
            % comes first, so long as the time difference is 
            % minimized.
            dte(k) = min( abs(t_ref(jst) - time(indexm)), ...
                          abs(t_ref(jst) - time(indexm-1)));
        end
        k = k + 1;
    end

    %
    % Go to the index in ref_t where the minimum between SCM and
    % FGM was found, then find the point in scrub_t that minimized
    % that difference.
    %   
    it_ref = find(dte == min(dte), 1) + first_ref - irange(1) - 1;
    it = find(time >= t_ref(it_ref), 1);

    %
    % Earlier, we did not care which side of ref_t we were looking
    % on. Now we do. Check the value of scrub_t on either side of
    % ref_t(iref_t)
    %
    if it == 1
        it = 2;
    end

    if (abs(t_ref(it_ref) - time(it-1)) < ...
        abs(t_ref(it_ref) - time(it)))

        it = it - 1;
    end
end
