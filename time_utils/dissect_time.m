function [hour, minute, second, milli, micro, nano, pico] = dissect_time(time, type)

    % if no type was specified, return the same as 'time'
    if nargin() == 1
        type = class(time);
    end
    
    % Type of output
    if iscell(time)
        n_times = length(time);
        hour    = cell(n_times, 1);
    elseif ischar(time)
        n_times = 1;
        hour    = '';
    else
        n_times = length(time);
        hour    = zeros(n_times, 1);
    end
    
    minute = hour;
    second = hour;
    milli  = hour;
    micro  = hour;
    nano   = hour;
    pico   = hour;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Break Down a Character Time \\\ %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if iscell(time) || ischar(time)
        % Get the hour, minute, second and number of milli-, micro-, nano-,
        % and picosecond substrings.
        regexp_str = '([0-9]{2})[^0-9]?([0-9]{2})[^0-9]?([0-9]{2})[.]?([0-9]*)';
        subexp = regexp(time, regexp_str, 'tokens');
        
        % Concatenate tokens into adjacent cells
        %   - If a cell array of strings was given, an extra concatenation
        %       is required.
        subexp = vertcat(subexp{:});
        if n_times > 1
            subexp = vertcat(subexp{:});
        end
            
        if strcmp(type, 'cell') || strcmp(type, 'char')
            hour    = {subexp{:,1}};
            minute  = {subexp{:,2}};
            second  = {subexp{:,3}};
            decimal = sprintf('%-12s', subexp{:,4});
            decimal = strrep(decimal, ' ', '0');
            decimal = reshape(decimal, n_times, 12);

            % Pick out the milli, micro, nano, and pico from the decimal
            % seconds. Remove all spaces.
            milli = decimal(:,1:3);
            micro = decimal(:,4:6);
            nano  = decimal(:,7:9);
            pico  = decimal(:,10:12);
        else
            % Store the times in format specified by 'type'
            hour    = str2num(vertcat(subexp{:,1}));
            minute  = str2num(vertcat(subexp{:,2}));
            second  = str2num(vertcat(subexp{:,3}));
            
            decimal = sprintf('%-12s', subexp{:,4});
            decimal = strrep(decimal, ' ', '0');
            decimal = reshape(decimal, n_times, 12);

            % Pick out the milli, micro, nano, and pico from the decimal
            % seconds. Remove all spaces.
            milli = str2num([type '(' decimal(1:3) ')']);
            micro = str2num([type '(' decimal(4:6) ')']);
            nano  = str2num([type '(' decimal(7:9) ')']);
            pico  = str2num([type '(' decimal(10:12) ')']);
        end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Break Down a Numeric Time \\\\\ %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        
        % Math out the hour, minute, second, and decimal seconds
        hour    = floor(time / 10000);
        minute  = floor((time - hour*10000)/100);
        second  = mod(time, 100.0);
        decimal = mod(second, 1);
        
        % Split the decimal seconds into the number of milli-, micro,
        % nano-, and picoseconds.
        milli = floor(decimal * 1e3);
        micro = floor(mod(decimal*1e6, 1e3));
        nano  = floor(mod(decimal*1e9, 1e3));
        pico  = floor(mod(decimal*1e12, 1e3));
        
        % Convert to character type if requested.
        if strcmp(type, 'char')
            hour   = cellstr(num2str(hour(:),   '%02i'));
            minute = cellstr(num2str(minute(:), '%02i'));
            second = cellstr(num2str(second(:), '%02i'));
            milli  = cellstr(num2str(milli(:),  '%03i'));
            micro  = cellstr(num2str(micro(:),  '%03i'));
            nano   = cellstr(num2str(nano(:),   '%03i'));
            pico   = cellstr(num2str(pico(:),   '%03i'));
        end
    end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Return Scalar \\\\\\\\\\\\\\\\\ %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if n_times == 1
        if iscell(hour)
            hour   = hour{1};
            minute = minute{1};
            second = second{1};
        else
            hour   = hour(1);
            minute = minute(1);
            second = second(1);
        end
        milli  = milli(1);
        micro  = micro(1);
        nano   = nano(1);
        pico   = pico(1);
    end
        
end