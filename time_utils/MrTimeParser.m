%
% Name
%   MrTimeParser
%
% Purpose
%   Return a character array of known tokens.
%
%   LIST OF TOKENS::
%       %Y      -   Four-digit year: 2012, 2013, etc.
%       %y      -   Two-digit year: 60-59
%       %M      -   Two-digit month: 01-12
%       %C      -   Calendar month: January, Feburary, etc.
%       %c      -   Abbreviated calendar month: Jan, Feb, etc.
%       %d      -   Day of month: 01-31
%       %D      -   Day of year: 000-366
%       %W      -   Week day: Monday, Tuesday, etc.
%       %w      -   Abbreviated week day: Mon, Tue, etc.
%       %H      -   Hour on a 24-hour clock: 00-24
%       %h      -   Hour on a 12-hour clock: 01-12
%       %m      -   Minute: 00-59
%       %S      -   Seconds: 00-60
%       %f      -   Fraction of a second. Decimal point followed by any number of digits.
%       %z      -   Time Zone, abbreviated name (e.g. EST, CST)
%       %o      -   Offset from UTC: (+|-)hh[:mm] (e.g. +00, +00:00, -01:30)
%       %1      -   Milli-seconds: 000-999
%       %2      -   Micro-seconds: 000-999
%       %3      -   Nano-seconds: 000-999
%       %4      -   Pico-seconds: 000-999
%       %A      -   A.M. or P.M. on a 12-hour clock
%       %?      -   A single, unknown character
%       \%      -   The "%" character
%       %(      -   Text is copied verbatim from "%(" until "%)"
%       %)      -   Text is copied verbatim from "%(" until "%)"
%
% Calling Sequence
%   RESULT = MrTimeParser(TIME, PATTERNIN)
%     Return the RESULT of dissecting a date-time string TIME into its
%     elements, where each element is represented by a token in the
%     MrTokens pattern PATTERNIN.
%
%   RESULT = MrTimeParser(TIME, PATTERNIN, PATTERNOUT)
%     Convert TIME, as represented by PATTERNIN, into a time represented by
%     PATTERNOUT.
%
% Parameters
%   TIME              in, required, type=char or cell
%   PATTERNIN         in, required, type=char
%   PATTERNOUT        in, optional, type=char
%
% Returns
%   RESULT            out, required, type=structure or (char or cell)
%
% Examples
%   Convert year-month-day to year-(day of year):
%     >> timeOut = MrTimeParser('2012-03-01', '%Y-%M-%d', '%Y-%D')
%       timeOut = '2012-061'
%
% Helper Functions
%   MrTimeParser_doy2monthday
%   MrTimeParser_monthday2doy
%   MrTimeParser_Breakdown
%   MrTimeParser_Compute
%   MrTimeParser_year2yr
%   MrTimeParser_yr2year
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-06      Written by Matthew Argall
%
function [result] = MrTimeParser(time, patternIn, patternOut)

	% Breakdown the time
	result = MrTimeParser_Breakdown(time, patternIn);
	
	% Compute the time in a new format
	if nargin > 2
		result = MrTimeParser_Compute(result, patternOut);
	end
end



%
% Name
%   MrTimeParser_Breakdown
%
% Purpose
%   Breakdown a time string into its components.
%
% Calling Sequence
%   TIME_PARTS = MrTimeParser_Breakdown(TIME, PATTERN)
%     Take a date-time string TIME, and its MrToken representation,
%     PATTERN, and break it down into its pieces. Return a structure of
%     time elements TIME_PARTS.
%
% Parameters
%   TIME              in, required, type = cell array of strings
%   PATTERN           in, required, type = char
%
% Returns
%   TIME_PARTS        out, required, type = structure
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-05      Written by Matthew Argall
%
function time_parts = MrTimeParser_Breakdown(time, pattern)

	% Number of times given
	if iscell(time)
		nTimes = length(time);
	else
		assert(isrow(time), 'TIME must be a time string or cell array of time strings.')
		nTimes = 1;
	end

%------------------------------------%
% Get Tokens and Time Parts          %
%------------------------------------%

	% Convert the pattern to a regular expression
	regex = MrTokens_ToRegex(pattern);
	
	% Extract the tokens
	tokens  = MrTokens_Extract(pattern);
	nTokens = length(tokens);
	
	% Apply the regular expression
	parts = regexp(time, regex, 'tokens');
	
	% Must get rid of nested cells
	if nTimes > 1
		parts = vertcat(parts{:});
	end
	parts = vertcat(parts{:});

