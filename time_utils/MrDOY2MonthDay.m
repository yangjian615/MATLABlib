%
% Name
%   MrDOY2MonthDay
%
% Purpose
%   Convert a month name to a 2-digit month number.
%
% Calling Sequence
%   [MONTH, DAY] = MrDOY2MonthDay(DOY)
%     Convert the day-of-year to a month and day. A non leap year is
%     assumed.
%
%   [MONTH, DAY] = MrDOY2MonthDay(DOY, YEAR)
%     Provide the YEAR to account for leap days. If YEAR is not double
%     precision, it will be converted to a double.
%
% Parameters
%   DOY               in, required, type = number
%   YEAR              in, optional, type = number, default = 2001
%
% Returns
%   MONTH             out, required, type = double
%   DAY               out, optional, type = double
%
% Examples
%   Return the month and day of DOY 60 in a non-leap year
%     >> [month, day] = MrDOY2monthday(60, 2011)
%       month = 3
%       day   = 1
%
%   Return the month and day of DOY 60 in a leap year
%     >> [month, day] = MrDOY2monthday(60, 2012)
%       month = 2
%       day   = 29
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-06      Written by Matthew Argall
%
function [month, day] = MrDOY2MonthDay(doy, year)

	% Number of DOYs given
	nDOY = length(doy);
		
	% Assume non leap year.
	if nargin < 2
		year = zeros(1, nDOY) + 2001;
	else
		% Year must be converted to double precision or DATENUM will fail
		if ~isa(year, 'double')
			try
				year = double(year);
			catch EM
				error( 'YEAR must be convertible to a double precision number.' )
			end
		end
	end
	
	% Convert year to a MATLAB datenum
	%   - Units: Number of days
	datnum = datenum(year, 1, 1, 0, 0, 0);
	
	% Add the day of year
	%   - Do not count January 1st twice.
	datnum = datnum + doy - 1;
	
	% Convert to month, day
	[~, month, day] = datevec(datnum);
end
