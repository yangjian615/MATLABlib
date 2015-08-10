%
% Name
%   MrDateGen
%
% Purpose
%   Generate a series of dates.
%
% Calling Sequence
%   DATES = MrMonthDay2DOY(DATE_START, DATE_END)
%     Generate a series of consecutive DATES starting at DATE_START
%     and ending at DATE_END. DATE_START and DATE_END should be
%     formatted as 'yyyy-mm-dd'.
%
% Parameters
%   DATE_START        in, required, type = char
%   DATE_END          in, required, type = char
%
% Returns
%   DATES             out, required, type = cell
%
% Examples
%   Return the DOY for March 1 in a non-leap year
%     >> dates = MrDateGen('2015-03-18', '2015-08-04');
%     >> whos dates
%       Name         Size            Bytes  Class    Attributes
%       dates        1x140           18480  cell
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-08-07      Written by Matthew Argall
%
function dates = MrDateGen(date_start, date_end)

	% Check inputs (no cell array of strings)
	assert( ischar(date_start) && isrow(date_start), 'DATE_START must be a row of characters.' );
	assert( ischar(date_end)   && isrow(date_end),   'DATE_END must be a row of characters.' );

	% Check that inputs are formatted correctly
	%          year    - month         - day
	regex = '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$';
	assert( ~isempty( regexp( date_start, regex, 'once' ) ), ...
	       'DATE_START must be a date formatted as yyyy-mm-dd.' );
	assert( ~isempty( regexp( date_end, regex, 'once' ) ), ...
	       'DATE_END must be a date formatted as yyyy-mm-dd.' );

	% Convert year to a MATLAB datenum
	%   - Units: Number of days
	startDay = datenum( [str2num(date_start(1:4)), str2num(date_start(6:7)), str2num(date_start(9:10)), 0, 0, 0] );
	endDay   = datenum( [str2num(date_end(1:4)),   str2num(date_end(6:7)),   str2num(date_end(9:10)),   0, 0, 0] );
	
	% Generate a series of date numbers, increasing by day
	datenumbers = startDay:endDay;
	
	% Convert to date
	%   - Convert from NxM character array to 1xN cell array.
	dates = cellstr( datestr(datenumbers, 'yyyy-mm-dd') )';
end
