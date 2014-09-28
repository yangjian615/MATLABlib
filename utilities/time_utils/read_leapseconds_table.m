function [leap_seconds, year, month, day, drift] = read_leapseconds_table(year, month, day)
    %
    % Read the contents of the CDF leapseconds table. The leapseconds table is pointed to
    % by the system variable CDF_LEAPSECONDSTABLE.
    %
    % Leap seconds are typically applied as the last second of the day. For example, the
    % last leap second was June 30, 2012 at 23:59:60. In the table, the leap second count
    % is 35 for July 1st, 2012. 
    %

    % Get the path and filename fof the leapseconds table.
    leapseconds_table = getenv('CDF_LEAPSECONDSTABLE');
    
    % Open the file and read its contents.
    fileID = fopen(leapseconds_table, 'r');
    contents = textscan(fileID, '%d%d%d%f%f%f', 'CommentStyle', ';');
    
    % If a date was given, return the total number of leap seconds up to that date.
    if nargin == 3
        mark_year = find(contents{1} == year);
        
        % If a leap second was not added during 'year' then get the cumulative leap
        % leap seconds from the next most recent year.
        if isempty(mark_year)
            mark_year = find(contents{1} < year, 1, 'last');
            leap_seconds = contents{4}(mark_year);
        
        % Otherwise, determine if the leap second was added before or after the given date.
        else
            % See if the leap second was added before the given date.
            mark_date = find(contents{2}(mark_year) <= month & ...
                             contents{3}(mark_year) <= day, 1, 'last');
            
            % If the leap second during year 'year' is after the input date, then return
            % the number of cumulative leap seconds in the previous year.
            if isempty(mark_date)
                leap_seconds = contents{4}(mark_year - 1);
            % Otherwise, return the cumulative leap seconds of this year.
            else
                leap_seconds = contents{4}(mark_year(mark_date));
            end
        end
    
    % If no arguments were given, return the contents of the leapseconds file. 
    elseif nargin == 0
        year = contents{1};
        month = contents{2};
        day = contents{3};
        leap_seconds = contents{4};
        drift = cell2mat(contents(5:6));
    end
    
end