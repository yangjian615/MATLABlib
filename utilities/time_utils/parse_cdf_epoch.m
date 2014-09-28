function [epoch_string] = parse_cdf_epoch(t_epoch, varargin)
    %
    % Convert CDF EPOCH, EPOCH16, and TT2000 values to UTC strings.
    %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check Inputs \\\\\\\\\\\\\\\\%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    inputs = inputParser;
    inputs.addRequired('t_epoch');
    inputs.addParamValue('date_delim', '-');
    inputs.addParamValue('separator', 'T');
    inputs.addParamValue('time_delim', ':');
    
    inputs.parse(t_epoch, varargin{:});
    
    t_epoch = inputs.Results.t_epoch;
    date_delim = inputs.Results.date_delim;
    separator = inputs.Results.separator;
    time_delim = inputs.Results.time_delim;
    clear inputs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAKE EPOCH STRING \\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Determine the type of CDF Epoch time 
    epoch_type = cdf_epoch_type(t_epoch);
    
    % Get the number of records.
    switch epoch_type
        case 'CDF_EPOCH16'
            n_epochs = length(t_epoch(1,:));
        otherwise
            n_epochs = length(t_epoch(:,1));
    end
    
    % Replicate the delimeters so that they can be concatenated into each time string.
    date_delim = repmat(date_delim, n_epochs, 1);
    separator = repmat(separator, n_epochs, 1);
    time_delim = repmat(time_delim, n_epochs, 1);
    decimal = repmat('.', n_epochs, 1);
    
    switch epoch_type
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CDF_EPOCH \\\\\\\\\\\\\\\\\\ %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'CDF_EPOCH'
            % Beakdown the epoch value and take the transpose so that the year, etc.,
            % fall in the columns.
            epoch_parts = cdflib.epochBreakdown(t_epoch)';
            
            % Convert to strings and parse together.
            epoch_string = [num2str(epoch_parts(:,1), '%4d'), date_delim, ...
                            num2str(epoch_parts(:,2), '%02d'), date_delim, ...
                            num2str(epoch_parts(:,3), '%02d'), separator, ...
                            num2str(epoch_parts(:,4), '%02d'), time_delim, ...
                            num2str(epoch_parts(:,5), '%02d'), time_delim, ...
                            num2str(epoch_parts(:,6), '%02d'), decimal, ...
                            num2str(epoch_parts(:,7), '%03d')];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CDF_EPOCH16 \\\\\\\\\\\\\\\\ %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'CDF_EPOCH16'
            % Beakdown the epoch value and take the transpose so that the year, etc.,
            % fall in the columns.
            epoch_parts = cdflib.epoch16Breakdown(t_epoch)';
            
            % Convert to strings and parse together.
            epoch_string = [num2str(epoch_parts(:,1), '%4d'), date_delim, ...
                            num2str(epoch_parts(:,2), '%02d'), date_delim, ...
                            num2str(epoch_parts(:,3), '%02d'), separator, ...
                            num2str(epoch_parts(:,4), '%02d'), time_delim, ...
                            num2str(epoch_parts(:,5), '%02d'), time_delim, ...
                            num2str(epoch_parts(:,6), '%02d'), decimal, ...
                            num2str(epoch_parts(:,7), '%03d'), ...
                            num2str(epoch_parts(:,8), '%03d'), ...
                            num2str(epoch_parts(:,9), '%03d'), ...
                            num2str(epoch_parts(:,10), '%03d')];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CDF_TIME_TT2000 \\\\\\\\\\\\ %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'CDF_TIME_TT2000'
            % Beakdown the epoch value
            epoch_parts = breakdowntt2000(t_epoch);
            
            % Convert to strings and parse together.
            epoch_string = [num2str(epoch_parts(:,1), '%4d'), date_delim, ...
                            num2str(epoch_parts(:,2), '%02d'), date_delim, ...
                            num2str(epoch_parts(:,3), '%02d'), separator, ...
                            num2str(epoch_parts(:,4), '%02d'), time_delim, ...
                            num2str(epoch_parts(:,5), '%02d'), time_delim, ...
                            num2str(epoch_parts(:,6), '%02d'), decimal, ...
                            num2str(epoch_parts(:,7), '%03d'), ...
                            num2str(epoch_parts(:,8), '%03d'), ...
                            num2str(epoch_parts(:,9), '%03d')];
    end

end