%------------------------------------%
% Allocate Memory                    %
%------------------------------------%
    year      = cell(1, nTimes);
    yr        = cell(1, nTimes);
    doy       = cell(1, nTimes);
    month     = cell(1, nTimes);
    cmonth    = cell(1, nTimes);
    calmo     = cell(1, nTimes);
    weekday   = cell(1, nTimes);
    wkday     = cell(1, nTimes);
    day       = cell(1, nTimes);
    hour      = cell(1, nTimes);
    hr        = cell(1, nTimes);
    minute    = cell(1, nTimes);
    second    = cell(1, nTimes);
    decimal   = cell(1, nTimes);
    milli     = cell(1, nTimes);
    micro     = cell(1, nTimes);
    nano      = cell(1, nTimes);
    pico      = cell(1, nTimes);
    am_pm     = cell(1, nTimes);
    offset    = cell(1, nTimes);
    time_zone = cell(1, nTimes);

%------------------------------------%
% Match Tokens to Time Parts         %
%------------------------------------%
	% Step through each token
	for ii = 1 : nTokens
		switch tokens{ii}
			case '%Y'
				year      = parts(:, ii)';
			case '%y'
				yr        = parts(:, ii)';
			case '%D'
				doy       = parts(:, ii)';
			case '%M'
				month     = parts(:, ii)';
			case '%C'
				cmonth    = parts(:, ii)';
			case '%c'
				calmo     = parts(:, ii)';
			case '%d'
				day       = parts(:, ii)';
			case '%W'
				weekday   = parts(:, ii)';
			case '%w'
				wkday     = parts(:, ii)';
			case '%H'
				hour      = parts(:, ii)';
			case '%h'
				hr        = parts(:, ii)';
			case '%m'
				minute    = parts(:, ii)';
			case '%S'
				second    = parts(:, ii)';
			case '%f'
				decimal   = parts(:, ii)';
			case '%1'
				milli     = parts(:, ii)';
			case '%2'
				micro     = parts(:, ii)';
			case '%3'
				nano      = parts(:, ii)';
			case '%4'
				pico      = parts(:, ii)';
			case '%A'
				am_pm     = parts(:, ii)';
			case '%o'
				offset    = parts(:, ii)';
			case '%z'
				time_zone = parts(:, ii)';
			otherwise
				error( ['Unrecognized token: "' tokens{ii} '".'] );
		end
	end

%------------------------------------%
% Create a Structure                 %
%------------------------------------%
		time_parts = struct( 'year',      year,    ...
			                   'yr',        yr,      ...
			                   'doy',       doy,     ...
			                   'month',     month,   ...
			                   'cmonth',    cmonth,  ...
			                   'calmo',     calmo,   ...
			                   'weekday',   weekday, ...
			                   'wkday',     wkday,   ...
			                   'day',       day,     ...
			                   'hour',      hour,    ...
			                   'hr',        hr,      ...
			                   'minute',    minute,  ...
			                   'second',    second,  ...
			                   'decimal',   decimal, ...
			                   'milli',     milli,   ...
			                   'micro',     micro,   ...
			                   'nano',      nano,    ...
			                   'pico',      pico,    ...
			                   'am_pm',     am_pm,   ...
			                   'offset',    offset,  ...
			                   'time_zone', time_zone );
end



%
% Name
%   MrTimeParser_Compute
%
% Purpose
%   Build-up a date-time string from component parts and a base pattern.
%
% Calling Sequence
%   TIME_PARTS = MrTimeParser_Compute(TIME, PATTERN)
%     Take a date-time string TIME, and its MrToken representation,
%     PATTERN, and break it down into its pieces. Return a structure of
%     time elements TIME_PARTS.
%
% Parameters
%   TIME_PARTS        out, required, type = structure
%   PATTERN           in, required, type = char
%
% Returns
%   TIME              in, required, type = cell array of strings
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-06      Written by Matthew Argall
%
function time = MrTimeParser_Compute(time_parts, pattern)

	% Extract the tokens from the pattern
	[tokens, istart, iend] = MrTokens_Extract(pattern);
	nTokens                = length(tokens);
	
	curPos = 1;
	time   = cell(1, length(time_parts));

