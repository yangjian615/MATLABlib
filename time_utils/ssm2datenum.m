%
% Name:
%    despin
%
% Purpose:
%    Transform data from a spinning coordinate system to a non-spinning
%    frame.
%
% Calling Sequence:
%    T_DATENUM = despin(T_SSM, DATE)
%        Convert time in seconds since midnight T_SSM, measured from
%        midnight on DATE to MatLab's datenum. DATE must be formatted as
%        'yyyy-mm-dd'.
%
% Parameters
%    T_SSM:        in, required, type = double
%    DATE:         in, required, type = char
%
% Returns:
%    T_DATENUM:    out, required, type = double
%
% Releases:
%   7.14.0.739 (R2012a)
%
% Required Products:
%   None
%
% History:
%   2014-12-02      Written by Matthew Argall
%
function t_datenum = ssm2datenum(t_ssm, date)

	% Convert: 
	%   - SSM to the fractional part of a day.
	%   - Date to a date number.
	t_datenum = t_ssm / 86400.0 + datenum(date, 'yyyy-mm-dd');
end