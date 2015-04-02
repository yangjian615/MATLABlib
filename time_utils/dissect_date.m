function [year, month, day] = dissect_date(date, type)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check Inputs \\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % if no type was specified, return the same as 'date'
    if nargin == 1
        type = 'cell';
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Allocate Memory \\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Allocate memory to the year, month, and date array
    if iscell(date)
        n_dates = length(date);
    else
        n_dates = 1;
    end
    
    % Make a cell array of we are dealing with characters. Otherwise,
    % create an array.
    if strcmp(type, 'cell') || ischar(date)
        year = cell(n_dates, 1);
    else
        year = zeros(n_dates, 1);
    end
    month = year;
    day = year;

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Break Down a Numeric Date \\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isnumeric(date)
        year  = floor(date / 10000);
        month = floor(mod(date, 10000) / 100);
        day   = floor(mod(date, 100));
        
        % Convert to character
        if strcmp(type, 'char')
            year  = cellstr(num2str(year(:),  '%04i'));
            month = cellstr(num2str(month(:), '%02i'));
            day   = cellstr(num2str(day(:),   '%02i'));
            
        % Convert to a different numeric type.
        elseif ~strcmp(class(date), type)
           year  = typecast(year, type);
           month = typecast(month, type);
           day   = typecast(day, type);
        end
        
        return
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Break Down a Character Date \\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    regexp_str = '([0-9]{4})[^0-9]?([0-9]{2})[^0-9]?([0-9]{2})';
    subexp = regexp(date, regexp_str, 'tokens');
    subexp = vertcat(subexp{:});
    if n_dates > 1
        subexp = vertcat(subexp{:});
    end

    % Keep the character type
    if strcmp(type, 'cell')
        year  = {subexp{:,1}};
        month = {subexp{:,2}};
        day   = {subexp{:,3}};
        
    %Convert to the specified numeric type
    else
        year  = str2num([type '(' subexp{:,1} ')']);
        month = str2num([type '(' subexp{:,2} ')']);
        day   = str2num([type '(' subexp{:,3} ')']);
    end
    
    if n_dates == 1
        year  = year{1};
        month = month{1};
        day   = day{1};
    end
end