%------------------------------------%
% Replace Tokens with Time           %
%------------------------------------%

	for ii = 1 : nTokens
		switch tokens{ii}
			
		%------------------------------------%
		% 4-Digit Year                       %
		%------------------------------------%
			case '%Y'
				% Extract into a cell array
				year = { time_parts(:).year };
				
				% If the 4-digit year was not available
				%   - Try to create it from the 2-digit year
				if isempty(year{1})
					if isempty(time_parts(1).yr)
						error( 'Cannot form %Y. Need %Y or %y.' );
					end
					
					% Get the 4-digit year
					year = MrTimeParser_yr2year( { time_parts(:).yr } );
				end
				
				subStr = year;
			
		%------------------------------------%
		% 2-Digit Year                       %
		%------------------------------------%
			case '%y'
				% Extract into a cell array
				yr = { time_parts(:).yr };
				
				% If the 4-digit year was not available
				%   - Try to create it from the 2-digit year
				if isempty(yr{1}) && ~isempty(time_parts(1).year)
					if isempty(time_parts(1).year)
						error( 'Cannot form %y. Need %Y or %y.' );
					end
					
					% Get the 2-digit year
					year = MrTimeParser_year2yr( { time_parts(:).year } );
				end
				
				subStr = year;
			
		%------------------------------------%
		% 2-Digit Month                      %
		%------------------------------------%
			case '%M'
				% Extract into a cell array
				month = { time_parts(:).month };
				
				% If the 2-digit month number was not available
				if isempty(month{1})
					% Try to create it from the calendar month name
					if ~isempty(time_parts(1).cmonth)
						month = MrMonthName2Number( { time_parts(:).cmonth } );
						
					% Or the abbreviated calendar month name
					elseif ~isempty(time_parts(1).calmo)
						month = MrMonthName2Number( { time_parts(:).cmonth }, true );
						
					% Or the day of year
					elseif ~isempty(time_parts(1).doy)
						% Try to use year information
						if ~isempty(time_parts(1).year)
							month = MrTimeParser_doy2monthday( { time_parts(:).doy }, { time_parts(:).year } );
						elseif ~isempty(time_parts(1).yr)
							month = MrTimeParser_doy2monthday( { time_parts(:).doy }, { time_parts(:).yr } );
						else
							month = MrTimeParser_doy2monthday( { time_parts(:).doy } );
						end
					else
						error( 'Cannot form %M. Need %M, %C, %c, or %D.' );
					end
				end
				
				subStr = month;
			
		%------------------------------------%
		% Calendar Month Name                %
		%------------------------------------%
			case '%C'
				% Extract into a cell array
				cmonth = { time_parts(:).cmonth };
				
				% If the 2-digit month number was not available
				if isempty(cmonth{1})
					% Try to create it from the 2-digit month number
					if ~isempty(time_parts(1).month)
						cmonth = MrMonthNumber2Name( { time_parts(:).month } );
						
					% Or the abbreviated calendar month name
					elseif ~isempty(time_parts(1).calmo)
						% Convert from abbreviated month name to 2-digit month number
						% then back to a month name (not abbreviated).
						monthnum = MrMonthName2Number( { time_parts(:).cmonth }, true );
						cmonth   = MrMonthNumber2Name( monthnum );
						
					% Or the day of year
					elseif ~isempty(time_parts(1).doy)
						% Try to use year information
						if ~isempty(time_parts(1).year)
							month = MrTimeParser_doy2monthday( { time_parts(:).doy }, { time_parts(:).year } );
						elseif ~isempty(time_parts(1).yr)
							month = MrTimeParser_doy2monthday( { time_parts(:).doy }, { time_parts(:).yr } );
						else
							month = MrTimeParser_doy2monthday( { time_parts(:).doy } );
						end
						
						% Convert from month number to month name
						cmonth = MrMonthNumber2Name( month );
					else
						error( 'Cannot form %C. Need %M, %C, %c, or %D.' );
					end
				end
				
				subStr = cmonth;
			
		%------------------------------------%
		% Abbreviated Calendar Month Name    %
		%------------------------------------%
			case '%c'
				% Extract into a cell array
				calmo = { time_parts(:).calmo };
				
				% If the 2-digit month number was not available
				if isempty(calmo{1})
					% Try to create it from the 2-digit month number
					if ~isempty(time_parts(1).month)
						calmo = MrMonthNumber2Name( { time_parts(:).month } );
						
					% Or the abbreviated calendar month name
					elseif ~isempty(time_parts(1).calmo)
						% Convert from month name to 2-digit month number
						% then back to a month name (abbreviated).
						monthnum = MrMonthName2Number( { time_parts(:).cmonth } );
						calmo    = MrMonthNumber2Name( monthnum, true );
						
					% Or the day of year
					elseif ~isempty(time_parts(1).doy)
						% Try to use year information
						if ~isempty(time_parts(1).year)
							month = MrTimeParser_doy2monthday( { time_parts(:).doy }, { time_parts(:).year } );
						elseif ~isempty(time_parts(1).yr)
							month = MrTimeParser_doy2monthday( { time_parts(:).doy }, { time_parts(:).yr } );
						else
							month = MrTimeParser_doy2monthday( { time_parts(:).doy } );
						end
						
						% Convert from month number to an abbreviated month name
						calmo = MrMonthNumber2Name( month, true );
					else
						error( 'Cannot form %c. Need %M, %C, %c, or %D.' );
					end
				end
				
				subStr = calmo;

		%------------------------------------%
		% Day of Month                       %
		%------------------------------------%
			case '%d'
				% Extract into a cell array
				day = { time_parts(:).day };
				
				% If the 2-digit day-in-month is not available
				%   - Try to get it from the day-of-year
				if isempty(day{1})
					if isempty( time_parts(1).doy )
						error( 'Cannot form %d. Need %d or %D.' );
					end
					
					% Try to use year information
					if ~isempty(time_parts(1).year)
						[~, day] = MrTimeParser_doy2monthday( { time_parts(:).doy }, { time_parts(:).year } );
					elseif ~isempty(time_parts(1).yr)
						[~, day] = MrTimeParser_doy2monthday( { time_parts(:).doy }, { time_parts(:).yr } );
					else
						[~, day] = MrTimeParser_doy2monthday( { time_parts(:).doy } );
					end
				end
				
				subStr = day;

		%------------------------------------%
		% Day of Year                        %
		%------------------------------------%
			case '%D'
				% Extract into a cell array
				doy = { time_parts(:).doy };
				
				% If the day of year is not available
				%   - Try to build it from the month, day, and year
				if isempty(doy{1})
					% Month
					if ~isempty(time_parts(1).month)
						month = { time_parts(:).month };
						
					% Calendar month
					elseif ~isempty(time_parts(1).cmonth)
						cmonth = { time_parts(:).cmonth };
						month  = MrMonthName2Number( cmonth );
						
					% Abbreviated calendar month
					elseif ~isempty(time_parts(1).calmo)
						calmo = { time_parts(:).calmo };
						month = MrMonthName2Number( calmo );
					else
						error( 'Cannot form %D. Need %D or [ (%M | %C | %c) and %d and (%Y | %y) ].' );
					end
					
					% Day
					if ~isempty(time_parts(1).day)
						day = { time_parts(1).day };
					else
						error( 'Cannot form %D. Need %D or [ (%M | %C | %c) and %d and (%Y | %y) ].' );
					end
					
					% Year
					if ~isempty( time_parts(1).year );
						year = { time_parts(1).year };
					elseif ~isempty( time_parts(1).yr )
						yr   = { time_parts(:).yr };
						year = MrTimeParser_yr2year(yr);
					end
						
					% Compute the day of year
					if isempty( year )
						doy = MrTimeParser_monthday2doy(month, day);
					else
						doy = MrTimeParser_monthday2doy(month, day, year);
					end
				end
				
				subStr = doy;

		%------------------------------------%
		% Hour on 24-Hour Clock              %
		%------------------------------------%
			case '%H'
				% Extract into a cell array
				hour = { time_parts(:).hour };
				
				% If the day of year is not available
				%   - Try to create it from a 12-hour clock time
				if isempty(hour{1}) && ~isempty( time_parts(1).hr )
					if isempty(time_parts(1).hr)
						error( 'Cannot form %H. Need %H or %h (with %A)' );
					end
					
					
					hour  = { time_parts(:).hr };
					nHour = length(hour);
					
					% Assume AM -- 1-12 implies 00-11 hours
					if isempty( time_parts(1).am_pm )
						warning('MrTimeParser:Compute', 'AM/PM not given. Assuming AM.')
						am_pm    = cell(1, nHour);
						am_pm(:) = {'AM'};
					else
						am_pm = time_parts(:).am_pm;
					end
						
					% Find AM and PM times
					pm_cell    = cell(1, nHour);
					pm_cell(:) = 'PM';
					tf_pm      = cellfun(@strcmp, am_pm, pm_cell);
					iPM        = find(tf_pm);
					iAM        = find(~tf_pm);
					
					% Convert HOUR to an integer
					hour_int = cellfun(@str2num, strcat( {'int16{'}, hour, {')'} ) );

					% Make 12:00 AM be 00:00 (midnight)
					if ~isempty(iAM)
						tf_noon                  = hour_int(iAM) == 12;
						hour_int( iAM(tf_noon) ) = 0;
					end
					
					% Add 12 hours to PM
					if ~isempty(iPM)
						% Convert to integer, add 12 hours to numbers 1-11 (not 12).
						tf_NotNoon                = hour_int(iPM) ~= 12;
						hour_int(iPM(tf_NotNoon)) = hour_int(iPM(tf_NotNoon)) + int16(12);
					end

					% Convert back to cell array of strings
					hour        = num2cell(hour_int);
					fmt_cell    = cell(1, nHour);
					fmt_cell(:) = {'%02d'};
					hour        = cellfun(num2str, hour, fmt_cell);
				end
					
				subStr = hour;

		%------------------------------------%
		% Hour on 12-Hour Clock              %
		%------------------------------------%
			case '%h'
				% Extract into a cell array
				hr = { time_parts(:).hr };
				
				% If the day of year is not available
				%   - Try to create it from a 24-hour clock time
				if isempty(hr{1})
					if isempty( time_parts(1).hour );
						error( 'Cannot form %h. Need %h (with %A) or %H' );
					end
					
					hr    = { time_parts(:).hour };
					nHour = length(hr);
					
					% Convert to an integer array
					hr_int = cellfun(@str2num, strcat( {'int16('}, hr, {')'} ) );
					
					% Convert 00 to 12 (midnight)
					hr_int( hr_int == 0 ) = 12;
					
					% Convert 13-23 to 1-11
					tf_pm            = (hr_int >= 13) && (hr_int <= 23);
					hr_int( tf_pm )  = hr_int( tf_pm ) - 12;
					
					% Convert back to a cell array of strings
					hr          = num2cell(hr_int);
					fmt_cell    = cell(1, nHour);
					fmt_cell(:) = {'%02d'};
					hr          = cellfun(num2str, hr, fmt_cell);
					
				end
					
				subStr = hr;

		%------------------------------------%
		% Minutes                            %
		%------------------------------------%
			case '%m'
				% Extract into a cell array
				minute = { time_parts(:).minute };
				
				% Minute cannot be built from anything else.
				if isempty(minute{1})
					error( 'Cannot form %m. Need %m.' );
				end
					
				subStr = minute;

		%------------------------------------%
		% Seconds                            %
		%------------------------------------%
			case '%S'
				% Extract into a cell array
				second = { time_parts(:).second };
				
				% Seconds cannot be built from anything else.
				if isempty(second{1})
					error( 'Cannot form %S. Need %S.' );
				end
					
				subStr = second;

		%------------------------------------%
		% Token Not Recognized               %
		%------------------------------------%
			% Token not recognized
			otherwise
				error( ['Token not recognized: "' tokens{ii} '".'] );
		end

	%------------------------------------%
	% Form the Output String             %
	%------------------------------------%
		% Grab all non-token characters from just after the previous token to
		% just before the current token.
		chars = pattern( curPos:istart(ii)-1 );
		
		% Concatenate everything together.
		time = strcat(time, chars, subStr);
		
		% Advance the current position.
		curPos = iend(ii) + 1;
	end
	
	% Return a cell array or char array
	if length(time) == 1
		time = time{1};
	end
