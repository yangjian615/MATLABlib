%
% Name
%   MrMonthDay2DOY
%
% Purpose
%   Convert a month and day to a day-of-year.
%
% Calling Sequence
%   DOY = MrMonthDay2DOY(MONTH, DAY)
%     Convert the month and day to day of year DOY
%
%   DOY = MrMonthDay2DOY(MONTH, DAY, YEAR)
%     Provide the YEAR to account for leap days.
%
% Parameters
%   MONTH             in, required, type = double
%   DAY               in, optional, type = double
%   YEAR              in, optional, type = number, default = 2001
%
% Returns
%   DOY               out, required, type = number
%
% Examples
%   Return the DOY for March 1 in a non-leap year
%     >> doy = MrMonthDay2DOY(3, 1, 2011)
%       doy = 60
%
%   Return the DOY for February 29 in a non-leap year
%     >> doy = MrMonthDay2DOY(2, 29, 2012)
%       doy = 60
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-06      Written by Matthew Argall
%
function doy = MrMonthDay2DOY(month, day, year)

	% Number of DOYs given
	nMoDay = length(month);

	% Assume non leap year.
	if nargin < 2
		year = zeros(1, nMoDay) + 2001;
	end
	
	% Convert year to a MATLAB datenum
	%   - Units: Number of days
	thisDay     = datenum(year, month, day, 0, 0, 0);
	thisNewYear = datenum(year,     1,   1, 0, 0, 0);
	
	% Add the day of year
	%   - Do not erase January 1st!
	doy = thisDay - thisNewYear + 1;
end
