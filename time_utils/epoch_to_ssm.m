function [t_ssm, epoch_type] = epoch_to_ssm(t_epoch)

%%%%%%%%%%%%%%%%%%%%%%%%
% DETERMINE EPOCH TYPE %
%%%%%%%%%%%%%%%%%%%%%%%%
    if isa(t_epoch, 'int64')
        epoch_type = 'CDF_TIME_TT2000'
    elseif isa(t_epoch, 'double') && size(t_epoch, 1) == 1
        epoch_type = 'CDF_EPOCH'
    elseif isa(t_epoch, 'double') && size(t_epoch, 1) == 2
        epoch_type = 'CDF_EPOCH16'
    else
        epoch_type = ''
    end

%%%%%%%%%%%%%%%%%%%%%%%
% COMPUTE FROM TT2000 %
%%%%%%%%%%%%%%%%%%%%%%%
    % TT2000 was vectorized with the new CDF Patch 3.4.1
    if strcmp(epoch_type, 'CDF_TIME_TT2000')
        % Breakdown the TT2000 value
        t_breakdown = breakdowntt2000(t_epoch);
            
        % Create a Nx9 array of start-dates. Convert them to an Epoch
        % value marking the beginning of each day.
        % [YYYY MM DD HH MM SS mmm uuu nnn]
        nil = zeros(length(t_epoch), 6);
        start_of_day = computett2000([t_breakdown(:, 1) ...
                                      t_breakdown(:, 2) ...
                                      t_breakdown(:, 3) ...
                                      nil]);
        
        % Convert from nano-seconds to seconds.
        t_ssm = double(t_epoch - start_of_day) * 1e-9;

    elseif strcmp(epoch_type, 'CDF_EPOCH')
        
%%%%%%%%%%%%%%%%%%%%%%%
% COMPUTE FROM EPOCH  %
%%%%%%%%%%%%%%%%%%%%%%%
        
        % Breakdown the Epoch value
        t_breakdown = cdflib.epochBreakdown(t_epoch);

        % Create a 7xN array of start-dates. Convert them to an Epoch
        % value marking the beginning of each day.
        % [YYYY; MM; DD; HH; MM; SS; mmm]
        nil = zeros(4, length(t_epoch));
        start_of_day = cdflib.computeEpoch([t_breakdown(1, :); ...
                                            t_breakdown(2, :); ...
                                            t_breakdown(3, :); ...
                                            nil]);

        % Subtract off the start-of-day value and convert from
        % milliseconds to seconds
        t_ssm = (t_epoch - start_of_day) * 1e-3;
    
    elseif strcmp(epoch_type, 'CDF_EPOCH16')
        
%%%%%%%%%%%%%%%%%%%%%%%%
% COMPUTE FROM EPOCH16 %
%%%%%%%%%%%%%%%%%%%%%%%%
    
        % Breakdown the Epoch value
        t_breakdown = cdflib.epoch16Breakdown(t_epoch);

        % Create a 10xN array of start-dates. Convert them to an Epoch
        % value marking the beginning of each day.
        % [YYYY; MM; DD; HH; MM; SS; mmm; uuu; nnn; ppp]
        nil = zeros(7, length(t_epoch));
        start_of_day = cdflib.computeEpoch16([t_breakdown(1, :); ...
                                              t_breakdown(2, :); ...
                                              t_breakdown(3, :); ...
                                              nil]);

        % Subtract off the start-of-day value. Convert the
        % left-over picoseconds to seconds and add them to the
        % left-over seconds value.
        temp_ssm = (t_epoch - start_of_day);
        t_ssm = temp_ssm(1,:) + temp_ssm(2,:) * 1e-12;
    end
end