end


%
% Name
%   MrTimeParser_year2yr
%
% Purpose
%   Convert a 4-digit year to a 2-digit year.
%
% Calling Sequence
%   YR = MrTimeParser_Compute(YEAR)
%     Convert a 4-digit year YEAR to a 2-digit year YR by extracting the
%     last two digits of YEAR.
%
% Parameters
%   YEAR              in, required, type = cell
%
% Returns
%   YR                out, required, type = cell
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-06      Written by Matthew Argall
%
function yr = MrTimeParser_year2yr(year)

	% Extract the 2-digit year
	yr = regexp(year, '([0-9]{2})$', 'match');
	
	% Un-nest the results
	yr = vertcat(yr{:})';
end


%
% Name
%   MrTimeParser_yr2year
%
% Purpose
%   Convert a 4-digit year to a 2-digit year.
%
% Calling Sequence
%   YR = MrTimeParser_Compute(YEAR)
%     Convert a 2-digit year YEAR to a 4-digit year YR. If YR is in the
%     range of 60-99, the 20th century is assumed (years 1960-1999). If YR
%     is in the range 0-59, the 21st century is assumed (years 2000-2059).
%
% Parameters
%   YR                in, required, type = cell
%
% Returns
%   YEAR              out, required, type = cell
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-06      Written by Matthew Argall
%
function year = MrTimeParser_yr2year(yr)

	% Allocate memory to output
	year = yr;

	% Convert YR to an integer
	int_yr = cellfun(@str2num, strcat( {'int16('}, yr, {')'} ) );
	
	% 20th & 21st century dates
	i20th = find( ge(int_yr, 60) );
	i21st = find( lt(int_yr, 60) );
	
	% Append the century
	year(i20th) = strcat( {'19'}, year(i20th) );
	year(i21st) = strcat( {'20'}, year(i21st) );
