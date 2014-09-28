function b_calibrated = calibrate_scm(sc, mode, t_full, b_full, clen, TransfrFn_dir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIND INTERVALS OF CONTINUOUS DATA TO CALIBRATE \\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Find major data gaps. Make a list of start and stop indices for each interval.
    [intervals, n_intervals] = find_gaps(t_full, 6, inf);
    if n_intervals == 0
        intervals = [1 length(t_full)];
        n_intervals = 1;
    else
        % The concatenation that follows requires a row vector
        if iscolumn(intervals)
            intervals = intervals';
        end
        
        % "find_gaps" returns the number of data gaps. There are "n_intervals + 1" number
        % of data intervals
        intervals = [1, intervals+1; intervals, length(t_full)]';
        n_intervals = n_intervals + 1;
    end
    
    % Allocate memory for the calibrated data
    b_calibrated = zeros(size(b_full));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALIBRATE EACH CONTINUOUS INTERVAL \\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Step through each continuous data interval.
    for k = 1:n_intervals
        if intervals(k,2) - intervals(k,1) + 1 < clen
            disp(['Skipping calibration interval ', num2str(k), ...
                  ' of ', num2str(n_intervals)]);
            continue
        end
        
        t_cal = t_full(intervals(k,1):intervals(k,2));
        b_cal = b_full(intervals(k,1):intervals(k,2), :);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DETERMINE CALIBRATION PARAMETERS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Ready FFT parameters for SCM
        dt = (t_cal(end) - t_cal(1)) / length(t_cal);
        n_max = merge_n_max(t_cal, clen, clen/4);
        df = merge_df(dt, clen);
        freqs = calc_fft_freqs(df, clen);

        % Ready calibration parameters. Note that the rotation matrix is suppose
        % to be used as x* = xA', not the usual x* = Ax
        rotmat_fgm2scm = cluster_fgm2scm_rotmat(sc);
        amp_factor = cluster_scm_amp_factor(sc);
        [transfr_fn, transfr_freqs] = read_cluster_scm_transfr_fn(mode, sc, TransfrFn_dir);
        comp_fn = cluster_interp_transfr_fn(clen, df, transfr_fn, transfr_freqs);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CALIBRATE THE CURRENT CONTINUOUS INTERVAL \\\\\\\\\\\\\\\\\\\\ %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Get the start and stop indices of the k-th calibration interval
        istart_calibrate = intervals(k,1);
        istop_calibrate = istart_calibrate + clen - 1;
    
        % Only the middle quarter of the FFT interval will be kept, the
        % rest will be overwritten by the next.
        begin_fill = floor( 0.375 * clen );     % 3/8 of the interval
        end_fill = begin_fill + clen/4 - 1;     % 1/4 of the interval
        
        % Step through all of the calibration intervals for the k-th continuous data interval
        for m = 1:n_max
            %
            % A hamming window is used on the first and last interval. A tukey
            % window is used on intermediate windows.
            %
            % The current continuous data interval has been split into
            % "max_number" of calibration intervals. The "filler_istart" and
            % and "filler_istop" variables determine section of the present
            % calibration interval is kept. The "istart_calibrate" and
            % "istop_calibrate" variables determine which section of the
            % overall dataset is begin calibrated while "istart" and "istop"
            % is the subsection of [istart_calibrate, istop_calibrate]
            % corresponding to [filler_istart, filler_istop].
            %
            % Keep in mind that, exept for the 1st and last interation, only
            % the middle quarter of the m-th calibration interval will be kept.
            %
            
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Which Part of the m-th Interval to Keep      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
            switch m
                % The first interval
                case 1
                    % To start, we need an entire FFT interval.
                    win = merge_fft_win('HAM', clen);
                    filler_istart = 1;
                    filler_istop = clen;
                    
                % The last interval
                case n_max
                    % The last iteration calibrates from the last point in the
                    % array backward by one whole interval. As such, there
                    % could be some overlap between this final interval and the
                    % previous one. Calculate this overlap and only fill new
                    % points.
                    win = merge_fft_win('HAM', clen);
                    filler_istart = (last_calibrated_point+1) - (istop_calibrate - clen);
                    filler_istop = clen;
                    
                % Intermediate intervals
                otherwise
                    % Intermediate iterations only required the middle quarter
                    % of the calibrated waveform, far away from any fringe
                    % affects or Gibbs phenomena, to be recorded
                    if m == 2
                        win = merge_fft_win('TUK', clen);
                    end
                    filler_istart = begin_fill + 1;
                    filler_istop = end_fill + 1;
            end
            
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calibrate the Data                           %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
            % Calibrate the waveform
            fft_cal = cluster_scm_calibrate_fft(b_cal, amp_factor, comp_fn, win, ...
                                                istart_calibrate-intervals(k,1)+1, ...
                                                istop_calibrate-intervals(k,1)+1);
            temp_data = ifft(fft_cal);
            
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Where to Put the Data in the Final Data Array %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % for the first calibration interval, this correpsonds to the whole
            % interval.
            if m == 1
                istart = istart_calibrate;
                istop = istop_calibrate;
                
            % for intermediate intervals, take only the middle quarter
            elseif m < n_max
                istart = istart_calibrate + begin_fill;
                istop = istart_calibrate + end_fill;
                
            % for the final interval, then we want to take whatever remains.
            elseif m == n_max
                istart = last_calibrated_point + 1;
                istop = istop_calibrate;
            end
            
            % Put it into the overall calibrated data array. Rotate it into the
            % frame of the FGM instrument.
            b_calibrated(istart:istop, :) ...
                = temp_data(filler_istart:filler_istop, :) * inv(rotmat_fgm2scm);
            
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Move to the Next Calibration Interval %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Prepare for the last interval...
            if m == n_max - 1
                % Record the last calibrated point
                % For the last iteration, this means taking an interval that
                % extends from the end of the array back one whole FFT
                % interval. Any overlap with the preceding iteration will be
                % dealt with later.
                last_calibrated_point = istop;
                istop_calibrate = length(t_cal) + intervals(k,1) - 1;
                istart_calibrate = istop_calibrate - clen + 1;
                
            % All other intervals
            else
                % Advance by 1/4 of the calibration interval
                istart_calibrate = istart_calibrate + clen/4;
                istop_calibrate = istart_calibrate + clen - 1;
            end
            
        end % for each calibration interval
    end % for each continuous data interval
end