end


%
% Name
%   MrTimeParser_Year2Yr
%
% Purpose
%   Convert a 4-digit year to a 2-digit year.
%
% Calling Sequence
%   [MONTH, DAY] = MrTimeParser_doy2monthday(DOY)
%     Convert the day-of-year to a MONTH and DAY. A non leap year is
%     assumed.
%
%   [MONTH, DAY] = MrTimeParser_doy2monthday(DOY, YEAR)
%     Provide the YEAR to account for leap days.
%
% Parameters
%   DOY               in, required, type = cell
%   YEAR              in, optional, type = cell
%
% Returns
%   MONTH             out, required, type = cell
%   DAY               out, optional, type = cell
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-06      Written by Matthew Argall
%
function [month, day] = MrTimeParser_doy2monthday(doy, year)

	% Number of DOYs given
	nDOY = length(doy);

	% Default to non-leap year
	if nargin < 2
		warning('MrTimeParser:doy2monthday', 'No year information provided. Assuming non-leap year.')
		year    = cell(1, nDOY);
		year(:) = {'2001'};
	end
	
	% Were 2-digit years provided?
	if length(year{1}) == 2
		year = MrTimeParser_yr2year(year);
	end
	
	% Convert from cell array of strings to numeric arrays
	%   - MrDOY2MonthDay takes doubles
	doy  = cellfun(@str2num, strcat( {'double('}, doy,  {')'} ) );
	year = cellfun(@str2num, strcat( {'double('}, year, {')'} ) );

	% Convert to month and day
	[month, day] = MrDOY2MonthDay(doy, year);

	% Convert to a cell array of strings
	month       = num2cell( month );
	fmt_cell    = cell(1, nDOY);
	fmt_cell(:) = {'%02d'};
	month       = cellfun(@num2str, month, fmt_cell, 'UniformOutput', false);
	
	% Do the same for DAY.
	if nargout == 2
		day         = num2cell( day );
		fmt_cell    = cell(1, nDOY);
		fmt_cell(:) = {'%02d'};
		day         = cellfun(@num2str, day, fmt_cell, 'UniformOutput', false);
	end
end



%
% Name
%   MrTimeParser_Year2Yr
%
% Purpose
%   Convert a 4-digit year to a 2-digit year.
%
% Calling Sequence
%   [MONTH, DAY] = MrTimeParser_doy2monthday(DOY)
%     Convert the day-of-year to a MONTH and DAY. A non leap year is
%     assumed.
%
%   [MONTH, DAY] = MrTimeParser_doy2monthday(DOY, YEAR)
%     Provide the YEAR to account for leap days.
%
% Parameters
%   DOY               in, required, type = cell
%   YEAR              in, optional, type = cell
%
% Returns
%   MONTH             out, required, type = cell
%   DAY               out, optional, type = cell
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-06      Written by Matthew Argall
%
function doy = MrTimeParser_monthday2doy(month, day, year)

	% Number of months and days given
	nMoDay = length(month);

	% Default to non-leap year
	if nargin < 3
		warning('MrTimeParser:monthday2doy', 'No year information provided. Assuming non-leap year.')
		year    = cell(1, nMoDay);
		year(:) = {'2001'};
	end
	
	% Were 2-digit years provided?
	if length(year{1}) == 2
		year = MrTimeParser_yr2year(year);
	end
	
	% Convert from cell array of strings to numeric arrays
	%   - DATEVEC does not like integers.
	month = cellfun(@str2double, month );
	day   = cellfun(@str2double, day );
	year  = cellfun(@str2double, year );

	% Convert to month and day
	doy = MrMonthDay2DOY(month, day, year);

	% Convert to a cell array of strings
	doy         = num2cell( doy );
	fmt_cell    = cell(1, nMoDay);
	fmt_cell(:) = {'%03d'};
	doy         = cellfun(@num2str, doy, fmt_cell, 'UniformOutput', false);
end